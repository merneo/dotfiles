-- =============================================================================
-- NEOVIM CONFIGURATION
-- Theme: Catppuccin Mocha Green
-- Goal: Lightweight, modern editor setup using lazy.nvim for package management.
-- =============================================================================

-- KEY MAPPINGS
-- Set <Space> as the leader key, which is ergonomic and standard in modern configs.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- PLUGIN MANAGEMENT (lazy.nvim)
-- Logic: Automatically clones the package manager if it's missing (bootstrapping).
-- This makes the config portable to new machines without manual setup.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none", -- Shallow clone for speed
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- LOAD PLUGINS
-- Plugins are defined in the 'lua/plugins' directory for modularity.
require("lazy").setup("plugins", {
  checker = { enabled = false }, -- Disable startup update check for faster launch
})

-- =============================================================================
-- EDITOR SETTINGS
-- =============================================================================

-- VISUALS
vim.opt.background = "dark" -- Hint for plugins that support dark modes

-- Cursor Line
-- Highlights the line number only, keeping the text area clean.
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- Line Numbers
-- Relative numbers help with jump motions (e.g., '5j'),
-- while the current line shows the absolute number.
vim.opt.number = true
vim.opt.relativenumber = true

-- INDENTATION
-- 2 spaces is standard for many modern web/JS projects and saves horizontal space.
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true -- Convert tabs to spaces

-- CLIPBOARD
-- 'unnamedplus' syncs the system clipboard (register +) with Neovim's default register.
-- Allows seamless copy/paste between Neovim and other apps.
vim.opt.clipboard = "unnamedplus"

-- WINDOW SPLITTING
-- More intuitive splitting behavior (new windows appear right/below).
vim.opt.splitbelow = true
vim.opt.splitright = true

-- CURSOR SHAPE
-- Changes cursor based on mode (Block in Normal, Bar in Insert, Underline in Replace).
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20"

-- WHITESPACE
-- Visualizes tabs and trailing spaces to catch formatting errors.
vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣" }

-- STATUSLINE
-- 'laststatus=3' creates a global statusline at the bottom, rather than per-window.
vim.opt.laststatus = 3