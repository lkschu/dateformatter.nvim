import pynvim
from datetime import datetime


@pynvim.plugin
class Limit(object):
    def __init__(self, vim):
        self.vim = vim
        self.defaultformat = "%Y-%m-%dT%H:%M:%S"


    @pynvim.function('FormatDateSetFormat', sync=True)
    def set_format(self, args):
        assert(len(args)==1)
        new_format = args[0]
        self.defaultformat = new_format

    """
    Expects 2 parameters: a date as string and a format string.
    Returns the parsed date, reformated as specified by the defaultformat.
    """
    @pynvim.function('FormatDate', sync=True)
    def convert_date(self, args):
        assert(len(args)==2)
        inp = args[0]
        format_str = args[1]

        if format_str == "%s":
            dateobj = datetime.fromtimestamp(float(inp))
        else:
            dateobj = datetime.strptime(inp, format_str)
        return dateobj.strftime(self.defaultformat)
