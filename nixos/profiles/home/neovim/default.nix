# modules/home/neovim.nix
#
# Author: João Borges <RageKnify@gmail.com>
# URL:    https://github.com/RageKnify/Config
#
# neovim home configuration.

{ pkgs, config, lib, ... }:
let
  # Used in all types
  commonGrammars = with pkgs.unstable.tree-sitter-grammars; [
    tree-sitter-bash
    tree-sitter-comment
    tree-sitter-html
    tree-sitter-javascript
    tree-sitter-markdown
    tree-sitter-python
    tree-sitter-nix
  ];
  #
  personalGrammars = with pkgs.unstable.tree-sitter-grammars; [
    tree-sitter-c
    tree-sitter-cpp
    tree-sitter-java
    tree-sitter-latex
    tree-sitter-lua
    tree-sitter-rust
    tree-sitter-toml
    tree-sitter-typescript
    tree-sitter-vim
    tree-sitter-yaml
  ];
  commonPlugins = with pkgs.unstable.vimPlugins; [
    nvim-web-devicons
    vim-markdown-composer
    copilot-vim
    {
      plugin = lualine-nvim;
      type = "lua";
      config = ''
vim.o.laststatus=2
vim.o.showtabline=2
vim.o.showmode=false
require'lualine'.setup {
  options = {
    theme = 'auto',
    section_separators = {left='', right=''},
    component_separators = {left='', right=''},
    icons_enabled = true
  },
  sections = {
    lualine_b = { 'diff' },
    lualine_c = {
      {'diagnostics', {
        sources = {nvim_diagnostic},
        symbols = {error = ':', warn =':', info = ':', hint = ':'}}},
      {'filename', file_status = true, path = 1}
    },
    lualine_x = { 'encoding', {'filetype', colored = false} },
  },
  inactive_sections = {
    lualine_c = {
      {'filename', file_status = true, path = 1}
    },
    lualine_x = { 'encoding', {'filetype', colored = false} },
  },
  tabline = {
    lualine_a = { 'hostname' },
    lualine_b = { 'branch' },
    lualine_z = { {'tabs', tabs_color = { inactive = "TermCursor", active = "ColorColumn" } } }
  },
  extensions = { fzf'' + ", fugitive " + ''},
}
if _G.Tabline_timer == nil then
  _G.Tabline_timer = vim.loop.new_timer()
else
  _G.Tabline_timer:stop()
end
_G.Tabline_timer:start(0,             -- never timeout
                       100,          -- repeat every 1000 ms
                       vim.schedule_wrap(function() -- updater function
                                            vim.api.nvim_command('redrawtabline')
                                         end))
      '';
    }

    {
      plugin = delimitMate;
      config = ''
      let delimitMate_expand_cr=2
      let delimitMate_expand_space=1
      '';
    }

    {
      plugin = vim-illuminate;
      config = ''
      let g:Illuminate_delay = 100
      hi def link LspReferenceText CursorLine
      hi def link LspReferenceRead CursorLine
      hi def link LspReferenceWrite CursorLine
      '';
    }

    {
      plugin = (nvim-treesitter.withPlugins (
        plugins: commonGrammars ++ personalGrammars
      ));
      type = "lua";
      config = ''
-- enable highlighting
require'nvim-treesitter.configs'.setup { highlight = { enable = true } }

local function define_fdm()
  if (require "nvim-treesitter.parsers".has_parser()) then
    -- with treesitter parser
    vim.wo.foldexpr="nvim_treesitter#foldexpr()"
    vim.wo.foldmethod="expr"
  else
    -- without treesitter parser
    vim.wo.foldmethod="syntax"
  end
end
vim.api.nvim_create_autocmd({ "FileType" }, { callback = define_fdm })
            '';
    }

    vim-signature

    {
      plugin = fzf-vim;
      config = ''
      let $FZF_DEFAULT_OPTS='--layout=reverse'

      " Using the custom window creation function
      let g:fzf_layout = { 'window': { 'height': 0.75, 'width': 0.75 } }
      '';
    }

    vim-commentary

    {
      plugin = base16-nvim;
      config = ''
      " colorscheme settings
      set termguicolors
      set background=dark
      colorscheme base16-horizon-dark
      '';
    }

    plenary-nvim

    {
      plugin = nvim-osc52;
      type = "lua";
      config = ''
        vim.keymap.set('n', '<leader>y', require('osc52').copy_operator, {expr = true})
        vim.keymap.set('n', '<leader>yy', '<leader>c_', {remap = true})
        vim.keymap.set('v', '<leader>y', require('osc52').copy_visual)
      '';
    }

    {
      plugin = nvim-colorizer-lua;
      type = "lua";
      config = ''
require 'colorizer'.setup ({ user_default_options = { names = false; }})
      '';
    }
  ];

 personalPlugins = with pkgs.unstable.vimPlugins; [
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = ''
          -- common lsp setup
          local lsp_config = require'lspconfig'
          local lsp_setup = require'generic_lsp'

          -- Rust lsp setup
          local rt = require("rust-tools")

          local capabilities = lsp_setup.capabilities
          local on_attach = lsp_setup.on_attach
          rt.setup({
            server = {
              capabilities = capabilities,
              on_attach = function(_, bufnr)
                -- Hover actions
                on_attach(_, bufnr)
                vim.keymap.set('n', 'K', rt.hover_actions.hover_actions, {silent=true})
              end,
              settings = {
                ["rust-analyzer"] = {
                  checkOnSave = {
                    command = "clippy",
                  },
                },
              },
            },
          })

          -- tex lsp setup
          lsp_config.texlab.setup(lsp_setup)

          -- python lsp setup
          lsp_config.pyright.setup(lsp_setup)

          -- Nix lsp setup
          lsp_config.nil_ls.setup({
            settings = {
               ['nil'] = {
                 formatting = {
                   command = { "${pkgs.nixfmt-rfc-style}/bin/nixfmt" },
                 },
               },
            },
            cmd = { "${pkgs.nil}/bin/nil" },
          });
'';
    }
    rust-tools-nvim # TODO Change to Rustaceanvim
    lsp_extensions-nvim
    copilot-vim
    {
      plugin = presence-nvim;
      config = ''
      let g:presence_auto_update       = 1
      let g:presence_editing_text      = "Editing %s"
      let g:presence_workspace_text    = "Working on %s"
      let g:presence_neovim_image_text = "vim but better"
      let g:presence_main_image        = "neovim"
      '';
    }
    luasnip
    {
      plugin = nvim-cmp;
      type = "lua";
      config = ''
        -- Setup nvim-cmp.
        local cmp = require'cmp'

        cmp.setup({
          snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
              require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end,
          },
          window = {
            -- completion = cmp.config.window.bordered(),
            -- documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'treesitter' },
            { name = 'spell' },
            { name = 'path' },
            { name = 'buffer' },
          })
        })

        -- autocomplete commits, Issue/PR numbers, mentions
        cmp.setup.filetype('gitcommit', {
          sources = cmp.config.sources({
            { name = 'git' },
            { name = 'spell' },
            { name = 'buffer' },
          })
        })

        -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline('/', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = 'buffer' },
          }
        })
      '';
    }
    cmp_luasnip
    cmp-treesitter
    cmp-nvim-lsp
    cmp-spell
    cmp-path
    cmp-git
  ];
  twoSpaceIndentConfig = ''
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal tabstop=2
setlocal expandtab
  '';

  files = {
    "${config.xdg.configHome}/nvim/lua/generic_lsp.lua".source =
      ./generic_lsp.lua;
    "${config.xdg.configHome}/nvim/after/ftplugin/nix.vim".text = ''
      nnoremap <silent> <leader>tt :silent !${pkgs.nixfmt-rfc-style}/bin/nixfmt %<CR>
    '' + twoSpaceIndentConfig;
  } //
    # languages that should use 2 space indent
    builtins.listToAttrs (builtins.map (filetype: {
      name = "${config.xdg.configHome}/nvim/after/ftplugin/${filetype}.vim";
      value = { text = twoSpaceIndentConfig; };
    }) [ "markdown" "ocaml" "wast" "yaml" "yacc" "lex" "cpp" "tex" "scheme" ]);
