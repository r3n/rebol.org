rebol [Title: "Markup language Dialect parser" 
Library: [ level: 'intermediate 
platform: 'all 
type: 'tool 
domain: [xml html markup ] 
tested-under: windows 
support: none 
license: none 
see-also: none ]
 Date: 1-Jan-2001 
Name: 'mdlParser 
Version: 0.0.2 
File: %mdlparser.r 
Home: http://www.rebol.org/ 
Author: "daniel murrill" 
Email: inetw3@mindspring.com 
Owner: "daniel murrill" 
Rights: "Copyright (C) daniel murrill 2000" 
Language: 'English Charset: 'ANSI 
Purpose: { To personally study the practicallity of Rebol
being used as bridge between browsers and markup languages. } 
Comment: { The purpose for this script is to parse xml, xhtml, css, and
html and have it viewable/scriptable in its own  document window. 
This script has been taken from a larger portion that's used in a Rebol browser. 
This script is only prelimanary dialect, there will be lots of changes seeing that 
some of it does not work properly at this time.  If you would like to share 
code to improve the ml parser, email it to the ML (mailing list) so others can learn 
about it too.  Thanks }
 ] 




macros:[
"&amp;" "&" 
"&lt;" "<" 
"&gt;" ">" 
"&quot;" {"} 
"&auml;" "ä" 
"&Auml;" "Ä" 
"&ouml;" "ö" 
"&Ouml;" "Ö" 
"&uuml;" "ü"
"&Uuml" "Ü" 
"&szlig;" "ß" 
]

histobj: []
clean: func [rgbs][
 
  replace/all rgbs {="Aliceblue"} {="#F0F8FF"}  
  replace/all rgbs {="Antiquewhite"} {="#FAEBD7"}
  replace/all rgbs {="Aqua"} {="#00FFFF"}
  replace/all rgbs {="Aquamarine"} {="#7FFFD4"}   
  replace/all rgbs {="Azure"} {="#F0FFFF"}
  replace/all rgbs {="Bisque"} {="#FFE4C4"} 
  replace/all rgbs {="Black"} {="#000000"} 
  replace/all rgbs {="Blueviolet"} {="#8A2BE2"}
  replace/all rgbs {="Blue"} {="#0000ff"}
  replace/all rgbs {="Blanchedalmond"} {="#FFEBCD"}  
  replace/all rgbs {="Burlywood"} {="#DEB887"}    
  replace/all rgbs {="Cadetblue"} {="#5F9EA0"}  
  replace/all rgbs {="Chartreuse"} {="#7FFF00"} 
  replace/all rgbs {="Chocolate"} {="#D2691E"}  
  replace/all rgbs {="Coral"} {="#FF7F50"}
  replace/all rgbs {="Cornflowerblue"} {="#6495ED"} 
  replace/all rgbs {="Cornsilk"} {="#FFF8DC"} 
  replace/all rgbs {="Crimson"} {="#DC143C"} 
  replace/all rgbs {="Cyan"} {="#00FFFF"}  
  replace/all rgbs {="Darkblue"} {="#00008B"} 
  replace/all rgbs {="Darkcyan"} {="#008B8B"}
  replace/all rgbs {="Darkgoldenrod"} {="#B8860B"}
  replace/all rgbs {="Darkgray"} {="#A9A9A9"}
  replace/all rgbs {="Darkgreen"} {="#006400"} 
  replace/all rgbs {="Darkkhaki"} {="#BDB76B"}
  replace/all rgbs {="Darkmagenta"} {="#8B008B"}
  replace/all rgbs {="Darkolivegreen"} {="#556B2F"}
  replace/all rgbs {="Darkorange"} {="#FF8C00"}
  replace/all rgbs {="Darkorchid"} {="#9932CC"}
  replace/all rgbs {="Darkred"} {="#8B0000"}
  replace/all rgbs {="Darksalmon"} {="#E9967A"}
  replace/all rgbs {="Darkseagreen"} {="#8FBC8F"}
  replace/all rgbs {="Darkturquoise"} {="#00CED1"}
  replace/all rgbs {="Darkslateblue"} {="#483D8B"}
  replace/all rgbs {="Darkslategray"} {="#2F4F4F"}
  replace/all rgbs {="Darkviolet"} {="#9400D3"}
  replace/all rgbs {="Deepskyblue"} {="#00BFFF"}   
  replace/all rgbs {="Dimgray"} {="#696969"}
  replace/all rgbs {="Firebrick"} {="#B22222"} 
  replace/all rgbs {="Floralwhite"} {="#FFFAF0"}
  replace/all rgbs {="Forestgreen"} {="#228B22"}
  replace/all rgbs {="Fuchsia"} {="#FF00FF"}
  replace/all rgbs {="Gainsboro"} {="#DCDCDC"}
  replace/all rgbs {="Ghostwhite"} {="#F8F8FF"}
  replace/all rgbs {="Gold"} {="#FFCD28"}
  replace/all rgbs {="Goldenrod"} {="#DAA520"}  
  replace/all rgbs {="Gray"} {="#808080"}  
  replace/all rgbs {="Green"} {="#008000"}
  replace/all rgbs {="Greenyellow"} {="#ADFF2F"}  
  replace/all rgbs {="Honeydew"} {="#F0FFF0"}  
  replace/all rgbs {="Hotpink"} {="#FF69B4"}  
  replace/all rgbs {="Indianred"} {="#CD5C5C"}  
  replace/all rgbs {="Indigo"} {="#4B0082"}  
  replace/all rgbs {="Ivory"} {="#FFFFF0"}  
  replace/all rgbs {="Khaki"} {="#F0E68C"}  
  replace/all rgbs {="Lavender"} {="#E6E6FA"}  
  replace/all rgbs {="Lavenderblush"} {="#FFF0F5"}  
  replace/all rgbs {="Lawngreen"} {="#7CFC00"}  
  replace/all rgbs {="Lemonchiffon"} {="#FFFACD"}  
  replace/all rgbs {="Lightblue"} {="#ADD8E6"}  
  replace/all rgbs {="Lightcoral"} {="#F08080"}  
  replace/all rgbs {="Lightcyan"} {="#E0FFFF"}  
  replace/all rgbs {="Lightgoldenrodyellow"} {="#FAFAD2"}  
  replace/all rgbs {="Lightgreen"} {="#90EE90"}  
  replace/all rgbs {="Lightgrey"} {="#D3D3D3"}  
  replace/all rgbs {="Lightpink"} {="#FFB6C1"}   
  replace/all rgbs {="Lightsalmon"} {="#FFA07A"}  
  replace/all rgbs {="Lightseagreen"} {="#20B2AA"}  
  replace/all rgbs {="Lightskyblue"} {="#87CEFA"}  
  replace/all rgbs {="Lightslategray"} {="#778899"}  
  replace/all rgbs {="Lightyellow"} {="#FFFFE0"}  
  replace/all rgbs {="Lime"} {="#00CD00"}  
  replace/all rgbs {="Limegreen"} {="#32CD32"}  
  replace/all rgbs {="Linen"} {="#FAF0E6"} 
  replace/all rgbs {="Magenta"} {="#FF00FF"} 
  replace/all rgbs {="Maroon"} {="#800000"}  
  replace/all rgbs {="Mediumauqamarine"} {="#66CDAA"}  
  replace/all rgbs {="Mediumblue"} {="#0000CD"}  
  replace/all rgbs {="Mediumorchid"} {="#BA55D3"}  
  replace/all rgbs {="Mediumpurple"} {="#9370D8"}  
  replace/all rgbs {="Mediumseagreen"} {="#3CB371"}  
  replace/all rgbs {="Mediumslateblue"} {="#7B68EE"}  
  replace/all rgbs {="Mediumspringgreen"} {="#00FA9A"}  
  replace/all rgbs {="Mediumturquoise"} {="#48D1CC"}  
  replace/all rgbs {="Mediumvioletred"} {="#C71585"}  
  replace/all rgbs {="Midnightblue"} {="#191970"}  
  replace/all rgbs {="Mintcream"} {="#F5FFFA"}  
  replace/all rgbs {="Mistyrose"} {="#FFE4E1"}    
  replace/all rgbs {="Moccasin"} {="#FFE4B5"}  
  replace/all rgbs {="Navajowhite"} {="#FFDEAD"}  
  replace/all rgbs {="Navy"} {="#000080"}  
  replace/all rgbs {="Olive"} {="#808000"}  
  replace/all rgbs {="Olivedrab"} {="#688E23"}  
  replace/all rgbs {="Orange"} {="#FFA500"}
  replace/all rgbs {="Orangepumpkin"} {="#FFA500"}  
  replace/all rgbs {="Orangered"} {="#FF4500"}  
  replace/all rgbs {="Orchid"} {="#DA70D6"}  
  replace/all rgbs {="Palegoldenrod"} {="#EEE8AA"}  
  replace/all rgbs {="Palegreen"} {="#98FB98"}  
  replace/all rgbs {="Paleturquoise"} {="#AFEEEE"}  
  replace/all rgbs {="Palevioletred"} {="#D87093"}  
  replace/all rgbs {="Papayawhip"} {="#FFEFD5"}  
  replace/all rgbs {="Peachpuff"} {="#FFDAB9"}  
  replace/all rgbs {="Peru"} {="#CD853F"}  
  replace/all rgbs {="Pink"} {="#FFC0CB"}  
  replace/all rgbs {="Palepink"} {="#FFC0CB"} 
  replace/all rgbs {="Plum"} {="#DDA0DD"}  
  replace/all rgbs {="Powderblue"} {="#B0E0E6"}  
  replace/all rgbs {="Purple"} {="#800080"} 
  replace/all rgbs {="Red"} {="#FF0000"}  
  replace/all rgbs {="Rosybrown"} {="#BC8F8F"}  
  replace/all rgbs {="Royalblue"} {="#4169E1"}  
  replace/all rgbs {="Saddlebrown"} {="#8B4513"}  
  replace/all rgbs {="Salmon"} {="#FA8072"}  
  replace/all rgbs {="Sandybrown"} {="#F4A460"}  
  replace/all rgbs {="Seagreen"} {="#2E8B57"}  
  replace/all rgbs {="Seashell"} {="#FFF5EE"}  
  replace/all rgbs {="Sienna"} {="#A0522D"}  
  replace/all rgbs {="Silver"} {="#C0C0C0"}  
  replace/all rgbs {="Skyblue"} {="#87CEEB"}    
  replace/all rgbs {="Slateblue"} {="#6A5ACD"}  
  replace/all rgbs {="Slategray"} {="#708090"}  
  replace/all rgbs {="Snow"} {="#FFFAFA"}  
  replace/all rgbs {="Springgreen"} {="#00FF7F"}  
  replace/all rgbs {="Steelblue"} {="#4682B4"}  
  replace/all rgbs {="Tan"} {="#D2B48C"}  
  replace/all rgbs {="Teal"} {="#008080"}  
  replace/all rgbs {="Thistle"} {="#D8BFD8"}   
  replace/all rgbs {="Tomato"} {="#FF6347"}  
  replace/all rgbs {="Turquoise"} {="#40E0D0"}  
  replace/all rgbs {="Violet"} {="#EE82EE"}  
  replace/all rgbs {="Wheat"} {="#F5DEB3"}
  replace/all rgbs {="White"} {="#FFFFFF"}
  replace/all rgbs {="Whightsmoke"} {="#F5F5F5"}  
  replace/all rgbs {="Yellow"} {="#FFFF00"}  
  replace/all rgbs {="YellowGreen"} {="#9ACD32"}  
  replace/all rgbs {="Base-color"} {="#8F7F6F"}
  replace/all rgbs {="Beige"} {="#FFE4C4"}
  replace/all rgbs {="Brick"} {="#B22222"}
  replace/all rgbs {="Coal"} {="#404040"}
  replace/all rgbs {="Coffee"} {="#4C1A00"}
  replace/all rgbs {="Forest"} {="#003000"}
  replace/all rgbs {="Leaf"} {="#008000"}
  replace/all rgbs {="Maroon"} {="#800000"}
  replace/all rgbs {="Mint"} {="#648874"}
  replace/all rgbs {="Oldrab"} {="#484810"}
  replace/all rgbs {="Papaya"} {="#FF5025"}
  replace/all rgbs {="Pewter"} {="#AAAAAA"}
  replace/all rgbs {="Rebolor"} {="#8E806E"}
  replace/all rgbs {="Sky"} {="#A4C8FF"}
  replace/all rgbs {="Water"} {="#506C8E"}
]

obj: func[this me][
either find n this [select this me][none]

]

rgb: func[bin][
if none? bin [bin: copy "#000000"]
clr: copy bin
either clr: find/match/part clr "#" 6 [
replace clr "#" ""
clr: to-issue clr to-tuple debase/base clr 16][
bin: 250.250.250]
]

bgrd: func[bin][
if none? cpybg [cpybg: "#ffffff"]
if none? bin [bin: copy cpybg]
clr: copy bin 
either clr: find/match/part clr "#" 6 [
clr: to-issue clr 
to-tuple debase/base clr 16][
bin: 250.250.250]
]


prgb: func[bin][if none? bin [bin: copy cpybg]
clr: copy bin
either clr: find/match/part clr "#" 6 [
replace clr "#" ""
clr: to-issue clr to-tuple debase/base clr 16][
clr: copy cpybg
replace clr #"#" ""
reduce clr: to-issue clr 
if error? try [to-tuple debase/base clr 16 ][200.200.200]]
 ]

tdrgb: func[bin][
either none? bin [
if none? bin [ bin: bg]
 if none? bin [bin: remove cpybg]
if none? bin [bin: "ffffff"]
clr: to-issue bin to-tuple debase/base clr 16][
either find bin "#" [
clr: remove bin 
clr: to-issue clr to-tuple debase/base clr 16][
bin: remove cpybg
clr: to-issue bin to-tuple debase/base clr 16
]
] 
]

btnrgb: func[bin][
either none? bin [
if none? bin [bin: copy "#c0c0c0"]
clr: remove bin 
clr: to-issue clr to-tuple debase/base clr 16][
if error? try [clr: remove bin 
clr: to-issue clr to-tuple debase/base clr 16][]
]
] 

tbwdth: func[bin][

checkhd: does [
if nhead = "<hr" [ 
numpair: to-string bin
getbin: parse/all numpair "."
getbin: to-integer getbin/1
bin: to-pair reduce [getbin 1] 
]
]
bn: to-string reduce [{"} bin {?}]
parse bn [[thru {"} copy num to "%" copy struc to {?}]| 
[thru {"} copy num to "px" copy struc to {?}] |
[thru {"} copy num to {?} (struc: "size?" replace num {"} "")]]

if error? try [num: to-integer num
switch struc [
"%"  [wdth: to-integer num bn: wdth * 500 bin: bn / 100 checkhd]
"px" [wdth: to-integer num bin:  wdth * 3 checkhd]
"size?" [wdth: length? text bin:  wdth + 2 *  8 checkhd]
]
][wdth: length? text bin:  wdth + 2 *  8]
bin]

tblalign: func[][  page/size]

parsize: does [psize: length? text 
if psize = none [psize: 1]
either psize > 40 [psize: psize][psize * 8]]

attr: func[bin][
if none? bin [bin: copy "none" ]
switch bin [
"left" [bin: "left"]
"right" [bin: "right"]
"center" [bin: "center"]
"none" [bin: "center"]
]
bin: to-word bin
]

ids: func[bin][
either none? bin: to-string obj n 'id
[][bin: to-string obj n 'id bin: to-set-word bin
]
]

click: func[] [
action: obj n 'onclick
either none? action [action: ""][
replace/all action #"." " "
replace/all action #"{" " {"
replace/all action #"}" "} "
replace/all action #"[" " ["
replace/all action #"]" "] "
replace/all action #"(" ": "
replace/all action #")" ""
insert action {if error? try [}
append action {] []}
]
]

divw: func [bin][
if error? try [bintop: to-integer obj n 'top][bintop: 0]
if error? try [binlft: to-integer obj n 'left][binlft: 0]
bintl: to-pair reduce [bintop binlft]
either bintl = 0x0 [bintl: "" bins: 'across][
]
binx: tbwdth obj n 'width
if none? binx [binx: length? text binx: binx * 8]
biny: tbwdth obj n 'height
if none? biny [biny: length? text biny: biny * 8]
binxy: to-pair reduce [binx biny]
]

btnw: func [bin][
bin: obj n 'size
tbwdth bin
]


getimg: does [
geto: obj n 'src 
if none? geto [geto: ""]

replace/all geto #"=" " "
geto: to-string reduce [{/} geto]
replace geto {//} {/} 
if find/match/part html/text "http://" 7 [
either find/match/part geto "http://" 7 [goto: to-string geto ][
parse/all html/text [to {http://} copy nav 
thru ".com" (geto: to-string reduce [nav geto]
goto: "" )]
parse/all html/text [to {http://} copy nav 
thru ".net" (geto: to-string reduce [nav {/} geto])]
parse/all html/text [to {http://} copy nav 
thru ".org" (geto: to-string reduce [nav {/} geto])]
  ]
] 

either geto/1 = #"/"
[replace geto "/" "" if error? try [
goto: load to-file geto][
either  gotoalt: obj n 'alt [goto: gotoalt][goto: "image"]
]
][goto: load geto]
img ]


getval: func[bin][
either obj n 'value [ 
bin: obj n 'value ][
bin: "none"]
]

setnstyle: func[][insert tail n getstyle]


title: func[][insert xmlview reduce [text 'title ]]
body: func[][ insert xmlview  reduce [1 'space mnb: bgrd  cpybg: obj n 'bgcolor  'backdrop]
]
p: func[][either find text "none" [ insert xmlview  reduce['below ]]
[insert xmlview  reduce[pcolor: prgb obj n 'bgcolor  rgb obj n 'color reduce ['do click ] text   'text ids obj n 'id 'across 0 'space 'below]]]
layer: func[][either text = "none" [insert xmlview reduce [""]][insert xmlview reduce [text txtsize 'text]]]
H1: func[][insert xmlview  reduce ['below
prgb obj n 'bgcolor rgb obj n 'color 24 'font-size text 'text 0 'space 'across 'below]]
H2: func[][insert xmlview  reduce ['below
prgb obj n 'bgcolor rgb obj n 'color 18 'font-size text 'text 0 'space 'across 'below]]
H3: func[][insert xmlview  reduce ['below
prgb obj n 'bgcolor rgb obj n 'color 16 'font-size text 'text 0 'space 'across 'below]]
H4: func[][either text = "none" [""][insert xmlview  reduce ['below
prgb obj n 'bgcolor rgb obj n 'color 'bold 11 'font-size  text 'text 0 'space 'across 'below]]]
H5: func[][insert xmlview  reduce ['below
prgb obj n 'bgcolor rgb obj n 'color 11 'font-size text 'text 0 'space 'across 'below]]
H6: func[][insert xmlview  reduce ['below
prgb obj n 'bgcolor rgb obj n 'color 9 'font-size text 'text 0 'space 'across 'below]]
font: func[][either text = "none" [insert xmlview reduce [ ]][insert xmlview  reduce [-6x0 'pad attr obj n 'align prgb obj n 'bgcolor rgb obj n 'color text tbwdth obj n 'width 'text 1 'space 'across]]]
nfont: func[][insert xmlview  reduce [-8x0 'pad attr obj n 'align prgb obj n 'bgcolor rgb obj n 'color text 'text -8x0 'pad 'across]]
div: func[][divw obj n 'width insert xmlview  reduce [prgb obj n 'bgcolor rgb obj n 'color 'font-color attr obj n 'align 'center reduce ['do click]binxy text 'box ids obj n 'id bintl 'at ]]
ahref: func[][ either text = "none" [][
either find goto ".r" [insert xmlview reduce ['underline rgb obj n 'color [] reduce ['do goto]  text 'text ids obj n 'id  0 'space 'across]][insert xmlview reduce ['underline rgb obj n 'color        [] reduce ['do gohere] rgb obj n 'color 'font-color  text 'text ids obj n 'id  0 'space 'across]]]]
btn1: func[][ insert xmlview  reduce [btnrgb obj n 'bgcolor reduce ['do click ]
btnw obj n 'size  to-file obj n 'src getval obj n 'value 'button ids obj n 'id 'across]]
btn2: func[][insert xmlview  reduce [btnrgb obj n 'bgcolor reduce ['do click ] getval obj n 'value btnw obj n 'size 'field ids obj n 'id 'across]]
img: func[][insert xmlview  reduce  [goto 'image 'across]]
b_: func[][insert xmlview reduce [prgb obj n 'bgcolor 'bold]]
b: func[][either text = "none" [insert xmlview reduce [""]][insert xmlview reduce [prgb obj n 'bgcolor rgb obj n 'color 'bold text 'text 'across]]]
italic: func[][insert xmlview reduce [prgb obj n 'bgcolor rgb obj n 'color 'italic text 'text ]]
br: func[][insert xmlview reduce ['below]]
area: func[][ insert xmlview reduce [200x100 text 'area  to-set-word ids obj n 'id 'across]]
hr: func[][insert xmlview reduce ['white tbwdth obj n 'width 'box 0x0 'pad 'gray tbwdth obj n 'width 'box 'below 0 'space]]
table: func[][ spc: to-integer  obj n 'cellspacing  pd: obj n 'cellpadding tbwdth obj n 'width
insert xmlview reduce ['across 0 'space]] 
tr: func[][insert xmlview reduce ['below ]]
td: func[][  either text = "none" 
[setnstyle][setnstyle
insert xmlview reduce [attr obj n 'align 'center 
prgb obj n 'bgcolor rgb obj n 'color 11 'font-size text 'text 'across]]]
{[size: 1x1 effect: 'bezel] 'edge}
code: func[][replace/all text {&lt;} "<" replace/all text {&gt;} ">" replace/all text {'} {"}
insert xmlview reduce [text 'text ]]
li: func[][insert xmlview reduce [bgrd obj n 'bgcolor rgb obj n 'color text 'text 15x10 '+ 'here 'at  'bold  24 'font-size "." 'text 'guide 'at to-set-word 'here 0x-10 'pad 'across 'below ]]
bq: func[][insert xmlview reduce [prgb obj n 'bgcolor rgb obj n 'color text 'text 0 'space]]
pre: func[][parse markup [thru "<pre>" copy pretext to "</pre>" (
oldpretext: copy pretext
replace/all pretext ">" "&gt;" replace/all pretext "<" "&lt;"

parse/all markup [to oldpretext begin: thru oldpretext ending:(change/part begin pretext ending )]

foreach [old new] macros[
parse/all pretext [some[to old begin: thru old ending:(change/part begin new ending )]skip]
]
insert xmlview reduce [pretext 'text ])] 
]

nl: func [][either text = "none" [insert xmlview 'across 'below][insert xmlview reduce [prgb obj n 'bgcolor rgb obj n 'color text 'text 'across 'below]]]

&nbsp: func [][insert xmlview reduce [prgb cpybg prgb cpybg "&" 'text +8x0 'pad 'across]]


update: does [

 xmlview:  []

mnb: "#ffffff"
cpybg: "#ffffff"
txtsz: 0
goto: ""
gohere: ""
getstyle: ""
text: ""
inparent: false
n: make block! [] 500
var: []
{replace/all markup "<b>" ""}
replace/all  markup "  " " "
replace/all  markup "<hr>" {<hr width="100%">}
replace/all  markup "<hr />" {<hr width="100%">}
replace/all  markup {=submit} {="submit"}
replace/all markup "name=" "id=" 
replace/all markup "background:" "bgcolor:"
replace/all markup "=#ffffff" {="#ffffff"}
replace/all markup "=#000000" {="#000000"}
replace/all markup {=0} {="0"}
replace/all markup "> <" "><"
replace/all markup "&nbsp;" "<&nbsp;>"


parse/all markup [some[to "<p" thru "<p" thru ">" copy pretext to "</p>" (
pretext: to-string pretext getpretext: copy pretext
thistext: replace/all pretext newline reduce [newline "<nl>"]
replace markup getpretext thistext )]
skip]
replace markup {<body>} {<body bgcolor="#ffffff" width="100%">}
replace markup {<table>} {<table bgcolor="#ffffff">}



parse/all markup [any[to "<" copy heads to ">" thru ">" copy text to "<" ( 
if none? text [text: to-string text] replace/all text {"} {'}
foreach [old new] macros[replace/all text  old new ]
this: parse heads "=" 
nhead: to-string this/1 
clear n  {n: [bgcolor "" color "#000000" align ""]}
remove this
this: form this 
replace/all this ";" " "
replace/all this 'style ""
this: parse this ":" 
foreach [key value] this [
insert tail n reduce [attname: to-word key attvalue: value]
 
]


switch nhead [
"<body" [  body inparent: false]
"<nl" [setnstyle getstyle: copy n nl]
"<title" [   title ]
"<p" [getstyle: copy n p inparent: true pstyle: copy n]
"</p" [getstyle: "" setnstyle br inparent: false]
"<font" [setnstyle font getstyle: copy n]
"</font" [setnstyle 
either inparent [getstyle: copy pstyle][
setnstyle getstyle: "" ]]
"<h1" [getstyle: copy n  H1 ]
"</h1" [getstyle: "" setnstyle ]
"<h2" [getstyle: copy n  H2 ]
"</h2" [getstyle: "" setnstyle ]
"<h3" [getstyle: copy n   H3 ]
"</h3" [getstyle: "" setnstyle ]
"<h4" [getstyle: copy n   H4 ]
"</h4" [getstyle: "" setnstyle ]
"<h5" [getstyle: copy n   H5 ]
"</h5" [getstyle: "" setnstyle ]
"<h6" [getstyle: copy n   H6 ]
"</h6" [getstyle: "" ]
"<div" [getstyle: copy n div ]
"</div" [getstyle: "" setnstyle]
"<span" [getstyle: copy n div ]
"</span" [getstyle: "" setnstyle]
"<image" [getimg]
"<img" [ getimg]
"<input" [ getstyle: copy n 
btn: obj n 'type  if btn = "button" [btn1 ]
btn: obj n 'type  if btn = "text" [btn2 ]
btn: obj n 'type  if btn = "input" [btn2 ]
btn: obj n 'type  if btn = "submit" [btn1 ]
btn: obj n 'type  if btn = "password" [btn2 ]
btn: obj n 'type  if btn = "hidden" [{btn2}]
btn: obj n 'type  if btn = "check" [insert xmlview 'check]
btn: obj n 'type  if btn = "radio" [insert xmlview 'radio]
btn: obj n 'type  if btn = "image" [btn1 insert n [value "24"]]
]
"<a" [
replace heads {href=/} {href="}
replace heads {href=} {href="}
replace heads {""} {"}
append heads {"}
parse heads [thru {href="} copy geto to {"}(geto: to-string geto
either find/match/part html/text "http://" 7 [
either find/match/part geto "http://" 7 [goto: geto ]
[goto: to-string reduce [html/text geto] replace goto "com" {com/} replace goto {com//} {com/}]
][geto: to-file geto
either exists? geto [goto: to-string reduce [{%} geto]][goto: "%xmlobject.htm"]
 replace goto "%http://" "http://" replace goto {%/} {%}] 
gohere: to-string reduce ["html/text:" { } goto { }{markup: read html/text update}]
)] setnstyle ahref ]
"<textarea"   [setnstyle area ]
"<b" [setnstyle b 
either inparent [getstyle: copy pstyle][
setnstyle getstyle: "" ]]
{"</b" [setnstyle b_]}
"<i" [setnstyle italic 
either inparent [getstyle: copy pstyle][
setnstyle getstyle: "" ]]
"<br/" [setnstyle p]
"<br" [setnstyle p]
"<&nbsp;" [setnstyle &nbsp ]
"<hr" [text: "none" insert tail n reduce ['width "24px"] hr ]
"<table" [getstyle: copy n table]
"</table" [&nbsp br {insert xmlview reduce [[ 20 gd/2 + 40] 'reduce 'to-pair 'at ]} getstyle: "" ]
"<tr" [setnstyle  getstyle: copy n ]
"</tr" [tr]
"<td" [getstyle: copy n td ] 
"<BLOCKQUOTE" [ "BLOCKQUOTE"  bq]
"<OL" [getstyle: "" ]
"<FRAME" [ "FRAME" ]
"<FORM" [ "FORM"  br]
"<FRAMESET" [ "FRAMESET" ]
"<MARQUEE" [ "MARQUEE" ]
"<BGSOUND" [ "BGSOUND" ]
"<BASE" [ "BASE" ]
"<OBJECT"  [ "OBJECT" ]
"<MAP" [ "MAP" ]
"<CODE" [ code ]
if find heads  "<PRE" [pre]
"<COMMENT" [ "COMMENT" ]
"<li" [li getstyle: copy n ]
"<LISTING" [ "LISTING" ]
"<OL" [setnstyle  "OL" getstyle: copy n]
"<OL" [getstyle: "" ]
"<U" [ "U" ]
"<UL" [ "UL" ]
"<SELECT" [ "SELECT" ]
"<MENU" [ "MENU" ]
"<MENU" [getstyle: "" ]
"<ISINDEX" [ "ISINDEX" ]
"<KBD" [ "KBD" ]
"<DD" [ "DD" ]
"<DFN" [ "DFN" ]
"<DIR" [ "DIR" ]
"<DL" [ "DL" ]
"<DT" [ "DT" ]
"<S>" [ "S" ]
"<SAMP" [ "SAMP" ]
"<SMALL" [ "SMALL" ]
"<STRIKE" [ "STRIKE" ]
"<STRONG" [ "STRONG" ]
"<BIG" [ "BIG" ]
"<SUB" [ "SUB" ]
"<SUP" [ "SUP" ]
"<CITE" [ "CITE" ]
"<TT" [ "TT" ]
"<VAR" [ "VAR" ]
"<XMP" [ "XMP" ]
])
]]
head reverse xmlview
replace/all xmlview [at ""][]
replace/all xmlview [across text "" font][across text "    " font]
replace/all xmlview [below text para [margin: 10x10] across][across]
replace/all xmlview [below text para [margin: 10x10] below][ ]
replace/all xmlview [pad none size none][ ]
replace/all xmlview [space 1 bold][space 1]
replace/all xmlview [space 1 text][text]
replace/all xmlview [bold below across][below across] 
replace/all xmlview [bold across][across] 
replace/all xmlview [bold below][below] 
replace/all xmlview [[to-word bin]][]
replace/all xmlview [text para [margin: 10x10] text][text]
replace/all xmlview [text "none" blue][text "  "]
replace/all xmlview [text text][text]
replace/all xmlview [ text "^/" edge [size: 1x1 effect: 'bezel]][ ]
replace/all xmlview [ text "none" edge [size: 1x1 effect: 'bezel]][ ]
replace/all xmlview [text 0.0.0 255.255.255][ ]
replace/all xmlview [text 16 para [margin: 10x10] "" 0.0.0][ ]
replace/all xmlview [ [] ] [] 
replace/all xmlview [none pad] 'pad
replace/all xmlview [none:] []
replace/all xmlview ["none"] [ ]
replace/all xmlview [[do "no"]] []
replace/all xmlview [0.0.0 0.0.0][0.0.0 255.255.255]
replace/all xmlview [0 blue underline across image "image"][across image "image"]
replace/all xmlview [1 ""] []
replace/all xmlview [%none][ ]
replace/all xmlview [–][]
replace/all xmlview [{'}] [{''}] 
replace/all markup "{p}" "<p>" 
replace/all markup  {"pre"} "<pre>"
replace/all markup "<nl>" ""
replace/all markup "<&nbsp;>" "&nbsp;"


editor/text: markup show editor
document: layout/offset/size xmlview 0x0  550x10000
page/pane: document show page
page/color: mnb show page
pagetitle: getnodename "title"

either find histobj pagetitle [][
append histobj pagetitle
append histobj reduce [to-block xmlview]
replace/all histobj false []
replace/all histobj [[]] []
]
clear xmlview
]

tbar: [backdrop silver space 3 pad -15x-20 text "New" [] text "Open" [] text "Save" [] pad -19x-1 space 0 
box 115x1 gray pad 0x0 
box 115x1 white space 0   below across pad -14x2 
text "Properties" []
below
history: text "" 
pad -19x10 space 0 
box 115x1 gray pad 0x0 
box 115x1 white space 0   below across pad -14x2
text "Exit" []] 100x150 35x85




goedit: layout/size/offset tbar 100x150 90x85
goview: layout/size/offset tbar 100x150 125x85
goinsert: layout/size/offset tbar 100x169 165x85   
gopreview: layout/size/offset tbar 100x150 216x85
goHelp: layout/size/offset tbar 100x150 277x85

document: []
vide: layout [at 0x0 ID: bck: backdrop  gold
across  
ID: t1: text "Html" [editor/text: markup: {<!doctype html public "-//w3c//dtd html 3.2//en">

<html>

<head>
<title>Demo page</title>
<meta name="GENERATOR" content="msgQ/pad 0.0">
<meta name="FORMATTER" content="msgQ/pad 0.0">
</head>

<body bgcolor="#ffffff" text="#000000" link="#0000ff" vlink="#800080" alink="#ff0000">

</body>


</html>} show html show editor update]font-size 12 0.0.0  
ID: t2: text "  " space 9  
ID: t3: text "Rebol"  [editor/text: markup: {REBOL [
    Title:  ""
    Date:   
    Author: ""
    File:   %RT.r
    Email:  you@www.com
    Purpose: {
        }
    Category: []
]} 
show editor if error? try [
do editor/text ][] ]
font-size 12 0.0.0   
ID: t4: text "Text" [editor/text: markup: thist4: {} show editor html/text: "" show html]
font-size 12 0.0.0  
ID: t5: text "Insert" []font-size 12 0.0.0  
ID: t6: text "Preview" []font-size 12 0.0.0 
ID: t8: text "Help" []font-size 12 0.0.0   below pad -19x-5 space 0 
ID: b1: box 549x1 gray pad 0x0 
ID: b2: box 549x1 white space 0   below across pad -14x2 
pad 300x0
Go: button "Go" 30x25 [replace html/text "http://" ""

either find html/text "www" [ 
insert html/text "http://" 
either exists? to-url html/text [
markup: read to-url html/text

][
html/text: "Error: File not found" show html markup: " " ]][
either find html/text "/" [
remove html/text "/"  
either exists? to-File html/text [
markup: read to-file html/text 

][html/text: "Error: File not found" show html markup: " "]  
][
either find html/text {: } [if error? try [do html/text markup: " "][]][markup: " "]
 ]] 
clean markup
show html
editor/text: markup show editor
editor/text
update

]
html: field 193
below
pad -19x3
page: box "msgQ/pad" 195.195.195 200.200.0 edge[size: 1x1 effect: 'inbevel ]  547x200
 
editor: area ivory 547x140 wrap

across

button "Up" 55x20   [if error? try [document/offset/y: document/offset/y + 30 show document][]]
button "Down" 55x20   [if error? try [document/offset/y: document/offset/y - 30 show document][]]
button "View code" 85x20 [clean editor/text markup: copy editor/text
update
]

]
page/pane: "" 

 getnodename: func [tag][
heads: to-string copy tag insert heads "<"
        findtail: parse/all tag " " tails: findtail/1
        tails: to-tag join "/" tails
        parse/all markup 
[
to heads copy nodename to ">" (heads: to-string reduce [nodename">"])
            thru ">" copy text to tails (text: to-string text)
            (parse nodename 
[
some [thru " " copy attname to "=" thru "=" copy attvalue to ">"
] skip
]node: to-string reduce [heads text tails] 
                )
]
]

selectnodes: func [nodename childnode nodevalue /local getchildnode][ 
getchildnode: [] text: copy nodevalue
        heads: to-string reduce ["<" nodename]
        tails: to-string reduce ["</" nodename ">"]
        nodelist: ""  clear getchildnode
      parse markup[
          some [
          to heads copy nodeslist thru tails
          ( append getchildnode nodeslist)]skip
]
          foreach child getchildnode [
                   getnode: find child childnode
                   gettails: find child tails 
                   node: find/part getnode nodevalue gettails
                   either find child node 
[
nodelist: [] append nodelist child
newlist: [] append newlist child
][
]
]
]


    getnodevalue: func [txt] [
text: txt if find markup text 
[
parse/all markup 
[
                thru "<" copy htag to txt copy text to "</"
]
            findtag: copy htag
            setag: find/last findtag "<"
            parse setag [thru "<" copy gethead to ">"]
            sethead: copy gethead
            hds: parse/all sethead " " gettail: copy hds/1
            heads: copy setag
            tails: to-tag copy gettail insert tails "/"
            parse setag 
[
thru " " copy attname to "=" thru "=" copy attvalue
to ">"
]
]
        node: to-string reduce [heads text tails]
        
    ]
    getattribute: func [attrv][
        parse/all markup [some [
to "<" copy heads to attrv
            copy attname to "=" thru {="} copy attvalue 
to {"} 
to ">" thru ">" copy text 
to "</"
]skip
]
        hds: find/last heads "<" 
parse markup 
[
to hds copy heads thru ">"
]
        parse hds 
[
thru "<" copy gettail to " " (trim/all gettail)
]
        tails: to-tag copy gettail insert tails "/"
        node: to-string reduce [heads text tails]
        
]

getid: func[id][
        parse markup [
to "<" copy heads 
to "id=" thru "id="
            to id copy attvalue thru id  
copy endhead to ">" thru ">" copy text 
to "</" (

        hds: find/last heads "<" 
        gettail: parse/all hds " " gettail: gettail/1
        remove gettail
        tails: to-tag copy gettail insert tails "/"
        node: to-string reduce [heads text tails]
        print node) ]

]
 
getattval: func[attrv]
[
        parse markup [some [
to "<" copy findheads to attrv thru attrv copy gettails to ">"
thru ">" copy text to "</"
(heads: to-string reduce [findheads attrv gettails ">"])
]
]
heads: find/last heads "<" 
           parse/all heads [some
[
          to " " copy attribute to {="} thru {="} 
to attrv copy attvalue thru attrv
to {"} 
]skip
]
        
parse heads 
[
thru "<" copy gettail to " " (trim/all gettail)
]
        tails: to-tag copy gettail insert tails "/"
        node: to-string reduce [heads text tails]
        
]

setnode: func [newhead][
newhead: to-string copy newhead 
        insert newhead "<"
        findtail: parse/all newhead " " 
        settail: copy findtail/1 
        remove settail settail/1
        newtail: to-tag to-string reduce ["/" settail]
parse markup [to heads copy oldhead thru text to "</"]
oldhead: find/last oldhead "<"
size: parse/all heads " "
parse markup 
[
to oldhead mark: (replace mark size/1 ""
mark: insert mark newhead) :mark
to tails mark: (replace mark tails ""
mark: insert mark newtail) :mark
]
parse markup 
[
to newhead copy heads to text
]
            parse newhead 
[
thru " " copy attname to "=" thru "=" copy attvalue to end
]clear newhead
]

    setnodevalue: func [newtext][
size: length? text  
parse/all markup [some
[
to heads thru heads to text mark:
             (remove/part mark size 
             mark: insert mark newtext) :mark
(text: mark)]skip
]
]
   setattribute: func [attrvar attrvalue] 
[
findhead: parse/all heads " " 
thishead: to-string findhead/1
        parse markup 
[
to thishead thru thishead
to attname mark: (replace mark attname ""
mark: insert mark attrvar) :mark
to attvalue mark: (replace mark attvalue ""
mark: insert mark attrvalue) :mark
]

        attname: attrvar
        attvalue: attrvalue
]

    getchildnode: func [][
parse markup [
to heads copy childnode to tails (
                replace childnode heads ""
                remove childnode ">"
                replace childnode tails ""
                parse childnode 
[
to "<" copy heads to ">" thru ">" copy text to "<" (text: to-string text)
]
                hds: parse/all heads " " gettail: to-string hds/1
                gettail: remove head gettail
                tails: to-tag copy gettail insert tails "/"
                node: to-string reduce [heads ">" text tails]
                )]
    ]
    getnextsibling: func [][
oldnode: copy/part (find markup text) (find/last markup "</")
        either find oldnode heads [
            parse oldnode 
[
thru text to heads copy nhead thru ">" copy text to "<"
]
            parse nhead 
[
thru " " copy attributename to "=" thru "=" copy attributevalue to ">"
]
            node: to-string reduce [heads text tails]
            
] 
[print reduce 
[
heads "has no sibling...."
]
]
]
    createnode: func [newnode][
tailnode: newnode
        parse markup 
[
to text thru text to tails thru tails objtail: to "<" 
objtext: (change/part objtail reduce [newline newnode newline] :objtext) 
(parse tailnode [some [thru ">" copy text to "</" (getnodevalue text)]])
]
]

    appendnode: func [newnode][
tailnode: newnode
endnode: find/last markup "</" 

        parse markup 
[
objtail: to endnode 
objhead: (append objtail reduce [newnode newline] :objhead 
parse endnode [to "</" copy lastnode thru ">"]
replace markup lastnode ""
append markup lastnode) 
(parse newnode [thru ">" copy text to "</" (getnodevalue text)])
]
]

    removenode: func [][either find markup node [
        replace markup node "    "
        replace markup "^/^/" "^/"
    ][
       print "Node not found"      
   ] 
   ]

vide/size: 550x440
view vide 
halt

