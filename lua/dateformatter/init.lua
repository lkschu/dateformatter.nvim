local M = {}


local P = function (v)
   print(vim.inspect(v))
   return v
end

M.date_input_format = "%d-%m-%Y"

M.dump_text = function ()
   local mode = vim.api.nvim_get_mode().mode
   local vstart = vim.fn.getcharpos(".")  -- bufnum, lnum, col, off
   local vend = vim.fn.getcharpos("v")  -- bufnum, lnum, col, off

   if mode == "V" then
      -- FIXME: line selection is currently broken. requires triming of whitespace,etc if there are less characters then maxcol
      vstart[3]=0
      vend[3]=vim.v.maxcol
      -- print(tostring(vim.v.maxcol))
      -- vim.api.nvim_set_current_line(tostring(vim.v.maxcol))
   end
   local line_min = 0
   local line_max = 0
   if vstart[2] > vend[2] then
      line_max = vstart[2]
      line_min = vend[2]
   else
      line_min = vstart[2]
      line_max = vend[2]
   end
   local ret = vim.api.nvim_buf_get_lines(vstart[1],line_min-1,line_max, true)

   local format_str = vim.fn.input("Date input format: ", M.date_input_format)
   if format_str == "" then
      vim.print("canceled")
      return
   end

   for i,key in ipairs(ret) do
      local col_min = 0
      local col_max = 0
      if vstart[3] > vend[3] then
         col_max = vstart[3]
         col_min = vend[3]
      else
         col_min = vstart[3]
         col_max = vend[3]
      end
      -- shorter stings are handled implicitely
      local line_left = ""
      if col_min > 1 then
        line_left = string.sub(key,1,col_min-1)
      end
      local line_middle = string.sub(key,col_min,col_max)
      -- catch python exceptions from remote plugin
      if pcall(function() line_middle = vim.fn.FormatDate(line_middle, format_str) end) then
      else
         line_middle = "ERROR"
      end

      local line_right = string.sub(key,col_max+1,nil)
      ret[i] = line_left .. line_middle .. line_right
   end

   vim.api.nvim_buf_set_lines(vstart[1],line_min-1,line_max, true, ret)
end


M.set_default_output_format = function ()
   local format_str = vim.fn.input("Date output format: ", "%Y-%m-%d")
   if format_str == "" then
      vim.print("canceled")
      return
   end
   vim.fn.FormatDateSetFormat(format_str)
end
M.set_default_intput_format = function ()
   local format_str = vim.fn.input("Date input format: ", M.date_input_format)
   if format_str == "" then
      vim.print("canceled")
      return
   end
   M.date_input_format = format_str
end


vim.keymap.set({'n', 'v'}, 'mo', M.set_default_output_format, {noremap = true, silent = false})
vim.keymap.set({'n', 'v'}, 'mi', M.set_default_intput_format, {noremap = true, silent = false})
vim.keymap.set({'n', 'v'}, 'mx', M.dump_text, {noremap = true, silent = false})

return M

-- TODO: config/setup function to configure some defaults