in
{

    programs.neovim = {
      package = pkgs.unstable.neovim-unwrapped;
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraConfig = ''
        " sane defaults
        set shiftwidth=4
        set softtabstop=4
        set tabstop=4
        set noexpandtab
        set encoding=UTF-8

        " delete trailing whitespace
        autocmd FileType c,cpp,java,lua,nix,ocaml,vim,wast autocmd BufWritePre <buffer> %s/\s\+$//e

        " makes n=Next and N=Previous for find (? / /)
        nnoremap <expr> n  'Nn'[v:searchforward]
        nnoremap <expr> N  'nN'[v:searchforward]

        " Easy bind to leave terminal mode
        tnoremap <Esc> <C-\><C-n>

        " Change leader key to comma
        let mapleader = ","
        " Change localleader key to cedilla for conjure
        let maplocalleader = "ç"

        " fuzzy find files in the working directory (where you launched Vim from)
        nmap <expr> <leader>f FugitiveHead() != "" ? ':GFiles --cached --others --exclude-standard<CR>' : ':Files<CR>'
        " fuzzy find lines in the current file
        nmap <leader>/ :BLines<cr>
        " fuzzy find an open buffer
        nmap <leader>b :Buffers<cr>
        " fuzzy find text in the working directory
        nmap <leader>rg :Rg<cr>
        " fuzzy find Vim commands (like Ctrl-Shift-P in Sublime/Atom/VSC)
        nmap <leader>c :Commands<cr>

        " Keeps undo history over different sessions
        set undofile
        set undodir=/tmp//

        " Saves cursor position to be used next time the file is edited
        autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   execute "normal! g`\"" |
        \ endif

        nnoremap <silent> <Up>       :resize +2<CR>
        nnoremap <silent> <Down>     :resize -2<CR>
        nnoremap <silent> <Left>     :vertical resize +2<CR>
        nnoremap <silent> <Right>    :vertical resize -2<CR>

        "move to the split in the direction shown, or create a new split
        nnoremap <silent> <C-h> :call WinMove('h')<cr>
        nnoremap <silent> <C-j> :call WinMove('j')<cr>
        nnoremap <silent> <C-k> :call WinMove('k')<cr>
        nnoremap <silent> <C-l> :call WinMove('l')<cr>

        set cc=80

        function! WinMove(key)
          let t:curwin = winnr()
          exec "wincmd ".a:key
          if (t:curwin == winnr())
            if (match(a:key,'[jk]'))
              wincmd v
            else
              wincmd s
            endif
            exec "wincmd ".a:key
          endif
        endfunction

        nnoremap <silent> <leader><leader> :nohlsearch<cr>
        nnoremap <silent> <leader>m :silent call jobstart('make')<cr>

        set selection=exclusive

        set mouse=a

        au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=1000, on_visual=true}

        let g:bufferline_echo = 0

        set nowrap

        set scrolloff=5

        set splitbelow
        set splitright

        set shiftwidth=4
        set softtabstop=4
        set tabstop=4

        " Avoiding W
        cabbrev W w
        '';
        plugins = commonPlugins ++ personalPlugins ++ (
          with pkgs.unstable.vimPlugins; [
            vim-fugitive
            {
              plugin = gitsigns-nvim;
              type = "lua";
              config = ''
require('gitsigns').setup{
  signs = {
    add = {  text = '+' },
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    map('n', '<leader>gb', gs.toggle_current_line_blame)
  end,
}
              '';
            }
          ]
        );
    };

    home.file = files;

    home.packages = [ pkgs.pyright ];

    home.sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
}

