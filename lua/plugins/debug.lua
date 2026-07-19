return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"mason-org/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"leoluz/nvim-dap-go",
		"theHamsta/nvim-dap-virtual-text",
	},
	keys = {
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Debug: Continue/Start",
		},
		{
			"<F10>",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: Step Over",
		},
		{
			"<F11>",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: Step Into",
		},
		{
			"<F12>",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: Step Out",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Debug: Toggle Breakpoint",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Debug: Conditional Breakpoint",
		},
		{
			"<leader>dl",
			function()
				require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end,
			desc = "Debug: Logpoint",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "Debug: Toggle REPL",
		},
		{
			"<leader>du",
			function()
				require("dapui").toggle()
			end,
			desc = "Debug: Toggle UI",
		},
		{
			"<leader>dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			mode = { "n", "v" },
			desc = "Debug: Hover Variable",
		},
		{
			"<leader>dp",
			function()
				require("dap.ui.widgets").preview()
			end,
			mode = { "n", "v" },
			desc = "Debug: Preview Variable",
		},
		{
			"<leader>dc",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Debug: Run To Cursor",
		},
		{
			"<leader>dx",
			function()
				require("dap").terminate()
			end,
			desc = "Debug: Terminate",
		},
		{
			"<leader>dL",
			function()
				require("dap").run_last()
			end,
			desc = "Debug: Run Last",
		},
		{
			"<leader>dt",
			function()
				require("dap-go").debug_test()
			end,
			desc = "Debug: Go Nearest Test",
		},
		{
			"<leader>dT",
			function()
				require("dap").run({
					type = "go",
					name = "Debug package tests",
					request = "launch",
					mode = "test",
					program = "./${relativeFileDirname}",
				})
			end,
			desc = "Debug: Go Package Tests",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local smoke_test = vim.env.NVIM_CONFIG_TEST == "smoke"

		local function mason_bin(name)
			return vim.fn.stdpath("data") .. "/mason/bin/" .. name
		end

		local function executable(name, fallback)
			local path = vim.fn.exepath(name)
			if path ~= "" then
				return path
			end

			return fallback or name
		end

		local function python_path()
			if vim.env.VIRTUAL_ENV then
				return vim.env.VIRTUAL_ENV .. "/bin/python"
			end

			local venv_root = vim.fs.root(0, { ".venv" })
			if venv_root then
				local venv_python = venv_root .. "/.venv/bin/python"
				if vim.uv.fs_stat(venv_python) then
					return venv_python
				end
			end

			local python3 = vim.fn.exepath("python3")
			if python3 ~= "" then
				return python3
			end

			local python = vim.fn.exepath("python")
			return python ~= "" and python or "python"
		end

		require("mason-nvim-dap").setup({
			ensure_installed = smoke_test and {} or { "python", "delve" },
			automatic_installation = false,
			handlers = {
				function(config)
					config.configurations = {}
					require("mason-nvim-dap").default_setup(config)
				end,
			},
		})

		dapui.setup({
			icons = { expanded = "v", collapsed = ">", current_frame = "*" },
			controls = {
				icons = {
					pause = "pause",
					play = "play",
					step_into = "into",
					step_over = "over",
					step_out = "out",
					step_back = "back",
					run_last = "last",
					terminate = "stop",
					disconnect = "disc",
				},
			},
		})

		require("nvim-dap-virtual-text").setup({
			commented = true,
		})

		vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticWarn" })
		vim.fn.sign_define("DapBreakpointRejected", { text = "R", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapLogPoint", { text = "L", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticOk", linehl = "Visual" })

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		require("dap-go").setup({
			delve = {
				path = executable("dlv", mason_bin("dlv")),
				detached = vim.fn.has("win32") == 0,
			},
		})

		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "Python: Launch current file",
				program = "${file}",
				pythonPath = python_path,
				console = "integratedTerminal",
				justMyCode = false,
			},
			{
				type = "python",
				request = "attach",
				name = "Python: Attach localhost:5678",
				connect = { host = "127.0.0.1", port = 5678 },
				pathMappings = { { localRoot = "${workspaceFolder}", remoteRoot = "." } },
				pythonPath = python_path,
				justMyCode = false,
			},
			{
				type = "python",
				request = "attach",
				name = "Python: Attach process",
				processId = require("dap.utils").pick_process,
				pythonPath = python_path,
				justMyCode = false,
			},
		}
	end,
}
