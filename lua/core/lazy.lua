-- lazy.nvim plugin manager and Onedarker theme. Plugin revisions live in lazy-lock.json.

local smoke_test = vim.env.NVIM_CONFIG_TEST == "smoke"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_commit = "306a05526ada86a7b30af95c5cc81ffba93fef97"

-- Tests collect plugin errors without installing missing dependencies.
if smoke_test then
	_G.NVIM_CONFIG_SMOKE_ERRORS = {}
	local original_notify = vim.notify
	vim.notify = function(message, level, opts)
		if level == vim.log.levels.ERROR then
			table.insert(_G.NVIM_CONFIG_SMOKE_ERRORS, tostring(message))
		end
		return original_notify(message, level, opts)
	end
end

-- Bootstrap lazy.nvim at a pinned commit.
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local clone_output = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Failed to clone lazy.nvim:\n" .. clone_output)
	end

	local checkout_output = vim.fn.system({ "git", "-C", lazypath, "checkout", lazy_commit })
	if vim.v.shell_error ~= 0 then
		error("Failed to pin lazy.nvim:\n" .. checkout_output)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	local_spec = false,
	install = { missing = not smoke_test },
	spec = {
		{
			"alphatechnolog/onedarker.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				vim.g.onedarker_transparent_background = true
				vim.g.onedarker_italic_comments = false

				local function apply_highlights()
					local c = require("onedarker.palette")
					-- Map legacy theme colors to current Tree-sitter and plugin highlight groups.
					local links = {
						["@variable"] = "TSVariable",
						["@variable.builtin"] = "TSVariableBuiltin",
						["@variable.parameter"] = "TSParameter",
						["@variable.member"] = "TSField",
						["@constant"] = "TSConstant",
						["@constant.builtin"] = "TSConstBuiltin",
						["@constant.macro"] = "TSConstMacro",
						["@module"] = "TSNamespace",
						["@label"] = "TSLabel",
						["@string"] = "TSString",
						["@string.regexp"] = "TSStringRegex",
						["@string.escape"] = "TSStringEscape",
						["@character"] = "TSCharacter",
						["@boolean"] = "TSBoolean",
						["@number"] = "TSNumber",
						["@number.float"] = "TSFloat",
						["@type"] = "TSType",
						["@type.builtin"] = "TSTypeBuiltin",
						["@attribute"] = "TSAttribute",
						["@property"] = "TSProperty",
						["@function"] = "TSFunction",
						["@function.builtin"] = "TSFuncBuiltin",
						["@function.macro"] = "TSFuncMacro",
						["@function.method"] = "TSMethod",
						["@constructor"] = "TSConstructor",
						["@operator"] = "TSOperator",
						["@keyword"] = "TSKeyword",
						["@keyword.import"] = "TSInclude",
						["@keyword.return"] = "TSKeywordReturn",
						["@keyword.function"] = "TSKeywordFunction",
						["@punctuation.delimiter"] = "TSPunctDelimiter",
						["@punctuation.bracket"] = "TSPunctBracket",
						["@punctuation.special"] = "TSPunctSpecial",
						["@comment"] = "TSComment",
						["@markup.heading"] = "TSTitle",
						["@markup.strong"] = "TSStrong",
						["@markup.italic"] = "TSEmphasis",
						["@markup.link.url"] = "TSURI",
						["@markup.raw"] = "TSLiteral",
						["@tag"] = "TSTag",
						["@tag.attribute"] = "TSTagAttribute",
						["@tag.delimiter"] = "TSTagDelimiter",
						IblIndent = "IndentBlanklineChar",
						NeoTreeNormal = "NvimTreeNormal",
						NeoTreeNormalNC = "NvimTreeNormal",
						NeoTreeDirectoryName = "NvimTreeFolderName",
						NeoTreeDirectoryIcon = "NvimTreeFolderIcon",
						BlinkCmpLabelMatch = "CmpItemAbbrMatch",
					}
					for group, target in pairs(links) do
						vim.api.nvim_set_hl(0, group, { link = target })
					end
					for severity, color in pairs({
						Error = c.error_red,
						Warn = c.warning_orange,
						Info = c.info_yellow,
						Hint = c.hint_blue,
						Ok = c.green,
					}) do
						vim.api.nvim_set_hl(0, "Diagnostic" .. severity, { fg = color })
						vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. severity, { fg = color })
					end
					-- Reuse the same palette in the embedded terminal.
					local ansi = {
						c.bg,
						c.red,
						c.green,
						c.yellow,
						c.blue,
						c.purple,
						c.cyan,
						c.fg,
						c.gray,
						c.red,
						c.green,
						c.yellow,
						c.blue,
						c.purple,
						c.cyan,
						c.accent,
					}
					for index, color in ipairs(ansi) do
						vim.g["terminal_color_" .. (index - 1)] = color
					end
				end

				vim.api.nvim_create_autocmd("ColorScheme", {
					group = vim.api.nvim_create_augroup("onedarker-highlights", { clear = true }),
					pattern = "onedarker",
					callback = apply_highlights,
				})
				vim.cmd.colorscheme("onedarker")
			end,
		},

		{ import = "plugins" },
	},
})
