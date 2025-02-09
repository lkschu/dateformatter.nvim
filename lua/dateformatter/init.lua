local M = {}


local P = function (v)
   print(vim.inspect(v))
   return v
end

M.dump_text = function ()
   local mode = vim.api.nvim_get_mode().mode
   local opts = {exclusive=false}
   --
   local vstart = vim.fn.getcharpos(".")  -- bufnum, lnum, col, off
   local vend = vim.fn.getcharpos("v")  -- bufnum, lnum, col, off

   if mode == "V" then
      vstart[3]=0
      vend[3]=5 --TODO: FIXME: this should be maxcol
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
   -- TODO: handle "V"


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
      -- TODO: handle shorter strings! (are already handled implicitly)
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
   -- print(table.concat(ret,"--"))
   vim.api.nvim_buf_set_lines(vstart[1],line_min-1,line_max, true, ret)
   -- local set_text_args = {vstart[1],vstart[2]-1,vstart[3]-1,vend[2]-1,vend[3],ret}
   -- -- vim.api.nvim_buf_set_text(vstart[1],vstart[2]-1,vstart[3]-1,vend[2]-1,vend[3],ret)
   -- vim.api.nvim_put(ret,"b",false,false)
end


--- first try, operate NOT on complete lines
M.dump_text_ = function ()
   local mode = vim.api.nvim_get_mode().mode
   local opts = {exclusive=false}
   if mode == "v" or mode == "V" or mode == "\22" then opts.type = mode end
   --
   local vstart = vim.fn.getpos(".")  -- bufnum, lnum, col, off
   local vend = vim.fn.getpos("v")  -- bufnum, lnum, col, off
   local ret = vim.fn.getregion(vstart, vend, opts)

   for i,key in ipairs(ret) do
      local bash_cmd = "date -d'" .. ret[1] .. "' --iso-8601"
      -- local ret_n = os.execute(bash_cmd)
      local handle = io.popen(bash_cmd)
      if handle ~= nil then
         local ret_n = handle:read("*a")
         ret_n = ret_n:gsub('[\n\r]', ' ')
         ret[i] = ret_n
         -- print(ret_n)
      end
   end
   local set_text_args = {vstart[1],vstart[2]-1,vstart[3]-1,vend[2]-1,vend[3],ret}
   -- vim.api.nvim_buf_set_text(vstart[1],vstart[2]-1,vstart[3]-1,vend[2]-1,vend[3],ret)
   vim.api.nvim_put(ret,"b",false,false)




   -- print("mode="..mode..";"..table.concat(ret,"--"))


   -- local vstart = vim.fn.getpos("'<")  -- bufnum, lnum, col, offgetreg
   -- local vend = vim.fn.getpos("'>")  -- bufnum, lnum, col, off
   -- get_text_args = {vstart[1],vstart[2]-1,vstart[3]-1,vend[2]-1,vend[3],{}}
   -- P({vstart = vstart, vend = vend, fn_params = get_text_args })
   -- local texts = vim.api.nvim_buf_get_text(unpack(get_text_args))
   -- -- local texts = vim.api.nvim_buf_get_lines(vstart[1],vstart[2]-1, vend[2], false)
   -- P(texts)
end


vim.keymap.set({'n', 'v'}, 'mx', M.dump_text, {noremap = true, silent = false})
vim.keymap.set({'n', 'v'}, 'mp', '<Cmd>Dateformat<CR>', {noremap = true, silent = false})


return M
