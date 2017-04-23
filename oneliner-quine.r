Rebol [
    Title: "Quine -- a program that displays it's own source"
    Date: 21-Jul-2003
    File: %oneliner-quine.r
    Purpose: {Creates a self modifying window. (includes the REBOL Header.)}
    One-liner-length: 100
    Version: 1.0.0
    Author: {Ammon Johnson}
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [game math]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
REBOL[] do a: {view layout[t: field 500 rejoin["REBOL[] do a: {" a "}"] button "do" [do do t/text]]}
