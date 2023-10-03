require("formatter").setup {
    logging = false,
    filetype = {
        python = {
            require("formatter.filetypes.python").black
        },
        javascript = {
            require("formatter.filetypes.typescript").prettier
        },
        typescript = {
            require("formatter.filetypes.typescript").prettier
        },
        typescriptreact = {
            require("formatter.filetypes.typescript").prettier
        },
        nix = {
            require("formatter.filetypes.nix").alejandra
        },
        rust = {
            require("formatter.filetypes.rust").rustfmt
        }
    }
}
