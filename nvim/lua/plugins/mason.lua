return {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",  -- Automatically update Mason packages
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },  -- Lazy load on these commands
    config = function()
        require("mason").setup({
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })
    end,
}