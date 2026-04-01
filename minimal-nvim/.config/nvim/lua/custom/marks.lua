local M = {}

local group = vim.api.nvim_create_augroup("native_marks_signs", { clear = true })
local sign_group = "native_marks"
local defined_signs = {}

local function define_sign(name, text)
  vim.fn.sign_define(name, {
    text = text,
    texthl = "DiagnosticHint",
    numhl = "",
    linehl = "",
  })
end

local function mark_char(mark_name)
  local ch = mark_name:sub(2, 2)
  if ch:match("[%a]") then
    return ch
  end
  return nil
end

local function sign_name_for_mark(mark_name)
  local ch = mark_char(mark_name)
  if not ch then
    return nil
  end
  if not defined_signs[ch] then
    local sign_name = "NativeMark_" .. ch
    define_sign(sign_name, ch)
    defined_signs[ch] = sign_name
  end
  return defined_signs[ch]
end

local function collect_marks(bufnr)
  local marks = {}
  for _, mark in ipairs(vim.fn.getmarklist(bufnr)) do
    marks[#marks + 1] = mark
  end
  for _, mark in ipairs(vim.fn.getmarklist()) do
    if mark.pos and mark.pos[1] == bufnr then
      marks[#marks + 1] = mark
    end
  end
  return marks
end

local function refresh(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.bo[bufnr].buftype ~= "" then
    vim.fn.sign_unplace(sign_group, { buffer = bufnr })
    return
  end

  vim.fn.sign_unplace(sign_group, { buffer = bufnr })

  local marks = collect_marks(bufnr)
  local placed = {}
  local id = 1

  for _, mark in ipairs(marks) do
    local name = mark.mark or ""
    local lnum = mark.pos and mark.pos[2] or 0
    if lnum > 0 then
      local key = ("%s:%d"):format(name, lnum)
      if not placed[key] then
        local sign_name = sign_name_for_mark(name)
        if sign_name then
          vim.fn.sign_place(id, sign_group, sign_name, bufnr, { lnum = lnum, priority = 10 })
          id = id + 1
          placed[key] = true
        end
      end
    end
  end
end

local function refresh_loaded_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == "" then
      refresh(bufnr)
    end
  end
end

function M.setup()
  vim.opt.signcolumn = "yes"

  vim.api.nvim_create_autocmd({
    "BufEnter",
    "CursorMoved",
    "CursorHold",
    "CursorHoldI",
    "CmdlineLeave",
    "TextChanged",
    "TextChangedI",
  }, {
    group = group,
    callback = function(args)
      refresh(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      vim.fn.sign_unplace(sign_group, { buffer = args.buf })
    end,
  })

  vim.api.nvim_create_user_command("MarksRefresh", function()
    refresh_loaded_buffers()
  end, { desc = "Refresh native mark signs" })

  -- Preserve native mark behavior but refresh signs immediately after `m{char}`.
  vim.keymap.set("n", "m", function()
    local ch = vim.fn.getcharstr()
    if not ch or ch == "" then
      return
    end
    vim.cmd("normal! m" .. ch)
    refresh_loaded_buffers()
  end, { noremap = true, silent = true, desc = "Set mark and refresh signs" })
end

return M
