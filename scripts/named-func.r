REBOL [
    Author: "Ladislav Mecir"
    Date: 10-Oct-2012/11:36:38+2:00
    Title: "Named functions"
    File: %named-func.r
    Purpose: {
        Numerous requests were made by REBOL beginners wanting to get an easy recipe,
        how to use named functions in REBOL. They usually get an answer that in REBOL,
        user-defined functions are anonymous, i.e., they do not have a name.
        Only after they are defined, they can be assigned to one or more variables.
        While such functions are named after the assignment is performed, there is no easy way
        how to obtain the name of a given function, which is a basic requirement in the requests.

        To help the beginners with their problem I decided to implement the function below, which
        can be used to define named functions. The name of the function has to be supplied as an
        argument, and it is assigned to the 'name variable available in the body of the function.
    }
]

named-func: func [
    {Defines a named function}
    'name [word! set-word!] {the name of the function}
    spec [block!] {the spec of the function}
    body [block!] {the body of the function}
    /local body-name
] [
    if set-word? :name [name: bind to word! name name]
    body: copy/deep body
    set [body body-name] use [name] reduce [reduce [:body 'name]]
    set body-name name
    set name func spec body
]

comment [
    ; Example
    named-func f [] [name]
    f
    ; == f

    ; Example
    named-func h: [] [name]
    h
    ; == h
]