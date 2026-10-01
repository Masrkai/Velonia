-- nvim.lua
-- Strip ^M from system clipboard on paste (Wayland/KDE/wl-copy)
local function strip_cr_from_clipboard()
  for _, reg in ipairs({ "+", "*" }) do
    local ok, lines = pcall(vim.fn.getreg, reg, 1, true)
    if ok and lines then
      local cleaned = vim.tbl_map(function(line)
        return line:gsub("\r", "")
      end, lines)
      -- Only update if something actually changed
      local orig = vim.fn.getreg(reg)
      local new = table.concat(cleaned, "\n")
      if orig ~= new then
        vim.fn.setreg(reg, cleaned, vim.fn.getregtype(reg))
      end
    end
  end
end

-- Sanitize clipboard right before every paste operation
vim.keymap.set({ "n", "v" }, "p", function()
  strip_cr_from_clipboard()
  return "p"
end, { expr = true, silent = true })

vim.keymap.set({ "n", "v" }, "P", function()
  strip_cr_from_clipboard()
  return "P"
end, { expr = true, silent = true })

-- Also sanitize on focus gain (e.g., switching back to kitty from browser)
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("StripClipboardCR", { clear = true }),
  callback = strip_cr_from_clipboard,
})