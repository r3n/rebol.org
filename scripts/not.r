REBOL [
    Title: "Not"
    Date: 14-Jul-2002
    Name: 'Not
    Version: 1.0.1
    File: %not.r
    Author: "Andrew Martin"
    Purpose: {Implements Not operator as '!, and Not Equal operator as '!=.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Acknowledgements: "Gabriele"
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

!: :not
!=: get first [<>]
