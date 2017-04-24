Rebol [
    Title: "Cellular automata"
    Date: 20-Jul-2003
    File: %oneliner-rule-110-ca.r
    Purpose: {Shows some steps in the evolution of a Turing complete cellular automaton from a
single marked cell. Replace "..1.11." with some other expression, like "..11.." or ".1..11",
and what do you have? Rule 90, and rule 30, respectively.}
    One-liner-length: 117
    Version: 1.0.0
    Author: "Errru"
    Library: [
        level: 'intermediate
        platform: none
        type: [How-to FAQ one-liner]
        domain: [game math]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
s:"..1.."loop 38[t: copy".."forall s[if s/3[append t pick{.1}none? find{..1.11.}copy/part s 3]]print s: append t".."]
