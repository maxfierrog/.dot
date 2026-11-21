//! Background Zellij plugin with two keybind helpers, driven by `MessagePlugin`:
//!
//! - payload "up" / "down": move focus to the neighbouring pane in the current
//!   tab, or, if there is no pane in that direction, switch to the
//!   previous/next tab. Mirrors what `MoveFocusOrTab` does for left/right.
//!
//! - payload "float": like `ToggleFloatingPanes`, but when the tab has no
//!   floating pane yet, open one at 90% of the pane area, centred.
//!
//! - Whenever the number of floating terminal panes in a tab changes to one or
//!   two, arrange them: one pane centred at 90%, two panes side by side.
//!
//! Zellij 0.46 positions percentage-based floating panes (including
//! `swap_floating_layout`) from column 0 rather than from the start of the
//! pane area, so with a sidebar on the left they land off-centre. This plugin
//! computes absolute coordinates instead.
//!
//! Example keybind:
//!   bind "Alt j" { MessagePlugin "file:~/.config/zellij/plugins/pane-helper.wasm" { payload "down"; } }

use std::collections::{BTreeMap, HashMap};
use std::path::PathBuf;
use zellij_tile::prelude::*;

/// Fraction of the pane area a new floating pane covers in each dimension.
const FLOAT_SCALE: f64 = 0.9;

/// A rectangle as fractions of the pane area: (x, y, width, height).
type Frac = (f64, f64, f64, f64);

/// Arrangement of a lone floating pane, and of a pair (left, right).
const ONE: [Frac; 1] = [((1.0 - FLOAT_SCALE) / 2.0, (1.0 - FLOAT_SCALE) / 2.0, FLOAT_SCALE, FLOAT_SCALE)];
const TWO: [Frac; 2] = [(0.04, 0.05, 0.45, 0.9), (0.51, 0.05, 0.45, 0.9)];

#[derive(Default)]
struct State {
    tabs: Vec<TabInfo>,
    panes: PaneManifest,
    /// Floating terminal pane count per tab id, as last seen.
    float_counts: HashMap<usize, usize>,
}

register_plugin!(State);

impl ZellijPlugin for State {
    fn load(&mut self, _config: BTreeMap<String, String>) {
        request_permission(&[
            PermissionType::ReadApplicationState,
            PermissionType::ChangeApplicationState,
            PermissionType::OpenTerminalsOrPlugins,
        ]);
        subscribe(&[EventType::TabUpdate, EventType::PaneUpdate]);
    }

    fn update(&mut self, event: Event) -> bool {
        match event {
            Event::TabUpdate(tabs) => self.tabs = tabs,
            Event::PaneUpdate(panes) => self.panes = panes,
            _ => return false,
        }
        self.arrange_floating();
        false
    }

    fn pipe(&mut self, msg: PipeMessage) -> bool {
        match msg.payload.as_deref() {
            Some("up") => self.navigate(Direction::Up),
            Some("down") => self.navigate(Direction::Down),
            Some("float") => self.toggle_float(),
            _ => {}
        }
        false
    }

    fn render(&mut self, _rows: usize, _cols: usize) {}
}

fn is_tiled(p: &&PaneInfo) -> bool {
    !p.is_floating && !p.is_suppressed && p.is_selectable
}

/// Floating terminal panes; floating plugins (e.g. the tab finder) are left alone.
fn is_floating_terminal(p: &&PaneInfo) -> bool {
    p.is_floating && !p.is_plugin && !p.is_suppressed && p.is_selectable
}

/// Absolute coordinates for a fractional rectangle of the tab's pane area,
/// which starts after any sidebar on the left/top edge.
fn place(tab: &TabInfo, (fx, fy, fw, fh): Frac) -> Option<FloatingPaneCoordinates> {
    let (cols, rows) = (tab.viewport_columns as f64, tab.viewport_rows as f64);
    let x0 = tab.display_area_columns.saturating_sub(tab.viewport_columns);
    let y0 = tab.display_area_rows.saturating_sub(tab.viewport_rows);
    let width = (cols * fw).round() as usize;
    let height = (rows * fh).round() as usize;
    // Centre on what is left over, so rounding never skews a centred pane.
    let x = x0 + if fx * 2.0 + fw == 1.0 {
        (tab.viewport_columns.saturating_sub(width)) / 2
    } else {
        (cols * fx).round() as usize
    };
    let y = y0 + if fy * 2.0 + fh == 1.0 {
        (tab.viewport_rows.saturating_sub(height)) / 2
    } else {
        (rows * fy).round() as usize
    };
    FloatingPaneCoordinates::new(
        Some(x.to_string()),
        Some(y.to_string()),
        Some(width.to_string()),
        Some(height.to_string()),
        None,
        None,
    )
}

