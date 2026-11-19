# Zellij tab plugins

- `zellij-vertical-tabs.wasm`: [cfal/zellij-vertical-tabs](https://github.com/cfal/zellij-vertical-tabs), v0.1.0
- `room.wasm`: [rvcas/room](https://github.com/rvcas/room), v1.2.1

The binaries are pinned in this dotfiles repository so a new machine does not
depend on a network fetch each time Zellij starts.

## Tab controls

- `Alt-/`: fuzzy-find a tab; type to filter, use arrows or `Tab`, then `Enter`
- `Alt-j/k`: switch to the next/previous tab
- `Alt-Shift-k/j` or `Alt-Shift-Up/Down`: move the active tab up/down
- `Ctrl-t`, then `f`: fuzzy-find from tab mode
- `Ctrl-t`, then `H/L`: repeatedly reorder from tab mode
- Click a sidebar row to switch tabs; scroll over it to move between tabs

On the first launch, approve the plugins' requested Zellij permissions. Both
need to read the tab list and switch the active tab.

## Checksums

```text
531091b56ab3bc0008bd14de19f71985e3ab8585110ee021ef8ee413556202a2  zellij-vertical-tabs.wasm
90b483a40b762468fb75862160587a05fbedcd5c13adcb3ed231f01bf9c072d1  room.wasm
```
