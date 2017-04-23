REBOL [
    Title: "ASCII Info"
    Date: 12-Oct-2001/16:07:26-7:00
    Version: 1.0.0
    File: %ascii-info.r
    Author: "Ryan S. Cole"
    Purpose: "Basically an ASCII chart."
    Email: ryan@practicalproductivity.com
    library: [
        level: 'beginner 
        Platform: 'all
        type: [Demo Tool] 
        domain: 'GUI
        tested-under: [core 1.3.2.3.1 "windows 98"]
        support: none
        license: 'public-domain
    ]
]

ascii-meanings: [
    0 "Null"
    1 "Start of heading"
    2 "Start of text"
    3 "End of text"
    4 "End of transmission"
    5 "Enquiry"
    6 "Acknowledge"
    7 "Bell"
    8 "Backspace"
    9 "Horizontal tab"
    10 "Line feed"
    11 "Vertical tab"
    12 "Form feed"
    13 "Carriage return"
    14 "Shift out"
    15 "Shift in"
    16 "Data link escape"
    17 "Device control 1"
    18 "Device control 2"
    19 "Device control 3"
    20 "Device control 4"
    21 "Negative acknowledge"
    22 "Synchronous idle"
    23 "End of transmission block"
    24 "Cancel"
    25 "End of medium"
    26 "Substitute"
    27 "Escape"
    28 "File seperator"
    29 "Group seperator"
    30 "Record seperator"
    31 "Unit seperator"
    32 "Space"
]

to-2-hex: func [num] [
    return skip to-string to-hex num 6
]

to-3-num: function [num] [tmp] [
    tmp: to-string num
    while [3 > length? tmp][insert tmp #"0"]
    return tmp
]

to-asc: function [num] [tmp] [
    tmp: head remove back tail copy skip mold to-char num 2
    while [2 > length? tmp][insert tmp #" "]
    return tmp
]

to-description: function [num] [tmp] [
    tmp: select ascii-meanings num
    if none? tmp [tmp: copy ""]
    return tmp
]

asc: copy [""] ; solves a bug with the list box

for i 0 255 1 [
    append asc rejoin [
        to-2-hex i  "   "
        to-3-num i  "   "
        to-asc i "   "
        to-description i
    ]
]

view layout [
  Title "ASCII Chart"
  label "hex, decimal, character, description"
  text-list 300x200 data (asc) with [font: [size: 14]]
]

                                                                                      