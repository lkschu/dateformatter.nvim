import pynvim
from datetime import datetime


@pynvim.plugin
class Limit(object):
    def __init__(self, vim):
        self.vim = vim
        self.calls = 0
        self.defaultformat = "_%Y-%m-%d_"

    """
    Expects 2 parameters: a date as string and a format string.
    Returns the parsed date, reformated as specified by the defaultformat.
    """
    @pynvim.function('FormatDate', sync=True)
    def convert_date(self, args):
        assert(len(args)==2)
        inp = args[0]
        format_str = args[1]
        dateobj = datetime.strptime(inp, format_str)
        return dateobj.strftime(self.defaultformat)
