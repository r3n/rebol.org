REBOL [
    Title: "REBOL Prompt Setter"
    Date: 16-Jun-1999
    File: %set-prompt.r
    Author: "Bohdan Lechnowsky"
    Purpose: {
        Demonstrates how to set the prompt in REBOL
    }
    Email: bo@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: [tool] 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

;Set system/console prompt
set-console: func ['word value] [
    set in system/console word value
]

set-console prompt [
    rejoin ["(" now/time ") " what-dir newline ">> "]
]
