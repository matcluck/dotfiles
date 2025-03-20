return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",  -- Automatically run :TSUpdate to install parsers
    event = { "BufReadPost", "BufNewFile" },  -- Lazy loads on buffer read or new file
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "lua", "python", "javascript", "html", "css" }, -- Add languages you need
            highlight = {
                enable = true,                -- Enable Treesitter-based syntax highlighting
                additional_vim_regex_highlighting = false,  -- Disable default Vim syntax
            },
            indent = {
                enable = true,                -- Enable Treesitter-based indentation
            },
        })
    end,
}
