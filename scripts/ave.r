REBOL [
  Title: "Attribute Values Extractor"
  File: %ave.r
  Author: [ "HY" ]
  Date: 9-Jan-2006
  Purpose: "Extract attribute values from (HTML) tags"
  Library: [
    level: 'intermediate
    domain: [http web]
    license: none
    Platform: 'all
    Tested-under: none
    Type: 'function
    Support: none
  ]

  Comment: {
    Here are two functions: ex-att1 and ex-att2. The first has some
    limitations, and will return the worng text for the ACTION attribute
    on the example tag herein. The second is usually a tiny bit faster
    than the first, but in some cases much slower (like in the default
    benchmark test further down in this document). But the ex-att2 function
    RETURNS THE RIGHT ATTRIBUTE VALUE.
  }

]




ex-att1: func [str attr /local a b] [
  a: parse str "<> ='"
  while [b: find a "" remove b] []
  trim to-string select a attr
]



ex-att2: func [str attr /local ] [
  ; the following definition has to be inside this function since I do a comparison on 'attr
  attr-value-pair: [copy a attr-name eq copy v attr-value (either all [dbq = first v dbq = last v] [v: trim-quotes v]
[if all [sgq = first v sgq = last v] [v: trim-quotes v]] if (trim attr) = (trim a) [return trim v]) any ws x: ]
  parse/all str [thru-ws any [attr-only | attr-value-pair ] to end]
  ""
]





thru-ws: [thru #" " | thru tab | thru newline]
ws: [#" " | tab | newline]
to-ws: [to #" " | to newline | to tab]
not-eq: complement charset reduce "="
not-eq-or-ws: complement charset reduce [newline tab #" " #"="]
dbq: to-char {"}
sgq: #"'"

eq: [ any ws #"=" any ws ]
attr-value: [ [ dbq [ thru dbq | to end ] ] | [ sgq [ thru sgq | to end ] ] | [ to-ws any ws | to end ] ]
attr-name:  [ some not-eq-or-ws ]
attr-only: [copy a attr-name any ws [not-eq x: (x: back x) :x | end] ]


trim-quotes: func [str] [
  str: reverse next reverse str
  str: next str
]








tag: <FORM METHOD = POST ACTION=index.php?id=2&plus=377.>

print tt: now/precise
loop 5110000 [ ex-att1 tag "action" ]
print join "ex-att1 used " difference now/precise tt


print "^/===^/"


print tt: now/precise
loop 5110000 [ ex-att2 tag "action" ]
print join "ex-att2 used " difference now/precise tt

halt

