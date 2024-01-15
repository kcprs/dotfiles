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

  -- Diagnostic keymaps
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
end

function M.telescope()
  -- See `:help telescope.builtin`
  vim.keymap.set('n', '<leader>fd', require('telescope.builtin').find_files, { desc = '[f]in[d] files' })
  vim.keymap.set('n', '<leader>fD', function() require('telescope.builtin').find_files{ hidden = true, no_ignore = true } end, { desc = '[f]in[D] ALL files' })
  vim.keymap.set('n', '<leader>fg', require('telescope.builtin').git_files, { desc = '[f]ind in [g]it'})
  vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = '[f]ind existing [b]uffers' })

  vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = '[f]ind in [h]elp' })
  vim.keymap.set('n', '<leader>fr', require('telescope.builtin').oldfiles, { desc = '[f]ind [r]ecently opened files' })
  vim.keymap.set('n', '<leader>fk', require('telescope.builtin').keymaps, { desc = '[f]ind [k]eymaps' })
  vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = '[f]ind by [g]rep' })

  --------------
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
  vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
end

function M.telescope_setup_defaults_mappings()
  return {
    i = {
      ['<C-u>'] = false,
      ['<C-d>'] = false,
      ["<esc>"] = require("telescope.actions").close,
      ["jk"] = require("telescope.actions").close,
    },
  }
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

function M.set_neotree()
  vim.keymap.set("n", "<leader>ef", ":Neotree toggle action=focus source=filesystem position=right<cr>", { desc = "Toggle Neotree - [e]xplore [f]iles" })
  vim.keymap.set("n", "<leader>eb", ":Neotree toggle action=focus source=buffers position=right<cr>", { desc = "Toggle Neotree - [e]xplore [b]uffers" })
  vim.keymap.set("n", "<leader>eg", ":Neotree toggle action=focus source=git_status position=right<cr>", { desc = "Toggle Neotree - [e]xplore [g]it" })

  vim.keymap.set("n", "<leader>eF", ":Neotree toggle action=focus source=filesystem position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [F]iles" })
  vim.keymap.set("n", "<leader>eB", ":Neotree toggle action=focus source=buffers position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [B]uffers" })
  vim.keymap.set("n", "<leader>eG", ":Neotree toggle action=focus source=git_status position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [G]it" })
end

return M
