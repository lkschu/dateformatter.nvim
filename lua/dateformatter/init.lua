local M = {}


local P = function (v)
   print(vim.inspect(v))
   return v
end

M.dump_text = function ()
   local mode = vim.api.nvim_get_mode().mode
   local vstart = vim.fn.getcharpos(".")  -- bufnum, lnum, col, off
   local vend = vim.fn.getcharpos("v")  -- bufnum, lnum, col, off

   if mode == "V" then
      vstart[3]=0
      vend[3]=64 --TODO: FIXME: this should be maxcol
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

   local format_str = vim.fn.input("Date format: ", "%d-%m-%Y")
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
      -- TODO: handle shorter strings! (are already handled implicitly, but still?)
      local line_left = ""
      if col_min > 1 then
        line_left = string.sub(key,1,col_min-1)
      end
      local line_middle = string.sub(key,col_min,col_max)
      if pcall(function() line_middle = vim.fn.FormatDate(line_middle, format_str) end) then
      else
         line_middle = "ERROR"
      end

      local line_right = string.sub(key,col_max+1,nil)
      ret[i] = line_left .. line_middle .. line_right
   end

   vim.api.nvim_buf_set_lines(vstart[1],line_min-1,line_max, true, ret)
end




vim.keymap.set({'n', 'v'}, 'mx', M.dump_text, {noremap = true, silent = false})

return M
