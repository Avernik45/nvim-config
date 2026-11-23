-- ============================================================================
--  init.lua  -  single-file Neovim config
--  Theme: Notepad++ "Default" (classic light) - no icons anywhere
--
--  REQUIREMENTS
--    * Neovim 0.11+          (built-in LSP API, vim.snippet)
--    * git                   (lazy.nvim clones plugins with it)
--    * C compiler + tree-sitter CLI  (only for Treesitter parsers that Neovim
--                                     does not ship; see section 6.1)
--
--  HOW TO EXPLORE THIS FILE
--    The file uses fold markers. It opens fully collapsed, one line per
--    section. Useful keys:   za = toggle fold    zR = open all    zM = close all
--    Or search for a section header:   /\[\[ 3
--
--  TABLE OF CONTENTS
--    [[ 1 ]]   Options              leader key, tabs, search, clipboard, ...
--    [[ 2 ]]   Theme                Notepad++ palette + all highlight groups
--    [[ 3 ]]   Keymaps              general (non-plugin) keybindings
--    [[ 4 ]]   Autocommands         yank flash, restore cursor position
--    [[ 5 ]]   Plugin manager       lazy.nvim bootstrap
--    [[ 6 ]]   Plugins              6.1 treesitter     6.2 nvim-tree
--                                   6.3 lualine        6.4 indent-blankline
--                                   6.5 autopairs      6.6 Comment.nvim
--                                   6.7 nvim-cmp
--    [[ 7 ]]   LSP & diagnostics    built-in LSP, you list your own servers
-- ============================================================================

if vim.fn.has("nvim-0.11") == 0 then
  vim.notify("This config needs Neovim 0.11 or newer.", vim.log.levels.ERROR)
end


-- [[ 1. OPTIONS ]] ---------------------------------------------------------- {{{1

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- netrw is replaced by nvim-tree (section 6.2)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local o = vim.opt

-- Appearance
o.termguicolors = true
o.number = true            -- Notepad++ shows absolute line numbers
o.relativenumber = false
o.cursorline = true        -- highlight the current line
o.signcolumn = "yes"       -- always reserve the left margin (no text jumping)
o.wrap = false
o.showmode = false         -- the status line shows the mode instead
o.laststatus = 3           -- one global status line, like Notepad++
o.scrolloff = 5
o.sidescrolloff = 8
o.fillchars = { eob = " " }  -- hide the "~" on empty lines

-- Show-all-characters mode (toggle with <leader>tw), plain ASCII symbols
o.list = false
o.listchars = { tab = "->", space = ".", trail = ".", nbsp = "+" }

-- Indentation (change to 2 or 8 if you prefer; set expandtab = false for real tabs)
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.smartindent = true

-- Search
o.ignorecase = true
o.smartcase = true         -- case-sensitive only if you type a capital
o.hlsearch = true
o.incsearch = true

-- Behaviour
o.mouse = "a"
o.clipboard = "unnamedplus"  -- Ctrl+C / Ctrl+V share the system clipboard
                             -- (Linux needs xclip or wl-clipboard installed)
o.undofile = true            -- undo history survives closing the file
o.swapfile = false
o.confirm = true             -- ask instead of failing when quitting unsaved files
o.splitright = true
o.splitbelow = true
o.updatetime = 250
o.timeoutlen = 500
o.completeopt = { "menu", "menuone", "noselect" }
o.pumheight = 12


-- [[ 2. THEME ]] ------------------------------------------------------------ {{{1
-- Notepad++ "Default" colours. Edit the palette (P) to tweak the whole theme;
-- the highlight groups below are built from it.

local P = {
  bg = "#FFFFFF",         fg = "#000000",
  comment = "#008000",    -- green
  keyword = "#0000FF",    -- bold blue
  type = "#8000FF",       -- bold purple
  number = "#FF8000",     -- orange
  string = "#808080",     -- grey (Notepad++ default)
  operator = "#000080",   -- bold navy (operators, brackets, delimiters)
  preproc = "#804000",    -- brown (#include, imports, attributes)
  margin_bg = "#E4E4E4",  margin_fg = "#808080",   -- line number / sign column
  cursorline = "#E8E8FF", selection = "#C0C0C0",
  panel_bg = "#F0F0F0",   popup_bg = "#F7F7F7",
  guide = "#C0C0C0",      whitespace = "#FFB56A",
  error = "#FF0000",      warn = "#FF8000",   info = "#0000FF",   hint = "#808080",
  find = "#FFFF80",       find_current = "#FF8000",
  accent = "#0078D7",     -- selected menu item
}

local function apply_theme()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.o.background = "light"
  vim.g.colors_name = "npp-classic"

  local groups = {
    -- ---- 2.1 Editor UI ----------------------------------------------------
    Normal       = { fg = P.fg, bg = P.bg },
    NormalNC     = { link = "Normal" },
    NormalFloat  = { fg = P.fg, bg = P.popup_bg },
    FloatBorder  = { fg = P.margin_fg, bg = P.popup_bg },
    FloatTitle   = { fg = P.fg, bg = P.popup_bg, bold = true },
    EndOfBuffer  = { fg = P.bg, bg = P.bg },
    CursorLine   = { bg = P.cursorline },
    CursorColumn = { bg = P.cursorline },
    ColorColumn  = { bg = P.panel_bg },
    LineNr       = { fg = P.margin_fg, bg = P.margin_bg },
    CursorLineNr = { fg = P.fg, bg = P.margin_bg, bold = true },
    SignColumn   = { bg = P.margin_bg },
    FoldColumn   = { fg = P.margin_fg, bg = P.panel_bg },
    Folded       = { fg = P.margin_fg, bg = P.panel_bg },
    Visual       = { bg = P.selection },
    VisualNOS    = { bg = P.selection },
    Search       = { fg = P.fg, bg = P.find },
    CurSearch    = { fg = "#FFFFFF", bg = P.find_current },
    IncSearch    = { fg = "#FFFFFF", bg = P.find_current },
    Substitute   = { fg = "#FFFFFF", bg = P.find_current },
    MatchParen   = { fg = P.error, bold = true },          -- Notepad++ brace match
    NonText      = { fg = P.whitespace },
    Whitespace   = { fg = P.whitespace },
    SpecialKey   = { fg = P.whitespace },
    Directory    = { fg = P.operator, bold = true },
    Title        = { fg = P.fg, bold = true },
    Conceal      = { fg = P.margin_fg },
    QuickFixLine = { bg = P.selection },
    WinSeparator = { fg = P.guide, bg = P.bg },
    VertSplit    = { link = "WinSeparator" },
    StatusLine   = { fg = P.fg, bg = P.panel_bg },
    StatusLineNC = { fg = P.margin_fg, bg = P.panel_bg },
    TabLine      = { fg = P.fg, bg = P.margin_bg },
    TabLineSel   = { fg = P.fg, bg = P.bg, bold = true },
    TabLineFill  = { bg = P.panel_bg },
    Pmenu        = { fg = P.fg, bg = P.popup_bg },
    PmenuSel     = { fg = "#FFFFFF", bg = P.accent },
    PmenuSbar    = { bg = P.margin_bg },
    PmenuThumb   = { bg = P.margin_fg },
    WildMenu     = { link = "PmenuSel" },
    ErrorMsg     = { fg = P.error, bold = true },
    WarningMsg   = { fg = P.warn },
    MoreMsg      = { fg = P.comment },
    Question     = { fg = P.comment },
    ModeMsg      = { bold = true },
    SpellBad     = { undercurl = true, sp = P.error },
    SpellCap     = { undercurl = true, sp = P.warn },

    -- ---- 2.2 Diff ---------------------------------------------------------
    DiffAdd      = { bg = "#C8F0C8" },
    DiffChange   = { bg = "#E8E8FF" },
    DiffDelete   = { fg = P.error, bg = "#FFD0D0" },
    DiffText     = { bg = P.find, bold = true },

    -- ---- 2.3 Syntax (classic Vim groups; Treesitter captures link to these)
    Comment      = { fg = P.comment },
    Constant     = { fg = P.fg },
    String       = { fg = P.string },
    Character    = { fg = P.string },
    Number       = { fg = P.number },
    Float        = { link = "Number" },
    Boolean      = { fg = P.keyword, bold = true },        -- true/false are keywords in N++
    Identifier   = { fg = P.fg },
    Function     = { fg = P.fg },
    Statement    = { fg = P.keyword, bold = true },
    Conditional  = { link = "Statement" },
    Repeat       = { link = "Statement" },
    Label        = { link = "Statement" },
    Keyword      = { link = "Statement" },
    Exception    = { link = "Statement" },
    Operator     = { fg = P.operator, bold = true },
    PreProc      = { fg = P.preproc },
    Include      = { link = "PreProc" },
    Define       = { link = "PreProc" },
    Macro        = { link = "PreProc" },
    PreCondit    = { link = "PreProc" },
    Type         = { fg = P.type, bold = true },
    StorageClass = { link = "Type" },
    Structure    = { link = "Type" },
    Typedef      = { link = "Type" },
    Special      = { fg = P.fg },
    SpecialChar  = { fg = P.number },
    Delimiter    = { fg = P.operator, bold = true },
    Tag          = { link = "Statement" },
    Underlined   = { fg = P.keyword, underline = true },
    Error        = { fg = P.error, bold = true },
    Todo         = { fg = P.fg, bg = P.find, bold = true },

    -- ---- 2.4 Treesitter tweaks (everything else falls back to 2.3) --------
    ["@variable.builtin"] = { link = "Keyword" },          -- this / self
    ["@constant.builtin"] = { link = "Keyword" },          -- null / nil / None
    ["@markup.heading"]   = { link = "Title" },
    ["@markup.link"]      = { link = "Underlined" },

    -- ---- 2.5 Diagnostics --------------------------------------------------
    DiagnosticError = { fg = P.error },
    DiagnosticWarn  = { fg = P.warn },
    DiagnosticInfo  = { fg = P.info },
    DiagnosticHint  = { fg = P.hint },
    DiagnosticOk    = { fg = P.comment },
    DiagnosticUnderlineError = { undercurl = true, sp = P.error },
    DiagnosticUnderlineWarn  = { undercurl = true, sp = P.warn },
    DiagnosticUnderlineInfo  = { undercurl = true, sp = P.info },
    DiagnosticUnderlineHint  = { undercurl = true, sp = P.hint },

    -- ---- 2.6 Plugin groups ------------------------------------------------
    -- indent-blankline
    IblIndent = { fg = P.guide },
    IblScope  = { fg = P.margin_fg },
    -- nvim-tree
    NvimTreeNormal           = { fg = P.fg, bg = P.bg },
    NvimTreeEndOfBuffer      = { fg = P.bg, bg = P.bg },
    NvimTreeWinSeparator     = { fg = P.guide, bg = P.bg },
    NvimTreeRootFolder       = { fg = P.fg, bold = true },
    NvimTreeFolderName       = { fg = P.operator, bold = true },
    NvimTreeOpenedFolderName = { fg = P.operator, bold = true },
    NvimTreeEmptyFolderName  = { fg = P.margin_fg },
    NvimTreeSymlinkFolderName = { fg = P.operator, bold = true },
    NvimTreeCursorLine       = { bg = P.selection },
    NvimTreeExecFile         = { fg = P.comment },
    -- nvim-cmp
    CmpItemAbbrMatch      = { fg = P.keyword, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = P.keyword, bold = true },
    CmpItemAbbrDeprecated = { fg = P.margin_fg, strikethrough = true },
    CmpItemMenu           = { fg = P.margin_fg },
  }

  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

apply_theme()


-- [[ 3. KEYMAPS ]] ---------------------------------------------------------- {{{1
-- Leader key is <Space>. Plugin-specific keymaps (LSP) live in their sections.

local map = vim.keymap.set

-- 3.1 File ------------------------------------------------------------------
-- Note: some terminals swallow Ctrl+S (flow control). If it freezes, run
-- `stty -ixon` in your shell profile.
map({ "n", "i", "x" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })

-- 3.2 Search ----------------------------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- 3.3 Buffers (open files) ---------------------------------------------------
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>bl", "<cmd>ls<cr>", { desc = "List buffers" })

-- 3.4 Windows ----------------------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- 3.5 Editing -----------------------------------------------------------------
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("x", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("x", "<", "<gv", { desc = "Indent left, keep selection" })
map("x", ">", ">gv", { desc = "Indent right, keep selection" })
map("n", "<leader>a", "ggVG", { desc = "Select all" })

-- 3.6 Comments (Comment.nvim, section 6.6; also gcc / gc in visual mode) -------
map("n", "<leader>/", function() require("Comment.api").toggle.linewise.current() end,
  { desc = "Toggle comment" })
map("x", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
  { desc = "Toggle comment" })

-- 3.7 Toggles (like Notepad++'s View menu) ------------------------------------
map("n", "<leader>tw", function() vim.opt.list = not vim.opt.list:get() end,
  { desc = "Toggle show whitespace" })
map("n", "<leader>tl", function() vim.opt.wrap = not vim.opt.wrap:get() end,
  { desc = "Toggle word wrap" })
map("n", "<leader>tn", function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end,
  { desc = "Toggle relative line numbers" })

-- 3.8 File explorer (nvim-tree, section 6.2) ------------------------------------
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
map("n", "<leader>E", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal current file in explorer" })


-- [[ 4. AUTOCOMMANDS ]] ----------------------------------------------------- {{{1

local augroup = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Flash the text you just yanked
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function() (vim.hl or vim.highlight).on_yank({ timeout = 150 }) end,
})

-- Reopen files at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})


-- [[ 5. PLUGIN MANAGER (lazy.nvim bootstrap) ]] ----------------------------- {{{1
-- Clones lazy.nvim on first start. Requires git and an internet connection.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out } }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)


-- [[ 6. PLUGINS ]] ---------------------------------------------------------- {{{1
-- Each plugin is its own block. To remove one, delete its block. To add one,
-- copy a block and change the repo name.

require("lazy").setup({

  -- 6.1 Treesitter: syntax highlighting that understands code structure ------ {{{2
  -- Uses the `main` branch. Parsers for Lua, Vim, Markdown and C ship with
  -- Neovim. For any other language, the parser is downloaded and compiled the
  -- first time you open such a file (needs a C compiler + the tree-sitter CLI).
  -- If that fails, highlighting simply falls back to Vim's regex syntax, which
  -- the theme (section 2) also covers.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter")
      if not ok then return end
      pcall(ts.setup, {})

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then return end
          -- already installed? start highlighting and stop here
          if pcall(vim.treesitter.start, args.buf, lang) then return end
          -- otherwise try to install it, then start highlighting
          local okAvail, available = pcall(ts.get_available)
          if not (okAvail and vim.tbl_contains(available, lang)) then return end
          local okInstall, task = pcall(ts.install, lang)
          if okInstall and task and task.await then
            task:await(function()
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(args.buf) then
                  pcall(vim.treesitter.start, args.buf, lang)
                end
              end)
            end)
          end
        end,
      })
    end,
  },

  -- 6.2 nvim-tree: file explorer sidebar (icons off) ------------------------- {{{2
  -- <leader>e toggles it. Inside the tree: a = new file, d = delete,
  -- r = rename, <CR> = open, g? = full help.
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen", "NvimTreeFocus" },
    opts = {
      hijack_cursor = true,
      view = { width = 32 },
      git = { enable = false },
      diagnostics = { enable = false },
      update_focused_file = { enable = true },
      filters = { dotfiles = false },
      renderer = {
        add_trailing = true,       -- folders end with "/" since there are no icons
        group_empty = true,
        indent_markers = { enable = false },
        icons = {
          show = {
            file = false, folder = false, folder_arrow = false, git = false,
            modified = false, hidden = false, diagnostics = false, bookmarks = false,
          },
        },
      },
    },
  },

  -- 6.3 lualine: status bar styled like Notepad++'s (icons off) -------------- {{{2
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      -- one colour per mode in the first box; the rest stays grey like Notepad++
      local function mode_theme(accent)
        return {
          a = { fg = "#FFFFFF", bg = accent, gui = "bold" },
          b = { fg = P.fg, bg = P.margin_bg },
          c = { fg = P.fg, bg = P.panel_bg },
        }
      end
      local npp = {
        normal   = mode_theme("#316AC5"),
        insert   = mode_theme("#008000"),
        visual   = mode_theme("#FF8000"),
        replace  = mode_theme("#FF0000"),
        command  = mode_theme("#8000FF"),
        inactive = {
          a = { fg = P.margin_fg, bg = P.panel_bg },
          b = { fg = P.margin_fg, bg = P.panel_bg },
          c = { fg = P.margin_fg, bg = P.panel_bg },
        },
      }

      require("lualine").setup({
        options = {
          icons_enabled = false,
          theme = npp,
          globalstatus = true,
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "filename" },
          lualine_c = { "diagnostics" },
          lualine_x = { "filetype" },
          lualine_y = { "encoding", "fileformat" },
          lualine_z = { function() return "Ln %l/%L  Col %v" end },
        },
        inactive_sections = {
          lualine_c = { "filename" },
          lualine_x = { "location" },
        },
      })
    end,
  },

  -- 6.4 indent-blankline: vertical indent guides ------------------------------ {{{2
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "|", highlight = "IblIndent" },
      scope = { enabled = false },
    },
  },

  -- 6.5 nvim-autopairs: auto-close brackets and quotes ------------------------- {{{2
  -- Also hooked into nvim-cmp (6.7) so confirming a function adds "()".
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = false },
  },

  -- 6.6 Comment.nvim: toggle comments ------------------------------------------ {{{2
  -- gcc = toggle line, gc + motion (e.g. gcap), gc in visual mode,
  -- gbc = toggle block comment. <leader>/ also works (section 3.6).
  {
    "numToStr/Comment.nvim",
    lazy = false,
    opts = {},
  },

  -- 6.7 nvim-cmp: autocomplete popup -------------------------------------------- {{{2
  -- Sources: LSP (section 7), file paths, words from open buffers.
  -- Keys: Tab / Shift-Tab = next / previous item (or jump in a snippet),
  --       Enter = confirm, Ctrl+Space = open manually, Ctrl+E = close.
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(a) vim.snippet.expand(a.body) end,  -- built-in snippets
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        completion = { completeopt = "menu,menuone,noselect" },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),  -- only confirms a selected item
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "path" } },
          { { name = "buffer" } }
        ),
        formatting = {
          fields = { "abbr", "menu" },                         -- no kind icons
          format = function(entry, item)
            item.menu = ({ nvim_lsp = "[LSP]", buffer = "[Buf]", path = "[Path]" })[entry.source.name]
            return item
          end,
        },
      })

      -- add "()" after confirming a function
      local okPairs, pairsCmp = pcall(require, "nvim-autopairs.completion.cmp")
      if okPairs then cmp.event:on("confirm_done", pairsCmp.on_confirm_done()) end
    end,
  },

}, {
  -- lazy.nvim's own settings: plain-text UI (no icons), quiet
  ui = {
    icons = {
      cmd = "cmd ", config = "cfg ", event = "evt ", favorite = "* ", ft = "ft ",
      init = "init ", import = "imp ", keys = "key ", lazy = "zz ", loaded = "+",
      not_loaded = "-", plugin = "# ", runtime = "rt ", require = "req ",
      source = "src ", start = "> ", task = "ok ", list = { "-", "-", "-", "-" },
    },
  },
  change_detection = { notify = false },
  checker = { enabled = false },
  rocks = { enabled = false },
})


-- [[ 7. LSP & DIAGNOSTICS ]] ------------------------------------------------ {{{1
-- Uses Neovim's built-in LSP client. No plugin, no Mason, no languages assumed.
--
-- To enable a language:
--   1. Install its language server yourself (system package manager, pip, npm,
--      `dotnet tool`, cargo, ...). Check it runs from a terminal.
--   2. Add an entry to `servers` below. `cmd` is the command that starts the
--      server, `filetypes` are the Neovim filetypes it should attach to, and
--      `root_markers` are files/folders that mark a project root.
--   3. Restart Neovim and open a matching file. `:checkhealth vim.lsp` helps.

local servers = {
  -- TEMPLATE (copy, uncomment and edit):
  -- my_server = {
  --   cmd = { "server-executable", "--stdio" },
  --   filetypes = { "somefiletype" },
  --   root_markers = { ".git" },
  -- },
  --
  -- EXAMPLES (uncomment only if you use that language and installed the server):
  -- pyright = {
  --   cmd = { "pyright-langserver", "--stdio" },
  --   filetypes = { "python" },
  --   root_markers = { "pyproject.toml", "setup.py", ".git" },
  -- },
  -- lua_ls = {
  --   cmd = { "lua-language-server" },
  --   filetypes = { "lua" },
  --   root_markers = { ".luarc.json", ".git" },
  -- },
}

-- 7.1 Register and enable the servers listed above ----------------------------
if vim.lsp.config and vim.lsp.enable then
  -- tell every server that nvim-cmp can handle completions
  local okCmp, cmpLsp = pcall(require, "cmp_nvim_lsp")
  if okCmp then
    vim.lsp.config("*", { capabilities = cmpLsp.default_capabilities() })
  end

  for name, cfg in pairs(servers) do
    vim.lsp.config(name, cfg)
    vim.lsp.enable(name)
  end
end

-- 7.2 Keymaps that only exist while a language server is attached --------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(ev)
    local function m(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
    end
    m("gd", vim.lsp.buf.definition, "Go to definition")
    m("gD", vim.lsp.buf.declaration, "Go to declaration")
    m("gi", vim.lsp.buf.implementation, "Go to implementation")
    m("K", vim.lsp.buf.hover, "Hover documentation")
    m("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    m("<leader>ca", vim.lsp.buf.code_action, "Code action")
    m("<leader>d", vim.diagnostic.open_float, "Show diagnostic")
    m("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format file")
    -- built-in extras (Neovim 0.11): grr = references, ]d / [d = next/prev diagnostic
  end,
})

-- 7.3 Diagnostics (errors / warnings): plain letters instead of icons ----------
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  float = { border = "single", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
})


-- vim: foldmethod=marker foldlevel=0 :
