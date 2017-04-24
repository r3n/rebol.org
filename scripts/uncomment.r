REBOL [
    Title: "uncomment"
    Date: 23-Jul-2002
    Version: 1.0.0
    File: %uncomment.r
    Author: "Gregory Pecheret"
    Purpose: "uncomment Java or C++ sources"
    Email: gregory.pecheret@free.fr
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]



remove-slashslash: func [java] [
    parse/all java [any [to "//" begin: thru newline ending: (remove/part begin ((index? ending) - (index? begin))) :begin]]
]

remove-slashstar: func [java] [
    parse/all java [any [to "/*" begin: thru "*/" ending: (remove/part begin ((index? ending) - (index? begin))) :begin]]
]

uncomment: func [java] [
        remove-slashslash java
        remove-slashstar java
]

{
; use sample
a: read %./CfgCmdOperations.java
uncomment a
print a
}
                                