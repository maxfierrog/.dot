local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key
local util = require("luasnip.util.util")
local node_util = require("luasnip.nodes.util")

-- INTERACTIVE SNIPPET UTILITIES

local external_update_id = 0

local function find_dynamic_node(node)
	while not node.dynamicNode do
		node = node.parent
	end
	return node.dynamicNode
end

function dynamic_node_external_update(func_indx)
	local current_node = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
	local dynamic_node = find_dynamic_node(current_node)

	external_update_id = external_update_id + 1
	current_node.external_update_id = external_update_id
	local current_node_key = current_node.key

	local insert_pre_call = vim.fn.mode() == "i"
	local cursor_pos_end_relative = util.pos_sub(
		util.get_cursor_0ind(),
		current_node.mark:get_endpoint(1)
	)

	node_util.leave_nodes_between(dynamic_node.snip, current_node)
	local func = dynamic_node.user_args[func_indx]
	if func then
		func(dynamic_node.parent.snippet)
	end

	dynamic_node.last_args = nil
	dynamic_node:update()

	local target_node = dynamic_node:find_node(function(test_node)
		return (test_node.external_update_id == external_update_id) or
			(current_node_key ~= nil and test_node.key == current_node_key)
	end)

	if target_node then
		node_util.enter_nodes_between(dynamic_node, target_node)
		if insert_pre_call then
			util.set_cursor_0ind(
				util.pos_add(
					target_node.mark:get_endpoint(1),
					cursor_pos_end_relative
				)
			)
		else
			node_util.select_node(target_node)
		end
		ls.session.current_nodes[vim.api.nvim_get_current_buf()] = target_node
	else
		ls.session.current_nodes[vim.api.nvim_get_current_buf()] = dynamic_node.snip:jump_into(1)
	end
end

vim.api.nvim_set_keymap('i', "<C-l>", '<cmd>lua _G.dynamic_node_external_update(1)<Cr>', { noremap = true })
vim.api.nvim_set_keymap('s', "<C-l>", '<cmd>lua _G.dynamic_node_external_update(1)<Cr>', { noremap = true })

vim.api.nvim_set_keymap('i', "<C-h>", '<cmd>lua _G.dynamic_node_external_update(2)<Cr>', { noremap = true })
vim.api.nvim_set_keymap('s', "<C-h>", '<cmd>lua _G.dynamic_node_external_update(2)<Cr>', { noremap = true })

vim.api.nvim_set_keymap('i', "<C-j>", '<cmd>lua _G.dynamic_node_external_update(3)<Cr>', { noremap = true })
vim.api.nvim_set_keymap('s', "<C-j>", '<cmd>lua _G.dynamic_node_external_update(3)<Cr>', { noremap = true })

vim.api.nvim_set_keymap('i', "<C-k>", '<cmd>lua _G.dynamic_node_external_update(4)<Cr>', { noremap = true })
vim.api.nvim_set_keymap('s', "<C-k>", '<cmd>lua _G.dynamic_node_external_update(4)<Cr>', { noremap = true })

-- BEGIN SNIPPETS

ls.add_snippets("markdown", {
	s({ trig = "katex", name = "Katex shortcode" }, {
		t("{{< katex "),
		i(1, "inline"),
		t(" >}} "),
		i(2),
		t(" {{< /katex }}"),
		i(0),
	}),
	s({ trig = "hint", name = "Hint shortcode" }, {
		t("{{< hint "),
		i(1, "info"),
		t({ " >}}", "", "" }),
		i(2),
		t({ "", "", "{{< /hint >}}", "" }),
		i(0),
	})
})

