# modules/home/neovim.nix
#
# Author: João Borges <RageKnify@gmail.com>
# URL:    https://github.com/RageKnify/Config
#
# neovim home configuration.

{ pkgs, config, lib, ... }:
let
  commonGrammars = with pkgs.unstable.tree-sitter-grammars; [
    tree-sitter-bash
    tree-sitter-comment
    tree-sitter-html
    tree-sitter-markdown
    tree-sitter-python
  ];
  personalGrammars = with pkgs.unstable.tree-sitter-grammars; [
    tree-sitter-nix
    tree-sitter-c
    tree-sitter-cpp
    tree-sitter-java
    tree-sitter-javascript
    tree-sitter-latex
    tree-sitter-lua
    tree-sitter-ocaml
    tree-sitter-ocaml-interface
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
local lsp = require'lspconfig'

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = {
		'documentation',
		'detail',
		'additionalTextEdits',
	}
}

lsp.rust_analyzer.setup{
	capabilities = capabilities,
	on_attach = require'generic_lsp'
}
lsp.texlab.setup{
	capabilities = capabilities,
	on_attach = require'generic_lsp'
}
      '';
    }
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
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    -- { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
      '';
    }

    cmp_luasnip
    cmp-treesitter
    cmp-nvim-lsp
  ];
  twoSpaceIndentConfig = ''
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal tabstop=2
setlocal expandtab
  '';
  # TODO: if nvim-osc52 is added to nixpkgs I can stop having it here
  nvim-osc52 = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-osc52";
    src = pkgs.fetchFromGitHub {
      owner = "ojroques";
      repo = "nvim-osc52";
      rev = "87069dc586d835b70360d4771de53adb9b4aaff7";
      sha256 = "sha256-JAWf0VDgsOF4K9BH3Ihc+JB8IAuaF7pmqPdAz8pytQ4=";
    };
  };
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

    # languages that should use 2 space indent
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/markdown.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/nix.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/ocaml.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/wast.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/yaml.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/yacc.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/lex.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/cpp.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/tex.vim".text = twoSpaceIndentConfig;
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/julia.vim".text = twoSpaceIndentConfig;

    # Rust config
    home.file."${config.xdg.configHome}/nvim/after/ftplugin/rust.vim".text = ''
" Use LSP omni-completion in Rust files.
setlocal omnifunc=v:lua.vim.lsp.omnifunc

lua << EOF
local inlay_hints = require('lsp_extensions').inlay_hints

-- Global function, so you can just call it on the lua side
ShowHintsLine = function()
  inlay_hints {
    only_current_line = true
  }
end

ShowHintsFile = function()
  inlay_hints()
end
EOF
" not working for some reason
" autocmd CursorHold,CursorHoldI *.rs :lua ShowHintsLine()

nnoremap <silent> <leader>h <cmd>lua ShowHintsFile()<CR>
    '';
    home.file."${config.xdg.configHome}/nvim/lua/generic_lsp.lua".text = ''
return function(client)
	-- [[ other on_attach code ]]
	vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})

	-- illuminate stuff
	vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gn', '<cmd>lua require"illuminate".next_reference{}<cr>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<leader>gp', '<cmd>lua require"illuminate".next_reference{reverse=true}<cr>', {noremap = true})
	require 'illuminate'.on_attach(client)

  local set = vim.keymap.set
  set('n', '<leader>n', function () vim.diagnostic.goto_next { wrap = false } end, {silent = true})
  set('n', '<leader>p', function () vim.diagnostic.goto_prev { wrap = false } end, {silent = true})
  set('n', '<leader>d', vim.lsp.buf.definition, {silent = true})
  set('n', '<leader>gr', vim.lsp.buf.references, {silent = true})
  set('n', '<leader>rn', vim.lsp.buf.rename, {silent = true})
  set('n', '<leader>a', vim.lsp.buf.code_action, {silent = true})
  set('n', '<leader><cr>', vim.diagnostic.open_float, {silent = true})
end
    '';

    home.sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
}

