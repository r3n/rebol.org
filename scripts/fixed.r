REBOL [
    Author: "Andrew Martin"
    Title: "Fixed"
    Date: 12-Jun-2003
    Name: "Fixed"
    Owner: "Aztecnology"
    Version: 1.6.9
    File: %fixed.r
    Rights: "Copyright © 2003 A J Martin, Aztecnology."
    Purpose: {Cuts up fixed width data file into Rebol values in an association.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://www.rebol.it/Valley/
    Example: [
        Arguments :Arguments
    ]
    library: [
        level: 'advanced
        platform: 'all
        type: 'function
        domain: [database dialects file-handling parse]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]





Fixed: function [
{Cuts up fixed width data file into Rebol values in an association.}
Data [string! binary!]"The data file"
Dialect [block!]"The dialect controlling the cutting."
/Debug"Prints out the Fields and Values as they occur."
] [
Values Field Width Widths Value Type Previous With Line
] [
Values: make block! 200
parse Dialect [
any [
[
'skip (Width: 1) opt [set Width integer!] (
Data: next at Data Width
)
]
| [
set Field [string! | word!] (Width: 1 Type: string!) [
[
set Width integer! set Type ['binary! | 'tuple!] (
Value: attempt [to do Type copy/part Data Width]
)
]
| [
set Width integer! set Type ['issue! | 'money!] (
Value: attempt [
to do Type trim to-string copy/part Data Width
]
)
]
| [
set Widths into [some integer!] set Type ['issue! | 'money!] (
Value: make block! length? Widths
foreach Width Widths [
Line: trim to-string copy/part Data Width
if not empty? Line [
append Value to do Type Line
]
Data: next at Data Width
]
Width: 0
)
]
| [
set Widths into [some integer!] set Type 'string! (
Value: make block! length? Widths
foreach Width Widths [
Line: trim to-string copy/part Data Width
append Value to do Type Line
Data: next at Data Width
]
if parse Value [some "" end] [
clear Value
]
Width: 0
)
]
| [
set Width integer! set Type ['integer! | 'date!] (
Value: attempt [to do Type trim to-string copy/part Data Width]
)
]
| [
set Widths into [some integer!] set Type ['integer! | 'date!] (
Value: make block! length? Widths
foreach Width Widths [
attempt [
append Value to do Type trim to-string copy/part Data Width
]
Data: next at Data Width
]
Width: 0
)
]
| [
set Widths integer! 'char! (
Value: make block! Widths
loop Widths [
attempt [
append Value to-char trim to-string copy/part Data 1
]
Data: next Data
]
Width: 0
)
]
| [
'char! (
Value: attempt [to-char trim to-string copy/part Data Width]
)
]
| [
'logic! (
Value: switch/default trim to-string copy/part Data Width [
"Y" [true]
"N" [none]
] [
none
]
)
]
| [
set Width integer! (With: none) opt [/with set With string!] (
Value: to-string copy/part Data Width
either With [
trim/with Value With
][
trim Value
]
)
]
| [
set Widths into [some integer!] (
Value: make string! 100
foreach Width Widths [
Line: trim to-string copy/part Data Width
append Line newline
append Value Line
Data: next at Data Width
]
trim Value
Width: 0
)
]
] (
Data: at Data 1 + Width
either Previous: associate? Values Field [
either series? Previous [
append Previous Value
] [
if not empty? Value [
associate-many Values Field Value
]
]
] [
if any [
all [
series? Value
not empty? Value
]
not series? Value
] [
associate Values Field Value
]
]
if Debug [
print rejoin [Field ": " mold Value "."]
]
)
]
| [
set Value any-type! set Value1 any-type! (
print rejoin [
"Error: Couldn't understand: " mold Value " & " mold Value1 "!"
]
halt
)
]
]
end
]
reduce [Values Data]
]