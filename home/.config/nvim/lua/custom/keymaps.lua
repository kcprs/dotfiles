local M = {}

function M.setup_leader()
  -- Set <space> as the leader key
  -- See `:help mapleader`
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
end

function M.setup_basic()
  -- Keymaps for better default experience
  -- See `:help vim.keymap.set()`
  vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

  vim.keymap.set('i', 'jk', "<ESC>", { noremap = true })

  -- Remap for dealing with word wrap
  vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

  -- Easily exit terminal mode
  vim.keymap.set("t", [[<c-\>]], [[<c-\><c-n>]])

  -- Diagnostic keymaps
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

  -- Move selected range up and down, stolen from the Primeagen
  vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
  vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
end

function M.gitsigns_on_attach(bufnr)
  vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

  -- don't override the built-in and fugitive keymaps
  local gs = package.loaded.gitsigns
  vim.keymap.set({ 'n', 'v' }, ']c', function()
    if vim.wo.diff then
      return ']c'
    end
    vim.schedule(function()
      gs.next_hunk()
    end)
    return '<Ignore>'
  end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
  vim.keymap.set({ 'n', 'v' }, '[c', function()
    if vim.wo.diff then
      return '[c'
    end
    vim.schedule(function()
      gs.prev_hunk()
    end)
    return '<Ignore>'
  end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
end

function M.lsp_on_attach(bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')
end

function M.cmp_mapping()
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
  return {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }
end

-- function M.set_neotree()
--   vim.keymap.set("n", "<leader>ef", ":Neotree toggle action=focus source=filesystem position=right<cr>", { desc = "Toggle Neotree - [e]xplore [f]iles" })
--   vim.keymap.set("n", "<leader>eb", ":Neotree toggle action=focus source=buffers position=right<cr>", { desc = "Toggle Neotree - [e]xplore [b]uffers" })
--   vim.keymap.set("n", "<leader>eg", ":Neotree toggle action=focus source=git_status position=right<cr>", { desc = "Toggle Neotree - [e]xplore [g]it" })
--
--   vim.keymap.set("n", "<leader>eF", ":Neotree toggle action=focus source=filesystem position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [F]iles" })
--   vim.keymap.set("n", "<leader>eB", ":Neotree toggle action=focus source=buffers position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [B]uffers" })
--   vim.keymap.set("n", "<leader>eG", ":Neotree toggle action=focus source=git_status position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [G]it" })
-- end

function M.oil_set()
  vim.keymap.set("n", "<leader>o", require("oil").toggle_float, { desc = "Open [o]il" })
end

function M.toggleterm_get_open_mapping()
  return [[<c-\>]]
end

function M.toggleterm_set()
  -- set up dedicated command to open a terminal with lazygit
  local Terminal  = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({
    cmd = "lazygit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
      border = "curved",
    },
    -- function to run on opening the terminal
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
    end,
    -- function to run on closing the terminal
    on_close = function()
      vim.cmd("startinsert!")
    end,
  })

  function LazyGitToggle()
    lazygit:toggle()
  end

  vim.keymap.set("n", "<leader>G", "<cmd>lua LazyGitToggle()<CR>", {noremap = true, silent = true}, "[G]it")
end

return M
