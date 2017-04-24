REBOL [
    File: %demo.r
    Date: 3-sep-2009
    Title: "Demo"
    Author:  Nick Antonaccio
    Purpose: {
        Amazingly small REBOL demo app:  10 useful programs in only 2.5k
        (LESS THAN HALF A PRINTED PAGE OF CODE!): 

             1 - FREEHAND PAINT:  draw and save graphic images
             2 - SNAKE GAME:  eat food, avoid hitting the walls and yourself  
             3 - TILE PUZZLE, "15":  arrange the tiles into alphabetical order
             4 - CALENDAR:  save and view events for any date
             5 - VIDEO:  live webcam video viewer - not just static images
             6 - IPs:  display your LAN and WAN IP addresses
             7 - EMAIL:  read emails from any pop account
             8 - COUNT DAYS:  count the days between 2 selected dates
             9 - PLAY SOUNDS:  Browse your computer for wave files to play
             10 - FTP TOOL:  web site editor (browse folders on your server,
                 click files to edit and save changes back to the server,
                 create and edit new files etc.)

        This example is 100% native REBOL.  No external libraries, images, 
        GUI components, or other resources of any kind are imported.  It runs
        on Windows, Mac, Linux, and any other OS supported by REBOL/View.
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

p: :append kk: :pick r: :random y: :layout q: 'image
z: :if gg: :to-image v: :length? g: :view k: :center-face ts: :to-string
tu: :to-url sh: :show al: :alert rr: :request-date co: :copy g y[style h
btn 150 h"Paint"[g/new k y[s: area black 650x350 feel[engage: func[f a e][
z a = 'over[p pk: s/effect/draw e/offset sh s]z a = 'up[p pk 'line]]]
effect[draw[line]]b: btn"Save"[save/png %a.png gg s al"Saved 'a.png'"]btn
"Clear"[s/effect/draw: co[line]sh s]]]h"Game"[u: :reduce x: does[al join{
SCORE: }[v b]unview]s: gg y/tight[btn red 10x10]o: gg y/tight[btn tan
10x10]d: 0x10 w: 0 r/seed now b: u[q o(((r 19x19)* 10)+ 50x50)q s(((r
19x19)* 10)+ 50x50)]g/new k y/tight[c: area 305x305 effect[draw b]rate 15
feel[engage: func[f a e][z a = 'key[d: select u['up 0x-10 'down 0x10 'left
-10x0 'right 10x0]e/key]z a = 'time[z any[b/6/1 < 0 b/6/2 < 0 b/6/1 > 290
b/6/2 > 290][x]z find(at b 7)b/6[x]z within? b/6 b/3 10x10[p b u[q s(last
b)]w: 1 b/3:((r 29x29)* 10)]n: co/part b 5 p n(b/6 + d)for i 7(v b)1[
either(type?(kk b i)= pair!)[p n kk b(i - 3)][p n kk b i]]z w = 1[clear(
back tail n)p n(last b)w: 0]b: co n sh c]]]do[focus c]]]h"Puzzle"[al{
Arrange tiles alphabetically:}g/new k y[origin 0x0 space 0x0 across style
p button 60x60[z not find[0x60 60x0 0x-60 -60x0]face/offset - x/offset[
exit]tp: face/offset face/offset: x/offset x/offset: tp]p"O"p"N"p"M"p"L"
return p"K"p"J"p"I"p"H"return p"G"p"F"p"E"p"D"return p"C"p"B"p"A"x: p
white edge[size: 0]]]h"Calendar"[do bx:[z not(exists? %s)[write %s ""]rq:
rr g/new k y[h5 ts rq aa: area ts select to-block(find/last(to-block read
%s)rq)rq btn"Save"[write/append %s rejoin[rq" {"aa/text"} "]unview do bx]]
]]h"Video"[wl: tu request-text/title/default"URL:"join"http://tinyurl.com"
"/m54ltm"g/new k y[image load wl 640x480 rate 0 feel[engage: func[f a e][
z a = 'time[f/image: load wl show f]]]]]h"IPs"[parse read tu join"http://"
"guitarz.org/ip.cgi"[thru<title>copy my to</title>]i: last parse my none
al ts rejoin["WAN: "i" -- LAN: "read join dns:// read dns://]]h"Email"[
g/new k y[mp: field"pop://user:pass@site.com"btn"Read"[ma: co[]foreach i
read tu mp/text[p ma join i"^/^/^/^/^/^/"editor ma]]]]h"Days"[g/new k y[
btn"Start"[sd: rr]btn"End"[ed: rr db/text: ts(ed - sd)show db]text{Days
Between:}db: field]]h"Sounds"[ps: func[sl][wait 0 rg: load sl wf: 1 sp:
open sound:// insert sp rg wait sp close sp wf: 0]wf: 0 change-dir
%/c/Windows/media do wl:[wv: co[]foreach i read %.[z %.wav = suffix? i[p
wv i]]]g/new k y[ft: text-list data wv[z wf <> 1[z error? try[ps value][al
"Error"close sp wf: 0]]]btn"Dir"[change-dir request-dir do wl ft/data: wv
sh ft]]]h{FTP}[g/new k y[px: field"ftp://user:pass@site.com/folder/"[
either dir? tu va: value[f/data: sort read tu va sh f][editor tu va]]f:
text-list[editor tu join px/text value]btn"?"[al{Type a URL path to browse
(nonexistent files are created). Click files to edit.}]]]]