ls.add_snippets("tex", {
	s({
		trig = "mat",
		name = "variadic matrix",
	}, {
		t("\\begin{"), i(1), t({ "}", "" }),
		d(2, function(_, snip)
			if not snip.rows then
				snip.rows = 1
			end

			if not snip.cols then
				snip.cols = 1
			end

			local nodes = {}
			local nindex = 1

			for row = 1, snip.rows do
				table.insert(nodes, t(" "))
				table.insert(nodes, r(nindex, tostring(row) .. "-1", i(1)))
				nindex = nindex + 1

				for col = 2, snip.cols do
					table.insert(nodes, t(" & "))
					table.insert(nodes, r(nindex, tostring(row) .. "-" .. tostring(col), i(1)))
					nindex = nindex + 1
				end
				table.insert(nodes, t({ " \\\\", "" }))
			end

			table.remove(nodes)
			return sn(nil, nodes)
		end, {}, {
			user_args = {
				function(snip) snip.cols = snip.cols + 1 end,
				function(snip) snip.cols = math.max(snip.cols - 1, 1) end,

				function(snip) snip.rows = snip.rows + 1 end,
				function(snip) snip.rows = math.max(snip.rows - 1, 1) end,
			}
		}),
		t({ "", "\\end{" }),
		f(function(args) return args[1][1] end, { 1 }, {}),
		t({ "}", "" }),
		i(0),
	}),
	s({
		trig = "//",
		name = "fraction",
		trigEngine = "vim",
		wordTrig = false,
	}, {
		t("\\frac{ "), i(1), t(" }{ "), i(2), t(" }"), i(0)
	}),
	s({
		trig = "sp",
		name = "superscript",
		wordTrig = false,
	}, {
		t("^{ "), i(1), t(" }"), i(0)
	}),
	s({
		trig = "sb",
		name = "subscript",
		wordTrig = false,
	}, {
		t("_{ "), i(1), t(" }"), i(0)
	}),
	s({
		trig = "ig",
		name = "integral",
		wordTrig = false,
	}, {
		t("\\int"), i(0)
	}),
	s({
		trig = "par",
		name = "parentheses",
		wordTrig = false,
	}, {
		t("\\left( "), i(1), t(" \\right)"), i(0)
	}),
	s({
		trig = "br",
		name = "brackets",
		wordTrig = false,
	}, {
		t("\\left[ "), i(1), t(" \\right]"), i(0)
	}),
	s({
		trig = "beg",
		name = "environment",
		wordTrig = false,
	}, {
		t("\\begin{"), i(1), t({ "}", "" }),
		i(2),
		t({ "", "\\end{" }), f(function(args) return args[1][1] end, { 1 }, {}), t({ "}", "" }),
		i(0)
	}),
	s({
		trig = "im",
		name = "inline math",
		wordTrig = false,
	}, {
		t("$ "), i(1), t(" $"), i(0)
	}),
	s({
		trig = "dm",
		name = "display math",
		wordTrig = false,
	}, {
		t({ "\\[", "", "" }), i(1), t({ "", "", "\\]", "" }), i(0)
	}),
	s({
		trig = "vec",
		name = "vector",
		wordTrig = false,
	}, {
		t("\\vec{"), i(1), t("}"), i(0)
	}),
	s({
		trig = "!>",
		name = "maps to",
		wordTrig = false,
	}, {
		t("\\mapsto"), i(0)
	}),
	s({
		trig = "->",
		name = "to",
		wordTrig = false,
	}, {
		t("\\to"), i(0)
	}),
	s({
		trig = "pi",
		name = "constant pi",
		wordTrig = false,
	}, {
		t("\\pi"), i(0)
	}),
	s({
		trig = "RR",
		name = "set of real numbers",
		wordTrig = false,
	}, {
		t("\\mathbb{R}"), i(0)
	}),
	s({
		trig = "ZZ",
		name = "set of integers",
		wordTrig = false,
	}, {
		t("\\mathbb{Z}"), i(0)
	}),
	s({
		trig = "SSS",
		name = "strict subset",
		wordTrig = false,
	}, {
		t("\\subset"), i(0)
	}),
	s({
		trig = "SS",
		name = "subset",
		wordTrig = false,
	}, {
		t("\\subseteq"), i(0)
	}),
	s({
		trig = "pa",
		name = "partial derivative",
		wordTrig = false,
	}, {
		t("\\partial"), i(0)
	}),
	s({
		trig = "dots",
		name = "dots",
		wordTrig = false,
	}, {
		t("\\dots"), i(0)
	}),
	s({
		trig = "ss",
		name = "set",
		wordTrig = false,
	}, {
		t("\\{ "), i(1), t(" \\}"), i(0)
	}),
	s({
		trig = "ex",
		name = "exponential",
		wordTrig = false,
	}, {
		t("\\exp"), i(0)
	}),
	s({
		trig = "ww",
		name = "inline text",
		wordTrig = false,
	}, {
		t("\\text{"), i(1), t("}"), i(0)
	}),
	s({
		trig = "tt",
		name = "transpose",
		wordTrig = false,
	}, {
		t("^\\top"), i(0)
	}),
	s({
		trig = "cp",
		name = "cross product",
		wordTrig = false,
	}, {
		t("\\times"), i(0)
	}),
	s({
		trig = ">=",
		name = "greater than or equal",
		wordTrig = false,
	}, {
		t("\\geq"), i(0)
	}),
	s({
		trig = "<=",
		name = "less than or equal",
		wordTrig = false,
	}, {
		t("\\leq"), i(0)
	}),
	s({
		trig = "ip",
		name = "inner product",
		wordTrig = false,
	}, {
		t("\\langle "), i(1), t(", "), i(2), t(" \\rangle"), i(0)
	}),
	s({
		trig = "nr",
		name = "norm",
		wordTrig = false,
	}, {
		t("\\| "), i(1), t(" \\|"), i(0)
	}),
	s({
		trig = "su",
		name = "sum",
		wordTrig = false,
	}, {
		t("\\sum"), i(0)
	}),
	s({
		trig = "sr",
		name = "squre root",
		wordTrig = false,
	}, {
		t("\\sqrt{ "), i(1), t(" }"), i(0)
	}),
	s({
		trig = "sq",
		name = "square",
		wordTrig = false,
	}, {
		t("^2"), i(0)
	}),
	s({
		trig = "cb",
		name = "cube",
		wordTrig = false,
	}, {
		t("^3"), i(0)
	}),
	s({
		trig = "lambda",
		name = "lambda",
		wordTrig = false,
	}, {
		t("{\\lambda}"), i(0)
	}),
	s({
		trig = "sigma",
		name = "lambda",
		wordTrig = false,
	}, {
		t("{\\sigma}"), i(0)
	}),
	s({
		trig = "sin",
		name = "sine function",
		wordTrig = false,
	}, {
		t("\\sin \\left( "), i(1), t(" \\right)"), i(0)
	}),
	s({
		trig = "cos",
		name = "cosine function",
		wordTrig = false,
	}, {
		t("\\cos \\left( "), i(1), t(" \\right)"), i(0)
	}),
	s({
		trig = "tan",
		name = "tangent function",
		wordTrig = false,
	}, {
		t("\\tan \\left( "), i(1), t(" \\right)"), i(0)
	}),
	s({
		trig = "alpha",
		name = "alpha",
		wordTrig = false,
	}, {
		t("{\\alpha}"), i(0)
	}),
	s({
		trig = "beta",
		name = "beta",
		wordTrig = false,
	}, {
		t("{\\beta}"), i(0)
	}),
	s({
		trig = "ln",
		name = "natural logarithm",
		wordTrig = false,
	}, {
		t("\\ln \\left( "), i(1), t(" \\right)"), i(0)
	}),
	s({
		trig = "nabla",
		name = "nabla",
		wordTrig = false,
	}, {
		t("{\\nabla}"), i(0)
	}),
	s({
		trig = "mu",
		name = "mu",
		wordTrig = false,
	}, {
		t("{\\mu}"), i(0)
	}),
	s({
		trig = "theta",
		name = "theta",
		wordTrig = false,
	}, {
		t("{\\theta}"), i(0)
	}),
	s({
		trig = "dot",
		name = "dot product",
		wordTrig = false,
	}, {
		t("{\\cdot}"), i(0)
	}),
	s({
		trig = "union",
		name = "set union",
		wordTrig = false,
	}, {
		t("\\cap"), i(0)
	}),
	s({
		trig = "inter",
		name = "set intersection",
		wordTrig = false,
	}, {
		t("\\cup"), i(0)
	}),
	s({
		trig = "inf",
		name = "infinity",
		wordTrig = false,
	}, {
		t("\\infty"), i(0)
	}),
	s({
		trig = "epn",
		name = "expectation",
		wordTrig = false,
	}, {
		t("\\mathbb{E} \\left[ "), i(1), t(" \\right]"), i(0)
	}),
	s({
		trig = "prob",
		name = "probability",
		wordTrig = false,
	}, {
		t("\\mathbb{P} \\left[ "), i(1), t(" \\right]"), i(0)
	}),
	s({
		trig = "sim",
		name = "similar distribution",
		wordTrig = false,
	}, {
		t("{\\sim}"), i(0)
	}),
	s({
		trig = "fa",
		name = "absolute quantifier",
		wordTrig = false,
	}, {
		t("\\forall"), i(0)
	}),
	s({
		trig = "exx",
		name = "existential quantifier",
		wordTrig = false,
	}, {
		t("\\exists"), i(0)
	}),
	s({
		trig = "epsilon",
		name = "epsilon",
		wordTrig = false,
	}, {
		t("{\\epsion}"), i(0)
	}),
	s({
		trig = "lim",
		name = "limit",
		wordTrig = false,
	}, {
		t("\\lim_{ "), i(1), t(" }"), i(0)
	}),
	s({
		trig = "abs",
		name = "absolute value",
		wordTrig = false,
	}, {
		t("| "), i(1), t(" |"), i(0)
	}),
	s({
		trig = "approx",
		name = "approximation",
		wordTrig = false,
	}, {
		t("{\\approx}"), i(0)
	}),
	s({
		trig = "cal",
		name = "caligraphy",
		wordTrig = false,
	}, {
		t("\\mathcal{"), i(1), t("}"), i(0)
	}),
	s({
		trig = "cov",
		name = "covariance",
		wordTrig = false,
	}, {
		t("\\text{Cov} \\left( "), i(1), t(", "), i(2), t(" \\right)"), i(0)
	}),
	s({
		trig = "var",
		name = "variance",
		wordTrig = false,
	}, {
		t("\\text{Var} \\left( "), i(1), t(" \\right)"), i(0)
	}),
	s({
		trig = "phi",
		name = "phi",
		wordTrig = false,
	}, {
		t("{\\phi}"), i(0)
	}),
	s({
		trig = "imp",
		name = "implication",
		wordTrig = false,
	}, {
		t("\\implies"), i(0)
	})
})

ls.setup({
	link_children = true,
	keep_roots = true,
	exit_roots = true,
	link_roots = false,
})
