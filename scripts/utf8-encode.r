REBOL [
    Title: "UTF-8 encode"
    Date: 14-Jun-2002/10:24:29+2:00
    Version: 1.0.0
    File: %utf8-encode.r
    Author: "Romano Paolo Tenca & Oldes"
    Usage: {
>> utf8-encode "chars: ìšèøžýáíé"
== "chars: Ã¬ÂšÃ¨Ã¸ÂžÃ½Ã¡Ã­Ã©"}
    Purpose: "Encodes the string data to UTF-8 (from Latin-1)"
    Comment: {More info about encoding: http://czyborra.com/utf/ }
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: 'text 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
utf8-encode: func[
  "Encodes the string data to UTF-8 (from Latin-1)"
  str [any-string!] "string to encode"
  /local c h
][
    ;if you remove 'copy you can change the original string
    parse/all copy str [
        any [
            h: skip ( if 127 < c: first h [
                h: change h c / 64 or 192
                insert h c and 63 or 128
            ]) :h
           skip
        ]
    ]
    head h
]                             