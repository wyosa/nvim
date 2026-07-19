return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	event = "VimEnter",
	dependencies = { "mason-org/mason.nvim" },
	opts = {
		ensure_installed = {
			"actionlint",
			"gofumpt",
			"goimports",
			"golines",
			"hadolint",
			"markdownlint-cli2",
			"prettierd",
			"shellcheck",
			"shfmt",
			"sqlfluff",
			"stylua",
			"yamllint",
		},
		run_on_start = vim.env.NVIM_CONFIG_TEST ~= "smoke",
		start_delay = 3000,
		debounce_hours = 12,
		integrations = {
			["mason-lspconfig"] = false,
			["mason-null-ls"] = false,
			["mason-nvim-dap"] = false,
		},
	},
}
