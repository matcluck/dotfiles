return {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },  -- Harpoon depends on plenary.nvim
    keys = {
        { "<leader>ha", function() require("harpoon.mark").add_file() end, desc = "Harpoon Add File" },
        { "<leader>hm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon Menu" },
        { "<leader>hn", function() require("harpoon.ui").nav_next() end, desc = "Harpoon Next" },
        { "<leader>hp", function() require("harpoon.ui").nav_prev() end, desc = "Harpoon Previous" },
    },
    config = function()
        require("harpoon").setup({
            menu = {
                width = vim.api.nvim_win_get_width(0) - 20,
            },
        })
    end,
}
