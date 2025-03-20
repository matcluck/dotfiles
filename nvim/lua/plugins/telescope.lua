return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",  -- Lazy loads on `:Telescope` command
    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = { "node_modules", ".git" },
            }
        })
    end,
}