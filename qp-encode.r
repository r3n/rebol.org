REBOL [
    Title: "quoted-printable encoder"
    Date: 20-Jun-2002/13:16:03+2:00
    Version: 1.0.0
    File: %qp-encode.r
    Author: "Oldes"
    Usage: {
>> qp-encode "nejzajímavìjší"
== "nejzaj=EDmav=ECj=9A=ED"}
    Purpose: "Encodes the string data to quoted-printable format"
    Comment: {More info about this encoding:
^-^-http://www.faqs.org/rfcs/rfc2045.html}
    Email: oliva.david@seznam.cz
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [email text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
qp-encode: func[
  "Encodes the string data to quoted-printable format"
  str [any-string!] "string to encode"
  /local c h l r normal rest
][
    l: 0 r: 0
    normal: charset [#"!" - #"<" #">" - #"~" #" "]
    rest: complement literal
    parse/all copy str [
        any [
            h: [
                ( r: (index? h) - l )
                 normal (
                    ;non encoded characters
                    if r = 76  [h: insert h "=^M^/" l: -1 + index? h]
                )
                | copy c rest (
                    remove h
                    if r >= 74 [h: insert h "=^M^/" l: -1 + index? h]
                    insert h join #"=" copy/part skip mold to binary! c 2 2
                ) 2 skip
            ] :h skip
        ]
    ]
    head h
]
                                         