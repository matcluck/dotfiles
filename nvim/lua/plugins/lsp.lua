return {
    {
        "williamboman/mason.nvim",
        opts = {
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls" },
                handlers = {
                    -- auto-configure any server installed via :Mason
                    function(server_name)
                        require("lspconfig")[server_name].setup({})
                    end,
                    -- lua_ls: teach it about the vim global
                    lua_ls = function()
                        require("lspconfig").lua_ls.setup({
                            settings = {
                                Lua = {
                                    diagnostics = { globals = { "vim" } },
                                    workspace = { checkThirdParty = false },
                                },
                            },
                        })
                    end,
                },
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,  opts)
                    vim.keymap.set("n", "K",          vim.lsp.buf.hover,       opts)
                    vim.keymap.set("n", "gr",         vim.lsp.buf.references,  opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      opts)
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>f",  function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)
                end,
            })
        end,
    },
}
