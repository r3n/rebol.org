REBOL [
    Title: "Object Cloner"
    Date: 30-Jun-2000
    File: %cloneobj.r
    Author: "Erin A. Thomas"
    Purpose: {
        Clone objects recursively. This way the objects inside
        are copies instead of references.
    }
    Email: timewarp@sirius.com
    Example: {
        new-object clone make existing-object []
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

clone: func [
    "Clones all sub objects so there are no multiple references"
    o [object!] "The object to clone"
    /local wrd so
] [
    foreach wrd next first o [
        if object? so: get in o :wrd [(set in o :wrd make so []) (clone so)]
    ]
    return o
]

