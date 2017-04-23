REBOL [
    title: "HTML Link"
    date: 18-Apr-2010
    file: %html-link.r
    author:  Nick Antonaccio
    purpose: {
        Takes input string containing any number of URLs and outputs a 
        a string with all the web URLs appropriately wrapped as HTML links. 
        Taken from the tutorial at http://re-bol.com
    }
]

bb:  "some text http://guitarz.org http://yahoo.com"
bb_temp: copy bb
append bb_temp " " ; in case the URL doesn't have a trailing space
append bb " "
parse bb [any [thru "http://" copy link to " " (
    replace bb_temp (rejoin [{http://} link]) (rejoin [
    {<a href="} {http://} link {" target=_blank>http://} 
    link {</a>}]))] to end
]
bb: copy bb_temp
print bb