impl State {
    fn active_tab(&self) -> Option<&TabInfo> {
        self.tabs.iter().find(|t| t.active)
    }

    fn focused_tiled_pane(&self, tab: &TabInfo) -> Option<&PaneInfo> {
        self.panes
            .panes
            .get(&tab.position)?
            .iter()
            .filter(is_tiled)
            .find(|p| p.is_focused)
    }

    fn navigate(&self, direction: Direction) {
        match self.has_neighbour(direction) {
            Some(false) => match direction {
                Direction::Up => go_to_previous_tab(),
                _ => go_to_next_tab(),
            },
            // A pane is there, or we lack the state to tell: plain movement.
            _ => move_focus(direction),
        }
    }

    /// Whether the focused tiled pane has a selectable pane above/below it.
    /// `None` when the layout state needed to decide is unavailable.
    fn has_neighbour(&self, direction: Direction) -> Option<bool> {
        let tab = self.active_tab()?;
        if tab.are_floating_panes_visible {
            return None;
        }
        if tab.is_fullscreen_active {
            return Some(false);
        }
        let focused = self.focused_tiled_pane(tab)?;
        let (top, bottom) = (focused.pane_y, focused.pane_y + focused.pane_rows);
        let (left, right) = (focused.pane_x, focused.pane_x + focused.pane_columns);

        let panes = self.panes.panes.get(&tab.position)?;
        Some(panes.iter().filter(is_tiled).any(|p| {
            let distinct = p.id != focused.id || p.is_plugin != focused.is_plugin;
            let overlaps = p.pane_x < right && left < p.pane_x + p.pane_columns;
            let beyond = match direction {
                Direction::Up => p.pane_y + p.pane_rows <= top,
                _ => p.pane_y >= bottom,
            };
            distinct && overlaps && beyond
        }))
    }

    fn floating_terminals(&self, tab: &TabInfo) -> Vec<&PaneInfo> {
        let mut panes: Vec<&PaneInfo> = self
            .panes
            .panes
            .get(&tab.position)
            .map(|ps| ps.iter().filter(is_floating_terminal).collect())
            .unwrap_or_default();
        panes.sort_by_key(|p| p.id); // creation order
        panes
    }

    fn toggle_float(&self) {
        let Some(tab) = self.active_tab() else {
            return toggle_floating_panes(None);
        };
        if tab.selectable_floating_panes_count > 0 {
            return toggle_floating_panes(None);
        }
        let cwd = self
            .focused_tiled_pane(tab)
            .filter(|p| !p.is_plugin)
            .and_then(|p| get_pane_cwd(PaneId::Terminal(p.id)).ok())
            .unwrap_or_else(|| PathBuf::from("."));
        open_terminal_floating(cwd, place(tab, ONE[0]));
    }

    /// Re-arrange a tab's floating terminals when their count changes to 1 or 2,
    /// the way a `swap_floating_layout` would. A tab seen for the first time
    /// only records its count, so existing arrangements are left untouched.
    fn arrange_floating(&mut self) {
        let mut moves = Vec::new();
        let mut counts = HashMap::new();
        for tab in &self.tabs {
            let panes = self.floating_terminals(tab);
            let count = panes.len();
            counts.insert(tab.tab_id, count);
            let previous = self.float_counts.get(&tab.tab_id).copied();
            if previous.map_or(true, |prev| prev == count) {
                continue;
            }
            let fracs: &[Frac] = match count {
                1 => &ONE,
                2 => &TWO,
                _ => continue,
            };
            for (pane, frac) in panes.iter().zip(fracs) {
                if let Some(coordinates) = place(tab, *frac) {
                    moves.push((PaneId::Terminal(pane.id), coordinates));
                }
            }
        }
        // Only trust counts once both tab and pane state have arrived.
        if !self.tabs.is_empty() && !self.panes.panes.is_empty() {
            self.float_counts = counts;
        }
        if !moves.is_empty() {
            change_floating_panes_coordinates(moves);
        }
    }
}
