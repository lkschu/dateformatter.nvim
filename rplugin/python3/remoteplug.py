import pynvim
from datetime import datetime


@pynvim.plugin
class Limit(object):
    def __init__(self, vim):
        self.vim = vim
        self.calls = 0
        self.defaultformat = "_%Y-%m-%d_"
        self.readformat = "%d-%m-%Y"

    """
    Expects 2 parameters: a date as string and a format string.
    Returns the parsed date, reformated as specified by the defaultformat.
    """
    @pynvim.function('FormatDate', sync=True)
    # def convert_date(self, inp: str, format: str):
    def convert_date(self, args):
        # self.vim.print(f"{args}")
        # return f"{args}"
        assert(len(args)==2)
        inp = args[0]
        format_str = args[1]
        dateobj = datetime.strptime(inp, format_str)
        return dateobj.strftime(self.defaultformat)


    @pynvim.command('Dateformat', range='', nargs='*', sync=True)
    def dateformat(self, args, range):
        print(f"Cc:{args}")
        # self.vim.current.line =  f'Cmd dateformatter: mode: {mode}'
        n = self.vim.funcs.input("Date format: ", "%d-%m-%Y")
        if n == "":
            # self.vim.current.line = "canceled"
            # self.vim.funcs.print("canceled")
            self.vim.print("canceled")
            return
        self.readformat = n

        mode = self.vim.funcs.mode()
        vstart = self.vim.funcs.getcharpos(".")  #-- bufnum, lnum, col, off
        vend = self.vim.funcs.getcharpos("v")  #-- bufnum, lnum, col, off
        if mode == "V":
            vstart[2]=0
            # vend[2]=2147483647 #--TODO: FIXME: this should be maxcol
            vend[2]=64 #--TODO: FIXME: this should be maxcol
        line_min = 0
        line_max = 0
        if vstart[1] > vend[1]:
            line_max = vstart[1]
            line_min = vend[1]
        else:
            line_min = vstart[1]
            line_max = vend[1]
        ret = self.vim.api.buf_get_lines(vstart[0],line_min-1,line_max, True)

        with open("/home/lks/pythonrplugin.log", "w") as f:
            f.writelines([r+"\n" for r in ret])

        col_min = vstart[2]
        col_max = vend[2]
        if vstart[2] > vend[2]:
            col_min = vend[2]-1
            col_max = vstart[2]-1
        for i,e in enumerate(list(ret)):
            line_left = ""
            if col_min >= 1:
                line_left = e[:col_min]
            line_middle = e[col_min:col_max+1]
            line_right = e[col_max+1:]

            ret[i] = f"{line_left}{self.convert_date([line_middle, self.readformat])}{line_right}"

        self.vim.api.buf_set_lines(vstart[0],line_min-1,line_max,True, ret)


    @pynvim.command('Cmd', range='', nargs='*', sync=True)
    def command_handler(self, args, range):
        self._increment_calls()
        self.vim.current.line = (
            'Command: Called %d times, args: %s, range: %s' % (self.calls,
                                                               args,
                                                               range))
    @pynvim.function('Func')
    def function_handler(self, args):
        self._increment_calls()
        self.vim.current.line = (
            'Function: Called %d times, args: %s' % (self.calls, args))
    def _increment_calls(self):
        if self.calls == 5:
            raise Exception('Too many calls!')
        self.calls += 1
