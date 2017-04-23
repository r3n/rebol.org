Rebol [
	title: "Supercalculator"
	author: "Massimiliano Vessi"
	date:  17/02/2010
	email: maxint@tiscali.it
	file: %supercalculator.r
	Purpose: {"Scientific calculator in Rebol!"}
	;following data are for www.rebol.org library
	;you can find a lot of rebol script there
	library: [ 
		level: 'beginner 
		platform: 'all 
		type: [tutorial  tool] 
		domain: [vid gui  text-processing ui user-interface scientific] 
		tested-under: [windows linux] 
		support: none 
		license: [gpl] 
		see-also: none 
		] 
	version: 2.7.15
	]

;FOREWORDS
;I wrote this scientific calculatur with only 200 lines of code (1-2 hours), all the rest is RebGUI code (about 5850 lines),
;I used RebGUI, but I could use VID reducing to the original 200 lines of code.
;but RebGui is more beautiful than VID...
;no other langage make people capable of writing a scientific calculatoin 2 hours or less.

	
;*******REBGUI SCRIPT for beautifull BUTTON**********
;******REBOL[Title: "RebGUI" Version: 218]***********
;**************START*********************************



system/locale: make system/locale[
colors:[black navy blue violet forest maroon coffee purple reblue coal oldrab red brick crimson leaf brown aqua teal magenta sienna water olive papaya mint gray rebolor green orange pewter base-color khaki cyan tan silver pink sky gold wheat yellow yello beige snow linen ivory white]
words:[]
language: "English" 
dictionary: none 
dict: none
]
win-offset?: make function![
"Returns the offset of a face within its window." 
face[object!]
/local xy
][
xy: 0x0 
while[face/parent-face][
xy: xy + face/offset 
face: face/parent-face 
if face/edge[xy: xy + face/edge/size]
]
xy
]
within?: make function![
{Return TRUE if the point is within the rectangle bounds.} 
point[pair!]"XY position" 
offset[pair!]"Offset of area" 
size[pair!]"Size of area"
][
all[
point/x >= offset/x 
point/y >= offset/y 
offset/x + size/x > point/x 
offset/y + size/y > point/y
]
]
ctx-rebgui: make object![
OS: switch fourth system/version[2['Mac]3['Win]true['Nix]]
build: 218 
view*: system/view 
screen*: view*/screen-face 
locale*: system/locale 
screen*/color: screen*/edge: screen*/font: screen*/para: screen*/feel: none 
view*/VID: 
view*/popface-feel: 
view*/popface-feel-nobtn: 
view*/popface-feel-away: 
view*/popface-feel-away-nobtn: 
view*/popface-feel-win: 
view*/popface-feel-win-nobtn: 
view*/popface-feel-win-away: 
view*/popface-feel-win-away-nobtn: none 
second-last: make function![
"Returns the second last value of a series." 
block[block!]
][
pick tail block -2
]
range: make function![
"Returns a number bounded by floor and ceiling." 
floor[integer!]
ceiling[integer!]
number[integer! decimal!]
][
max floor min ceiling number
]
sjoin: make function![
"Concatenates values." 
value "Base value" 
rest "Value or block of values"
][
either series? value[
make type? value reduce[value rest]
][
make string! reduce[value rest]
]
]
srejoin: make function![
"Reduces and joins a block of values." 
block[block!]"Values to reduce and join"
][
either empty? block: reduce block[block][
make either series? first block[type? first block][string!]block
]
]
span-resize: make function![face[object!]delta[pair!]][
if face/span[
face/old-size: face/size 
all[find face/span #X face/offset/x: face/offset/x + delta/x]
all[find face/span #Y face/offset/y: face/offset/y + delta/y]
all[find face/span #W face/size/x: face/size/x + delta/x]
all[find face/span #H face/size/y: face/size/y + delta/y]
all[face/type <> 'face-iterator face/old-size <> face/size object? get in face 'action face/action/on-resize face]
]
any[
all[block? get in face 'pane foreach f face/pane[span-resize f delta]]
all[object? get in face 'pane span-resize face/pane delta]
]
]
span-R: 0 
span-init: make function![face[object!]size[pair!]margin[pair!]][
if face/span[
if find face/span #L[
face/size/x: size/x - face/offset/x - margin/x 
all[face/type <> 'face-iterator get in face 'action face/action/on-resize face]
]
if find face/span #V[
face/size/y: size/y - face/offset/y - margin/y 
all[face/type <> 'face-iterator get in face 'action face/action/on-resize face]
]
either find face/span #R[
span-R: face/offset/x 
face/offset/x: size/x - face/size/x - margin/x 
span-R: face/offset/x - span-R
][
all[
find face/span #O 
face/offset/x: face/offset/x + span-R
]
]
]
any[
all[block? get in face 'pane either face/type = 'tab-panel[
foreach f face/pane[span-init f face/size 0x0]
][
foreach f face/pane[span-init f face/size face/pane/1/offset]
]
]
all[object? get in face 'pane span-init face/pane face/size face/pane/offset]
]
]
words:[after at bold button-size data disable do edge effect feel field-size font indent italic label-size margin on on-alt-click on-away on-click on-dbl-click on-edit on-focus on-key on-over on-resize on-scroll on-time on-unfocus options pad para rate return reverse space text-color text-size tight underline]
select-face: make function![face][
face/font/color: colors/edit 
set-color face colors/theme/3
]
deselect-face: make function![face /no-show][
face/font/color: colors/text 
set-color/no-show/deselect face none 
unless no-show[show face]
]
attribute-old-color?: make function![
face 
/only "Return true if present but none"
][
all[in face 'old-color any[face/old-color either only[true][none]]]
]
colors: make object![
page: either OS = 'Mac[232.232.232][white]
edit: white 
text: black 
true: leaf 
false: red 
link: blue 
theme:[165.217.246 0.105.207 0.55.155]
outline:[207.207.207 160.160.160 112.112.112]
]
sizes: make object![
cell: 4 
font: 12 
font-height: none 
gap: 2 
line: cell * 5 
margin: 4 
slider: cell * 4 
gap-size: cell * as-pair gap gap 
margin-size: cell * as-pair margin margin
]
behaviors: make object![
action-on-enter:[drop-list edit-list field password spinner]
action-on-tab:[field]
caret-on-focus:[area]
hilight-on-focus:[edit-list field password spinner]
tabbed:[area button drop-list edit-list field password spinner table text-list tree]
]
effects: make object![
radius: either OS = 'Mac[to integer! sizes/line / 2][2]
font: select[Mac "Lucida Grande" Win "Verdana" Nix "Helvetica"]OS 
splash-delay: 1 
window: none
]
on-error: make object![
email: none 
subject: "RebGUI Error Report"
]
fonts: copy[]
on-fkey: make object![
f1: f2: f3: f4: f5: f6: f7: f8: f9: f10: f11: f12: none
]
disable-widgets: copy[]
edit: make object![
siblings: none 
caret: none 
letter: make bitset![#"A" - #"Z" #"a" - #"z" #"'"]
capital: make bitset![#"A" - #"Z"]
other: negate letter 
edits: make function![
words[block!]
/local result ln w
][
result: copy[]
foreach word words[
repeat n ln: length? word[
insert tail result head remove at copy word n
]
repeat n ln - 1[
insert tail result head change change at copy word n pick word n + 1 pick word n
]
foreach ch "abcdefghijklmnopqrstuvwxyz"[
repeat n ln[
poke w: copy word n ch 
insert tail result w
]
repeat n ln + 1[
insert tail result head insert at copy word n ch
]
]
]
result
]
lookup-word: make function![
word[string!]
/local result
][
any[
not empty? result: intersect locale*/dict make hash! word: reduce[word]
not empty? result: intersect locale*/dict make hash! edits word 
result: word
]
sort result
]
insert?: true 
keymap:[
#"^H" back-char 
#"^~" del-char 
#"^M" enter 
#"^A" all-text 
#"^C" copy-text 
#"^X" cut-text 
#"^V" paste-text 
#"^T" clear-tail 
#"^Z" undo 
#"^Y" redo 
#"^[" undo-all 
#"^S" spellcheck 
#"^/" ctrl-enter
]
hilight-text: make function![start end][
view*/highlight-start: start 
view*/highlight-end: end
]
hilight-all: make function![face][
either empty? face/text[unlight-text][
view*/highlight-start: head face/text 
view*/highlight-end: tail face/text
]
]
unlight-text: make function![][
view*/highlight-start: view*/highlight-end: none
]
hilight?: make function![][
all[
object? view*/focal-face 
string? view*/highlight-start 
string? view*/highlight-end 
not zero? offset? view*/highlight-end view*/highlight-start
]
]
hilight-range?: make function![/local start end][
start: view*/highlight-start 
end: view*/highlight-end 
if negative? offset? start end[start: end end: view*/highlight-start]
reduce[start end]
]
tabbed?: make function![
face[object!]
][
all[
face/show? 
find behaviors/tabbed face/type 
face
]
]
group?: make function![
face[object!]
][
all[
face/show? 
in face 'group 
get in face 'group
]
]
child?: make function![
face[object!]
][
any[
attempt[all[face/parent-face/parent-face/type = 'tab-panel face/parent-face/parent-face]]
all[in face/parent-face 'group face/parent-face]
]
]
unfocus: make function![/local face][
if face: view*/focal-face[
if all[
face/type <> 'face 
face/action 
get in face/action 'on-unfocus
][
unless face/action/on-unfocus face[return false]
]
all[
view*/caret 
in face 'caret 
face/caret: index? view*/caret
]
switch face/type[
button[face/feel/over face off 0x0]
drop-list[face/feel/over face off 0x0]
]
]
view*/focal-face: view*/caret: none 
unlight-text 
all[face show face]
true
]
copy-selected-text: make function![/local start end][
if hilight?[
set[start end]hilight-range? 
write clipboard:// copy/part start end 
true
]
]
delete-selected-text: make function![/local start end][
if hilight?[
set[start end]hilight-range? 
remove/part start end 
view*/caret: start 
view*/focal-face/line-list: none 
unlight-text 
true
]
]
cut-text: make function![][
undo-add face 
copy-selected-text face 
delete-selected-text
]
paste-text: make function![][
undo-add face 
delete-selected-text 
face/line-list: none 
view*/caret: insert view*/caret read clipboard://
]
undo-max: 20 
undo-add: make function![face][
if in face 'undo[
insert clear face/undo at copy face/text index? view*/caret 
if all[undo-max undo-max < length? head face/undo][remove head face/undo]
face/undo: tail face/undo
]
]
undo-get: make function![face][
face/text: head view*/caret: first face/undo 
face/line-list: none 
remove face/undo
]
word-limits: make bitset! { 
^-^M/[](){}"} 
word-limits: reduce[word-limits complement word-limits]
current-word: make function![str[string!]/local s ns][
set[s]word-limits 
s: any[all[s: find/reverse str s next s]head str]
set[ns]word-limits 
ns: any[find str ns tail str]
hilight-text s ns 
show view*/focal-face
]
next-word: make function![str /local s ns][
set[s ns]word-limits 
any[all[s: find str s find s ns]tail str]
]
back-word: make function![str /local s ns][
set[s ns]word-limits 
any[all[ns: find/reverse str ns ns: find/reverse ns s next ns]head str]
]
end-of-line: make function![str][
any[find str "^/" tail str]
]
beg-of-line: make function![str /local nstr][
either nstr: find/reverse str "^/"[next nstr][head str]
]
next-field: make function![face /wrap /local f g][
foreach sibling either wrap[face/parent-face/pane][find/tail face/parent-face/pane face][
case[
g: group? sibling[
return next-field/wrap first g
]
sibling/type = 'face[
all[
find[table text-list tree]face/parent-face/parent-face/type 
return next-field face/parent-face/parent-face
]
]
tabbed? sibling[return sibling]
]
]
unless all[
f: child? face 
face <> f 
return next-field f
][
next-field/wrap face
]
]
back-field: make function![face /wrap /local f siblings][
siblings: reverse compose[(face/parent-face/pane)]
unless wrap[siblings: find/tail siblings face]
foreach sibling siblings[
case[
g: group? sibling[
return back-field/wrap first g
]
sibling/type = 'face[
all[
find[table text-list tree]face/parent-face/parent-face/type 
return back-field face/parent-face/parent-face
]
]
tabbed? sibling[return sibling]
]
]
unless all[
f: child? face 
face <> f 
return back-field f
][
back-field/wrap face
]
]
keys-to-insert: make bitset! #{
01000000FFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
} 
insert-char: make function![face char][
delete-selected-text 
unless any[insert? tail? view*/caret "^/" = first view*/caret][remove view*/caret]
insert view*/caret char 
view*/caret: next view*/caret
]
move: make function![event ctrl plain][
either event/shift[
any[view*/highlight-start view*/highlight-start: view*/caret]
][unlight-text]
view*/caret: either event/control ctrl plain 
if event/shift[
either view*/caret = view*/highlight-start[unlight-text][view*/highlight-end: view*/caret]
]
]
move-y: make function![face delta /local pos tmp tmp2][
tmp: offset-to-caret face 0x2 + delta + pos: caret-to-offset face view*/caret 
tmp2: caret-to-offset face tmp 
either tmp2/y <> pos/y[tmp][view*/caret]
]
edit-text: make function![
face event 
/local key edge para caret scroll page-up page-down face-size
][
face-size: face/size - either face/edge[2 * face/edge/size][0]
key: event/key 
if char? key[
either find keys-to-insert key[
undo-add face 
insert-char face key
][key: select keymap key]
]
if word? key[
page-up:[move-y face face-size - sizes/font-height - sizes/font-height * 0x-1]
page-down:[move-y face face-size - sizes/font-height * 0x1]
switch key[
left[move event[back-word view*/caret][back view*/caret]]
right[move event[next-word view*/caret][next view*/caret]]
up[move event page-up[move-y face sizes/font-height * 0x-1]]
down[move event page-down[move-y face sizes/font-height * 0x1]]
page-up[move event[head view*/caret]page-up]
page-down[move event[tail view*/caret]page-down]
home[move event[head view*/caret][beg-of-line view*/caret]]
end[move event[tail view*/caret][end-of-line view*/caret]]
insert[either event/shift[paste-text][insert?: complement insert?]]
back-char[
undo-add face 
any[
delete-selected-text 
head? view*/caret 
either event/control[
tmp: view*/caret 
remove/part view*/caret: back-word tmp tmp
][remove view*/caret: back view*/caret]
]
]
del-char[
undo-add face 
either event/shift[unless face/type = 'password[cut-text]][
any[
delete-selected-text 
tail? view*/caret 
either event/control[
remove/part view*/caret back next-word view*/caret 
if tail? next view*/caret[remove back tail view*/caret]
][remove view*/caret]
]
]
]
enter[
either find behaviors/action-on-enter face/type[
all[face/type = 'spinner face/action/on-unfocus face]
set-focus face 
face/action/on-click face
][
undo-add face 
insert-char face "^/"
]
]
ctrl-enter[undo-add face insert-char face tab]
all-text[hilight-all face]
copy-text[unless face/type = 'password[copy-selected-text face unlight-text]]
cut-text[unless face/type = 'password[cut-text]]
paste-text[paste-text]
clear-tail[
undo-add face 
remove/part view*/caret end-of-line view*/caret
]
undo[
if all[in face 'undo not head? face/undo][
insert face/undo at copy face/text index? view*/caret 
face/undo: back face/undo 
undo-get face
]
]
redo[
if all[in face 'undo not tail? face/undo][
face/undo: insert face/undo at copy face/text index? view*/caret 
undo-get face
]
]
undo-all[
if in face 'esc[
clear face/text 
all[in face 'undo clear face/undo]
all[string? face/esc insert face/text face/esc]
view*/caret: tail face/text
]
]
spellcheck[
request-spellcheck face
]
]
]
edge: face/edge 
para: face/para 
scroll: face/para/scroll 
error? try[
caret: caret-to-offset face view*/caret 
if caret/y < (edge/size/y + para/origin/y + para/indent/y)[
scroll/y: round/to scroll/y - caret/y sizes/font-height
]
if caret/y > (face-size/y - sizes/font-height)[
scroll/y: round/to (scroll/y + ((face-size/y - sizes/font-height) - caret/y)) sizes/font-height
]
unless para/wrap?[
if caret/x < (edge/size/x + para/origin/x + para/indent/x)[
scroll/x: scroll/x - caret/x + (edge/size/x + para/origin/x + para/indent/x)
]
if caret/x > (face-size/x - para/margin/x)[
scroll/x: scroll/x + (face-size/x - para/margin/x - caret/x)
]
]
if scroll <> face/para/scroll[
face/para/scroll: scroll 
if face/type = 'area[face/key-scroll?: true]
]
]
show face
]
feel: make object![
redraw: detect: over: none 
engage: make function![face act event /local txt][
switch act[
key[
unless all[get in face/action 'on-key not face/action/on-key face event][
txt: copy face/text 
edit-text face event 
all[
get in face/action 'on-edit 
strict-not-equal? txt face/text 
face/action/on-edit face
]
]
]
down[
either event/double-click[
all[view*/caret not empty? view*/caret current-word view*/caret]
][
either face = view*/focal-face[
unlight-text 
view*/caret: offset-to-caret face event/offset 
show face
][
caret: offset-to-caret face event/offset 
set-focus face
]
]
]
over[
unless view*/caret = offset-to-caret face event/offset[
unless view*/highlight-start[view*/highlight-start: view*/caret]
view*/highlight-end: view*/caret: offset-to-caret face event/offset 
show face
]
]
alt-up[face/action/on-alt-click face]
scroll-line[face/action/on-scroll face event/offset]
scroll-page[face/action/on-scroll/page face event/offset]
]
]
]
]
view*/window-feel: make object![
redraw: none 
detect: make function![face event /local f][
all[
view*/pop-face 
view*/pop-face/type = 'modal 
view*/pop-face <> face 
exit
]
all[
find[down alt-down up alt-up]event/type 
all[
view*/pop-face 
view*/pop-face/type = 'choose 
not within? event/offset (win-offset? view*/pop-face) - as-pair 0 sizes/line view*/pop-face/size + as-pair 0 sizes/line 
hide-popup
]
view*/focal-face 
not within? event/offset win-offset? view*/focal-face view*/focal-face/size 
unless edit/unfocus[exit]
]
switch event/type[
key[
case[
event/key = #"^-"[
if view*/focal-face[
f: either event/shift[edit/back-field view*/focal-face][edit/next-field view*/focal-face]
all[
find behaviors/action-on-tab view*/focal-face/type 
get in view*/focal-face 'action 
view*/focal-face/action/on-click view*/focal-face
]
all[:f set-focus f]
exit
]
]
find[#" " #"^M"]event/key[
all[
view*/focal-face view*/focal-face/type = 'button 
get in view*/focal-face 'action 
view*/focal-face/action/on-click view*/focal-face 
exit
]
]
all[
find[f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12]event/key 
get in on-fkey event/key 
on-fkey/(event/key) face event 
exit
]
any[not view*/focal-face view*/focal-face/type = 'button][
either f: select face/data event/key[
all[
get f 'action 
f/action/on-click f 
exit
]
][
if event/key = #"^["[
unless empty? view*/pop-list[hide-popup exit]
all[1 = length? screen*/pane exit]
all[get in face 'action not face/action face exit]
all[
face = pick screen*/pane 1 1 <> length? screen*/pane 
either confirm "Do you really want to quit?"[quit][exit]
]
undisplay face 
exit
]
]
]
]
]
resize[
all[face/size <> face/span-size span-resize face face/size - face/span-size]
show face 
face/span-size: face/size 
exit
]
close[
if view*/focal-face[view*/focal-face: view*/caret: none edit/unlight-text]
all[get in face 'action not face/action face exit]
all[face/type = 'modal hide-popup exit]
all[
face = pick screen*/pane 1 1 <> length? screen*/pane 
either confirm "Do you really want to quit?"[quit][exit]
]
]
]
event
]
over: none 
engage: none
]
functions: make object![
clear-text: make function![
{Clear text attribute of a widget or block of widgets.} 
face[object! block!]
/no-show "Don't show" 
/focus
][
foreach f reduce either object? face[[face]][face][
unless f/parent-face/type = 'disable[
if string? f/text[
clear f/text 
all[f/type = 'area f/para/scroll: 0x0 f/pane/data: 0]
f/line-list: none
]
]
]
unless no-show[
either all[focus object? face][set-focus face][show face]
]
]
disable: make function![
"Disable a widget." 
face[object! block!]
][
foreach f reduce either object? face[[face]][face][
unless 'disable = f/parent-face/type[
change find f/parent-face/pane f make widgets/baseface[
type: 'disable 
offset: f/offset 
size: f/size 
span: all[f/span copy f/span]
pane: reduce[
f 
make widgets/baseface[
size: f/size 
span: all[
f/span 
case[
all[find f/span #"H" find f/span #"H"][#HW]
find f/span #"H"[#H]
find f/span #"W"[#W]
]
]
effect:[merge colorize 224.224.224]
]
]
data: all[f/span copy f/span]
feel: action: none
]
f/offset: 0x0 
if f/span[
remove find f/span #"X" 
remove find f/span #"Y"
]
show f/parent-face
]
]
]
display: make function![
{Displays widgets in a centered window with a title.} 
title[string!]"Window title" 
spec[block!]"Block of widgets, attributes and keywords" 
/dialog "Modal dialog with /parent & /close options" 
/parent "Force parent to be last window (default is first)" 
/close closer[block!]"Handle window close event" 
/offset xy[pair!]"Offset of window on screen" 
/maximize "Maximize window" 
/no-wait "Don't wait if a dialog (used by request-progress)"
][
foreach window screen*/pane[all[title = window/text exit]]
spec: layout spec 
spec/text: title 
spec/feel: view*/window-feel 
all[offset spec/offset: xy]
all[close spec/action: make function![face /local var]closer]
all[
not empty? screen*/pane 
insert tail spec/options reduce[
'parent 
either any[dialog parent][last screen*/pane][first screen*/pane]
]
]
either maximize[
insert tail spec/options 'resize 
spec/changes:[maximize]
][
foreach face spec/pane[
all[
face/span 
not empty? intersect face/span #HWXY 
insert tail spec/options 'resize 
break
]
]
]
all[
find spec/options 'resize 
insert tail spec/options reduce['min-size spec/size + view*/title-size + view*/resize-border]
]
all[
dialog 
spec/type: 'modal 
insert tail view*/pop-list view*/pop-face: spec
]
insert tail screen*/pane spec 
show screen* 
disable disable-widgets 
either all[dialog not no-wait][wait[]][spec]
]
do-events: make function![
"Process all Display events." 
/email address[email!]"Specify an email address to send errors to." 
/local *error
][
all[
email 
on-error/email: address
]
if error? set/any '*error try[
wait[]
][request-error *error]
]
enable: make function![
"Enable a widget." 
face[object! block!]
][
foreach f reduce either object? face[[face]][face][
if 'disable = f/parent-face/type[
f: f/parent-face 
f/pane/1/offset: f/offset 
f/pane/1/span: f/data 
change find f/parent-face/pane f f/pane/1 
show f/parent-face
]
]
]
examine: make function![
"Prints information about widgets and attributes." 
'widget 
/indent "Indent output as an MD2 ready string" 
/no-print "Do not print output to console" 
/local string tmp blk funcs
][
unless word? widget[widget: to word! widget]
unless find tmp: next find first widgets 'choose widget[
print "Unknown widget. Supported widgets are:^/" 
foreach widget tmp[print join "^-" widget]
exit
]
widget: widgets/:widget 
string: replace/all trim/head copy widget/options "^/" "^/^-" 
replace/all string "[" join " " "[" 
replace/all string "]" join "]" " " 
replace/all string "^- " "^-" 
replace/all string " ^/" "^/" 
replace string "^-DESCRIPTION:" "^/DESCRIPTION:" 
replace string "^-OPTIONS:" "^/OPTIONS:" 
insert tail string {

ATTRIBUTES:} 
foreach attribute skip first widgets/baseface 3[
if all[
not find[show? options face-flags feel action]attribute 
get tmp: in widget attribute
][
tmp: either find["function" "object" "block" "bitset"]form type? get tmp[join type? get tmp "!"][mold get tmp]
insert tail string rejoin[
"^/^-" 
head insert/dup tail form attribute " " 16 - length? form attribute 
tmp
]
]
]
if all[widget/feel widget/feel <> widgets/default-feel][
insert tail string "^/^/PREDEFINED FEELS:" 
foreach attribute next first widgets/default-feel[
if get in widget/feel attribute[
insert tail string join "^/^-" attribute
]
]
]
if all[widget/action widget/action <> widgets/default-action][
insert tail string "^/^/PREDEFINED ACTIONS:" 
foreach attribute next first widgets/default-action[
if get in widget/action attribute[
insert tail string join "^/^-" attribute
]
]
]
funcs: copy[]
unless empty? blk: difference first widgets/baseface first widget[
insert tail string "^/^/EXTENDED ATTRIBUTES:" 
foreach attribute blk[
if tmp: in widget attribute[
either all[attribute <> 'init function? get tmp][
insert tail funcs attribute
][
tmp: either find["object" "block" "bitset" "function"]form type? get tmp[join type? get tmp "!"][mold get tmp]
insert tail string rejoin["^/^-" head insert/dup tail form attribute " " 16 - length? form attribute tmp]
]
]
]
]
unless empty? funcs[
insert tail string "^/^/ACCESSOR FUNCTIONS:" 
foreach attribute funcs[
tmp: copy "" 
foreach w third get in widget attribute[
all[word? w insert tail tmp join " " w]
if refinement? w[
either w = /local[break][insert tail tmp join " /" w]
]
]
insert tail string rejoin["^/^-" uppercase form attribute tmp]
]
]
if indent[
replace/all string "^/" "^/^-" 
replace/all string "^-^/" "^/" 
insert string "^-"
]
if no-print[
replace/all string "^-" "    "
]
either any[indent no-print][string][print string]
]
get-fonts: make function![
"Obtain list of fonts on supported platforms." 
/cache file[file!]"Obtain fonts from file" 
/local s
][
all[cache exists? file][insert clear fonts unique load file]
if empty? fonts[
either OS = 'Win[
call/output {reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"} s: copy "" 
s: skip parse/all s "^-^/" 4 
request-progress/title (length? s) / 3[
foreach[fn reg style]s[
fn: trim first parse/all fn "(" 
all[
not find fonts fn 
not find["Estrangelo Edessa" "Gautami" "Latha" "Mangal" "Mv Boli" "Raavi" "Shruti" "Tunga"]fn 
not find fn " Bold" 
not find fn " Italic" 
not find fn " Black" 
not find fn "WST_" 
insert tail fonts fn
]
wait 0.01 
step
]
]"Loading fonts ..."
][
call/output "fc-list" s: copy "" 
s: parse/all s ":^/" 
request-progress/title (length? s) / 2[
foreach[fn style]s[
all[
not find fonts fn 
(size-text make widgets/gradface[text: "A" font: make font[name: fn size: 10]]) <> 
size-text make widgets/gradface[text: "A" font: make font[name: fn size: 12 style: 'bold]]
insert tail fonts fn
]
wait 0.01 
step
]
]"Loading fonts ..."
]
]
sort fonts
]
get-values: make function![
{Gets values from input widgets within a display or grouping widget.} 
face[object!]"Display face" 
/type "Precede each value with its type" 
/local blk
][
blk: copy[]
foreach widget either in face 'group[face/group][face/pane][
if find[
area 
calendar 
check 
check-group 
drop-list 
edit-list 
field 
group-box 
led 
led-group 
panel 
password 
progress 
radio-group 
scroll-panel 
sheet 
slider 
spinner 
tab-panel 
table 
text-list 
tool-bar 
tree
]widget/type[
all[type insert tail blk widget/type]
insert/only tail blk case[
find[area drop-list edit-list field password]widget/type[widget/text]
find[calendar check check-group led led-group progress slider spinner]widget/type[widget/data]
find[radio-group table text-list tree]widget/type[widget/picked]
true[either type[get-values/type widget][get-values widget]]
]
]
]
blk
]
hide-popup: make function![
"Undisplay current modal dialog/popup." 
/local face
][
if find view*/pop-list view*/pop-face[
face: any[view*/pop-face/parent-face screen*]
remove find face/pane view*/pop-face 
remove back tail view*/pop-list 
show face
]
]
in-widget: make function![
"Find matching widget types in a widget's pane." 
face[object!]"Widget" 
type[word!]"Widget type to find" 
/local blk
][
blk: copy[]
foreach f face/pane[
all[
f/type = type 
insert tail blk f
]
]
blk
]
layout: make function![
{Parse/layout a block of widgets, attributes and keywords.} 
spec[block!]"Block of widgets, attributes and keywords" 
/only "Do not change face offset" 
/local 
view-face 
here 
margin-size indent-width xy gap-size max-width max-height last-widget widget-face arg append-widget left-to-right? 
after-count after-limit 
word 
widget 
disable? 
button-size 
field-size 
label-size 
text-size 
action-alt-click 
action-away 
action-click 
action-dbl-click 
action-edit 
action-focus 
action-key 
action-over 
action-resize 
action-scroll 
action-time 
action-unfocus 
attribute-size 
attribute-span 
attribute-text 
attribute-text-color 
attribute-text-style 
attribute-color 
attribute-image 
attribute-effect 
attribute-data 
attribute-edge 
attribute-font 
attribute-para 
attribute-feel 
attribute-rate 
attribute-show? 
attribute-options 
attribute-keycode
][
margin-size: xy: sizes/margin-size 
gap-size: sizes/gap-size 
indent-width: 0 
max-width: xy/x 
max-height: xy/y 
unless only[clear disable-widgets]
left-to-right?: true 
after-count: 1 
after-limit: 10000 
view-face: make widgets/baseface[
pane: copy[]
color: colors/page 
effect: all[not only effects/window]
options: copy[activate-on-show]
data: copy[]
span-size: init: none
]
append-widget: make function![][
if widget[
insert tail view-face/pane make widgets/:widget[
type: either widgets/:widget/type = 'face[widget][widgets/:widget/type]
offset: xy 
size: sizes/cell * any[
all[
attribute-size 
either pair? attribute-size[attribute-size][as-pair attribute-size size/y]
]
all[
widget = 'bar 
as-pair max-width - margin-size/x / sizes/cell size/y
]
all[
button-size 
widget = 'button 
either pair? button-size[button-size][as-pair button-size size/y]
]
all[
field-size 
widget = 'field 
either pair? field-size[field-size][as-pair field-size size/y]
]
all[
label-size 
widget = 'label 
either pair? label-size[label-size][as-pair label-size size/y]
]
all[
text-size 
widget = 'text 
either pair? text-size[text-size][as-pair text-size size/y]
]
size
]
span: any[attribute-span span]
text: any[attribute-text text]
effect: any[attribute-effect effect]
data: either any[attribute-data = false data = false][false][any[attribute-data data]]
rate: any[attribute-rate rate]
show?: either none? attribute-show?[show?][attribute-show?]
options: attribute-options 
color: any[attribute-color color]
image: any[attribute-image image]
text: translate text 
data: translate data 
all[
attribute-text-color 
font: make any[font widgets/default-font][color: attribute-text-color]
]
all[
attribute-text-style 
font: make any[font widgets/default-font][style: attribute-text-style]
]
all[attribute-edge edge: make any[edge widgets/default-edge]attribute-edge]
all[attribute-font font: make any[font widgets/default-font]attribute-font]
all[attribute-para para: make any[para widgets/default-para]attribute-para]
all[attribute-feel feel: make any[feel widgets/default-feel]attribute-feel]
if any[
action-alt-click 
action-away 
action-click 
action-dbl-click 
action-edit 
action-focus 
action-key 
action-over 
action-resize 
action-scroll 
action-time 
action-unfocus
][
action: make any[action widgets/default-action][
all[
action-alt-click 
on-alt-click: make function![face /local var]action-alt-click
]
all[
action-away 
on-away: make function![face /local var]action-away
]
all[
action-click 
on-click: make function![face /local var]action-click
]
all[
action-dbl-click 
on-dbl-click: make function![face /local var]action-dbl-click
]
all[
action-edit 
on-edit: make function![face /local var]action-edit
]
all[
action-focus 
on-focus: make function![face /local var]action-focus
]
all[
action-key 
on-key: make function![face event /local var]action-key
]
all[
action-over 
on-over: make function![face /local var]action-over
]
all[
action-resize 
on-resize: make function![face /local var]action-resize
]
all[
action-scroll 
on-scroll: make function![face scroll /page /local var]action-scroll
]
all[
action-time 
on-time: make function![face /local var]action-time
]
all[
action-unfocus 
on-unfocus: make function![face /local var]action-unfocus
]
]
]
if action[
unless feel[
feel: make widgets/default-feel[]
]
if any[
get in action 'on-alt-click 
get in action 'on-click 
get in action 'on-dbl-click 
get in action 'on-edit 
get in action 'on-key 
get in action 'on-scroll 
get in action 'on-time
][
unless get in feel 'engage[
feel/engage: make function![face act event][
case[
event/double-click[face/action/on-dbl-click face]
event/type = 'time[face/action/on-time face]
act = 'up[face/action/on-click face]
act = 'alt-up[face/action/on-alt-click face]
act = 'key[
face/action/on-key face event 
face/action/on-edit face
]
act = 'scroll-line[face/action/on-scroll face event/offset]
act = 'scroll-page[face/action/on-scroll/page face event/offset]
]
]
]
]
if any[
get in action 'on-away 
get in action 'on-over
][
unless get in feel 'over[
feel/over: make function![face into pos][
either into[face/action/on-over face][face/action/on-away face]
]
]
]
]
]
last-widget: last view-face/pane 
all[
attribute-keycode 
insert tail view-face/data reduce[attribute-keycode last-widget]
]
if in last-widget 'init[
last-widget/init 
last-widget/init: none
]
all[disable? insert tail disable-widgets last-widget]
unless left-to-right?[
last-widget/offset/x: last-widget/offset/x - last-widget/size/x
]
xy: last-widget/offset 
max-height: max max-height xy/y + last-widget/size/y 
all[
left-to-right? 
xy/x: xy/x + last-widget/size/x 
max-width: max max-width xy/x
]
after-count: either after-count < after-limit[
xy/x: xy/x + either left-to-right?[gap-size/x][negate gap-size/x]
after-count + 1
][
xy: as-pair margin-size/x + indent-width max-height + gap-size/y 
after-count: 1
]
all[:word set :word last-widget]
word: 
widget: 
disable?: 
action-alt-click: 
action-away: 
action-click: 
action-dbl-click: 
action-edit: 
action-focus: 
action-key: 
action-over: 
action-resize: 
action-scroll: 
action-time: 
action-unfocus: 
attribute-size: 
attribute-span: 
attribute-text: 
attribute-text-color: 
attribute-text-style: 
attribute-color: 
attribute-image: 
attribute-effect: 
attribute-data: 
attribute-edge: 
attribute-font: 
attribute-para: 
attribute-feel: 
attribute-rate: 
attribute-show?: 
attribute-options: 
attribute-keycode: none
]
]
parse reduce/only spec words[
any[
opt[here: set arg paren! (here/1: do arg) :here][
'return (
append-widget 
xy: as-pair margin-size/x + indent-width max-height + gap-size/y 
left-to-right?: true 
after-limit: 10000
) 
| 'reverse (
append-widget 
xy: as-pair max-width max-height + gap-size/y 
left-to-right?: false 
after-limit: 10000
) 
| 'after set arg integer! (
if widget[
append-widget 
xy: as-pair margin-size/x + indent-width max-height + gap-size/y
]
after-count: 1 
after-limit: arg
) 
| 'disable (disable?: true) 
| 'button-size[set arg integer! | set arg pair! | | set arg none!](button-size: arg) 
| 'field-size[set arg integer! | set arg pair! | | set arg none!](field-size: arg) 
| 'label-size[set arg integer! | set arg pair! | | set arg none!](label-size: arg) 
| 'text-size[set arg integer! | set arg pair! | | set arg none!](text-size: arg) 
| 'pad[set arg pair! | set arg integer! | set arg paren!](
append-widget 
all[paren? arg arg: do arg]
either integer? arg[
arg: either left-to-right?[arg * sizes/cell][negate arg * sizes/cell]
either after-count = 1[xy/y: xy/y + arg][xy/x: xy/x + arg]
][xy: xy + arg]
) 
| 'do set arg block! (view-face/init: make function![face /local var]arg) 
| 'margin set arg pair! (append-widget margin-size: xy: arg * sizes/cell) 
| 'indent set arg integer! (
append-widget 
indent-width: arg * sizes/cell 
xy/x: margin-size/x + indent-width
) 
| 'space set arg pair! (append-widget gap-size: arg * sizes/cell) 
| 'tight (append-widget xy: margin-size: gap-size: 0x0) 
| 'at set arg pair! (append-widget xy: arg * sizes/cell + margin-size after-limit: 10000) 
| 'effect[set arg word! | set arg block!](attribute-effect: arg) 
| 'options set arg block! (attribute-options: arg) 
| 'data set arg any-type! (attribute-data: either paren? arg[do arg][arg]) 
| 'edge set arg block! (attribute-edge: arg) 
| 'font set arg block! (attribute-font: arg) 
| 'para set arg block! (attribute-para: arg) 
| 'feel set arg block! (attribute-feel: arg) 
| 'on set arg block! (
action-click: any[action-click select arg 'click]
action-alt-click: any[action-alt-click select arg 'alt-click]
action-dbl-click: any[action-dbl-click select arg 'dbl-click]
action-away: select arg 'away 
action-edit: select arg 'edit 
action-focus: select arg 'focus 
action-key: select arg 'key 
action-over: select arg 'over 
action-resize: select arg 'resize 
action-scroll: select arg 'scroll 
action-time: select arg 'time 
action-unfocus: select arg 'unfocus
) 
| 'on-alt-click set arg block! (action-alt-click: arg) 
| 'on-away set arg block! (action-away: arg) 
| 'on-click set arg block! (action-click: arg) 
| 'on-dbl-click set arg block! (action-dbl-click: arg) 
| 'on-edit set arg block! (action-edit: arg) 
| 'on-focus set arg block! (action-focus: arg) 
| 'on-key set arg block! (action-key: arg) 
| 'on-over set arg block! (action-over: arg) 
| 'on-resize set arg block! (action-resize: arg) 
| 'on-scroll set arg block! (action-scroll: arg) 
| 'on-time set arg block! (action-time: arg) 
| 'on-unfocus set arg block! (action-unfocus: arg) 
| 'rate[set arg integer! | set arg time!](attribute-rate: arg) 
| 'text-color set arg tuple! (attribute-text-color: arg) 
| 'bold (attribute-text-style: 'bold) 
| 'italic (attribute-text-style: 'italic) 
| 'underline (attribute-text-style: 'underline) 
|[set arg integer! | set arg pair!](attribute-size: arg) 
| set arg issue! (attribute-span: sort arg) 
| set arg string! (attribute-text: arg) 
|[set arg tuple! | set arg none!](attribute-color: arg) 
| set arg image! (attribute-image: arg) 
| set arg file! (widget attribute-image: either widget = 'icon[arg][load arg]) 
| set arg url! (attribute-data: arg) 
| set arg block! (
case[
none? action-click[action-click: arg]
none? action-alt-click[action-alt-click: arg]
none? action-dbl-click[action-dbl-click: arg]
]
) 
| set arg logic! (attribute-show?: arg) 
| set arg char! (attribute-keycode: arg) 
| set arg set-word! (append-widget word: :arg) 
| set arg word! (append-widget widget: arg)
]
]
]
append-widget 
view-face/init view-face 
view-face/init: none 
view-face/size: view-face/span-size: margin-size + as-pair max-width max-height 
unless only[
foreach face view-face/pane[span-init face view-face/size margin-size]
all[
zero? view-face/offset 
view-face/offset: max 0x0 screen*/size - view-face/size / 2
]
]
view-face
]
set-color: make function![
"Set and show a widget's color attribute." 
face[object!]
color[tuple! none!]
/no-show "Don't show" 
/deselect "Restore to base color"
][
either block? face/effect[
all[
deselect 
attribute-old-color?/only face 
face/old-color: colors/outline/1
]
either 'gradient = first face/effect[
poke face/effect 4 either color[color][any[attribute-old-color? face colors/outline/1]]
][
either color[
poke face/effect/draw 13 color 
poke face/effect/draw 15 color
][
poke face/effect/draw 13 any[attribute-old-color? face colors/outline/1]
poke face/effect/draw 15 any[attribute-old-color? face colors/outline/1]
]
]
unless find reduce[none colors/theme/1 colors/outline/1]color[
all[attribute-old-color?/only face face/old-color: color]
face/color: none
]
][
face/color: color
]
unless no-show[show face]
]
set-data: make function![
"Set and show a widget's data attribute." 
face[object!]
data[any-type!]
/no-show "Don't show"
][
face/data: either series? data[copy data][data]
unless no-show[show face]
]
set-focus: make function![
"Set and show widget focus." 
face[object!]
/caret
][
unless edit/unfocus[exit]
if face/show?[
if all[
face/action 
get in face/action 'on-focus
][
unless face/action/on-focus face[return false]
]
view*/focal-face: face 
view*/caret: case[
all[caret in face 'caret face/caret][at face/text face/caret]
find behaviors/caret-on-focus face/type[either none? edit/caret[tail face/text][edit/caret]]
find behaviors/hilight-on-focus face/type[edit/hilight-all face face/text]
]
edit/caret: none 
all[in face 'esc face/esc: copy face/text]
switch/default face/type[
button[face/feel/over face on 0x0]
drop-list[face/feel/over face on 0x0]
table[face/select-row 1]
text-list[face/select-row 1]
tree[face/select-row 1]
][show face]
]
]
set-locale: make function![
"Dynamically set/change locale." 
language[string! none!]
/local dat-file
][
clear locale*/words 
locale*/dict: none 
all[
exists? dat-file: join what-dir either language[rejoin[%language/ language %.dat]][%locale.dat]
locale*: construct/with load dat-file locale*
]
all[
exists? locale*/dictionary: rejoin[what-dir %dictionary/ locale*/language %.dat]
locale*/dict: make hash! parse read locale*/dictionary " "
]
]
set-state: make function![
"Set and show a widget's state." 
face[object!]
state[logic!]
/no-show "Don't show"
][
either state[
all[
'luma <> second-last face/effect 
insert tail face/effect reduce['luma -64]
]
][
all[
'luma = second-last face/effect 
clear back back tail face/effect
]
]
unless no-show[show face]
]
set-text: make function![
"Set and show a widget's text attribute." 
face[object!]"Widget" 
text[any-type!]"Text" 
/caret "Insert at cursor position (tail if none)" 
/no-show "Don't show" 
/focus
][
all[face/parent-face/type = 'disable exit]
unless string? face/text[exit]
either caret[
if all[
face = view*/focal-face 
view*/caret
][face/caret: index? view*/caret]
either face/caret[
insert at face/text face/caret form text 
view*/caret: at face/text face/caret + length? form text 
face/caret: index? view*/caret
][insert tail face/text form text]
][insert clear face/text form text]
all[
face/para 
face/para/scroll: 0x0 
all[face/type = 'area face/pane/data: 0]
]
face/line-list: none 
unless no-show[either focus[set-focus face][show face]]
]
set-text-color: make function![
"Set and show a widget's font color attribute." 
face[object!]
color[tuple! none!]
/no-show "Don't show"
][
unless string? face/text[exit]
all[
widgets/(face/type)/font 
face/font = widgets/(face/type)/font 
face/font: make face/font[]
]
face/font/color: color 
unless no-show[show face]
]
set-texts: make function![
"Set and show text attribute of a block of widgets." 
faces[block!]"Widgets" 
text[any-type!]"Text or block of text" 
/no-show "Don't show"
][
unless block? text[text: reduce[text]]
foreach face reduce faces[
unless face/parent-face/type = 'disable[set-text face first text]
unless 1 = length? text[text: next text]
]
text: head text 
unless no-show[show faces]
]
set-title: make function![
"Set and show window title." 
face[object!]"Any face in the window" 
title[string!]"Window bar title"
][
while[face/parent-face][face: face/parent-face]
face/text: title 
face/changes: 'text 
show face
]
show-popup: make function![
face[object!]"Face to show" 
/window window-face[object!]"Parent pane to appear in"
][
all[find view*/pop-list face exit]
window: either window[window-face][screen*]
insert tail view*/pop-list view*/pop-face: face 
insert tail window/pane face 
show window
]
translate: make function![
{Dynamically translate a string or block of strings.} 
text "String (or block of strings) to translate" 
/local match
][
if all[series? text locale*/words][
text: copy/deep text 
all[
string? text 
match: select/skip locale*/words text 2 
insert clear text match
]
if block? text[
foreach word text[
all[
string? word 
match: select/skip locale*/words word 2 
insert clear word match
]
]
]
]
text
]
undisplay: make function![
"Closes parent display of face." 
face[object!]
][
while[face/parent-face][face: face/parent-face]
remove find screen*/pane face 
show screen*
]
]
foreach word find first functions 'clear-text[
set to word! word get in functions word
]
images: make object![
alert: load #{
89504E470D0A1A0A0000000D49484452000000300000003008060000005702F9
870000001374455874536F667477617265005245424F4C2F566965778FD91678
00000E3A49444154789CED9709509457B6C719E5C50D446413704CF4D524953C
93093EB3A880A844055C105C00574411511277CD888A51DC41A3880A363B22FB
BE8A80080AC8BEA3AC2A82D00BBDD1DD989C33F77EDD2026649B4942D5D4DCAA
7F7DF7EBBE5DF53BE7FECFB9B79594FE3BFE4387E049C658C9D3CCD5E2C6B895
82C7E9A3879BE7370D7E43EAD457ED29B5D2962890368763DFD3F8F29E9A84BF
0E37D7AF1ABCEAD811AF3AEE64891F47604B6604B46484A1A83600258D6169EC
92D0BF0C37DF2F0E5153D25A59EB2D68CBBA0D0D09B7A03E2E045AD20340DA70
1D847551AB869BEF6707BF3E41E3557B7433BB3808EBE343B0212110EA63FDB0
3AE226BECCF382BE26BFC79CD25BEAC3CDF99343D212E32E6D64C1E3C420AC8D
0EC0970FAE4167AE1756867A6375D815E8AD3C07A2DAC0A3C3CD39E4E0D7C7FE
ADAF95C57D917B136A224910F1D7415AE70992DAF350177109CAFC2F425BF219
90569DEAE614074C1D6EDE1F0DD9D3F01861D555AC89B80155B7BC915BE481B2
8633D057770AD979EE58E273164A6EB8232FFF304A6ABDC3869BF78DC1AF0E32
E96BFAF6BBA6642FAC08F682A6C48B28AB3F85B2BA6F4056730CA595AE581FE6
0685578E636D3009A064DFABEE3CCFD9C3CDCD0C7689CFE8BEA7010F38451E50
117C19CA032F81B0FC24C8EADC08BC2B48AB0F81B4F220F43C380805975CE181
C721E848FD122495A7739EA71E1B35DCFC4AA2C7418EB22767A0E6F6452C6579
605BAA3BB18D2BCA6ABF4659F5019055ED4369C56E94967D058FC37663EEA9BD
58E8F925881F6C015EC1F98DC30ACF2EBEAA2D6BF6687D917D064A7CCF6145C0
2914577C0DB2DA0328AB21E095BB415AE142E07710DB388120CF111F9C73C16C
B79DD07CCB01C50F9D1B9F251ED018B600242D0167C5356E50EE7F1A8ABC4FC2
8B3B8709FC5E90D610F0AA2F09BC3348CBB681A4742B488A1D4052B4099A6F6F
86CCC38E70CF6D33F032D680E091FBF16181E756F8BCFBAAE9A8AC29CE0D0BAF
9E80AAA02328ADDA4D6CE3426CE38CB22A47B20BF6D057BD11A5E51B5052B41E
24857628CA5D830F4F6F80F4FD1BB1E25B1B14E7ACEC6D8BDEF9CE9F0ADFF5F0
CC4859AB5734AFE8103EF276C382CB47819DB78B0053F06D20AB76C0A65C7B64
5DDA0257CFDA6359B20D4A4B5782E4E12AECCDB3C2F6286B48DD6D8B697B5663
4784390A729D6F35856C1CF1A705C02BBBB0B0AF717F5F3569890F3D5DB13664
1FE93824E3550E28ABB0075EE97A3C7AC011B76F7580AD9B37E17E9775C82F5E
06923C4BECCD5D42B26E0605272D3161FB0ABC7FC40245E9A6B2F6B86D267F0A
7C57C1B9B17D2D27CB3AB3F640FEF9AFE1A1E77EE0173A12DB6C22ED7203C82A
D6425DA62D386DB107874D1BC07EFD5A225BA8CF3083DEFB8BA137E70B1067CD
87AE980590BC6309C4399843E375231065DB15925DF8E3FF37086B3D5C24D53B
BE2FBEBA0F724FEFC5A6C8EDC4F704BC722DCACA8955CA5641658A356EDEB00E
37AEB5857536ABD176953596C699426FEE7C146799A028D3184419865876D604
A3379862EA7663E0457DF25D778AD3963F14BEF3DE11F5578D7BBB5AE29CF19E
FB6E28F0D889E292F528ABB40559F92A94955AA1B4C4126AD397E106BB35141C
565B59E24ACBA558166B4CB26F8CE2CC3928CAF81CC4699F22376626266D35C2
88358650EE3E03452926ED0DD797AAFC21F01D59FB95244FCE5FE1173940DE19
17C83EBE139E2751CBAC0669B935484B9783B47829481F994343C62258BB7A05
582F5F0A2B965A80D55233A849FC1C7AEF12F08C4F40943A03442906204CFA3B
D45D348030AB4F216AF50CE860FD8DB456FB73B59E86BF7F005DF9AE067D75DB
84557EDB20EBE8762CBAE8407ABC15CACA2C49875946E0CD515AB4082505A6D0
7CC7046DAD2D70B985192C59BC105758CCC746022CCE20594EFB1885291F8128
E9FF5018FF3EF263DEC564FB0F21C4E243CCD9F91E0A223FE869F431FBE07785
EFC83AF497DEEA7D49EC9CF578F7C836B8EBEA802FD35792AC2F2396B14049F1
62901699A2B4601E4AF28DE179F66CB4B15A88E60B17C0C2F926B8C2CC10DBEF
7C00A2B48F5094FC3E0A13FE1784B1535010A587FC701D6CF4D08540D369E83F
7F2AB65CD00676F89CC81ACFB9BF5F009C02572B4999DDAB428F4D9071D01E2A
BC6D808093AC2F22A7AB2939A0E6931E6F0C927C43D26966033B7726AC593E17
E619CD8159330DE00BC377819B3E1E04514411E3807F9B284C05F8B754A02754
157A82552163930EF8CED18738EB49C06169C95AFDCDCD7E17F88EEC236F49AB
9CEADAA2D760C6C14D78F7F03AE0659BA3E4D117202D9C47B23E17250F8D08FC
6C94E47E86BDD90620C87D1B4D3E9B8A5327EBC2145D6D34329888E28C11047E
2C0AC2C7210D4010A682FC5055463DC1E3E1F9E50918B4400F6F1AEA43C53F34
91173EA3ACFCF874E57F3B007EC9D15DC2072BF09EDB3A4CDDB316EB59CB68C6
89D7E782F4A1114A29781E29D0ECE9284ED34551E238E8CD1CC140FF75921613
C032637514A72BD3ECCB0360B22F87E7878CC79EA0F1D013A886F92E5A4877E1
B6991EBEF456C78E706BC77F0BBE3D75E71469D9FACE1A1F6B48F9CA06B2BEB6
02719E09B18B21C9F81C90DCFF8C80136FA76A8230611408E389E24641EF9D11
6061A80E3400AACDCBD4409CA20CFCF0A1EDA30800D83727C0ADC57A4077E1BE
B336F9FE83E7B51E46BAFF12FCD3587B2571A5EB75CE1D7348DDB51293765A61
4BA829C93605FF9C58E5430A4E323E1A29BC287E148AE2C83C7634F4A68F44BB
456A033BB07F9D2A8A92FE0768F619EB107879F689825FEF408FFF0424F60196
913EFA9BE8E3334F0D78E137EBD2BF1440E7DDBD337B0B96898ACE2E8104274B
BC7FCC8CDC616663EFBD99204E9F4CC0C78028814013709A79053C0A4800E254
657459AD3A10C07997B1741D086EABC80308ED0F603CF2834800812480007900
1C5F7552C8BAA4162663FAFA49C0654D1134F92CFFE837C1B7C56C5112E6DBE5
3C0B3725F04B21D1C9023AA367938388D825494D6E15855D8471A381669D4A10
330604D124B0C4B7E0CADEB103168A3D4BD691CFDFB04E08B5CF78C63EBC0035
E0F913F94D001E6B02349ED600BFB9FA7427A0FE98167407CC4CFF4D01B0EFED
B716DE3581EC436618BB79313C3A6584A2D4778845C62203ACB00ACD3893F518
328F19830492F4F631643E1A6B429571D6471AB068963AB6C78D4401F5BEA270
29BCC23A48AD4303A0D927012097A50E5C9F899869AFC31474B4A52E767B697E
FF2CC476C9AF826F0EB65215DFB7AE69B86E82B1F60B317EF33CE044EA11D031
8C040CF89837A1497685D124B828D22623C702118A12DEC2CE8491C04E1A8974
DD80EF99B6C9142E0980D886588766BF87C0F358EAC8BDA90E3CDF89F8E29206
0698E8D382C6923DDAC8093028AF709B31EE1703E8C9FBEA704FD2E790B8753E
44DA1943C589C98C2D8654D420C9C1811F41358E16ACFC33FA1E466DA322B74D
C87845D721D6095458C77F02631F0ACFF5657600B8372642818B36D3918217E8
4387A726BC0CB7DDF7B3F06DE176D3C47717BC2C3E391B226D8C30CE761A7243
C701CD6CBF188B304F0227CF382A4091F679BE1C1CF92923B12C5019CA039591
9FACCC1C5E4CD10EEE3A8AC2957B5F1D7937C90EF832F0C8BDAE812F2F6B40B8
851E53D0395BC809EDF3DE8B7A8F2FA6FC6400DCF4557E2F42FF1F62D61942E0
C2F7A0EEF40426A3FDD97D4311FDD91E2BEFEFFD3D9E48983612BEB25185B7F5
B4E01DA23D76AA204C5596679E166D607FE12A32CFFA71F639D789BC2742D521
2D6617A89D5A4E68931BEBBC6B43C27724EFFC5498F8F1F759BB3EC1A045EF43
CA7A1DECA12D2F7C9CBC7F2BD4FF3EF873E66AA06891D43A052C659C36596BA0
8DD239F90C68DF1F5CB46FFA9EEC00295E0A4FB3CFBDA6811C6F0D605FD1C4A4
55BA4C41D327FBD2A4EF5AFD3718BC01FFC4D77C544FAA79D6932B1F62E892E9
E83777323CF35293F76CE25F064EA17E58FE6D95D77D9DB647E6805265BECFF7
55C6A9FAAF03A0F37C1F657AEA2A8A76C240D1CA6D430290C313EB9000083CD7
9B04705503385E9AD87C420B59C64C5BC5EA033AD8E53B3BBDFCF0C76F0D04D0
9DE162CB8F7EFFFBF8B5D391653405739CB4E42D8F910A73F1EA171350FF693A
68CD4087213D9E973C12B75A8EC729BA34002D66CE4B5286A13C4F33CFD8C647
EE7BCE353227F0DCAB64EE4502203BC0B9A285991B7581D642B8B91E7679925D
B861B992817F7C7581BA207E5663E9B1F7C0CF642A842ED2834E1F35F9613320
952134E8FB90412287130D4844EE3E95C1CA5011A40CC21465E6F37ECFF37EE8
F9C1BEBF46BD4FC049F6D95E9AC0BE4CA505CFCF684388A93E73E52ED8AE0B6C
EFBF37941DF94C4DA9E3F6A2439D7ED3207CF9BB4C8425073598EB2DED16CC4D
911E3A218A7B4B88EAC0BBFCA958D3BF3E48D161687FA7F36026A001DBF07EE8
79D2EF87F23D87C9BE2612FF03E7B21672BED522DED782C21D93E8751B69204F
4FE842CBA579FB9584719FB63FD8338D786C0A4491538FCD525340BC0662E014
EA87659E413F80A605DA7FAFE93FA0068A7570AB54789E8127B043F89E5A8766
5F0EAF8DDD17B5A1F39C0E4692B64A77E19EBD1E09D6E099524FB01E019FC26C
CD4D72F7F0331E5EB106CBE8C7A22D95B2869BE943D7595D50EA09D495E538EA
907F43FAE03F975C6389E8456AA8F9E0F79F5AF36BE77EF267BF60C8B9B1626E
AC981BCB7F1F345F1F7236EA61F7F9B7A54AFCECDD0778FEDAD21757D4A1CD63
22B65E60C4CC99778FD773F9BB629DE2A9F80DB45D78FDDBD6F3E4C948035ACF
6920A3B39A40842D67884E6B0211B69C2272276DD25D0B9A4F6A31EDB2991C56
CDDF6863F3711D6C72D301226C3A46747412341D99449FF8FC1B5DE8BE30B5B7
C5C37897FC0A1162A3DF7C79FA2A6E9A931327D5D1999DBACD993358693FA11F
AE63E4E4CC49918B4D953C4849DB5F2BF1B5BA1388E2A99CE58A5328966A8773
77CC0EE72EAA68F21EE3E2F4E4E40CABE61BEB747EF162F7DFF1278C7F026C2A
CF4E2621E5110000000049454E44AE426082
} 
help: load #{
89504E470D0A1A0A0000000D49484452000000300000003008060000005702F9
870000001374455874536F667477617265005245424F4C2F566965778FD91678
000010D249444154789CBD5A09585457967E8AA89D4E4FEC99A46DA3635CF265
8C1AB02AC405030A2EB1932FD1681454880B6EA0289A4ECCB4FB1E359A51032A
9B289B80801854881A27CB3431C18DA5A028A028AA584A14641154E09C39E7BE
5750D87425DA76BFEF3B1FB7AADE3DE73FEB3DF75E24E9293C7ABDC15EA72B76
D068F2BCB55ADDF6DC9CDC849CECEC0B9ADCDC1F7373727ECCCECABA909D959D
A0C9D36ECFCECEF1CECBD739D0FBF64F43F693832E31F6D06A8B9C737335813A
9DAEA0CC646ABC7DFB36D4D5D5C1BD7BF7B0A9A909EF37350111363636E2BD86
06B87BF72EDE329BC1603034E6E5E515DCB87133303B27DF595B50DCE35F06BC
A8B8D44EA3C9F7D06AB519151515ADF5F5F5F0F0E143686D6DED4075F7EE4391
A946108FAD7F6B696981FBF7EF434D4D0D941A0CADE49D8C6BD7B33C34798576
FF34E0FA125397BCFC42B78282822CB6F483070F801E6C696DC5BC22331C8BBB
82CB3F8947E777BE80418E1B71C0D0BF3081F217E93B707EFB0BF10EBD0B7945
B7C45C5208C963505E5606146A59D7AFE7B869F28ABA3C55F005BA925E14DF41
9515154D6C39165AD7701F12526FE0F405A138E48D2DF0D2F0753880C9613D0C
1AB10107AB36E2CBEA8DF0B27A9318D37730E0B5F5E21D7A17688E98CB3C9817
7905C99B58A2D7375DBB7A3DE866567EAFA7025EA3D10E2A2C2CCAACABAD15AE
E710483C9F05EED30FC14BAFAD83FE04F825C70D306CEC0E1835792F8C9B7A00
267EF025BC352B08A6781E16C463FE6EDC7B07C43BC3C66E870134E7259E4B3C
9817F364DE1C8E9C27D9D9D99999993707FD43E0A95A8C31949498C8EAC8E1A2
3755E3F445C7A0BFE306FC4F02F0F2C8ADF8C6947D3891C1CE398A4C6FCD3D0A
44A850C7B1F2CE94394760D2AC201CF9D63E641EC48F0D8133161F6319C2C3B5
B5B598A7D19832AFDE1CF384E00BC7988CC64A8E756678F67FF3513DF973EC37
62230C20F7BF3E651F4CF43C2CC04D267093BD82916992773010A1421DC7CA3B
93BDDA15631E4EC46B20F124A3A07AD25E387B394FE4473D55346DBEB6F2B195
20CB0F2A2D2D3529E0212AE53A0C1EB31DFAAA36C17FB9EC84F13303814130A8
891F86089A302F14DC15729BDF39597E9FA0CCE1F9A490E035FE8340C1BB9F6A
230C1EBD4DC864D9AC047BE2E75F1B4E457A632FBD5E9F49E045858824467DD5
9BB1AFD3661C4E1E9848C248384E9817026EF3429180E17802376E4118BEEB1F
85017BCEC1C1E80C8C3A731D4F5FD240DAFF1560527A0E86C7FD04EB769D45CF
1551E84279317E7E98984B0AA15088BC34913CF21A79A0EFEB248F929F65B728
E1440B60E68D5F4A6C6359459782025D50032D3A1CF3A9DFE6E3404ACE3EE45E
873FED437712C21624C04880C1756118BAF884A3C7A7099042215655738F5D0F
A83C8289D5983F35D4DFC7AB997AF00F884197195FA22BF39A1F0616654806B0
AC179DB6E040E71D709630B02139B1B93A69F26D94D8C2A212B7DB55554DEC3A
7D590D38BCFD05F4A612399462743C59892DED4AC05D1686C3589F7018E3730C
36857C0B35754DF0B84F4B4B2B9C270BBB4ED80B6389AFCBC230F6A290E146B2
58E61F9DB680E39FF613966A519D4489BD91EBD6B9F54D1576F442567373336B
0CEFF945E21FA8420C98B0075CC9326CED37C9DACE047AD4A2087C637104AC0B
F9161F34B7FC8DA51F67ACC932A233597A14C918EB730C1545701C7D1EE8BE1B
7A8FDC82EFF99E1098789DE0C52EB7B315BBB048EF417D8C7057DCD739F0FCE8
6DD8DB65178EA20A431667E06801FEFA92E3386D7D1234343D7C22D0D6637E52
E27F86116377326F1C4D655A510447CF390A7F74D9897F18B515E3D373C46247
2B3672DBD1017C45A5B907355819BC50D5D2AA389A40FF3B559D21D30E895019
454C65E011A05E7A1C9C7C23E1FC4FFAC70E9BBFF73C7CD8029EEF1E80119E47
C089648C24591C9E6F52A8BE3AEDA0C0C2CA30366E3B6891CBC8D7E9DB1BC052
6399333556AD6C98E8B46CFC3DB9F405F73D38724138323327B2380147F5B213
A85A1609D336A560D383669BD62D3356630C559ED0E46BF85D96091F36779EDC
96CF27281C878FDB4D724E809AE4399137C8E3308AAA556FF7DDF87B522286B0
7184700398455D6C9B02543603B9E673C99ABC3C129F75FD0C06CF08142EA570
21AB9F20F091A8F68D42D5F228F83CF1AACDF0C8B9518AEEB4CA8E2065D50127
D1690D357017F36C2A70F54A110E75DC842AF22E1B8A0DF6BAEC0D7C99B0FCCE
65174CA6BC648CDCC5722B2EC0579ACDF6E565E53A4E921C7D15BE30E973B49F
15068E14876C0962066A5F02EF1785EAE5D1A85A110D699925361558E479041D
BDC350B53A1ED4ABE39169E1C16F6C2A50A8ADC05787AE130612B2D860E40DCE
B7110B8F61F759A1D09BB0E512466E28693FA1D315EAEDA5F28A0A879AEAEA46
562028F91A7477DF0BCFAD4804F59F1381C345E51B05CC54B53C1A542B6240E5
1F0B093FE8209F7A16737583885FEBA79E4AEAB0217F0107FF93E0400A303912
6D4BB86A330F32330A61A86A33B081842C3F92297B03D41F250A4C3D09DB61C2
C8B9CA9B220DEDEC246369A9772325062B3067EB19ECFAF641ECFB492AA8B7A6
A3DA3F46B6C88A683156AF8C45D5AA9314167138FAE353E0B6EE34BEBDED2C7A
FDCF255815FC3D6E3EF9336E3C9E01FFE1BC0B7F333B0C7BCE0E05221CB7F10C
56D634DAF440D0FE747C6DCA17A85A194BF24816C99465D3784B3A61FA0AEC08
9B176164AC72C79AEB2DD1AE6A87D236C0A0B921D8654630BEB2E13CA8775C44
F5BA5464ABABFD6351BDEA24723CAB02E24458A8D624B075B1FFD2287CD62B1C
EC6686A0F44130134833E9AF4C3071DB392CAFBE67B38CD6D536C294F1BB71C4
D248D9406428613CF2867ADD57C8585E597F1E18DBE0B9C1022B6F4F698FBD43
321A8DF1963EDF6ED23EB09B1B01C336A7836AC74550EDBC04AAB5A781993270
D56AA235141244041CBA7B8682002C408780344B218F50E83A3B0C7C8E7C070F
9A5B7FB18C6E5E9B00C3DF0F14BC859C8093B2CCB5C9320E22C664372702EC27
EE1358798F9D959D132F5149BAC00B446DE30390DCF762B7F9D1E8B8ED02A877
5E42265642FD49122A56C72114DBBFF30AC72E164BCF22CB5382491E61287932
8543B7B911B821FE1AAFD2364B6D33ADE2C15F5EC2E7C7EC827F9B1BC6BC9195
1089FF7112C9BE28E3200F386EBD00DDE647216364AC7C50C0A71D92C964FA91
6BABAEE22E4813F7A1FDC2581CB1DD4A815DDF8831790207FBC5A0BD47088850
11160F4519783848B38FA134872902D6275CC3E696569B958AC1EFFFEC1C3EEF
BA47841AF3B427630CF68D61CB1368967DA94D81116454FB8531284DF85C60E5
D30E3EB291CA48010E215D3929402164EF130B2A52A02D844801D5AECBD07F7D
3A74F53E21878B0893305080038396E6321D07F75D5F938B6D870CC7FC325A5F
7EFBD60199077B70A6308C90D17F7D9A90C90A080C8C4556406064AC7C64C3E7
4E5C85DA4368F27EECB620A66308910203377E8D762B53505A41B4F0A46CEDD9
24982D4EE122791D07C9FB04DA2F88C68BB91536C3A69CB6A5B3A865E83EF588
3C9779B0129EE1C43B96649C063BFF141CB831BD83074408117FC6C858F9DC89
0FCFD8039CC422B3EDDE3988761F46E2B02DE9A0C43F0ED94213FD4FA3B4FCB4
AC80FF1990FC92519A4FD6F03A8E0C5CFA3012A47951D86F7532D6DFFFFB2D46
4D75034E7DF700DACF206B931CC98BE6CE251EF3A3659EFE675806B0AC6E2B4E
0BD92A450191C424CBEE9D03022B1F9EE5E4E4C64B66B37947B372303560E171
E1D25736A409B7396CBF08BF5D95C2CC992908E6ACC0CAAF405A952A7F5E140F
D2821841AE9F5DB4193A41FBD2A0D7F8FDF42E0166D08BE264BECC8B79326FF2
80B49CE4F92509D90EDBE42AC465948A04618C900FCE68AB995FA0DBC11EF026
77882F3DF6A4895ADE6F6D2A4FC2173F3D8B926F1233230F24B37B51510085D0
00FA3DE01CD1595606DF3D9C613371BDA61EC4EE73A3642BAF4A4579FE599917
5B9F424728C4DEF02599BE89F0E2DAB3C858FAD1E22ACD388A1EBBD38407F870
2D5793E7CD1E70206D442B7128350BA56941F8DCCA6418BEE56BB45F4E4C9625
B62B2087912C8C2D6601B0FA1C486BCEA37AFF5F3124C3082119A5A85087F1F0
E9C1D8750529BF9AACB9FA9C053C2AD69743D45A01926DBF3C1119CB73FE64C8
A981C818192B9FC51614163B48555555F6B42C8B662EDB701B9E997514BA927B
5FF8882CBD34018402C20BC9B26BD9C5D66114203C01420906B686E8A334A274
2BA2CF6BD2E4DFC47BE7E439D6A1E39F22F3F693C387AD2F2D3B25303096AEF3
A2E09999470446DE5EEAE8292E29954FB84D4653206D25453BEDFCDFC9BC2081
B4240169320A266C0DF6825F322AB9601D4AA828816F1ECA40DF989BE0177D1D
156A1F475D07A78064B45F740A15F016EBCBBC64EBA35040B63EC9170AA0C042
65DBF9D324F9BCA8BE1EF854BC6D3F505E691EDBD0D02036341197B5284D3F02
924F1C2A4A8060E66B514078C13A94DAF221E80783CD1CD8F4711C3E3B3D5C7E
BF1D7C5BE51161CADE6E53204136A4CF4994DE3F0C8C8D59F2A978BEAEB87D43
5375FB4E0FFA3283C3A8F6DE0318B22A5E2C4AD29278258C4E751E4AD6558928
E887129B5568D39FE3E0D9F7C3ACC2E60C28E0DB2A8F1C3A446CFD25247B71BC
582887AC8A13D878E3C547FBC50653C73B05A3A9CCA389FA0BD630F23B1DAF8C
F2C2222B816D5E9095B0F6042A6030E87BDB1B1DE181F74395F753B02D6C04F8
F6C42583C9E1BB4494686E5B04266E79A8FA606E9EB6E3A69E1FF3ADDB76E485
2CCB2584EBE6545E69650BB025965ABCF08827444EC8DE08FADEF6465F78605A
886C7551EFAD2D9F040A78D9EB0C9ED7096A555C37A50A4CBC13E3FB099DDED8
F94588B1ACC2ADBEAE4E1C6C1556D6621FDF5879955D1C2F5B64E9295442A9DD
13166F902549815FF6C0D4105480CB73FDE47A2F3C2C5B5E8E7B96497D519F65
B1C858B85FE3FB895C6D51E7075BFCDCBA5DDD85F6074196DB97A49F4AB0E77C
52607E0CBBD3A284222CD1BA3A094041DF15FF0A058251299596907C246C1264
83515BDF73DE09600CCC86EF273479F941C5A565B66F6FCA2A6FF5AAAC34672A
FD11067FA3957B9E058A12229C94F2DA212F927041E4558CBE62002214F463C7
F1F48004ECE119D1B1D23C5A2E172B714F3D12CB660C7C3FC1972CDA22C3AFBB
B52929350DA2643159766AC1970BA0E722EE7762959C50AA9375856ACB0F2547
3AA5C4F62A631DEF969897C1C36F7CA2854C96CDD1C0972C39F9BAC7BBAD3118
CBC654DFB953A928818999A5D86755125726D9C54BE2DB173B59116C0B2D8B65
3B1D9F6AB7B8B5D517C5092FF7599908899906E17D06CF972C1A6DE193DDD2B0
128A27441C169AEBD0853A4EB1B02C8E571449682FB51D945180B68D133ABE23
CF939395AB8D4F2CBAECBAC03244EAF041035FB2680A8A9E0CBCE5E170E29CB0
DCD6304566E8E1D50DE7E5F26AA1C54A18FC1AB294E625F29C57379C133C2DFC
F97E42AF2FC9CC2B28FCC72EF92C4F5965552FA3D1146429B16C21DE1545FC55
8F63F75CC667569E860E1565E929B9E42E512CBDF49475F5126593E6D0DC6F90
79302F0E193EDAE7FB09BE642934989ECE35ABE51125B6BCD28D173B5EB12D8A
7073956DBA0B872E17A247D84F386043BAD8128A55562C5829621F41DF01FD86
1EA15790DE059A23E60A1E94677CB4CFF7133ABDC1ADB4DCFC742FBAAD1F73D5
1D3B6E3BB877E20690BBD847FFCD40F4548D0FA1C05C0F3A221E77F60E87259F
8AF3D17E6171890719E89FF7AF068F3E5577AA7B70176B329902693F51C09B22
DED9F1F694935E21111A963127261F63F2596C797979019F8A1B4CE563CB2B6F
FDEBFED9A3536568536436DF72E0ED29EDF0B6D3DF046369E9453EB22105AF94
1A0C1769854F20AF6DE7B3583E50E653F1A721FBFF0123A667CC3DDC35930000
000049454E44AE426082
} 
info: logo: load #{
89504E470D0A1A0A0000000D49484452000000300000003008060000005702F9
870000001374455874536F667477617265005245424F4C2F566965778FD91678
0000102049444154789CBD5A0B7494D5B5FE3146BCB62EF1AE5A8A639187F562
D584199190D000E1256A975A154281487805F206B52205228104EA035DCA4D94
BC087941262480264224CA6DEF5D45DB54308F99CC4C92C964268F21E1914012
9E7B77EF73FE99CCD05C925AEABFD65EF367E69CBDBFBDF777F67945516EC163
B5DA7C2D96463F83C118663259926A6B6A8B6AAAAB8F196A6BBFAEADA9F9BABA
AAEA5875557591C1684AAAAEAE0933D659FCA8BDEFADB0FDFD4137D9879B4C0D
41B5B586148BC5626E71387A3B3B3BA1BBBB1B7A7A7AB0AFAF0F2FF5F50109F6
F6F662CFC58B70FEFC793CED7482CD66EB351A8DE653A7BE4BA9AEA90B32991B
87FF60C01B1A9B7D0C86BA5093C974A2ADADEDFA850B17E0CA952B70FDFA752F
E9EEB9040D8E7342F8DDF3B76BD7AEC1A54B97E0DCB973D06CB35DA7EC9CF8F6
6455A8C158EFF36F036E6D720C33D6D58798CDE62A8EF4E5CB97811EBC76FD3A
1A1B9CB0A7F01B8C7E438F41CF7E00E3FC1370CC2F7FCF02EA27D27710F4CC07
A20DB50563C369D1971C42CA18B4B6B40051ADEAE4C99A1083B161D82D056FB6
348D207EA7B6B7B5F571E4D868F7C54B50547A0A5F5C9681139E4C84071FDB88
6358FC36C1B8899B71BC36011FD225C043BAB7C43B7D07631EDF24DA505BA03E
A22FEB605D9415A46C6293D5DAF7EDDF4EA67E575537E2968037184CE3EAEB1B
2ABBBBBA44EA9902C547AA60E68BBBE0C1C737C26802FCA0FF6678746A3204CC
7D17A63FFF21CC7EF9BFE1A905A9306FE1C742F89DBF9BFEDC87A2CDA3539360
0CF57990FB920ED6C53A5937D391C7497575756565E577E3FE25F0542D026D4D
4D0E8A3A325DAC8EB3F8E2CA3D30DA7F33FE9C003C34792B3E396F27CE66B08B
7623CB538B770309AAE2FDAEB699B7E81398B32015273FB5135907E9E340E04B
ABF6B00D91E1AEAE2E341A0C8ECABF7D17F83DC1D7073AECF676E63A2B2CFB9F
3AD4CD7D0F1F9898006328FD4FCCDB09B3177E2CC0CD25707397A421CB9CB034
204155BCDFD5367397F43BC63A2691AEB1A4938282BA39EF42D971A3181F17A8
A299EA4CEDFFB41314F971CDCDCD0E153CE41D3E09E3039340A37D0BFE2B783B
CC989F020C8241CD7E255DC8ACA51930539590F081C5F5FB2CB50FF7278784AE
192FA708DD0F681360FC946DC226DB662738137F1D2A9D1AACF61156ABB592C0
8B0A914B8A34BA2DA899B4051FA30CCC2663641C672D4D8790A51948C0700681
9BBE2C137F1D938747FECF0CC7FE6C4155BCDE8FFCB10E67CC790FA72FCB8019
E199A22F3984C221CAD26CCAC8E39401CD13648F063FDBBEA6D28926C0CA5383
0D6C7B4BDB30B3D9927A91261DE67C29191C4B837314A5D7EFE99D38938C7004
093081C88469CB3331787916FE6A79164C5DB1079F7BBD10FB2E5F05541FA1C4
E3BDAFF70ACE08D88653576401F5A1BE99388D1C9F1E9E092E67C806B0ADFB27
25E2D8A06428230C1C481ED85C9D0C753729B1F50D4D219D1D1D7D9C3A6BCB39
F07BE603184925F297C4D11914258E3419846001380B0257EC818095D9307955
363C49F2CC1B7A6007FEBFA7AFF7324C277A705BEE33850A4210E9F815E92267
388BC24608D9629B3F9B9408FE4FBF4F58CE8AEA244AECA9DA9081A3EF68F3A1
065557AF5E658FE1B9A85CFC29558831B3DE816914198E3619C220091A19C4A4
886C7C22622FEA22F6826EF55E9CB7BE68D00C4C9F9224DA733F9649ABB25175
06398BAA23389D6C8E9DF9368C9C9C88CF45E6084C3C4FF064573BD08C5DDF60
0DA5758C4857E11735F09329DB7064F00E0CA00AC33421E0E802EE095AB72607
B56B724117998BF336140FC901D17E4D2EEA56E720EB207D2218A41B392BAA23
3865D16EF859F076FC69C056D497D788C98E666CE4658717F8B676E7705A609D
E089AA8B66C52904FA3FA9EA4C786197A04A002995C0B31934490E30086D2449
541E68A3A5CCD9500CB6F62E686D1B589A9A3A21387887ECC312992775ACC911
3A75D211412FA6278FAD475EF848606167181B2F3B68923B5167B1F62F009BED
2D41B4B0BACE01CB3F5A8DF7D2E0B96FE63B3879599648EF248EB857B4F39001
EBA2F35117938FDA987CD0C514A090D802D0C5EE4355BCDFD536B23DF58D96C2
CEB04E352BEC88A0168FAF00AA562367BE8DF7921305848D19C20BC02A5AC5BA
1DA0B299C2359F4BD6DCE85CFCF1B43FC0F89752444A9F1054C991CA3D80BB41
C712A03802174720E3F7A3367E3FE8D6EE47967F78A7DF459B3897631E0E4593
0351A43F92E9E5A296C8063E4458EEA6CCCDA571C9187915CB4B7101BEDDE9F4
6D6D69B5F020A9B176E07D54A77D1764823FF19023A1E3F412BF59B927706DAC
07E8B50CB410A76D28C19C0A231494D7A22A5EEF7BCBAA30F0F95DB2BDEA0CEB
D072D64476F26580A2FAB3C1E36DE2F23D78C7820C1849D86A09232F28693F61
B1D45B7D95D6B636BF7367CFF6B203A907BF853B66BE0BF7C41483EEF56295E7
2E8EE78336A60018384753C8DA4229EBF442E625960E5E460393D5F685FDFD59
1765851DE100095B51727C8800BE562C30DD49D83E268C3C56795364A09D9D62
6F6E0EEBA581C10E2CDAFA29DEF6CC47A879A314745BCB253D3822CC574E3747
2B5E469B01E8D6E951FB6A114E7C550F13E2F663C09B07B177902A144C556842
EC7EA03EA2AFD0414E08AAB9E8E5990D7E4F2C274C9F810F615B421819AB5CB1
D68629B4AB4A56970D306E713A0E7B290D1FDE7C0474C915A8DB588A1C75C1D7
7895CB6BDDC0C18F3E47AFCEC31F2FC9029FF9E9A889C8C79E4B377720F0C96D
E8333F0DEE5E9C25FAFA095D7AA1530486031427C787A0EBC6CF90B13CBCE908
30B6F18BD30456DE9ED21E3B59B1DBED7AD73ADF67CE4EF0599C0D8F6E29076D
720568B77F09DAF587FAE9C2692763FE24641CEE589801CACB6952E6A783664D
01B00337A350E0E46DD436CDDDEF8ED00C181D9107FE4C2BD22B69A55274FD41
89838431F92CCA06DFD93B0556DE635755D7E8152A49C77882E822E5CACC77F1
F6F07CF4DF760C74DBBF44167642F74609BAE8C2E9BF7B49160E13A0D3505990
4E428E8466A226723FF60C42217240B6E77E94357242E8629DA4BB3F1BBF2B21
DB15120765C07FEB31B83D3C0F192363E583023EED501C0EC7D75C5B2D6DE741
99BD137D97EFC389491E0EECF84ABC5326707C5401FA86A673E4D83881C84006
AE2CCC02E5B77B5013A31F9A03BFA5F60BB3645FE188C80655BF741C1F59C091
27D06CFB4BB7031329A8BECB0B5099F59EC0CAA71D7C64A3B490034C214B2B39
4014F25D41D5801C7053881CD0EE380EA33795C36D613932F50BD239E2A00207
8552AB10F534B145D03348151214E2F68BF6C8BEAC8333325F0446D818BDE9A8
B0C90E080C8C453A203032563EB2E17327AE42FD149AFB3EDEBEACC09B42E4C0
D8842FD027EE302A3124CBF78B688B282EA2CFC5D9A82CD90B4A580E6AE20F0C
9E818024D97EC95ED997752C543342D957620E814FEC611C9B50EE950141A165
F9C818192B9F3BF1E119678007B118D93ECF7E843EAFE4E2A389E5A0F21F2724
52C7D843A8441F920EC47E0A4AD44154C20B240802AEBC920BCAD23CD4AC2B19
9A03DC9EEC284BA8EF62D2119E2F75C67ECA36806DDD1E7348D8D6AA0E88414C
B67C9EFD5060E5C3B39A9A5ABDE2743A93AFAA07536396EF15297D78F3519136
BFA40AF851FC6156CE4A41286707E23E0325BE54FEBD520FCAB202219AD70E0D
4EA1802410805956164ABDAC8B75B26ECA80124DF6A24A846DBF6DB20A711955
166612C66C7970465BCD3AB32599331046E9105F86BE7354548507D6977227BC
FFCD3254224B581965E020A717550750185D4BBFAFFD9CA48C9D41CD86239481
6B37CFC0946419E5F85294FDCBA42E8E3E514738C4D988249B91C570FFFA3264
2C0FD0E4AABCB41B43DF3E2A32C0876BB506631867C08FBC114B895DA555A8BC
908AF7C41D84C712BF40DF6852B2A6B8DF014923698C23E602B0EE73505E3D82
9AC4E3833B10B89DDA5334D77DEE028F6AF425453D1D20DBBED1C5C858EE89A5
403E9F828C91B1F259ACB9BED14FE9E8E8F0A569592CE6AA6D9D70D782DD701B
A5F7BED728D2AB8B403820B27050A69653EC49A3B522130C08C80160076E4AA1
C0EDB23D8B2775620F4BDD51923E1C7D65CD018181B1DCB6340FEE9AFF89C0C8
DB4B0B3D8D4DCDF284DB6177A4D056522CA7833690F7C43525A208A9330A251C
0DCE42D44154C7822795507502355BBE1C5A06E2CB248564F4A52E197D140EC8
E8937DE1000A2C54B683DE2C91E745172E009F8ABBF703ADEDCEA9172F5E141B
9AECE326545EFC04941585A83A014259A4CB0191054F2AB9C783E6ADA13A500A
1EE0DD9547D094B3ED76A0480672C57E547EF331303656C9A7E27596C6FE0D4D
47E799E1F4E509A65157CF6598104F95653155A408BD4AA3030353C9B32A9168
122A864621376D3E0515BCBBF248EA9070F423C8F62ABD98F826C4170A6CBCF1
E2A3FD469BC3FB4EC1EE6809EDA3F5057B98FB270B88750A4F2CD2097467413A
E1990954C1A026E1D8D03220398F6EDA08F0FD03970226E91B214AB458333126
5EF250F5C15AA3C97B53CF8FF374A70F65A1CA7509316D4BA99CEE39021C89D5
AE2CDC900931266436349BBE183C03539265D445BDF78C7C09A8E065D6193CCF
13B4DC98F656A9C0C43B31BE9FB058ED035F84D85BDA422E74778B83ADFAF62E
1C15B94FCE9AABF43222AB0FA04AA5FE4CB8B24191D46C2A1FDA3C20DAAB7DA3
64BD1719969197BC679BB42E1AB5661F32165EAFF1FD44ADA961E0832D7E4E77
9E1D46FB8354D7ED4BC95F9AF0CE707220BC80D3E972423556EC599D0420CDC6
A3437340964A17256FA04D910C182DEBEF5C9A038C81D5F0FD84C15897DAD8DC
72F3DB9B96F6D323DADB9D95EAFA08D3BE32C935CF32D5094127B5BC7A8D8B12
BCF7F552CC3E61837DDFD85015AFF79CFF6DC45F3CBDCBBBD2DC582E57A9BCA7
3512DB660C7C3FC1972CA606DBD06E6D9A9A1DE368B0385C3BB5B4E366B87325
AF77F6A96342AD4E9E15CA3D3ED43132A014F757194FBEBB382FC1C37FACC817
36D936B3812F596AEA2CFFDC6D8DCDDE1278F6CC9976D5092CAE6CC651F1255C
99648A23F4FD939D7404DDD4724576C0F703FD11F78CFACA4291E55171C5505C
6913D967F07CC96230D57FBF5B1A7642CD84E061BDB31B83FF5001626259A557
1D29EA2FB55ECEA840DDEF45DE6D643F3958B9DAACD887C13B8EB10D3174F8A0
812F590CE686EF07DEF5309D784CB86E6B58724F58E191CD47647975C92A9506
431157698E907D1ED9FCB9D0E9D2CFF713566B53A5D15CFFAF5DF2B99E96F68E
1176BB23D555623942BC2BCAFEB315A7BE731CEF8A3B045E1565F501597223D4
48AF3EE059BD44D9A43ED4F72B641DAC8B29C347FB7C3FC1972CF536C7ADB966
753DA2C4B6B687F064C733B6CB115E5C553BCEC3AEE3F5189AF9171CB3B95C6C
09C52C2B26ACC3621F41DF01FD86A119DF20B505EA23FA0A1D34CEF8689FEF27
2C565B4873ABF3D65E747B3ECE8E333EBCECE0B5132F0079157BE3BF19883555
EF15303B2F808584DF076AC3B4E453713EDAAF6F6C0AA500FDFBFED5E0C6A7E3
CCD9E1BC8A75381C29B49F30F3A6887776BC3DE541AF8AA086EB9D07261F63F2
596C6B6BAB994FC56D8ED6A9ADEDA77FB87FF618D019DA14399DA7FD787B4A3B
BC24FA2CB2373757F0910D39F84DB3CD5641337C11652D89CF62F940994FC56F
85EDBF03EF05D52010E23D260000000049454E44AE426082
} 
stop: load #{
89504E470D0A1A0A0000000D49484452000000300000003008060000005702F9
870000001374455874536F667477617265005245424F4C2F566965778FD91678
0000109D49444154789CBD5A6B50555796C64AA5F237D34605246A6B8CE20345
41454501E5E133BE8D46D399EE744F4DD764FAA1A66C533553351D6BA626954E
6B17CE746AAAACEA64A62A1A3089313E133BBEF0818808F7FD38F79CCBBD28F8
00410461EDF9BE7DCE8D68404CDAEE53B5EA6EEE3D67AF6FADF5EDB5D6DE87A4
A4277059E1F0D386DF97E1ADABDB18F478DE76D5D6EEADBD72E5A8ABAEEE6C5D
6DEDD92B353547EB6A6AF6FA5DAEB75D35351B836E7786E1F73FFD24747FEF2B
160E3F63783D33DDB5B5A501BFDF571F8DDE696A6A92969616696B6B53EDEDED
EA6E7BBB40D49D3B77545B6BABDCBA754B5DBB7A552291C81D8FDBEDABB974A9
D47FA56666C4EB7DE66F06BC3E1878CA5F57B7D6E7F554C4E3F1EEDBB76F4B67
67A77477773F20F7F07D9B118284F5B8E76F5D5D5D72F7EE5DB979F3A6989148
776D4D4D455D55D55AC355F7D45F0D783C1C1E1076BBF27D3E5F0D3DDDD1D121
B8547757976AF17A24F4C16E75FE17FFA88EE4CD90F231C3D49E178652C4F954
656386097ED3F784FEB45BF08C7E160629444C62F5F502AAD578AAAAF2236ED7
80270ADEF2F99EF5BA5CBB1AE2F1767A8E4A3B6FB78855BE579D58BB4C7D32F1
05F918202965005DFEE2F36ADFD8E19011B22F7D841EE33B2973EEF97854AAE0
19FDAC89393817A2A2104D6584C3EDD5172FEE0A5CAE7EF689800FD4D58D0C05
02952DCDCD3AF4A440F49332F9B2244FCA00A41C80F78D4E93CF33D3E5D0EC2C
39363F57BE5A304F8E2F2E92E34B8B6DC198DF1DC56FBC673FEE2DC7337CB66C
D4503D57F4D3323D37E9C87582455F597BE1C2C8BF087CC8EDCE891846145E57
A44B5BC450A7D7AD907DF022443E1B3F4A1D999DAD8E2F9A2F5FBFB440514E2C
2D9113FCEC63ACEFC318CFA8C3789673D010883AB56E0575E8083737372BB7CB
15ADABBC90F3FDC07BDC3951CB6A20D73961FCF017EA70CE14F50994ED1F3B42
1D9D95255F2F2E5227979650E41480514E637C9A9FCEF84C8F71E29E53189FC4
279FE51C4730D76798938E39949329D4459DB791D1BC1E4FC37736029E1F699A
66D4012FE647FF279F8F1F259FBD902607278F95AF4BF285203440472A206729
2FDD97738EF4FCAEC2B9F78CF3FC2947FE8C3939F7A7D0415DD449DD34829178
6C3AC542C1678D50A812E0B517AC8FFE57F6BF90A63E1FFDBC3A3A7D923AB5A4
587B5503C6E7392D25727ED902A5E531C6B6610BD459472A9C48616E7574DA24
A12E384BEB66A6229DB82682FD2DEC6B516B40C0E7DBD58AA243CE5F3D7C501D
84370E60C2AF409F335070D6519E007D818271253E2F5230E6671505E3AA87BE
E77D95185F4818D6C3A00A0874C897D0459DD47DF5C841ED482EECCBC84E8F4C
B1562090DFD4D8D8CED0713101B47C81907E05AF9CC5C41A34953BE27DEB4D09
FFFE1D21D04B3DA4BA0F49FC5EE5089FF56EDBA2E73AEF0875544017751E806E
18A3B1303B31C57A51277AF7BE653D851B6AEEDDBB478BE5FCBA95EA20C2F825
78796E69B14A78BBD2F1AA1FE0BBEEB4A9EECE4E65ECDA2997F15D0D05BFD738
E32B185FE9E5FBCB1847DFDFA504BAEEB5B62ACFD64DDF44C73604D482CE63D0
4D0CC4A2D703EA048B5DA4B78A1D0904D6A28FD1E18A23CF1FC683C750842AB0
B82E389313F8A5650B24F02F5BD5BD5BB74439178C90C8CEDFA9DAE50B552D00
D4E13E2D0F8D6BF1C97BEA77ED10824F5C1D376F309A9C5B53ADD2A116751F45
763A042CC4C462878AADD8763C00BE311E7FC6348C0A16AA7BA88A678AF3E408
C2770A45A7D20977821A01789EE01FBEBA3AEE8AB9F377E2C63D9E3E84BFC501
BEDB6E431EB8B41188448262171D9A9E04066221266263DBC1DEC9ECD900C64C
73261AAB6E2EDC78F91E75140F1C9F304A552E29D20BB19A618784E025D0467B
5EAF72E74A8C49A7FAD29DE20705B420BBF41C5FFBA34D9B9ECFF67C9E74F2C1
886A3BD25AF7056020161A1147DB4186B0010CA08BFDC600A4CD529DF311A22A
F427C7470F958ADC6C056FA86A87BBE472F4BD77345DFA322041A77AD029B86C
A10A027410E039BE567A9F367D19D0D5D9A14EBEF92B395B9CA71DE6444311CB
57683D2E021B31B28B652B6E2FDE8686A7C12B3F17492B3AC4AF278E56D563D3
A46AF17C3D498DC35DF2D80DB1E0617ABA2F0338EEEEB8ABE230C28001060C68
2ADDA9D0BEF67A7FE26F823FFDAF6FA9BD1963E4F2E242EDB01A27FAC4523DE6
79F933B011231B4AEC27FC116E8A1A62B18C9B376EDCA101F51FEC9693F07E20
7BAC78572283103CC4E570D80B2115A23BDE952E4CF2A88B916800DF6FBC5F0A
CF773EF2DE7B98EB04D2E9C700EF460AE55AA97374D308CF0AE8CD1A2B27808D
18B956B92942C790916499E6C63B581834C08D5EFDFCE8A12A5C902591978B95
6B7989B2C12F503E87CBA445089488C30846A23F3A01FC23EFA1E7097E5FE638
E581E7E920EAA24EEA2686C89A6215CECB9273C0E6FEE5CF754A656173637B9A
845DD576A76D90CAFC1C842A4D198B72C55A8F876084F63A260B404290301444
F0692E2B8187DF53FDD1E951E3046DCA278D9100C0871D07F91D8731EAA1B5C5
CA020E6341AE5C7A314D1123B1727B1A70B9B6275996B927D1E7578C1D2EB5E9
C324B2BC40CC578AC4FA519184D6144B805E279F35F8123197154A787EB604A6
8E90E8BF6DE9974EBD5D5D09DA8016C17C447C69919E3BECE8D23AA1DBDA5824
E6BA62FC56A0B19D0646DD29A0DD417FB4270929E9280B4417F6AD15A3D3947B
FC7065AE2A146B032CFF51B18AFEB8588C550823B201BCAE228BE64A70C61815
C8C45A9992AA02D386AAFAED5BFAA5D343B42178559E0E7D9331C76418317D8C
8A2C9C4B3D7AE187A1D3FA7B18F02A70800DE68A42718F1BAECE006357EB6DE1
41014F3B92A2D1E859E6D6BB91303896A6BC134728734D916DC06B30E0F52289
FEB44859E0A151325305A60E974066AAF267A548607A8A0AE44066A548ECDD6D
8F45A72EDC03DA48597AAAF2F0F969986B2AE6A22199C395513453ACD5D40BFD
3F2EBA6FC0AA62F18C1FA1CE0223B1F2B483473649F530409F121861B980CD0A
0C101A606EC0C3AF013C0DF8078C5FC992E0CCA1E29F0265D9901910000FE626
4B706EB234EDD826D2F9ED0AFB2DEAE09EAADF6E133F9F9B9D2C8199DA111280
43FC99A9886E9A98EBB324FA33E8D40600CB7AC8EA62F14E1821E7510F889547
363C776216FA864217D173787B528811F8091E7E65BA0A97A44286A8500114CF
4A51C1D929048EBF5355E3BB9B09FEB129D40D2362FFB9593F1B9C634790910C
E561BEE221122E4E55E6BAE90F466065A17840A10BA410B0F2DC8987678C0017
B15ED9D563862B4FFA30C5456CBDC23500EA6C9823A1F9692A5498ACC20B86A8
F092C102C1DF4304C6A8C6F736A348DDFDCE59A81BFBECD83B30221FA0E703F4
A2C18A420342F3F1DDBC3465AE9FC308286B5DB18A2C2B10CFD861EA1230EA45
DCD6A6DCB5B57B92AE36346CBFE71C4C79F272C4FD629A4416E7EAB0591BE661
B29112CC4BE6A4122A81A2C583C55836488C95CFC9F5F7B73E166DFABA1889F8
AEAD62AC780ED9078E5908F034609E4DCB5001B696EBE78BF932B2D0C25C7101
9B1B1889952780418F673B23B011E1B0F7BE28642E16B2795942AB8D45992A48
9EE721BCF3108162089418CB9255D37FFD1A45EAD1B421DFBBFA2D761D683B36
C1003BC2A1221880A8686AE5A488B1205359A80561A4DA3A6CFA23C048AC3C5C
E3596C122A5A06ACD1ADC4F53FED566EDC149C962EE6CA02159C314C4FC2C948
97501164C11069FAC3A67E6993C83697FE639B06D99701DA08CC157B6F93BDC6
1869AC05AC31C5C51D9C3E4C99CB81253B1D06A4A9A60F766B0378168B5E2823
095BC8A761846EE6DABD6EACF4D1E24F4F93D0DC0C3BE37012648B048D9A4A7F
D32F6DEC22F5A6944F45B436FE401ADEFF95DE2FF44BA71DBF9160814D1F9D9D
90EDFC935325949B213E34731E6023466E2F037EBF9FA7E2BA238D5A5629B692
BA9D36D1B2FAC6205D8E1FAAFCCCCD9824381359676E8ABAF6EF6F2882EF8F36
27B7BDA93EC94686593750CC8D3F50E6C6E754C37FFF9A207B8D40E26FFE6EFD
F60D09E4C2FB3352747DF067A04E8C1BAA7CA8D89135763BCD03659E8ADFDF0F
C7E3B35A5B5BF586A6191B1A5F7AAAF021FF44A7C8CCD06953C57EB11C9B8EDB
7D1A90A04D792628B07AA08AD080750395F932C66B074AC31FB77E8B4E3D9FEF
C49EF7C0BA9572318B050E06A02EF8C703C3D8A1DAA9CDD8D0F0569E8A47BC9E
FB1B9A9B4D8DCF34C4E315FAE81BDBB6C892B902F07C58875017AE1CBB68996F
2C97CE1B4D7DD36612A8860C65AC1E28C69A81F6E76AFCBDEA399DB9E27FD8D4
2B9DEE5C6F92FD2FAF94C313E175D0D6F13EE86CE33016CFD5D8B8F1D247FBE1
F083EF146296B5B61DFD052D6CD95FA6FB1C6DFD8454A7E7411448A5392962FD
72B5A2110FD3665F26A2B6042976F92065ACA000F40A67BC7C10D32F3ACE6415
FBFDE66F7A275E047F60C31A756822BCCE0A9F95AAE9AB1D388EBD52AA6ADEAF
0F7F15B28F0AD4D53DB8A9E775E3DAD5A7109A9AC44B88E8EB2B3891F8C6A5DA
9E98EA94FC993A2BE948904E04AF7B9B0929E273EA842E764B7B08FFE6F78B9C
5C8FFB62683DB870411BEDF943F43CA2ECCFB65B0A3A8E5486F324FA93151A13
77627C3F110F067A7F11722D6AE5DF6E69D1075B1D96A18CC59395EE51E0052E
A6C0D4543BB53112369DD4A92DFFACCAC6C3B042BB4EE862C78ACD9C0EB0006C
8FF97DF110FB9EC264162B2E58725E69DA609D05B0F03578AEBD74EA431D5838
59110BFB35BE9F88B85DBD1F6CF1BAD5D838A0DE327725DEBEDC3EFE05F2F20F
D968D974CA7016F534BBC870615743B11711D175625EB29DC70B9D9AC1A254E4
8C0B93ED1601F705F393757164B6E18225E7B1CE94EE72273AB4016D43053F14
62D0B46E6E16BE64B96A841FFDF6E67A3CF62C36FA954E7FA49A3FFB101B8E64
3B2BD891B0D744B6939D180DD609143B82D2F522DF015A906C1B966F830EE5D9
E95877B06C08739C6C93A5F33DD71B3DAF1DC6B99A3FFD50F39EEF27F89225E6
F73DDE5B9B58C41889C5124DECD49AF77F28C6A211509A6C67A6097676D2D1C8
76D6468EBD3E023426D791398E60CCEF03B39C0295D3A3859EE2641B7BC1829E
C9A0DD08AD5353196CE04B9690ABEEBBBDAD69B0223937AE5F6FA0119849B59E
3880EE3043778E81CC143B434C74B2C5143B73686A4DB723A325C76E939DBFED
0D10A9C2CD10B3DC24C7EB001E98CC7E6B086A4686501775123C5FB2181ED7F7
7B4B43239C48681E76D687557CCB4BCC2CE8DD87D85572BCC3DB49A9368769CC
547BC1EB5D5B963366B4321D8333741455A25886E6EAECA5629B5FA20EBDFE78
D0C0972C86D7FDFDC027AE98698CE49A48BCADD1A7C45F7E2CF5FF344B17A770
E160D0C8A696CF114DB1890FC904E7F771365DF84C08CFB2B8457F3E5BCF9998
9FEF2722E15065D8EBFECB5EF2252E2E6C66A7448AA587BA5A5BA0F423157F6B
91B25EC51E02AD83B1681016EC6009E660D16741188DCC143DC67712CE1FACEF
89AC628FF4BC7E9673702E2E561EEDF3FD44D0E7DB150F079FCC6BD6C475ABA9
71C0B57A2B9FC58E153B61089BAB0EC32D2D5FFC8F6ADCF1BAAA7F2313BBA841
D8CDA1897BEDEF849F7AFCEA20C16FFA1EDC2B78463FAB9D8175C6A37DBE9F88
06FDF98DF5D6937DD1DDF362C58E45CDB5EC9DD800EA2EF6A17F33D03D555B8B
7446435A1C0F7F4B484B9E8A9B11A322120CAC05F0BFDEBF1A3C7CB1016C6C88
CFAA472B8EFD848F9B22EEECB83DD58704B6686A24C65C983CC6E4596CACBEDE
678443A571CB9CD5D410FFDBFDB3476F97B329CAE0F6F4EAD586B7F1B9D732CD
633CB28946A3E7CC48E49865997B41BFB77916DB108F655CBBDAF044FEDDE6FF
019DEB617075C550CD0000000049454E44AE426082
}
]
widgets: make object![
default-edge: make object![
color: colors/outline/3 
image: none 
effect: none 
size: 1x1
]
default-font: make object![
name: effects/font 
style: none 
size: sizes/font 
color: colors/text 
offset: 0x0 
space: 0x0 
align: 'left 
valign: 'middle 
shadow: none
]
default-para: make object![
origin: 2x2 
margin: 2x2 
indent: 0x0 
tabs: 0 
wrap?: false 
scroll: 0x0
]
default-feel: make object![
redraw: 
detect: 
over: 
engage: none
]
default-action: make object![
on-alt-click: 
on-away: 
on-click: 
on-dbl-click: 
on-edit: 
on-focus: 
on-key: 
on-over: 
on-resize: 
on-scroll: 
on-time: 
on-unfocus: none
]
font-button: make default-font[align: 'center]
font-heading: make default-font[color: colors/theme/3 size: sizes/font * 2]
font-label: make default-font[color: colors/theme/2]
font-link: make default-font[style: 'underline color: blue]
font-right: make default-font[align: 'right]
font-top: make default-font[valign: 'top]
para-wrap: make default-para[origin: 2x0 wrap?: true]
para-indent: make default-para[origin: as-pair sizes/line 2]
over?: make function![face event][
all[
event/offset/x < face/size/x 
event/offset/y < face/size/y 
event/offset/x >= 0 
event/offset/y >= 0
]
]
feel-click: make object![
redraw: 
detect: none 
over: make function![face into pos /state][
all[state set-state/no-show face into]
set-color face either into[colors/theme/1][none]
]
engage: make function![face act event][
switch act[
down[face/feel/over/state face on 0x0]
up[set-state face off all[over? face event face/action/on-click face]]
over[face/feel/over/state face on 0x0]
away[face/feel/over/state face off 0x0]
]
]
]
baseface: system/standard/face 
baseface/color: 
baseface/edge: 
baseface/font: 
baseface/para: 
baseface/feel: none 
gradface: make baseface[
effect: reduce['gradient 0x1 white colors/outline/1]
edge: default-edge 
font: font-button
]
text-size?: make function![
"Returns default text size." 
string[string!]
][
size-text make baseface[
size: 10000x10000 
text: string 
font: default-font
]
]
text-width?: make function![
{Returns greater of text width, specified size and line height.} 
face 
/pad 
/local x
][
pad: either pad[sizes/font][0]
x: face/size/x 
face/size/x: 10000 
max sizes/line either negative? x[pad + first size-text face][max x pad + first size-text face]
]
sizes/font-height: second text-size? "" 
face-iterator: make baseface[
type: 'face-iterator 
pane:[]
data:[]
options:[]
timeout: now/time/precise 
feel: make default-feel[
redraw: make function![face act pos][
all[act = 'show face/size <> face/old-size face/resize]
]
engage: make function![face act event /local i][
if act = 'time[
if (now/time/precise - face/timeout) > 0:00:00.2[
face/action/on-click face 
face/rate: none 
show face
]
]
if act = 'key[
switch event/key[
#"^A"[
all[
find face/options 'multi 
clear face/picked 
repeat i face/rows[insert tail face/picked i]
face/action/on-click face
]
]
down[
all[empty? face/picked insert face/picked 0]
i: 1 + last face/picked 
if i <= face/rows[
insert clear face/picked i 
if find[table text-list tree]face/parent-face/type[
face/timeout: now/time/precise 
face/rate: 60 
if i > (face/scroll + face/lines)[
face/pane/2/data: 1 / (face/rows - face/lines) * ((min (face/rows - face/lines + 1) (i - face/lines + 1)) - 1) 
face/scroll: face/scroll + 1
]
]
]
]
up[
all[empty? face/picked insert face/picked face/rows + 1]
i: -1 + last face/picked 
if i > 0[
insert clear face/picked i 
if find[table text-list tree]face/parent-face/type[
face/timeout: now/time/precise 
face/rate: 60 
if i = face/scroll[
face/pane/2/data: 1 / (face/rows - face/lines) * ((min (face/rows - face/lines + 1) i) - 1) 
face/scroll: face/scroll - 1
]
]
]
]
#"^M"[
face/action/on-click face
]
]
show face
]
]
]
lines: 
rows: 
widths: 
aligns: 
tab-levels: none 
cols: 1 
picked:[]
scroll: 0 
resize: make function![][
lines: to integer! size/y / sizes/line 
pane/2/show?: either rows > lines[
scroll: max 0 min scroll rows - lines 
true
][
scroll: 0 
false
]
]
redraw: make function![][
clear picked 
rows: either empty? data[0][(length? data) / cols]
resize 
pane/2/ratio: either zero? rows[1][lines / rows]
show self
]
selected: make function![/local blk][
all[empty? picked return none]
if parent-face/type = 'tree[
return either find options 'only[
trim/head copy pick data first picked
][
pick parent-face/.data-path first picked
]
]
either any[find options 'multi parent-face/type = 'table][
all[rows = length? picked return data]
blk: copy[]
either cols = 1[
foreach row picked[insert tail blk pick data row]
][
foreach row picked[
repeat col cols[
insert tail blk pick data -1 + row * cols + col
]
]
]
blk
][pick data first picked]
]
init: make function![/local p][
error? try[remove find span #X]
error? try[remove find span #Y]
lines: to integer! size/y / sizes/line 
rows: (length? data) / cols 
clear pane 
p: self 
insert pane make baseface[
size: p/size 
span: p/span 
pane: make function![face index /local col-offset clr][
either integer? index[
if index <= min lines rows[
line/offset/y: index - 1 * sizes/line 
line/size/x: size/x 
index: index + scroll 
either p/parent-face/type = 'table[
col-offset: 0 
repeat i p/cols[
line/pane/:i/offset/x: col-offset 
line/pane/:i/size/x: p/widths/:i - sizes/cell 
all[
p/pane/2/show? 
i = p/cols 
line/pane/:i/size/x: line/pane/:i/size/x + (p/size/x - p/pane/2/size/x - (line/pane/:i/offset/x + line/pane/:i/size/x))
]
line/pane/:i/text: form pick p/data index - 1 * cols + i 
line/pane/:i/font/color: either find picked index[colors/edit][colors/text]
col-offset: col-offset + pick widths i
]
][
line/text: form pick face/parent-face/data index 
line/font/color: either find picked index[colors/edit][colors/text]
]
line/color: case[
find picked index[colors/theme/3]
all[even? index face/parent-face/type <> 'choose][snow]
]
line/data: index 
line
]
][to integer! index/y / sizes/line + 1]
]
text: "" 
line: make baseface[
size: as-pair 0 sizes/line 
font: make default-font[]
para: either tab-levels[make default-para[tabs: tab-levels]][none]
feel: make default-feel[
over: make function![face into pos][
all[
face/parent-face/parent-face/type = 'choose 
either into[insert clear picked data][clear picked]
show face
]
]
engage: make function![face act event /local p a b][
p: face/parent-face 
either event/double-click[
all[act = 'down p/parent-face/action/on-dbl-click p/parent-face]
][
if find[up alt-up]act[
view*/focal-face: p 
view*/caret: tail p/text 
either find p/parent-face/options 'multi[
unless any[event/control event/shift][clear picked]
either all[event/control find picked data][
remove find picked data
][
unless find picked data[insert tail picked data]
]
if all[event/shift 1 < length? picked][
clear next picked 
repeat i (max data first picked) - (a: min data first picked) + 1[
b: i + a - 1 
all[b <> first picked insert tail picked b]
]
]
][
either any[empty? picked data <> first picked][
insert clear picked data
][
clear picked
]
]
show p 
either act = 'up[
p/parent-face/action/on-click p/parent-face
][
p/parent-face/action/on-alt-click p/parent-face
]
]
]
]
]
]
]
if find options 'table[
pane/1/line/pane: copy[]
repeat i cols[
insert tail pane/1/line/pane make baseface[
size: as-pair 0 sizes/line 
font: either 'left = aligns/:i[default-font][make default-font[align: aligns/:i]]
]
]
]
insert tail pane make slider[
offset: as-pair p/size/x - sizes/slider - 1 -1 
size: as-pair sizes/slider p/size/y 0 
span: case[none? p/span[none]find p/span #H[#H]]
show?: either rows > lines[true][false]
action: make default-action[
on-click: make function![face][
scroll: to integer! rows - lines * data 
show face/parent-face
]
]
ratio: either rows > 0[lines / rows][1]
]
pane/2/init
]
]
load-icon: make function![
size[pair!]
file[file!]
/local cache icon
][
cache:[]
file: rejoin[%icons/ size %/ file]
unless icon: select cache file[
insert tail cache reduce[file icon: load file]
]
icon
]
choose: make function![
parent[object!]"Widget to appear in relation to" 
width[integer!]"Width in pixels" 
xy[pair!]"Offset of choice box" 
items[block!]"Block of items to display" 
/local popup result
][
result: none 
popup: make face-iterator[
type: 'choose 
offset: xy 
size: as-pair width sizes/line * min length? items to integer! parent/parent-face/size/y - xy/y / sizes/line 
color: colors/edit 
edge: default-edge 
data: items 
action: make default-action[
on-click: make function![face][result: pick data first picked hide-popup]
]
]
popup/init 
view*/caret: popup/pane/1/text 
view*/focal-face: popup/pane/1 
show-popup/window popup parent/parent-face 
wait[]
result
]
anim: make baseface[
options: {USAGE:
anim data[ctx-rebgui/images/help ctx-rebgui/images/info]
anim data[%img1.png %img2.png %img3.png]
anim data[img1 img2 img3]rate 2
DESCRIPTION:
Cycles a set of images at a specified rate.}
size: -1x-1 
effect: 'fit 
action: make default-action[
on-time: make function![face][
face/image: first face/data 
face/data: either tail? next face/data[head face/data][next face/data]
show face
]
]
rate: 1 
init: make function![/local v][
repeat n length? data: reduce data[
v: pick data n 
all[file? v poke data n load v]
]
image: first data 
data: next data 
all[negative? size/x size/x: image/size/x]
all[negative? size/y size/y: image/size/y]
]
]
pill: make baseface[
options: {USAGE:
pill red
DESCRIPTION:
A rectangular area with rounded corners.}
size: 10x10 
effect:[
draw[
pen colors/outline/3 
line-width 1 
fill-pen linear 0x0 0 0 90 1 1 colors/outline/1 white colors/outline/1 
box 0x0 0x0 effects/radius
]
]
action: make default-action[
on-resize: make function![face][
either face/size/x >= face/size/y[
poke face/effect/draw 8 to integer! face/size/y * 0.1 
poke face/effect/draw 9 to integer! face/size/y * 0.9 
poke face/effect/draw 10 90
][
poke face/effect/draw 8 to integer! face/size/x * 0.1 
poke face/effect/draw 9 to integer! face/size/x * 0.9 
poke face/effect/draw 10 0
]
poke face/effect/draw 18 face/size - 1x1
]
]
init: make function![][
all[color set-color/no-show self color]
all[font size/x: text-width?/pad self]
action/on-resize self
]
]
area: make baseface[
options: {USAGE:
area
area "Text" -1
area "Text" 50x-1
DESCRIPTION:
Editable text area with wrapping and scroller.}
size: 50x25 
text: "" 
color: colors/edit 
edge: default-edge 
font: font-top 
para: make para-wrap[margin: as-pair sizes/slider + 2 2]
feel: make edit/feel[
redraw: make function![face act pos /local height total visible][
if act = 'show[
if face/size <> face/old-size[
face/pane/offset/x: max 0 face/size/x - face/pane/size/x 
face/pane/size/y: face/size/y
]
if any[
face/text-y <> height: second size-text face 
face/size <> face/old-size
][
face/text-y: height 
total: face/text-y 
visible: face/size/y - (edge/size/y * 2) - para/origin/y - para/indent/y 
face/pane/ratio: either total > 0[min 1 (visible / total)][1]
face/pane/step: either visible < total[min 1 (sizes/font-height / (total - visible))][0]
]
if all[face/pane/ratio < 1 face/key-scroll?][
do bind[
total: text-y 
visible: size/y - (edge/size/y * 2) - para/origin/y - para/indent/y 
pane/data: - para/scroll/y / (total - visible)
]face 
face/key-scroll?: false
]
]
]
]
action: make default-action[
on-resize: make function![face][
face/pane/offset/x: face/size/x - sizes/slider 
face/pane/size/y: face/size/y 
face/line-list: none
]
on-scroll: make function![face scroll /page /local total visible][
total: second size-text face 
visible: face/size/y - (face/edge/size/y * 2) - face/para/origin/y - face/para/indent/y 
face/para/scroll/y: either page[
min max face/para/scroll/y - (visible * sign? scroll/y) (visible - total) 0
][
min max face/para/scroll/y - (scroll/y * sizes/font-height) (visible - total) 0
]
all[face/pane/data: - face/para/scroll/y / (total - visible)]
show face
]
]
esc: none 
caret: none 
undo: copy[]
text-y: none 
key-scroll?: false 
init: make function![/local p][
para: make para[]
p: self 
text-y: second size-text self 
all[negative? size/x size/x: 10000 size/x: 4 + first size-text self]
all[negative? size/y size/y: 10000 size/y: 8 + text-y]
pane: make slider[
offset: as-pair p/size/x - sizes/slider -1 
size: as-pair sizes/slider p/size/y 
action: make default-action[
on-click: make function![face /local visible][
unless parent-face/key-scroll?[
visible: (parent-face/size/y - (parent-face/edge/size/y * 2) - parent-face/para/origin/y - parent-face/para/indent/y) 
parent-face/para/scroll/y: negate parent-face/text-y - visible * data 
show parent-face
]
parent-face/key-scroll?: false
]
]
ratio: p/size/y - 4 / text-y
]
pane/init
]
]
arrow: make gradface[
options: {USAGE:
arrow
arrow 10
arrow data 'up
arrow data 'down
arrow data 'left
arrow data 'right
DESCRIPTION:
An arrow (default down) on a square button face with height set to width.}
size: 5x-1 
text: none 
data: 'down 
font: none 
feel: make feel-click[
engage: make function![face act event][
switch act[
time[all[over? face event face/data face/action/on-click face]]
down[set-state face face/data: on]
up[all[over? face event face/action/on-click face]set-state face face/data: off]
over[face/feel/over/state face face/data: on 0x0]
away[face/feel/over/state face face/data: off 0x0]
]
]
]
action: default-action 
old-color: none 
init: make function![][
all[color set-color/no-show self color]
insert tail effect reduce['arrow colors/text 'rotate select[up 0 right 90 down 180 left 270]data]
effect/gradient: select[up 0x1 right 1x0 down 0x-1 left -1x0]data 
all[negative? size/y size/y: size/x]
data: off
]
]
bar: make baseface[
options: {USAGE:
bar 100
DESCRIPTION:
A thin bar used to separate widgets.
Defaults to maximum display width.}
size: -1x-1 
color: colors/outline/3 
init: make function![][
size/y: 1
]
]
box: make baseface[
options: {USAGE:
box red
DESCRIPTION:
The most basic of widgets, a rectangular area.}
size: 25x25
]
btn: make gradface[
options: {USAGE:
btn "Hello"
btn -1 "Go!"
btn "Click me!"[print "click"]
DESCRIPTION:
Performs action when clicked.}
size: -1x5 
text: "" 
font: font-button 
feel: feel-click 
action: default-action 
old-color: none 
init: make function![][
all[color set-color/no-show self color]
all[font size/x: text-width? self]
]
]
button: make pill[
options: {USAGE:
button "Hello"
button -1 "Go!"
button "Click me!"[print "click"]
DESCRIPTION:
Performs action when clicked.}
size: 15x5 
text: "" 
font: font-button 
feel: feel-click 
old-color: none
]
calendar: make baseface[
options: {USAGE:
calendar
calendar data 1-Jan-2000
DESCRIPTION:
Used to select a date, with face/data set to current selection.
Default selection is now/date.}
size: 56x40 
color: colors/edit 
edge: default-edge 
feel: make default-feel[
redraw: make function![face act pos /local date month][
if act = 'show[
date: face/date 
month: date/month 
date/day: 1 
date: date - date/weekday + 1 
foreach f skip face/pane 12[
f/text: form date/day 
f/font/color: either date/month = month[colors/text][colors/outline/1]
f/color: f/data: either all[date/month = month date = face/data][
f/font/color: colors/edit 
colors/theme/3
][none]
date: date + 1
]
face/pane/3/text: reform[pick locale*/months face/date/month next next form face/date/year]
]
]
]
action: default-action 
date: none 
init: make function![/local spec v][
spec:[
tight 
btn 8 "|<"[face/parent-face/date/year: face/parent-face/date/year - 1 show face/parent-face]
btn 8 "<"[face/parent-face/date/month: face/parent-face/date/month - 1 show face/parent-face]
btn 24[face/parent-face/date: face/parent-face/data show face/parent-face]
btn 8 ">"[face/parent-face/date/month: face/parent-face/date/month + 1 show face/parent-face]
btn 8 ">|"[face/parent-face/date/year: face/parent-face/date/year + 1 show face/parent-face]
return
]
foreach day locale*/days[
insert tail spec compose[label 8 (copy/part day 3) font[align: 'center]]
]
loop 6[
insert tail spec 'return 
loop 7[
insert tail spec[
box 8x5 font[align: 'center valign: 'middle]feel[
over: make function![face into pos][
face/color: either all[into face/font/color <> colors/outline/1][colors/theme/1][face/data]
show face
]
engage: make function![face act event /local p][
if all[act = 'up face/font/color <> colors/outline/1][
p: face/parent-face 
p/data: p/date 
p/data/day: to integer! face/text 
show p 
p/action/on-click p
]
]
]
]
]
]
v: any[data now/date]
data: layout/only spec 
pane: data/pane 
foreach n pane[n/offset: n/offset - 1x1]
repeat n 5[pane/:n/size/x: pane/:n/size/x + 1]
data: date: v
]
]
chat: make baseface[
options: {USAGE:
chat 120 data["Bob" blue "My comment." yello 14-Apr-2007/10:58]
DESCRIPTION:
Three column chat display as found in IM apps such as AltME.
Messages are appended, with those exceeding 'limit not shown.
OPTIONS:
[limit n]where n specifies number of messages to show (default 100)
[id n]where n specifies id column width (default 10)
[user n]where n specifies user column width (default 15)
[date n]where n specifies date column width (default 25)}
size: 200x100 
pane:[]
data:[]
edge: default-edge 
action: make default-action[
on-resize: make function![face][
poke face/pane/2/para/tabs 3 face/pane/1/size/x - (sizes/cell * any[select face/options 'date 25]) 
face/redraw/no-show
]
]
height: 0 
rows: 0 
limit: none 
append-message: make function![
user[string!]
user-color[tuple! word! none!]
msg[string!]
msg-color[tuple! word! none!]
date[date!]
/no-show row 
/local p y t1 t2 t3
][
t1: pick pane/2/para/tabs 1 
t2: pick pane/2/para/tabs 2 
t3: pick pane/2/para/tabs 3 
y: max sizes/line 4 + second size-text make baseface[
size: as-pair t3 - t2 10000 
text: msg 
font: default-font 
para: para-wrap
]
p: self 
insert tail pane/1/pane reduce[
make gradface[
offset: as-pair -1 height - 1 
size: as-pair t1 y 
text: form any[row rows: rows + 1]
]
make baseface[
offset: as-pair t1 - 1 height - 1 
size: as-pair t2 - t1 y 
text: user 
edge: make default-edge[size: 0x1]
font: make font-top[color: either word? user-color[get user-color][user-color]style: 'bold]
]
make baseface[
offset: as-pair t2 - 1 height - 1 
size: as-pair t3 - t2 y 
span: all[p/span find p/span #W #W]
text: form msg 
color: either word? msg-color[get msg-color][msg-color]
edge: make default-edge[size: 0x1]
font: default-font 
para: para-wrap
]
make baseface[
offset: as-pair t3 - 1 height - 1 
size: as-pair p/size/x - t3 - sizes/slider + 1 y 
span: all[p/span find p/span #W #X]
text: form either now/date = date/date[date/time][date/date]
edge: make default-edge[size: 0x1]
font: font-top
]
]
height: height + y - 1 
if ((length? pane/1/pane) / 4) > limit[
y: pane/1/pane/1/size/y - 1 
remove/part pane/1/pane 4 
foreach[i u m d]pane/1/pane[
i/offset/y: u/offset/y: m/offset/y: d/offset/y: i/offset/y - y
]
height: height - y
]
unless no-show[
insert tail data reduce[user user-color msg msg-color date]
pane/1/size/y: height 
pane/3/ratio: pane/3/size/y / height 
show p
]
show pane/1
]
set-user-color: make function![id[integer!]color[tuple! word! none!]/local idx][
if any[zero? id id > rows][exit]
poke data id * 5 - 3 color 
if limit > (rows - id)[
idx: either rows > limit[(id + limit - rows) * 4 - 2][id * 4 - 2]
pane/1/pane/:idx/font/color: either word? color[get color][color]
show pane/1/pane/:idx
]
]
set-message-text: make function![id[integer!]string[string!]/local idx][
if any[zero? id id > rows][exit]
poke data id * 5 - 2 string 
if limit > (rows - id)[
idx: either rows > limit[(id + limit - rows) * 4 - 1][id * 4 - 1]
insert clear pane/1/pane/:idx/text string 
redraw
]
]
set-message-color: make function![id[integer!]color[tuple! word! none!]/local idx][
if any[zero? id id > rows][exit]
poke data id * 5 - 1 color 
if limit > (rows - id)[
idx: either rows > limit[(id + limit - rows) * 4 - 1][id * 4 - 1]
pane/1/pane/:idx/color: either word? color[get color][color]
show pane/1/pane/:idx
]
]
redraw: make function![/no-show /local row][
clear pane/1/pane 
height: 0 
rows: (length? data) / 5 
row: max 0 rows - limit: any[select options 'limit 100]
foreach[user user-color msg msg-color date]skip data row * 5[
append-message/no-show user user-color msg msg-color date row: row + 1
]
pane/1/size/y: height 
pane/3/ratio: either zero? height[1][pane/3/size/y / height]
unless no-show[show self]
]
init: make function![/local p][
unless options[options: copy[]]
p: self 
limit: any[select options 'limit 100]
insert pane make baseface[
offset: as-pair 0 sizes/line 
size: p/size - as-pair sizes/slider sizes/line 
span: all[p/span find p/span #W #W]
pane:[]
]
insert tail pane make gradface[
offset: -1x-1 
size: as-pair p/size/x sizes/line 
text: {ID^-User^-Message^-Sent} 
span: all[p/span find p/span #W #W]
font: make font-button[align: 'left]
para: make default-para[tabs:[0 0 0]]
]
poke pane/2/para/tabs 1 sizes/cell * any[select options 'id 10]
poke pane/2/para/tabs 2 sizes/cell * (any[select options 'user 15]) + pick pane/2/para/tabs 1 
poke pane/2/para/tabs 3 size/x - sizes/slider - (sizes/cell * any[select options 'date 25]) 
insert tail pane make slider[
offset: as-pair p/size/x - sizes/slider sizes/line - 2 
size: as-pair sizes/slider p/size/y - sizes/line + 2 
span: case[
none? p/span[none]
all[find p/span #H find p/span #W][#XH]
find p/span #H[#H]
find p/span #W[#X]
]
action: make default-action[
on-click: make function![face][
if height > face/size/y[
face/parent-face/pane/1/offset/y: (height - face/size/y * negate face/data) + sizes/line 
show face/parent-face
]
]
]
]
pane/3/init 
action/on-resize self
]
]
check: make baseface[
options: {USAGE:
check "Option"
check "Option" data true
check "Option" data false
DESCRIPTION:
Bistate check-box with a tick for Yes and empty for No.}
size: -1x5 
text: "" 
effect:[draw[pen colors/outline/3 fill-pen colors/edit box 0x0 0x0]]
font: default-font 
para: para-indent 
feel: make default-feel[
over: make function![face act pos][
face/effect/draw/pen: either act[colors/theme/1][colors/outline/3]
show face
]
engage: make function![face act event][
switch act[
down[
face/data: either none? face/data[true][none]
clear skip face/effect/draw 7 
unless none? face/data[
insert tail face/effect/draw reduce[
'pen colors/true 
'line-width sizes/cell / 3 
'line as-pair 2 sizes/cell * 3 as-pair sizes/cell * 1.5 p2/y as-pair p2/x p1/y
]
]
show face 
face/action/on-click face
]
away[face/feel/over face false 0x0]
]
]
]
action: default-action 
p1: as-pair 2 sizes/cell + 2 
p2: -4x-4 + p1 + as-pair sizes/cell * 3 sizes/cell * 3 
init: make function![][
all[negative? size/x size/x: 10000 size/x: 4 + para/origin/x + first size-text self]
effect/draw/6/y: sizes/cell 
effect/draw/7: as-pair sizes/cell * 3 sizes/cell * 4 
all[
data 
insert tail effect/draw reduce[
'pen colors/true 
'line-width sizes/cell / 3 
'line as-pair 2 sizes/cell * 3 as-pair sizes/cell * 1.5 p2/y as-pair p2/x p1/y
]
]
]
]
check-group: make baseface[
options: {USAGE:
check-group data["Option-1" true "Option-2" false "Option-3" none]
DESCRIPTION:
Group of check boxes.
Alignment is vertical unless height is specified as line height.
At runtime face/data is a block of logic (or none) indicating state of each check box.}
size: 50x-1 
pane:[]
init: make function![/local off siz pos last-pane][
data: reduce data 
all[negative? size/y size/y: 0.5 * sizes/line * length? data]
off: either size/y > sizes/line[
siz: as-pair size/x sizes/line 
as-pair 0 sizes/line
][
siz: as-pair 2 * size/x / length? data sizes/line 
as-pair siz/x 0
]
pos: 0x0 
foreach[label state]data[
insert tail pane make check[
offset: pos 
size: siz 
text: label 
data: state
]
pos: pos + off 
last-pane: last pane 
last-pane/options: options 
last-pane/init 
last-pane/init: none
]
data: make function![/local states][
states: copy[]
foreach check pane[insert tail states check/data]
states
]
]
]
drop-list: make gradface[
options: {USAGE:
drop-list "1" data[1 2 3]
drop-list data["One" "Two" "Three"]
drop-list data ctx-rebgui/locale*/colors
DESCRIPTION:
Single column modal selection list.
At runtime face/text contains current selection.}
size: 25x5 
text: "" 
data:[]
font: default-font 
feel: make feel-click[
engage: make function![face act event][
switch act[
down[set-state face on]
up[set-state face off all[over? face event face/pane/feel/engage face/pane act event]]
over[face/feel/over/state face on 0x0]
away[face/feel/over/state face off 0x0]
]
]
]
action: make default-action[
on-resize: make function![face][
face/pane/offset/x: face/size/x - sizes/line - 2
]
on-unfocus: make function![face][
face/hidden-text: face/hidden-caret: none 
true
]
]
hidden-caret: hidden-text: none 
picked: make function![][
index? find data text
]
init: make function![/local p][
unless block? data[request-error "drop-list expected data block"]
para: make para[]
p: self 
pane: make baseface[
offset: as-pair p/size/x - p/size/y - 2 0 
size: as-pair p/size/y - 2 p/size/y - 2 
effect: reduce['arrow colors/text 'rotate 180]
feel: make default-feel[
engage: make function![face act event /filter-data fd[block!]/local data p v lines oft][
if act = 'up[
unless filter-data[edit/unfocus]
p: face/parent-face 
p/feel/over/state p off 0x0 
data: any[fd p/data]
unless zero? lines: length? data[
oft: either (lines * sizes/line) < (p/parent-face/size/y - p/offset/y - p/size/y)[
p/offset + as-pair 0 p/size/y - 1
][
either (lines * sizes/line) <= (p/parent-face/size/y - 4)[
as-pair p/offset/x p/parent-face/size/y - 2 - (lines * sizes/line)
][
as-pair p/offset/x p/parent-face/size/y - 2 - (sizes/line * to integer! p/parent-face/size/y / sizes/line)
]
]
if v: choose p p/size/x oft data[
p/text: form v 
p/hidden-text: p/hidden-caret: none 
p/action/on-click p 
either p/type = 'drop-list[show p][set-focus p]
]
]
]
]
]
]
]
]
edit-list: make drop-list[
options: {USAGE:
edit-list "1" data[1 2 3]
edit-list data["One" "Two" "Three"]
edit-list data ctx-rebgui/locale*/colors
DESCRIPTION:
Editable single column modal selection list.
At runtime face/text contains current selection.}
text: "" 
color: colors/edit 
effect: none 
data:[]
edge: default-edge 
para: make default-para[margin: as-pair sizes/line + 2 2]
feel: make edit/feel bind[
over: make function![face into pos /state][]
engage: make function![face action event /local start end total visible fd pf][
switch action[
key[
if event/key = #"^M"[
edit-text face event 
hide-popup 
edit/unfocus 
exit
]
if event/key = 'down[
either view*/pop-face[set-focus view*/pop-face][face/pane/feel/engage face/pane action event]
exit
]
prev-caret: index? view*/caret 
face/text: any[face/hidden-text head view*/caret]
view*/caret: any[face/hidden-caret view*/caret]
all[view*/highlight-start view*/highlight-start: at face/text index? view*/highlight-start]
all[view*/highlight-end view*/highlight-end: at face/text index? view*/highlight-end]
edit-text face event 
face/hidden-text: copy face/text 
face/hidden-caret: at face/hidden-text index? view*/caret 
fd: copy[]
if find face/text edit/letter[
foreach ln sort face/data[
if find/match ln: form ln face/text[
face/text: copy ln 
view*/caret: at face/text index? view*/caret 
unless char? event/key[
view*/caret: at face/text prev-caret 
edit-text face event 
face/hidden-text: copy face/text 
face/hidden-caret: at face/hidden-text index? view*/caret
]
]
if find/match ln face/hidden-text[
insert tail fd ln
]
]
]
unless empty? fd[
either none? view*/pop-face[
face/pane/feel/engage/filter-data face/pane 'down none fd
][
pf: view*/pop-face 
pf/data: copy fd 
pf/pane/1/size/y: pf/size/y: sizes/line * (length? fd) 
pf/lines: to integer! pf/size/y / sizes/line 
pf/rows: length? fd 
show pf
]
]
show face
]
down[
either event/double-click[
all[view*/caret not empty? view*/caret current-word view*/caret]
][
either face <> view*/focal-face[set-focus face][unlight-text]
view*/caret: offset-to-caret face event/offset 
show face
]
]
over[
unless equal? view*/caret offset-to-caret face event/offset[
unless view*/highlight-start[view*/highlight-start: view*/caret]
view*/highlight-end: view*/caret: offset-to-caret face event/offset 
show face
]
]
]
]
]in edit 'self 
caret: none
]
field: make baseface[
options: {USAGE:
field
field -1 "String"
DESCRIPTION:
Editable text field with no text wrapping.}
size: 50x5 
text: "" 
color: colors/edit 
edge: default-edge 
font: default-font 
para: default-para 
feel: edit/feel 
action: default-action 
init: make function![][
para: make para[]
all[negative? size/x size/x: 10000 size/x: 4 + first size-text self]
]
esc: none 
caret: none 
undo: copy[]
]
group-box: make baseface[
options: {USAGE:
group-box "Title" data[field field]
DESCRIPTION:
A static widget used to group widgets within a bounded container.}
size: -1x-1 
text: "" 
effect:[draw[pen colors/outline/3 line-width 1 fill-pen none box 0x0 0x0 effects/radius]]
font: make font-top[color: colors/outline/3]
para: make default-para[origin: as-pair sizes/cell * 4 0]
feel: make default-feel[
redraw: make function![face act pos][
if act = 'show[
all[
face/color 
face/effect/draw/fill-pen: face/color 
poke face/effect/draw 12 face/color 
face/color: none
]
all[
clear skip face/effect/draw 10 
unless empty? face/text[
insert tail face/effect/draw reduce[
'pen colors/page 'line 
3x2 * sizes/cell 
as-pair sizes/cell * 5 + first size-text face sizes/cell * 2
]
]
]
]
]
]
action: make default-action[
on-resize: make function![face][
poke face/effect/draw 9 face/size - 1x1
]
]
group: none 
init: make function![][
data: layout/only data 
group: pane: data/pane 
foreach face pane[face/offset: face/offset + as-pair 0 sizes/cell * sizes/gap]
all[negative? size/x size/x: max 16 + first size-text self data/size/x]
all[negative? size/y size/y: sizes/cell * sizes/gap + data/size/y]
effect/draw/box/y: sizes/cell * 2 
data: none 
action/on-resize self
]
]
heading: make baseface[
options: {USAGE:
heading "A text heading."
DESCRIPTION:
Large text.}
size: -1x7 
text: "" 
font: font-heading 
init: make function![][size/x: text-width? self]
]
icon: make arrow[
options: {USAGE:
icon %actions/go-up.png
DESCRIPTION:
An icon.}
size: 5x5 
pane:[]
init: make function![/local v p][
all[color set-color/no-show self color]
size: max size 18x18 
size/y: size/x 
v: case[32 < size/x[32x32]22 < size/x[22x22]true[16x16]]
p: self 
insert pane make baseface[
offset: p/size - v / 2 - 1x1 
size: v 
image: load-icon v p/image
]
image: none 
data: off
]
]
image: make baseface[
options: {USAGE:
image %icons/Tango-feet.png
image logo
image logo effect[crop 10x10 50x50]
DESCRIPTION:
An image.}
size: -1x-1 
effect: 'fit 
init: make function![][
all[negative? size/x size/x: image/size/x]
all[negative? size/y size/y: image/size/y]
]
]
label: make heading[
options: {USAGE:
label "A text label."
DESCRIPTION:
Label text.}
size: 25x5 
font: font-label
]
led: make baseface[
options: {USAGE:
led "Option"
led "Option" data true
led "Option" data false
led "Option" data none
DESCRIPTION:
Tristate indicator box with colors representing Yes & No, and empty being Unknown.}
size: -1x5 
effect: compose/deep[draw[pen (colors/outline/3) fill-pen (colors/page) circle (sizes/cell * 2x2) (sizes/cell * 1.5)]]
font: default-font 
para: para-indent 
feel: make default-feel[
redraw: make function![face act pos][
all[
act = 'show 
face/effect/draw/fill-pen: select reduce[true colors/true false colors/false]face/data
]
]
]
init: make function![][
if negative? size/x[size/x: 10000 size/x: 4 + para/origin/x + first size-text self]
]
]
led-group: make baseface[
options: {USAGE:
led-group data["Option-1" true "Option-2" false "Option-3" none]
DESCRIPTION:
Group of LED indicators.
Alignment is vertical unless height is specified as line height.
At runtime face/data is a block of logic (or none) indicating state of each LED indicator.}
size: 50x-1 
pane:[]
feel: make default-feel[
redraw: make function![face act pos][
if act = 'show[
face/data: reduce face/data 
repeat i length? face/pane[
face/pane/:i/data: pick face/data i
]
]
]
]
init: make function![/local off siz pos last-pane][
data: reduce data 
all[negative? size/y size/y: 0.5 * sizes/line * length? data]
off: either size/y > sizes/line[
siz: as-pair size/x sizes/line 
as-pair 0 sizes/line
][
siz: as-pair 2 * size/x / length? data sizes/line 
as-pair siz/x 0
]
pos: 0x0 
foreach[label state]data[
insert tail pane make led[
offset: pos 
size: siz 
text: label 
data: state
]
pos: pos + off 
last-pane: last pane 
last-pane/init 
last-pane/init: none
]
clear data 
foreach led pane[insert tail data led/data]
]
]
link: make baseface[
options: {USAGE:
link
link http://www.dobeash.com
link "RebGUI" http://www.dobeash.com/rebgui
DESCRIPTION:
Hypertext link.}
size: -1x5 
font: font-link 
feel: make default-feel[
over: make function![face act pos][
face/font/color: either act[colors/theme/1][colors/link]
show face
]
engage: make function![face act event][
all[act = 'up browse face/data]
]
]
init: make function![][
text: form any[text data "http://www.dobeash.com"]
unless data[data: to url! text]
size/x: text-width? self
]
]
menu: make gradface[
options: {USAGE:
menu data["Item-1"["Choice 1"[alert "1"]"Choice 2"[alert "2"]]"Item-2"[]]
DESCRIPTION:
Simple one-level text-only menu system.}
size: 100x5 
pane:[]
color: colors/outline/1 
init: make function![/local item item-offset][
item-offset: 0x0 
foreach[label block]data[
insert tail pane make gradface[
offset: item-offset 
size: as-pair 1 sizes/line 
text: label 
edge: none 
data: block 
font: make default-font[align: 'center]
para: default-para 
feel: feel-click 
action: make default-action[
on-click: make function![face][
do select face/data choose face/parent-face face/options face/parent-face/offset + face/offset + as-pair 0 face/size/y - 1 extract face/data 2
]
]
old-color: none
]
item: last pane 
item/options: item/size/x: sizes/line + first size-text item 
item-offset/x: item-offset/x + item/size/x 
foreach i extract item/data 2[
item/options: max item/options sizes/cell + first text-size? i
]
]
data: first pane
]
]
panel: make baseface[
options: {USAGE:
panel data[after 1 field field]
DESCRIPTION:
A static widget used to group widgets within a container.}
size: -1x-1 
effect:[draw[pen colors/outline/3 line-width 1 fill-pen colors/edit box 0x0 0x0 effects/radius]]
action: make default-action[
on-resize: make function![face][
poke face/effect/draw 9 face/size - 1x1
]
]
group: pane 
init: make function![][
data: layout/only data 
group: pane: data/pane 
all[negative? size/x size/x: data/size/x]
all[negative? size/y size/y: data/size/y]
poke effect/draw 9 size - 1x1 
data: none
]
]
password: make field[
options: {USAGE:
password
password "Secret"
DESCRIPTION:
Editable password field with text displayed as a progress bar.}
font: make default-font[color: colors/theme/2]
para: make default-para[origin: 0x2]
effect:[draw[pen colors/theme/2 fill-pen colors/theme/2]]
action: make default-action[
on-edit: make function![face /local xy1 xy2][
xy1: 1x1 
xy2: as-pair sizes/font sizes/line - 4 
clear skip face/effect/draw 4 
loop length? face/text[
insert tail face/effect/draw reduce['box xy1 xy2]
xy1/x: xy1/x + sizes/font 
xy2/x: xy2/x + sizes/font
]
show face
]
]
init: make function![][
action/on-edit self
]
]
progress: make baseface[
options: {USAGE:
progress
progress data .5
DESCRIPTION:
A horizontal progress indicator.
At runtime face/data ranges from 0 to 1 indicating percentage.}
size: 50x5 
effect:[draw[pen colors/theme/2 fill-pen colors/theme/2 box 1x1 1x1]]
data: 0 
edge: default-edge 
feel: make default-feel[
redraw: make function![face act pos][
all[
act = 'show 
face/effect/draw/7/x: max 1 face/size/x - 4 * face/data: min 1 max 0 face/data
]
]
]
action: make default-action[
on-resize: make function![face][face/effect/draw/6/y: face/size/y - 4]
]
init: make function![][action/on-resize self]
]
radio-group: make baseface[
options: {USAGE:
radio-group data["Option A" "Option B"]
radio-group data[2 "On" "Off"]
DESCRIPTION:
Group of mutually exclusive radio buttons.
Alignment is vertical unless height is specified as line height.
An integer provided as the first entry in the block indicates the default selection.}
size: -1x-1 
pane:[]
action: default-action 
picked: none 
selected: make function![][
all[picked pick data picked]
]
select-item: make function![item[integer! none!]][
either any[none? item zero? item][
item: either picked = 1[2][1]
pane/:item/feel/engage/reset pane/:item 'down none
][
all[item <> picked pane/:item/feel/engage pane/:item 'down none]
]
]
init: make function![/local off siz pos index][
unless string? first data: reduce data[
picked: first data 
remove data
]
all[negative? size/x foreach label data[size/x: max size/x sizes/line + first text-size? label]]
all[negative? size/y size/y: sizes/line * length? data]
off: either size/y > sizes/line[
siz: as-pair size/x sizes/line 
as-pair 0 sizes/line
][
siz: as-pair size/x / length? data sizes/line 
as-pair siz/x 0
]
pos: 0x0 
index: 1 
foreach label data[
insert tail pane make baseface[
offset: pos 
size: siz 
text: label 
effect: compose/deep[draw[pen (colors/outline/3) fill-pen (colors/edit) circle (sizes/cell * 2x2) (sizes/cell * 1.5)]]
data: index 
font: default-font 
para: para-indent 
feel: make default-feel[
over: make function![face act pos][
face/effect/draw/pen: either act[colors/theme/1][colors/outline/3]
show face
]
engage: make function![face act event /reset /local pf][
switch act[
down[
if all[pf: face/parent-face pf/picked <> face/data][
all[
pf/picked 
clear skip pf/pane/(pf/picked)/effect/draw 7 
show pf/pane/(pf/picked)
]
either reset[pf/picked: none][
pf/picked: face/data 
insert tail face/effect/draw reduce[
'pen colors/true 'fill-pen colors/true 'circle sizes/cell * 2x2 sizes/cell * 0.75
]
show face 
pf/action/on-click pf
]
]
]
away[face/feel/over face false 0x0]
]
]
]
]
pos: pos + off 
index: index + 1
]
all[
integer? picked 
insert tail pane/:picked/effect/draw reduce[
'pen colors/true 'fill-pen colors/true 'circle sizes/cell * 2x2 sizes/cell * 0.75
]
]
]
]
scroll-panel: make baseface[
options: {USAGE:
scroll-panel data[sheet]
DESCRIPTION:
A panel used to group widgets within a scrollable container.
OPTIONS:
'offset keeps the original offset}
size: 50x50 
pane:[]
edge: default-edge 
action: make default-action[
on-click: make function![face][view*/focal-face: face]
on-scroll: make function![face scroll /page][
either page[
all[face/pane/3/show? face/pane/3/set-data scroll]
][
all[face/pane/2/show? face/pane/2/set-data scroll]
]
]
on-resize: make function![face /child /local p1 p2 p3 p4][
p1: face/pane/1 
p2: face/pane/2 
p3: face/pane/3 
p4: face/pane/4 
p2/show?: either p1/size/y <= face/size/y[face/sld-offset/x: 0 false][face/sld-offset/x: sizes/slider true]
p3/show?: either p1/size/x <= face/size/x[face/sld-offset/y: 0 false][face/sld-offset/y: sizes/slider true]
p4/show?: either any[p2/show? p3/show?][true][false]
p2/ratio: min 1 face/size/y - face/sld-offset/y / p1/size/y 
p3/ratio: min 1 face/size/x - face/sld-offset/x / p1/size/x 
if child[
all[p2/ratio = 1 p2/data: p1/offset/y: 0]
all[p3/ratio = 1 p3/data: p1/offset/x: 0]
show face
]
]
]
p1: p2: p3: p4: none 
sld-offset: 0x0 
init: make function![/local p][
unless options[options: copy[]]
p: self 
data: layout/only data 
insert pane either 1 = length? data/pane[first data/pane][data]
all[negative? size/x size/x: data/size/x]
all[negative? size/y size/y: data/size/y]
data: none 
p1: first pane 
color: p1/color 
unless find options 'offset[p1/offset: 0x0]
p1/edge: none 
if span[
all[find span #H p1/span: #H]
all[find span #W p1/span: #W]
all[find span #H find span #W p1/span: #HW]
]
insert tail pane make slider[
offset: as-pair p/size/x - sizes/slider - 1 -1 
size: as-pair sizes/slider p/size/y - sizes/slider + 1 
span: case[
none? p/span[none]
all[find p/span #H find p/span #W][#XH]
find p/span #H[#H]
find p/span #W[#X]
]
action: make default-action[
on-click: make function![face][
p1/offset/y: negate p1/size/y + sld-offset/y - p/size/y * face/data 
show p1
]
]
]
p2: second pane 
p2/init 
insert tail pane make slider[
offset: as-pair -1 p/size/y - sizes/slider - 1 
size: as-pair p/size/x - sizes/slider + 1 sizes/slider 
span: case[
none? p/span[none]
all[find p/span #H find p/span #W][#YW]
find p/span #H[#Y]
find p/span #W[#W]
]
action: make default-action[
on-click: make function![face][
p1/offset/x: negate p1/size/x + sld-offset/x - p/size/x * face/data 
show p1
]
]
]
p3: third pane 
p3/init 
insert tail pane make btn[
offset: p/size - 1x1 - as-pair sizes/slider sizes/slider 
size: as-pair sizes/slider sizes/slider 
span: case[
none? p/span[none]
all[find p/span #H find p/span #W][#XY]
find p/span #H[#Y]
find p/span #W[#X]
]
]
p4: fourth pane 
p4/action: make default-action[
on-click: make function![face /local p][
p: face/parent-face 
p2/data: p3/data: either p1/offset = 0x0[1][0]
all[p2/show? show p2]
all[p3/show? show p3]
]
]
p4/init 
action/on-resize self
]
]
sheet: make baseface[
options: {USAGE:
sheet
sheet options[size 3x3 width 2]
sheet options[size 3x3 widths[2 3 4]]
sheet data[A1 1 A2 2 A3 "=A1 + A2"]
DESCRIPTION:
Simple spreadsheet, based on rebocalc.r, with formulas calculated left to right, top to bottom.
A cell is either a scalar value, string, or a formula starting with "=".
Scalar values are automatically right-justified, series values left-justified.
Remember to put spaces between each item in a formula and use () where needed.
OPTIONS:
'size specifies number of columns and rows
'width specifies cell width in relation to cell height
'widths specifies n cell widths}
size: -1x-1 
color: colors/outline/1 
pane:[]
data:[]
group: none 
load-data: make function![dat /local v][
insert clear data dat 
foreach cell group[
cell/text: either v: select data cell/data[form v][copy ""]
enter cell
]
compute 
show group
]
save-data: make function![][
clear data 
foreach cell group[
unless empty? cell/text[
insert tail data either cell/options[
reduce[cell/data join "=" form cell/options]
][
reduce[cell/data get cell/data]
]
]
]
]
enter: make function![face /local v][
face/color: colors/edit 
face/font/align: 'left 
error? try[unset face/data]
face/options: none 
all[empty? trim face/text exit]
v: attempt[load either #"=" = first face/text[next face/text][face/text]]
either any[series? v word? v][
either #"=" = first face/text[face/color: colors/theme/1 face/options: :v][set face/data face/text]
][
face/font/align: 'right 
set face/data v
]
]
compute: make function![/local v][
foreach cell group[
if cell/options[
either all[word? cell/options string? get cell/options][v: get cell/options][
unless v: attempt[do cell/options][cell/text: "ERROR!"]
]
cell/font/align: either series? v['left]['right]
cell/text: form v 
set cell/data cell/text 
show cell
]
]
]
init: make function![/local cols rows p pos char v widths row-size][
unless options[options: copy[]]
either pair? v: select options 'size[cols: v/x rows: v/y][
either empty? data[cols: 6 rows: 12][
cols: #"A" 
rows: 1 
foreach[cell val]data[
cols: max cols uppercase first form cell 
rows: max rows to integer! next form cell
]
cols: to integer! cols - 64
]
]
widths: copy[]
case[
v: select options 'widths[insert widths v]
v: select options 'width[insert/dup widths v cols]
true[insert/dup widths 4 cols]
]
row-size: as-pair sizes/line * 2 sizes/line 
if negative? size/x[
size/x: row-size/x + cols + 1 
foreach w widths[size/x: w * sizes/line + size/x]
]
all[negative? size/y size/y: rows * sizes/line + rows + row-size/y + 1]
char: #"A" 
pos: as-pair row-size/x + 1 0 
repeat x cols[
insert tail pane make gradface[
offset: pos 
size: as-pair sizes/line * pick widths x sizes/line 
text: form char
]
char: char + 1 
pos/x: sizes/line * (pick widths x) + pos/x + 1
]
pos: as-pair 0 sizes/line + 1 
repeat y rows[
insert tail pane make gradface[
offset: pos 
size: row-size 
text: form y
]
pos/y: pos/y + sizes/line + 1
]
p: self 
group: tail pane 
pos: row-size + 1x1 
repeat y rows[
pos/x: row-size/x + 1 
char: #"A" 
repeat x cols[
v: to word! join char y 
insert tail pane make baseface[
type: 'field 
offset: pos 
size: as-pair sizes/line * pick widths x sizes/line 
text: form any[select p/data v ""]
color: colors/edit 
font: make default-font[]
para: make default-para[]
feel: edit/feel 
data: v 
options: none 
action: make default-action[
on-focus: make function![face][
all[face/options face/text: join "=" form face/options]
face/font/align: 'left 
select-face face 
true
]
on-unfocus: make function![face][
deselect-face face 
enter face compute face/para/scroll: 0x0 
true
]
]
]
char: char + 1 
pos/x: sizes/line * (pick widths x) + pos/x + 1
]
pos/y: pos/y + sizes/line + 1
]
unless empty? data[
foreach cell group[
unless empty? cell/text[enter cell]
]
compute
]
]
]
slider: make gradface[
options: {USAGE:
slider[]
slider data .5[print face/data]
DESCRIPTION:
A slider control. Its size determines whether it is vertical or horizontal.
At runtime face/data ranges from 0 to 1 indicating percentage.
OPTIONS:
[ratio n]where n indicates the initial dragger size}
size: 5x50 
pane:[]
data: 0 
feel: make feel-click[
redraw: make function![face act pos /local n][
if all[
act = 'show 
n: face/axis 
face/state <> reduce[to integer! face/size/:n * face/ratio face/data face/ratio]
][
face/pane/1/size/:n: face/size/:n * face/ratio 
face/pane/1/offset/:n: face/size/:n * face/data - (face/pane/1/size/:n / 2) 
face/pane/1/offset/:n: face/size/:n - face/pane/1/size/:n * face/data - 1 
face/state: reduce[face/pane/1/size/:n face/data face/ratio]
all[face/old-size face/action/on-click face]
]
]
engage: make function![face act event][
switch act[
down[face/feel/over/state face on 0x0 face/update-data event/offset]
up[set-state face off]
over[face/feel/over/state face on 0x0]
away[face/feel/over/state face off 0x0]
]
]
]
set-data: make function![new[integer! decimal! pair!]][
new: min 1 max 0 either pair? new[
data + either negative? new/y[negate step][step]
][new]
all[data <> new data: new show self]
]
ratio: 0.1 
step: 0.05 
axis: 2 
state: none 
update-data: make function![offset[pair!]/local new][
unless ratio = 1[
new: min 1 max 0 offset/:axis - (pane/1/size/:axis / 2) / (size/:axis - pane/1/size/:axis) 
all[data <> new data: new show self]
]
]
init: make function![/local p][
all[block? options find options 'ratio ratio: select options 'ratio]
data: min 1 max 0 data 
ratio: min 1 max 0.1 ratio 
p: self 
insert tail pane make gradface[
offset: -1x-1 
size: min p/size reverse p/size 
text: "=" 
feel: make feel-click[
over: make function![face into pos /state][
all[state set-state/no-show face into]
face/parent-face/feel/over/state face/parent-face off 0x0 
set-color face either into[colors/theme/1][none]
]
engage: make function![face act event][
switch act[
down[set-state face on face/parent-face/update-data face/offset + event/offset]
up[face/feel/over/state face off 0x0]
over[face/parent-face/update-data face/offset + event/offset]
away[face/parent-face/update-data face/offset + event/offset]
]
]
]
]
axis: either size/y > size/x[
effect/gradient: -1x0 
effect/4: colors/outline/2 
2
][
effect/gradient: 0x-1 
effect/4: colors/outline/2 
pane/1/text: "+" 1
]
]
]
spinner: make baseface[
options: {USAGE:
spinner
spinner options[$1 $10 $1]data $5
DESCRIPTION:
Similar to a field, with arrows to increment/decrement a value by a nominated step amount.
OPTIONS:
[min max step]block of minimum, maximum and step amounts}
size: 20x5 
color: colors/edit 
text: "" 
edge: default-edge 
font: font-right 
para: make default-para[]
feel: edit/feel 
pane: copy[]
action: make default-action[
on-resize: make function![face][
face/pane/1/offset/x: face/size/x - sizes/line + sizes/cell - 1 
face/pane/2/offset/x: face/size/x - sizes/line + sizes/cell - 1
]
on-scroll: make function![face scroll /page][
face/text: either any[none? face/data page][
form data: either negative? scroll/y[second face/options][first face/options]
][
form face/data + either negative? scroll/y[last face/options][negate last face/options]
]
face/action/on-unfocus face
]
on-unfocus: make function![face][
either empty? face/text[
face/data: none
][
face/data: any[attempt[to type? first face/options face/text]face/data]
face/text: either face/data[form face/data: min max face/data first face/options second face/options][copy ""]
show face
]
face/action/on-click face 
true
]
]
init: make function![/local p][
unless options[options: copy[]]
all[empty? options options: copy[1 10 1]]
all[data text: form data]
all[not empty? text data: to type? first options text]
para/margin/x: size/y - sizes/cell 
p: self 
insert pane make arrow[
offset: as-pair p/size/x - sizes/line + sizes/cell - 1 0 
size: as-pair p/size/y - sizes/cell p/size/y / 2 - 1 
data: 'up 
edge: make default-edge[size: 1x0]
rate: 10 
action: make default-action[
on-click: make function![face /local p][
p: face/parent-face 
p/data: any[attempt[to type? first p/options p/text]p/data first p/options]
p/data: p/data + third p/options 
if p/data > second p/options[p/data: second p/options]
p/text: form p/data 
edit/unlight-text 
view*/caret: none 
show p 
p/action/on-click p
]
]
]
pane/1/init 
insert tail pane make arrow[
offset: as-pair p/size/x - sizes/line + sizes/cell - 1 p/size/y / 2 - 1 
size: as-pair p/size/y - sizes/cell p/size/y / 2 - 1 
edge: make default-edge[size: 1x0]
rate: 10 
action: make default-action[
on-click: make function![face /local p][
p: face/parent-face 
p/data: any[attempt[to type? first p/options p/text]p/data first p/options]
p/data: p/data - third p/options 
if p/data < first p/options[p/data: first p/options]
p/text: form p/data 
edit/unlight-text 
view*/caret: none 
show p 
p/action/on-click p
]
]
]
pane/2/init 
pane/2/effect/gradient: 0x1
]
esc: none 
caret: none 
undo: copy[]
]
splitter: make gradface[
options: {USAGE:
area splitter area
DESCRIPTION:
Placed between two widgets on the same row or column.
Allows both to be resized by dragging the splitter left/right or up/down respectively.
Its size determines whether it is vertical or horizontal.}
size: 2x25 
feel: make feel-click[
redraw: make function![face act pos /local f p n][
unless face/data[
f: find face/parent-face/pane face 
p: back f 
n: next f 
if face/size/y <= face/size/x[
while[face/offset/x <> p/1/offset/x][
if head? p[request-error "splitter failed to find previous widget"]
p: back p
]
while[face/offset/x <> n/1/offset/x][
if tail? p[request-error "splitter failed to find next widget"]
n: next n
]
]
face/data: reduce[first p first n]
]
]
engage: make function![face act event /local p n delta][
switch act[
down[set-state face on]
up[set-state face off all[over? face event face/action/on-click face]]
over[face/feel/over/state face on 0x0]
away[face/feel/over/state face off 0x0]
]
if event/type = 'move[
p: first face/data 
n: second face/data 
either face/size/y > face/size/x[
delta: face/offset/x - face/offset/x: min n/offset/x + n/size/x - face/size/x - 1 max p/offset/x + 1 face/offset/x + event/offset/x 
p/size/x: p/size/x - delta 
n/size/x: n/size/x + delta 
n/offset/x: n/offset/x - delta
][
delta: face/offset/y - face/offset/y: min n/offset/y + n/size/y - face/size/y - 1 max p/offset/y + 1 face/offset/y + event/offset/y 
p/size/y: p/size/y - delta 
n/size/y: n/size/y + delta 
n/offset/y: n/offset/y - delta
]
show[p face n]
]
all[act = 'away face/feel/over face false 0x0]
]
]
action: default-action 
init: make function![][
effect/gradient: either size/y > size/x[text: "=" -1x0][text: "+" 0x-1]
]
]
table: make baseface[
options: {USAGE:
table options["Name" left .5 "Age" right .5]data["Bob" 32 "Pete" 45 "Jack" 29]
DESCRIPTION:
Columns and rows of values formatted according to a header definition block.
OPTIONS:
'multi allows multiple rows to be selected at once
'no-sort disables column sorting
'no-resize disables column resizing
'fixed-sort limits sorting to first column only}
size: 50x25 
color: colors/edit 
pane:[]
data:[]
edge: default-edge 
action: make default-action[
on-resize: make function![face /local v][
v: second-last face/pane 
v/pane/2/offset/x: face/size/x - sizes/slider - 1 
v: face/pane/(face/cols) 
v/size/x: face/size/x - v/offset/x - 1
]
]
redraw: make function![][]
selected: make function![][]
picked:[]
widths:[]
aligns:[]
cols: none 
rows: make function![][pane/(cols + 1)/rows]
add-row: make function![
row[block!]
/position 
pos[integer!]
][
either pos[
pos: (pos - 1) * cols
][
pos: 1 + length? data
]
insert at data pos row 
redraw
]
remove-row: make function![
row[integer! block!]
/local rows removed
][
if integer? row[row: to-block row]
rows: sort/reverse copy row 
repeat n length? rows[
row: max 1 min rows/:n (length? data) / cols 
remove/part skip data (row - 1) * cols cols
]
redraw
]
alter-row: make function![
row[integer! block!]
values[block!]
/local rows last-picked
][
last-picked: copy picked 
if integer? row[row: to-block row]
rows: row 
if (length? rows) <> (length? values)[
values: reduce[values]
]
if (length? rows) = (length? values)[
repeat n length? rows[
row: max 1 min rows/:n (length? data) / cols 
change skip data (row - 1) * cols copy/part values/:n cols
]
]
redraw 
unless empty? last-picked[select-row/no-action last-picked]
]
select-row: make function![
row[integer! none! block!]
/no-action 
/local rows lines
][
clear picked 
if row[
row: either integer? row[to block! row][sort copy row]
rows: pane/(cols + 1)/rows 
lines: pane/(cols + 1)/lines 
foreach r row[
r: max 1 min rows r 
insert picked r
]
if any[
row/1 < (pane/(cols + 1)/scroll + 1) 
row/1 > (pane/(cols + 1)/scroll + pane/(cols + 1)/lines)
][
pane/(cols + 1)/pane/2/data: 1 / (rows - lines) * ((min (rows - lines + 1) row/1) - 1)
]
unless no-action[action/on-click self]
]
view*/caret: pane/(cols + 1)/pane/1/text 
view*/focal-face: pane/(cols + 1)/pane/1 
show self
]
init: make function![/local p opts col-offset last-col][
unless options[options: copy[]]
opts:[table]
all[remove find options 'multi insert tail opts 'multi]
all[remove find options 'no-sort insert tail opts 'no-sort]
all[remove find options 'no-resize insert tail opts 'no-resize]
all[remove find options 'fixed-sort insert tail opts 'fixed-sort]
unless integer? cols: divide length? options 3[
request-error "table has an invalid options block"
]
if all[not empty? data decimal? divide length? data cols][
request-error "table has an invalid data block"
]
p: self 
col-offset: -1 
foreach[column halign width]options[
unless any[string? column word? column][
request-error "table column name must be a string or word"
]
unless find[left center right]halign[
request-error {table column align must be one of left, center or right}
]
unless number? width[
request-error "table column width must be a decimal"
]
insert tail aligns halign 
insert tail widths width: to integer! size/x * width 
insert tail pane make gradface[
offset: as-pair col-offset -1 
size: as-pair width + 1 sizes/line + 1 
text: form column 
options: opts 
col: length? widths 
feel: make default-feel[
engage: make function![face act event /local delta arrow][
switch/default act[
down[
unless find face/options 'no-sort[
unless all[face/col > 1 find face/options 'fixed-sort][
arrow: last face/parent-face/pane 
unless arrow/col = face/col[
arrow/col: face/col 
arrow/asc: none 
arrow/offset/x: offset/x + size/x + sizes/cell - sizes/line
]
arrow/action arrow
]
]
data: event/offset/x
]
up[
data: none
]
][
if all[
not find face/options 'no-resize 
col <> 1 
data 
event/type = 'move 
event/offset/x <> data
][
delta: event/offset/x - data 
delta: either positive? delta[
min delta parent-face/pane/:col/size/x - (sizes/line * 2)
][
max delta negate parent-face/pane/(col - 1)/size/x - (sizes/line * 2)
]
delta 
unless zero? delta[
all[
col = 2 
find face/options 'fixed-sort 
arrow: last face/parent-face/pane 
arrow/col = 1 
arrow/offset/x: arrow/offset/x + delta
]
widths/:col: widths/:col - delta 
widths/(col - 1): widths/(col - 1) + delta 
parent-face/pane/:col/size/x: widths/:col + 1 
parent-face/pane/:col/offset/x: parent-face/pane/:col/offset/x + delta 
parent-face/pane/(col - 1)/size/x: widths/(col - 1) + 1 
show parent-face
]
]
]
show face
]
]
]
col-offset: col-offset + width
]
insert tail pane make face-iterator[
offset: as-pair 0 sizes/line 
size: p/size - as-pair 0 sizes/line 
span: either p/span[copy p/span][none]
data: p/data 
cols: p/cols 
widths: p/widths 
aligns: p/aligns 
options: opts 
picked: p/picked 
action: p/action
]
insert tail pane make baseface[
offset: as-pair negate sizes/line sizes/cell 
size: as-pair sizes/cell * 3 sizes/cell * 3 
effect:[arrow colors/text rotate 0]
cols: p/cols 
col: none 
asc: true 
feel: make default-feel[
engage: make function![face act event][
all[act = 'down face/action face]
]
]
action: make function![face /local last-selected][
asc: either none? asc[true][complement asc]
effect/rotate: either asc[0][180]
last-selected: selected 
either asc[
sort/skip/compare parent-face/data cols col
][
sort/skip/compare/reverse parent-face/data cols col
]
all[
last-selected 
select-row/no-action (((index? find parent-face/data last-selected) - 1) / cols) + 1
]
show parent-face
]
]
pane/(cols + 1)/cols: cols 
pane/(cols + 1)/data: data 
options: pane/(cols + 1)/options 
last-col: first back back back tail pane 
last-col/size/x: size/x - last-col/offset/x - 1 
all[negative? last-col/size/x request-error "table column widths are too large"]
widths/:cols: last-col/size/x - 1 
pane/(cols + 1)/init 
redraw: get in pane/(cols + 1) 'redraw 
selected: get in pane/(cols + 1) 'selected
]
]
tab-panel: make baseface[
options: {USAGE:
tab-panel data["A"[field]"B"[field]"C"[field]]
tab-panel data["1"[field]action[face/color: red]"2"[field]]
DESCRIPTION:
A panel with a set of tabs.
Each tab spec may be preceded by an action block spec.
OPTIONS:
'action do action of initial tab (if any)
[tab n]where n specifies tab to initially open with (default 1)
no-tabs do not display tabs (overlay mode)}
size: -1x-1 
pane:[]
group: none 
tabs: 0 
selected: make function![][
either find options 'no-tabs[data][pane/(tabs + data)/text]
]
select-tab: make function![
num[integer!]
][
unless any[num < 1 num > tabs][
edit/unfocus 
pane/:data/show?: false 
unless find options 'no-tabs[
deselect-face pane/(tabs + data) 
select-face pane/(tabs + num)
]
pane/(data: num)/show?: true 
all[pane/:data/action pane/:data/action/on-click pane/:data]
group: pane/:data/pane 
show self
]
]
replace-tab: make function![
num[integer!]
block[block!]
/title text[string!]
/local prev-offset prev-size prev-span
][
unless any[num < 1 num > tabs][
prev-offset: pane/1/offset 
prev-size: pane/1/size 
prev-span: pane/1/span 
pane/:num: layout/only block 
pane/:num/offset: prev-offset 
pane/:num/size: prev-size 
pane/:num/span: prev-span 
pane/:num/color: colors/page 
pane/:num/edge: default-edge 
all[title pane/(tabs + num)/text: text]
if data <> num[pane/:num/show?: false]
show self
]
]
init: make function![/local tab tab-offset trigger][
unless options[options: copy[]]
tab-offset: 0x0 
foreach[title spec]data[
either title = 'action[
trigger: spec
][
tabs: tabs + 1 
tab: layout/only spec 
tab/offset/y: either find options 'no-tabs[0][sizes/line]
tab/color: colors/page 
tab/edge: default-edge 
tab/show?: false 
tab/span: #LV 
tab/action: either trigger[
make default-action[on-click: make function![face /local var]trigger]
][none]
insert at pane tabs tab 
unless find options 'no-tabs[
insert tail pane make gradface[
offset: tab-offset 
size: as-pair 1 sizes/line + 1 
font: make font-button[]
text: title 
data: tabs 
feel: feel-click 
action: make default-action[
on-click: make function![face][
face/parent-face/select-tab face/data
]
]
old-color: none
]
tab: last pane 
tab/size/x: 8 + first size-text tab 
tab-offset/x: tab-offset/x + tab/size/x - 1
]
trigger: none
]
]
all[
negative? size/x 
repeat i tabs[size/x: max size/x pane/:i/size/x]
]
all[
negative? size/y 
repeat i tabs[size/y: max size/y pane/:i/size/y]
size/y: size/y + either find options 'no-tabs[0][sizes/line]
]
unless all[span find span #H find span #W][
repeat n tabs[
foreach widget pane/:n/pane[
if widget/span[
all[find widget/span #H either span[insert tail span #H][span: #H]]
all[find widget/span #W either span[insert tail span #W][span: #W]]
]
all[span find span #H find span #W break]
]
all[span find span #H find span #W break]
]
]
if span[
repeat n tabs[
all[find span #H either pane/:n/span[insert tail pane/:n/span #H][pane/:n/span: #H]]
all[find span #W either pane/:n/span[insert tail pane/:n/span #W][pane/:n/span: #W]]
]
]
pane/(data: any[select options 'tab 1])/show?: true 
group: pane/:data/pane 
unless find options 'no-tabs[select-tab data]
all[find options 'action pane/:data/action pane/:data/action/on-click pane/:data]
]
]
text: make baseface[
options: {USAGE:
text "A text string."
text "Blue text" text-color blue
text "Bold text" bold
text "Italic text" italic
text "Underline text" underline
DESCRIPTION:
Normal text.}
size: -1x5 
text: "" 
font: default-font 
para: para-wrap 
init: make function![][
all[find text "^/" size/y = sizes/line size/y: -1]
all[negative? size/x negative? size/y size: 10000x10000 size: 4x4 + size-text self]
all[negative? size/x size/x: 10000 size/x: 4 + first size-text self]
all[positive? size/y size/x < first text-size? text size/y: -1]
all[negative? size/y size/y: 10000 size/y: 4 + second size-text self]
either size/y > sizes/line[font: make font[valign: 'top]][para: none]
size/y: max size/y sizes/line
]
]
text-list: make baseface[
options: {USAGE:
text-list data["One" "Two"]
text-list data ctx-rebgui/locale*/colors
text-list data[1 2][print face/selected]
DESCRIPTION:
A single column list with a scroller.
OPTIONS:
'multi allows multiple rows to be selected at once}
size: 50x25 
color: colors/edit 
data:[]
edge: default-edge 
action: make default-action[
on-resize: make function![face][
face/pane/pane/2/offset/x: face/size/x - sizes/slider - 1
]
]
redraw: make function![][]
selected: make function![][]
picked:[]
rows: make function![][pane/rows]
select-row: make function![
row[integer! none! block!]
/no-action 
/local rows lines
][
clear picked 
if row[
row: either integer? row[to block! row][sort copy row]
rows: pane/rows 
lines: pane/lines 
foreach r row[
r: max 1 min rows r 
insert picked r
]
unless no-action[action/on-click self]
]
view*/caret: pane/pane/1/text 
view*/focal-face: pane/pane/1 
show self
]
init: make function![/local p][
unless options[options: copy[]]
p: self 
pane: make face-iterator[
size: p/size 
span: either p/span[copy p/span][none]
data: p/data 
options: p/options 
picked: p/picked 
action: p/action
]
pane/init 
redraw: get in pane 'redraw 
selected: get in pane 'selected
]
]
title-group: make baseface[
options: {USAGE:
title-group %icons/setup.png data "Title" "Body"
DESCRIPTION:
A title and text with an optional image to the left.
If an image is specified then height is set to image height.}
font: font-top 
init: make function![/local p indent][
indent: either image[size/y: image/size/y image/size/x + sizes/line][sizes/line]
p: self 
pane: make baseface[
offset: as-pair indent sizes/line 
size: as-pair p/size/x - indent - sizes/line 10000 
text: p/data 
font: font-heading
]
pane/size: 5x5 + size-text pane 
para: make para-wrap compose[
origin: (as-pair indent p/pane/size/y + sizes/line + sizes/line) 
margin: (as-pair sizes/line 0)
]
all[not image negative? size/y size/y: 10000 size/y: para/origin/y + second size-text self]
data: none
]
]
toggle: make btn[
options: {USAGE:
toggle data["A" "B"]
DESCRIPTION:
Toggles state when clicked.
OPTIONS:
'on starts selected}
size: 15x5 
text: "" 
font: font-button 
feel: make object![
redraw: 
detect: none 
over: make function![face into pos /state][
all[state set-state/no-show face into]
set-color face either into[colors/theme/1][none]
]
engage: make function![face act event][
switch act[
down[face/feel/over/state face on 0x0]
up[
if over? face event[
face/data: complement face/data 
face/text: pick face/texts face/data 
face/effect/gradient: pick[0x-1 0x1]face/data 
face/edge/size: pick[2x2 1x1]face/data 
face/action/on-click face
]
set-state face off
]
over[face/feel/over/state face on 0x0]
away[face/feel/over/state face off 0x0]
]
]
]
action: default-action 
old-color: none 
texts: none 
init: make function![][
edge: make default-edge[]
texts: reverse data 
data: either all[options find options 'on][true][false]
text: pick texts data 
effect/gradient: pick[0x-1 0x1]data 
edge/size: pick[2x2 1x1]data 
all[color set-color/no-show self color]
all[font size/x: text-width?/pad self]
]
]
tool-bar: make gradface[
options: {USAGE:
tool-bar data[arrow button field]
tool-bar data[icon "Open" %actions/document-open.png[]]
DESCRIPTION:
A toolbar with small margins (2x1) and minimal spacing (1x1).}
size: -1x7 
feel: make default-feel[
detect: make function![face event /local var txt][
unless event[exit]
if event/type = 'move[
txt: none 
var: win-offset? face 
foreach f face/pane[
all[
f/type = 'icon 
within? event/offset - var f/offset f/size 
txt: f/text 
break
]
]
either txt[
var/x: var/x - sizes/cell 
var/y: var/y + sizes/cell 
face/.tip/text: txt 
face/.tip/size: size-text face/.tip 
face/.tip/offset: min event/offset - var as-pair event/offset/x - var/x face/size/y - face/.tip/size/y - 3 
show face/.tip
][
all[
face/.tip/show? 
hide face/.tip
]
]
]
event
]
]
group: pane 
.tip: none 
init: make function![/local p][
size/y: size/y + 2 
data: copy data 
insert data reduce['margin 2x1 'space 1x1]
data: layout/only data 
group: pane: data/pane 
p: self 
insert tail pane make baseface[
color: yello 
edge: make default-edge[color: black]
font: default-font 
show?: false
]
.tip: last pane 
all[negative? size/x size/x: data/size/x]
data: none
]
]
tree: make baseface[
options: {USAGE:
tree data["Pets"["Cat" "Dog"]"Numbers"[1 2 3]]
DESCRIPTION:
Values arranged in a collapsible hierarchy.
OPTIONS:
'only returns item not full path}
size: 50x25 
color: colors/edit 
pane:[]
data:[]
edge: default-edge 
action: make default-action[
on-resize: make function![face][
face/pane/pane/2/offset/x: face/size/x - sizes/slider - 1
]
]
redraw: make function![][]
selected: make function![][]
picked:[]
rows: make function![][pane/rows]
select-row: make function![
row[integer! none! block!]
/no-action 
/local rows lines
][
clear picked 
if row[
row: either integer? row[to block! row][sort copy row]
rows: pane/rows 
lines: pane/lines 
foreach r row[
r: max 1 min rows r 
insert picked r
]
unless no-action[action/on-click self]
]
view*/caret: pane/pane/1/text 
view*/focal-face: pane/pane/1 
show self
]
build-tree: make function![
string[string!]
items[block!]
][
foreach item items[
either block? item[
build-tree join last .data-path "/" item
][
insert tail .data-path join string item
]
]
]
.data:[]
.tabs:[]
.data-path:[]
.data-list:[]
init: make function![/local p blk levels][
unless options[options: copy[]]
either find data block![build-tree "" data][.data-path: copy data]
levels: 1 
foreach item sort .data-path[
blk: remove-each i parse/all form item "/\"[empty? i]
levels: max levels length? blk 
insert tail .data-list head insert/dup last blk "^-" -1 + length? blk
]
repeat n levels[insert tail .tabs n * sizes/line]
p: self 
pane: make face-iterator[
size: p/size 
span: either p/span[copy p/span][none]
data: p/.data-list 
options: p/options 
picked: p/picked 
action: p/action 
tab-levels: p/.tabs
]
pane/init 
redraw: get in pane 'redraw 
selected: get in pane 'selected
]
]
]
requestors: make object![
color-spec: copy[text-size 15 space 1x1]
do make function![/local bx r g b i][
bx: 4 + length? locale*/colors 
r: bx - 1 
g: bx + 2 
b: bx + 4 
i: 1 
foreach color locale*/colors[
insert tail color-spec compose/deep[
box 5x5 (color)[face/parent-face/pane/(bx)/action/on-click face]edge[]feel[
over: make function![face act pos /local p][
all[
act 
p: face/parent-face/pane 
p/(bx)/color: face/color 
p/(r)/text: form face/color/1 
p/(g)/text: form face/color/2 
p/(b)/text: form face/color/3 
set-title face (uppercase/part form color 1)
]
]
]
]
all[zero? i // 8 insert tail color-spec 'return]
i: i + 1
]
all['return <> last color-spec insert tail color-spec 'return]
]
read-dir: make function![path /local blk dirs][
blk: copy[]
if dirs: attempt[read path][
foreach dir remove-each file sort dirs[any[#"/" <> last file #"." = first file]][
insert tail blk head remove back tail dir 
insert/only tail blk read-dir dirize path/:dir 
if empty? last blk[remove back tail blk]
]
]
blk
]
alert: make function![
{Flashes an alert message to the user. Waits for a user response.} 
value[any-type!]"Value to display" 
/title text[string!]
][
request/title/ok/type form value any[text "Alert"]'alert
]
confirm: make function![
"Confirms a user choice." 
question[string!]"Prompt to user" 
/title text[string!]
][
request/title/confirm/type question any[text "Confirm"]'help
]
editor: make function![
{Displays text in an editable area with option to save.} 
file[file! string!]
/title text[string!]"Title text" 
/size cells[pair!]"Size of edit area in cells" 
/local string txt chk save?
][
either file? file[
string: either exists? file[read file][copy ""]
][
string: file 
file: none
]
chk: checksum string 
save?: make function![][
all[
none? file 
file: request-file/save
]
if chk <> checksum txt/text[
either file[
confirm "Save changes?" 
write file txt/text
][
all[
file: request-file/save 
write file txt/text
]
]
]
]
display/dialog/close any[text either file[reform["Edit -" to-local-file file]]["Edit"]][
space 0x0 
tool-bar #LW data[
button "New"[
save? 
file: none 
clear-text/focus txt 
chk: checksum txt/text
]
button "Open"[
save? 
if var: request-file[
file: var 
set-title face reform["Edit -" to-local-file file]
set-text/focus read file
]
chk: checksum txt/text
]
button "Save"[
save? 
chk: checksum txt/text
]
button "Close"[
save? 
hide-popup
]
]
return 
pad 0x-1 
txt: area 80x120 #HW string 
do[set-focus last face/pane]
][
save? 
true
]
file
]
flash: make function![
"Flashes a message to the user and continues." 
value[any-type!]"Value to display" 
/title text[string!]
][
display/dialog/no-wait any[text "Information"][
image images/info 
text #V (form value)
]
]
request: make function![
"Requests an answer to a simple question." 
prompt[string!]
/title text[string!]
/ok 
/confirm 
/type icon[word!]"Valid values are: alert, help, info, stop" 
/local result
][
result: none 
display/dialog any[text "Request"]compose[
after 1 
(
either type[
reduce['image select[alert images/alert help images/help info images/info stop images/stop]icon]
][]
) 
text 60 (prompt) 
bar 
reverse 
(
case[
ok[
[button "OK"[result: true hide-popup]]
]
confirm[
[button "No"[result: false hide-popup]button "Yes"[result: true hide-popup]]
]
true[
[button "Cancel"[hide-popup]button "No"[result: false hide-popup]button "Yes"[result: true hide-popup]]
]
]
) 
do[set-focus last face/pane]
]
result
]
request-about: make function![
"Requests an About dialog." 
product[string!]"Product name" 
version[tuple!]"Product version" 
copyright[string!]"Copyright notice" 
/url link[string! url!]"Product website"
][
display/dialog "" compose/deep[
after 1 
pad (as-pair (60 * sizes/cell / 2) - (images/logo/size/x / 2) 0) 
image images/logo 
text 60 (product) font[size: (sizes/font + 4) style: 'bold align: 'center]
(either url[[link 60 (link) font[align: 'center]]][]) 
text 60 (join "Version " version) font[align: 'center]
text 60 (copyright) font[align: 'center]
]
]
request-calc: make function![
"Requests a calculation." 
/title text[string!]"Title text" 
/stay "Don't exit on =" 
/local result c reg op acc lcd
][
result: none 
reg:[]
op: false 
acc: none 
c: make function![face /local key][
either find ".0123456789" key: face/text[
all[none? pick reg not op insert reg copy ""]
unless all["." = key find reg/1 key][insert tail reg/1 key]
][
if any[key = "=" reg/2][
acc: none 
all[
op 
acc: attempt[do reform[any[reg/2 acc 0]op 'to-decimal reg/1]]
]
clear reg 
op: false
]
either key = "="[
unless stay[
result: any[reg/1 acc 0]
hide-popup
]
][
any[reg/1 insert reg any[acc 0]]
op: key
]
]
unless find lcd/text: form any[reg/1 acc 0]"."[insert tail lcd/text "."]
show lcd
]
display/dialog any[text "Calculator"][
button-size 7 
lcd: text "0." #L font[align: 'right]edge[color: colors/text]
after 4 
button "7"[c face]button "8"[c face]button "9"[c face]button sky "/"[c face]
button "4"[c face]button "5"[c face]button "6"[c face]button sky "*"[c face]
button "1"[c face]button "2"[c face]button "3"[c face]button sky "-"[c face]
button "0"[c face]button "."[c face]button green "="[c face]button sky "+"[c face]
]
result
]
request-char: make function![
"Requests a character." 
/title text[string!]"Title text" 
/font name[string!]"Font to use" 
/local result char-spec size
][
get-fonts 
name: any[name effects/font]
char-spec: compose/only[
text-list 50x120 data (fonts)[
foreach f face/parent-face/parent-face/pane/2/pane[
f/font/name: face/selected
]
show face/parent-face/parent-face
]
panel data[space 0x0 text-size 8x8]
]
repeat i 256[
if i > 32[
insert tail last char-spec compose/deep[
text (colors/edit) (form to char! i - 1) font[
name: (name) 
size: (to integer! sizes/font * 2) 
valign: 'middle 
align: 'center
][result: to char! face/text hide-popup]on[
over[select-face face]
away[deselect-face face]
]
]
if zero? remainder i 16[insert tail last char-spec 'return]
]
]
insert tail char-spec compose[do[face/color: colors/edit]]
result: none 
display/dialog any[text "Character Map"]char-spec 
result
]
request-color: make function![
"Requests a color." 
/title text[string!]"Title text" 
/color clr[tuple!]"Default color" 
/local result bx
][
clr: any[clr colors/text]
result: none 
display/dialog any[text "Color Palette"]compose[
(color-spec) 
return bar return 
text "Red" spinner 15 data (clr/1) options[0 255 1][bx/color/1: face/data show bx]
bx: box 5x5 #L clr edge[][result: bx/color hide-popup]
return 
text "Green" spinner 15 data (clr/2) options[0 255 1][bx/color/2: face/data show bx]
return 
text "Blue" spinner 15 data (clr/3) options[0 255 1][bx/color/3: face/data show bx]
return 
bar 
reverse 
button "Cancel"[hide-popup]
button "OK"[result: bx/color hide-popup]
do[
bx/size/y: sizes/cell * 17
]
]
result
]
request-date: make function![
"Requests a date." 
/title text[string!]"Title text" 
/date dt[date!]"Initial date to show (default is today)" 
/local result
][
result: none 
display/dialog any[text "Calender"][
calendar data (any[dt now/date])[result: face/data hide-popup]
reverse 
button "Cancel"[hide-popup]
button "OK"[result: any[dt now/date]hide-popup]
]
result
]
request-dir: make function![
"Requests a directory." 
/title text[string!]"Title text" 
/path dir[file!]"Set starting directory" 
/only "Only allow new folder at root" 
/local result txt
][
if any[none? dir not exists? dir][dir: what-dir]
dir: dirize dir 
result: none 
display/dialog any[text "Folder"]compose/only/deep[
after 1 
image images/help 
txt: text 100 (to-local-file dir) 
tree #HW 100x50 data (read-dir dir)[
set-text txt to-local-file join dir face/selected
]on-dbl-click[result: dirize to-rebol-file txt/text hide-popup]
reverse 
button #XY "Cancel"[hide-popup]
button #XY "New"[
if var: request-value/type "New Folder" file![
var: to-rebol-file either only[dirize var][join dirize txt/text dirize var]
either exists? var[
alert "Folder already exists."
][
make-dir result: var 
hide-popup
]
]
]
button #XY "Open"[result: dirize to-rebol-file txt/text hide-popup]
]
result
]
request-email: make function![
"Requests email settings." 
/title text[string!]"Title text" 
/default settings[block!]"Default user, address, SMTP and POP settings" 
/local result f1 f2 f3 f4
][
unless default[
settings: reduce[
any[system/user/name ""]
any[system/user/email ""]
any[system/schemes/default/host ""]
any[system/schemes/pop/host ""]
]
]
result: none 
display/dialog any[text "Email Settings"][
image images/help 
after 2 
label "User name" f1: field (form first settings) 
label "Email address" f2: field (form second settings) 
label "SMTP server" f3: field (form third settings) 
label "POP server" f4: field (form fourth settings) on-focus[
all[empty? face/text face/text: copy f3/text]
true
]
bar 
reverse 
button "Cancel"[hide-popup]
button "OK"[
unless any[
empty? f1/text 
empty? f2/text 
empty? f3/text 
empty? f4/text
][
either error? try[set-net reduce[to email! f2/text f3/text f4/text]][
alert "Failed to change email settings."
][
system/user/name: f1/text 
result: reduce[f1/text to email! f2/text f3/text f4/text]
]
]
hide-popup
]
do[set-focus third face/pane]
]
result
]
request-error: make function![
"Displays an error with send and exit options." 
error[error! string!]
/local s
][
error: either error? error[disarm error][disarm make error! error]
s: copy "" 
foreach window screen*/pane[
insert tail s join window/text "^/"
]
remove back tail s 
clear screen*/pane 
clear view*/pop-list 
view*/focal-face: view*/pop-face: none 
show screen* 
recycle 
display/dialog join uppercase/part form error/type 1 " Error" compose[
after 1 
image images/stop 
heading (form error/id) 
panel data[
after 1 
label "Info" 
text 100 (reform["RebGUI" build now/date now/time]) 
label "Displays" 
text 100 s 
label "Arguments" 
text 100 (reform[mold error/arg1 mold error/arg2 mold error/arg3]) 
label "Near" 
text 100 (mold/only error/near) 
label "Where" 
text 100 (mold/only error/where)
]
reverse 
button "Exit"[quit]
(
either all[on-error/email system/user/email][
[
button "Send"[
alert either error? try[
send/subject on-error/email rejoin[
error/type error/id 
"^/^/-INFO-^/" reform["RebGUI" build now/date now/time]
"^/^/-DISPLAYS-^/" s 
"^/^/-ARGUMENTS-^/" reform[mold error/arg1 mold error/arg2 mold error/arg3]
"^/^/-NEAR-^/" mold/only error/near 
"^/^/-WHERE-^/" mold/only error/where
]on-error/subject
]["Failed to send email!"]["Email sent." quit]
]
]
][]
) 
do[set-focus last face/pane]
]
]
request-file: make function![
"Requests a file." 
/title text[string!]"Title text" 
/path dir[file!]"Set starting directory" 
/save "Request file for saving, otherwise loading" 
/filter mask[file! block!]"Coerce suffix if file!" 
/default file[file!]
/local result
][
if any[none? dir not exists? dir][dir: what-dir]
dir: dirize dir 
result: none 
display/dialog any[text either save["Save"]["Open"]]compose[
after 1 
image images/help 
field (all[default as-string file]) 
(
unless save[
sort filter: remove-each f read dir[
any[
#"." = first f 
#"/" = last f 
all[file? mask mask <> suffix? f]
all[block? mask not find mask suffix? f]
]
]
[
text-list data filter[
set-text first in-widget face/parent-face/parent-face 'field face/selected
]on-dbl-click[
var: first in-widget face/parent-face/parent-face 'field 
unless empty? trim var/text[result: to-rebol-file var/text]
hide-popup
]
]
]
) 
reverse 
button "Cancel"[hide-popup]
button "OK"[
var: first in-widget face/parent-face 'field 
unless empty? trim var/text[result: to-rebol-file var/text]
hide-popup
]
do[set-focus first in-widget face 'field]
]
either result[
all[
file? mask 
mask <> suffix? result 
result: join result mask
]
join dir result
][result]
]
request-font: make function![
"Requests a font name, returning a string." 
/title text[string!]"Title text" 
/object {Adds style, size and align selectors (returns font! object!)} 
/local result f blk
][
get-fonts 
f: rejoin["Fonts (" length? fonts ")"]
result: none 
blk: either object[
compose[
group-box 50x43 (f) data[
text-list #LV data fonts[f/font/name: copy f/text: copy face/selected show f]
]
group-box 25x43 "Style" data[
after 1 
radio-group data[1 "Normal" "Bold" "Italic" "Underline"][f/font/style: pick reduce[none 'bold 'italic 'underline]face/picked show f]
label "Size" 
spinner #L options[8 36 2]data 24[f/font/size: face/data show f]
]
group-box 25x43 "Align" data[
radio-group data[2 "left" "center" "right"][f/font/align: to word! face/selected show f]
return 
radio-group data[2 "top" "middle" "bottom"][f/font/valign: to word! face/selected show f]
]
after 1
]
][
compose[
after 1 
label (f) 
text-list 50x30 data fonts[f/font/name: copy f/text: copy face/selected show f]
]
]
insert tail blk[
f: field #L effects/font 20x20 edge[size: 0x0]font[size: 24 align: 'center]
bar 
reverse 
button "Cancel"[hide-popup]
button "OK"[result: either object[f/font][f/font/name]hide-popup]
]
display/dialog any[text "Available Fonts"]blk 
result
]
request-list: make function![
"Requests a selection from a list." 
items[block!]"List of items to display." 
/title text[string!]"Title text" 
/prompt string[string!]"Prompt text" 
/ok 
/local result size
][
size: 0 
foreach item items[
size: max size first widgets/text-size? form item
]
size: max 50x10 min 200x100 as-pair size / sizes/cell + sizes/cell 5 * length? items 
result: none 
display/dialog any[text either ok["View"]["List"]]compose[
after 1 
image (either ok[images/info][images/help]) 
text (any[string either ok["Details:"]["Select an entry:"]]) 
text-list (size) data items 
reverse 
(either ok[][[button "Cancel"[hide-popup]]]) 
button "OK"[result: face/parent-face/pane/3/selected hide-popup]
do[set-focus last face/pane]
]
result
]
request-menu: make function![
"Requests a menu choice." 
face[object!]"Widget to appear in relation to" 
menu[block!]"Label/Action block pairs" 
/width x[integer!]"Width in pixels (defaults to 25 units)" 
/offset xy[pair!]"Offset relative to widget (defaults to top right)" 
/local result
][
result: none 
do select menu result: widgets/choose face any[x 25 * sizes/cell]any[xy face/offset + as-pair face/size/x 0]extract menu 2 
result
]
request-pass: make function![
"Requests a username and password." 
/title text[string!]"Title text" 
/user username[string!]"Default username" 
/pass password[string!]"Default password" 
/check rules[block!]{Rules to test password against (fails if string returned)} 
/only "Password only" 
/verify "Verify password" 
/local result s blk u p v
][
blk: copy[]
all[check rules: make function![text[string!]]rules]
all[not only insert tail blk compose[text "Username:" u: field (any[username ""])]]
insert tail blk compose[text "Password:" p: password (any[password ""])]
all[verify insert tail blk[text "Verify:" v: password]]
result: none 
display/dialog any[text "Password"]compose[
text-size 20 
image images/help 
after 2 
(blk) 
bar 
reverse 
button "Cancel"[hide-popup]
button "OK"[
case[
all[not only empty? u/text][
alert "Username must be provided." 
set-focus u
]
all[check string? s: rules p/text][
alert s 
set-focus p
]
all[verify p/text <> v/text][
alert "Please try again." 
set-focus v
]
true[
result: either only[copy p/text][reduce[u/text p/text]]
hide-popup
]
]
]
do[set-focus third face/pane]
]
result
]
request-progress: make function![
"Requests a progress dialog for an action block." 
steps[integer!]"Number of iterations" 
block[block!]"Action block" 
/title text[string!]"Title text" 
/local step *s *p
][
*s: 1 / steps 
step: make function![][*p/data: *p/data + *s show *p]
display/dialog/no-wait any[text "Loading ..."][
image images/info 
return 
*p: progress
]
do bind block 'step 
wait 0.1 
hide-popup 
wait[]
]
request-spellcheck: make function![
"Requests spellcheck on a widget's text." 
face[object!]
/title text[string!]"Title text" 
/anagram "Anagram option" 
/local ignore new next-word word start end txt fld lst a
][
if any[not string? face/text empty? face/text][exit]
ignore: copy[]
new: copy[]
unless exists? %dictionary[make-dir %dictionary]
unless locale*/dict[locale*/dict: make hash! 1000]
next-word: make function![/init][
while[any[init start <> end]][
either init[
start: end: head face/text 
unless find edit/letter first start[
while[all[not tail? start: next start find edit/other first start]][]
]
init: false
][
start: end 
while[all[not tail? start: next start find edit/other first start]][]
]
end: start 
while[all[not tail? end: next end find edit/letter first end]][]
word: copy/part start end 
unless any[
empty? word 
find ignore word 
find new word 
find locale*/dict word
][break]
word: none
]
if all[none? init word][
txt/text: fld/text: word 
show[txt fld]
insert clear lst/data edit/lookup-word word lst/redraw 
view*/focal-face: face 
view*/caret: none 
edit/hilight-text start end 
show face
]
string? word
]
if next-word/init[
view*/caret: none 
edit/hilight-text start end 
show face 
display/dialog any[text rejoin["Spellcheck (" locale*/language ")"]][
image images/help 
after 2 
label "Original" txt: text 75 word 
label "Word" fld: field 75 word 
label "Suggestions" lst: text-list data (edit/lookup-word word) 75x50[set-text fld face/selected]
bar 
reverse 
button "Close"[
hide-popup
]
button "Add"[
insert tail new fld/text 
unless next-word[hide-popup]
]
button "Replace"[
change/part start fld/text end 
end: skip start length? fld/text 
unless next-word[hide-popup]
]
button "Ignore"[
insert tail ignore word 
unless next-word[hide-popup]
]
a: button "Anagram" false[
either 2 < var: length? fld/text[
face/data: lowercase sort copy fld/text 
clear lst/data 
foreach word locale*/dict[
all[var = length? word face/data = sort copy word insert tail lst/data word]
]
lst/redraw
][alert "Requires a word with at least 3 characters."]
]
do[all[anagram a/show?: true]]
]
set-focus face 
unless empty? new[
insert tail locale*/dict new 
write locale*/dictionary form locale*/dict
]
]
]
request-value: make function![
"Requests a value." 
prompt[string!]"Prompt text" 
/title text[string!]"Title text" 
/default value[any-type!]"Default value" 
/type datatype[datatype!]"Return type" 
/key keytype[datatype!]"Key type" 
/chars limit[pair!]
/local result f b
][
value: form any[value ""]
limit: any[limit 0x255]
result: none 
display/dialog any[text "Ask"][
after 1 
image images/help 
text 50 prompt 
f: field value[b/action/on-click b]on-key[
unless any[
word? event/key 
find edit/keymap event/key
][
all[
limit/2 <= length? face/text 
return false
]
all[
key 
error? try[to keytype form event/key]
return false
]
]
true
]
bar 
reverse 
button "Cancel"[hide-popup]
b: button "OK"[
if limit/1 <= length? trim f/text[
either type[
unless result: attempt[to datatype f/text][
alert rejoin[f/text " is not a valid " datatype "!"]
exit
]
][
result: f/text
]
]
hide-popup
]
do[set-focus first in-widget face 'field]
]
result
]
request-verify: make function![
{Displays a set of labels/values and prompts for verification.} 
labels[block!]"Labels" 
values[block!]"Values" 
/title text[string!]"Title text" 
/prompt string[string!]"Prompt text" 
/ok 
/local result blk width
][
blk: copy[]
width: 0 
foreach label labels[
label: form label 
insert tail blk compose[label (label) text (form first values)]
width: max width first widgets/text-size? label 
values: next values
]
values: head values 
result: false 
display/dialog any[text either ok["Info"]["Verify"]]compose[
label-size (1 + to integer! width / sizes/cell) 
image (either ok[images/info][images/help]) 
return 
text (any[string either ok["Details."]["Are these details correct?"]]) 
after 2 
(blk) 
return 
bar 
reverse 
(
either ok[
[button "OK"[result: true hide-popup]]
][
[button "No"[hide-popup]button "Yes"[result: true hide-popup]]
]
) 
do[set-focus last face/pane]
]
result
]
splash: make function![
{Displays a centered splash screen for one or more seconds.} 
spec[block! file! image!]"The face spec or image to display"
][
spec: either block? spec[make widgets/baseface spec][
make widgets/baseface[
image: either file? spec[load spec][spec]
size: image/size
]
]
spec/type: 'splash 
spec/offset: max 0x0 screen*/size - spec/size / 2 
spec/color: any[spec/color colors/page]
view/new/options spec 'no-title 
wait effects/splash-delay
]
]
foreach word find first requestors 'alert[
set to word! word get in requestors word
]
set-locale none 
insert tail words next find first widgets 'choose
]
open-events 
recycle



;**************END of REBGUI script******************
;****************************************************		

;Here starts supercalculator script:
errore: false  ;error checking
;set background color
CTX-REBGUI/COLORS/page: 255.255.240
	
;following lines are to obtain current file version
header-script: system/script/header
version: "Version: "
append version header-script/version
	

risultato2: " "
ultimo: 0


decimali: 0.01     
; We define a function to round the values to the specified digits
troncare: func [ misura2 ]
   [
   esatto: round/to misura2 decimali
   return esatto
   ]


valuta: func [frase][	
	frase: to-string frase
	frase: trim/all frase  ;we avoid spaces
	nega: false
	
	 
	;let's check if want to reuse last result
	if (parse frase  [ ["+"|"-"|"*"|"/"|"^^" ] to end ])  [ 
		ultimo2: to-decimal ultimo 
		if ultimo2 < 0 [   ;so we avoid problems with negative numbers
			ultimo: to-string ultimo 
			insert ultimo "0"  
			nega: true
			]
		insert frase ultimo
		]
	
	replace/all frase "("  " ((( " ;so we don't mix original parentheisis with the followings
	replace/all frase ")"  " ))) " ;so we don't mix original parentheisis with the followings
	replace/all frase  "abs-"   "  abs  " ;it's tricky but necessary
	replace/all frase  "abs+"   "  abs  "
	replace/all frase "exp-"   "  exp  negate "
	replace/all frase "log-"   "  log negate  "
	replace/all frase "ln-"   "  ln negate  "
	replace/all frase "sin-"   "  sin negate  " 
	replace/all frase "cos-"   "  cos negate  "
	replace/all frase "tangent-"   "  tangent  negate "
	replace/all frase "arcs-"   "  arcs negate  " ;bad change, but necessary
	replace/all frase "arcc-"   "  arcc negate  " ;bad change, but necessary
	replace/all frase "arct-"   "  arct negate  " ;bad change, but necessary
	replace/all frase "*"  " ) * ( "
	replace/all frase "/"   " ) / ( "
	replace/all frase "+"   " )) + (( "
	replace/all frase "-"   " )) - (( "
	replace/all frase "^^"   "  **  " ;bad change, but necessary
	replace/all frase "exp"   "  exp  "
	replace/all frase "log"   "  log-10  "
	replace/all frase "ln"   "  log-e  "
	replace/all frase "sqrt"   "  square-root  " ;bad change, but necessary
	replace/all frase  "abs"   "  abs  "
	replace/all frase "sin"   "  sine  " 
	replace/all frase "cos"   "  cosine  "
	replace/all frase "tangent"   "  tangent  "
	replace/all frase "arcs"   "  arcsine  " ;bad change, but necessary
	replace/all frase "arcc"   "  arccosine  " ;bad change, but necessary
	replace/all frase "arct"   "  arctangent  " ;bad change, but necessary
	replace/all frase "e )) - (( "   "e-" ;bad change, but necessary
	insert frase " (( "
	append frase " )) "	
	
	;uncomment the following line to debug or to see what happen...	
	;print frase
	
	risultato: attempt [do frase ]
	if risultato = none  [  errore: true 
		risultato: 0 ]
	ultimo: risultato ;the last result
	;check if user wants to round result
	if y_chk/data = true [  risultato: troncare risultato ]
	
	;print risultato
	;restore the origina string
	replace/all frase    "  **  " "^^"
	replace/all frase   "  arcsine  "  "arcs" 
	replace/all frase    "  arccosine  " "arcc"
	replace/all frase   "  arctangent  " "arct" 
	replace/all frase    "  square-root  " "sqrt"
	replace/all frase    "  abs  "  "abs"
	replace/all frase    "  sine  "  "sin"
	replace/all frase   "  cosine  " "cos" 
	replace/all frase    "  log-10  " "log"
	replace/all frase    "  log-e  " "ln"
	
	replace/all frase    "  exp  negate " "exp-"
	replace/all frase    "  log negate  " "log-"
	replace/all frase    "  ln negate  "  "ln-"
	replace/all frase    "  sin negate  "  "sin-"
	replace/all frase    "  cos negate  " "cos-"
	replace/all frase    "  tangent  negate " "tangent-"
	replace/all frase   "  arcs negate  "   "arcs-" 
	replace/all frase    "  arcc negate  "  "arcc-"
	replace/all frase   "  arct negate  "  "arct-" 
	
	replace/all  frase " ) " "" ;remove al simple parenthesis
	replace/all  frase " ( " "" ;remove al simple parenthesis
	replace/all  frase " (( " "" ;remove al double parenthesis
	replace/all  frase " )) " "" ;remove al double parenthesis
	replace/all frase   " ((( "  "(" ;
	replace/all frase   " ))) "  ")"
	
	
	
	pretty_frase: trim/all frase
	if nega = true [ remove pretty_frase] ;we remove the first zero added to avoid problems with negative numbers
	;riga is the separetor line
	riga: copy "-------"
	n_riga: length? pretty_frase
	for i 1 n_riga 1 [ append riga "-" ]
	
	risultato2: head risultato2
	either errore [  risultato2: insert risultato2  (reform [ "^/" pretty_frase "^/" riga "^/= " " ERROR!^/"]) ] [
		risultato2: insert risultato2  (reform [ "^/" pretty_frase "^/" riga "^/= " risultato "^/"]) 
		]
	risultato2: head risultato2
	errore: false
	return risultato2
	]



solve_all: func [] [
	
	]

display "Supercalculator" [

	text "History:"
	return
	a_field: area 130x50
	
	
	
	
	return
	text "Write expression:"
	b_field: field 100x5 [ 
		if  b_field/text = "" [ b_field/text: "0"]
		a_field/text: to-string (valuta b_field/text)
		;b_field/text: copy []
		clear-text/focus b_field
		;b_field/text: to-string b_field/text
		show [ a_field b_field]
		]
	return 
	button  yellow "1" [ append b_field/text "1"  show b_field]
	button  yellow "2" [ append b_field/text "2"  show b_field]
	button  yellow "3" [ append b_field/text "3"  show b_field]
	button   "+" [ append b_field/text "+"  show b_field]
	button   "-" [ append b_field/text "-"  show b_field]
	button "sin"   [ append b_field/text "sin"  show b_field]
	button "cos"  [ append b_field/text "cos"  show b_field]
	button "tan"  [ append b_field/text "tangent"  show b_field]
	return
	button yellow  "4" [ append b_field/text "4"  show b_field]
	button  yellow "5" [ append b_field/text "5"  show b_field]
	button  yellow "6" [ append b_field/text "6"  show b_field]
	button   "*" [ append b_field/text "*"  show b_field]
	button   "/" [ append b_field/text "/"  show b_field]
	button "asin"  [ append b_field/text "arcs"  show b_field]
	button "acos"  [ append b_field/text "arcc"  show b_field]
	button "atan"  [ append b_field/text "arct"  show b_field]
	return
	button  yellow "7" [ append b_field/text "7"  show b_field]
	button  yellow "8" [ append b_field/text "8"  show b_field]
	button yellow  "9" [ append b_field/text "9"  show b_field]
	
	button   " ^^ " [ append b_field/text "^^"  show b_field]
	button  "EE" [ append b_field/text "e"  show b_field]
	button  "log"  [ append b_field/text "log"  show b_field]	
	button  "ln" [ append b_field/text "ln"  show b_field]	
	button  "e^^"  [ append b_field/text " exp "  show b_field]	
	
	return
	button  yellow "." [ append b_field/text "."  show b_field]
	button yellow  "0" [ append b_field/text "0"  show b_field]
	button   green "=" [ 
		if  b_field/text = "" [ b_field/text: "0"]
		a_field/text: to-string (valuta b_field/text)
		b_field/text: copy []
		b_field/text: to-string b_field/text
		show [ a_field b_field]
		]
	button red  "CC" [ b_field/text: copy []   show b_field]
	button    "SQRT" [ append b_field/text "sqrt"  show b_field]
	
	button   "(" [ append b_field/text "("  show b_field]
	button   ")" [ append b_field/text ")"  show b_field]
	
	button  "abs"   [ append b_field/text "abs"  show b_field]	
		
		
	return
	
	y_chk: check "Fixed decimal digits?" data false
	;return
	text "Digits"
	;cifredecimali: text "2"
    cifredecimali: spinner data  2 [decimali: 0.1 ** (  cifredecimali/data )]
	button blue "?" [ display "Help"  [ 
			heading "HELP"
			return
			text {Welcome to Supercalculator, a Scientific calculator written in Rebol.
You can use it on Windows, Liunx, Mac and whatever Rebol works!
You can write directly the formulas in the field an press ENTER or press =.
You can use parethesis to write correctly the formulas.
You can contact me for help: 
Massimiliano Vessi 
maxint@tiscali.it}
			return
			text  version
			return
			image logo.gif [display "my note" [text { I wrote this scientific calculatur with only 200 lines of code (1-2 hours), 
all the rest is a copy and paste of RebGUI code (about 5850 lines),
I used RebGUI, but I could use the orginal VID reducing to the original 200 lines of code,
but RebGui is more beautiful than VID...
However no other langage make people capable of writing a scientific calculatoin 2 hours or less.
Massimiliano Vessi}] 
				]
			]
		]
	return
	text version ;to visualize version		         
	 
	]

do-events
	