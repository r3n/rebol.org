REBOL [
    title: "Quick Color Guide"
    date: 23-sep-2009
    file: %quick-color-guide.r
    purpose: {
        Provides a quick visual reference for all of REBOL's built in colors.
        Click the color to see it's tuple value.
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

echo %colors.txt ? tuple! echo off
lines: read/lines %colors.txt
colors: copy []
gui: copy [across space 1x1]
count: 0
foreach line at lines 2 [
    if error? try [append colors to-word first parse line none][] 
]
foreach color colors [
    append gui [style box box [alert to-string face/color]]
    append gui reduce ['box 110x25 color to-string color]
    count: count + 1
    if count = 5 [append gui 'return count: 0]
]
view center-face layout gui