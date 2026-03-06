return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local runtime_files = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/init.lua", false)
      local runtime_root = runtime_files[1] and vim.fn.fnamemodify(runtime_files[1], ":h:h:h") or nil
      local runtime_queries = runtime_root and (runtime_root .. "/runtime") or nil
      if runtime_queries and not vim.tbl_contains(vim.opt.rtp:get(), runtime_queries) then
        vim.opt.rtp:append(runtime_queries)
      end

      local parsers = require('nvim-treesitter.parsers')
      local parser_config = parsers.get_parser_configs and parsers.get_parser_configs() or parsers

      if parser_config.sql and parser_config.sql.install_info then
        parser_config.sql.install_info.queries = "queries"
      end

      parser_config.clickhouse = {
        install_info = {
          url = "https://github.com/r-k-jonynas/tree-sitter-clickhouse",
          branch = "master",
          files = { "src/parser.c" },
          queries = "queries",
        },
        filetype = "clickhouse",
      }

      parser_config.postgresql = {
        install_info = {
          url = "https://github.com/tenebras/tree-sitter-postgresql",
          branch = "main",
          files = { "src/parser.c" },
          generate = true,
          queries = "queries",
        },
        filetype = "postgresql",
      }

      require('nvim-treesitter').setup({
        ensure_installed = {
          "sql",
          "postgresql",
          "clickhouse",
          "go",
          "typescript",
          "javascript",
          "lua",
          "python",
          "php",
          "c",
          "rust",
          "tsx",
          "vue",
          "angular",
          "html",
          "css",
          "scss",
          "vim",
          "markdown",
          "json",
          "yaml",
          "xml",
          "toml",
          "bash",
          "zsh",
          "fish",
          "tmux",
          "dockerfile",
          "gomod",
          "gosum"
        },
        auto_install = true,
      })

      -- Enable highlighting for all supported filetypes automatically
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          "sql",
          "postgresql",
          "clickhouse",
          "go",
          "typescript",
          "javascript",
          "lua",
          "python",
          "php",
          "c",
          "rust",
          "tsx",
          "vue",
          "angular",
          "html",
          "css",
          "scss",
          "vim",
          "markdown",
          "json",
          "yaml",
          "xml",
          "toml",
          "bash",
          "zsh",
          "fish",
          "tmux",
          "dockerfile",
          "gomod",
          "gosum",
        },
        callback = function(args)
          local buf = args.buf
          if vim.bo[buf].buftype == '' then
            vim.schedule(function()
              pcall(vim.treesitter.start, buf)
            end)
          end
        end,
      })
    end
  },
  {
    "DariusCorvus/tree-sitter-language-injection.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("tree-sitter-language-injection").setup({
        go = {
          string = {
            langs = {
              {
                name = "sql",
                match = [[^\_s*\c\(select\|insert\|update\|delete\|with\|create\|alter\|drop\|truncate\|merge\)\>]],
              },
            },
            query = [[
              ((raw_string_literal) @injection.content
                (#match? @injection.content "{match}")
                (#set! injection.language "{name}"))
            ]],
          },
          comment = {
            langs = {
              {
                name = "sql",
                match = [[^//\s*sql\s*$|^/\*\s*sql\s*\*/$]],
              },
              {
                name = "postgresql",
                match = [[^//\s*postgresql\s*$|^/\*\s*postgresql\s*\*/$]],
              },
              {
                name = "clickhouse",
                match = [[^//\s*clickhouse\s*$|^/\*\s*clickhouse\s*\*/$]],
              },
            },
            query = [[
              ((comment) @comment
                .
                [
                  (short_var_declaration
                    right: (expression_list (raw_string_literal) @injection.content))
                  (assignment_statement
                    right: (expression_list (raw_string_literal) @injection.content))
                  (var_declaration
                    (var_spec
                      value: (expression_list (raw_string_literal) @injection.content)))
                  (call_expression
                    arguments: (argument_list (raw_string_literal) @injection.content))
                ]
                (#match? @comment "{match}")
                (#set! injection.language "{name}"))
            ]],
          },
        },
      })
    end,
  },
}
