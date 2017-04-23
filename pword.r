REBOL [
    File: %pword.r
    Date: 19-Jun-2005   
    Title: "Password Generation"
    Purpose: "Create passwords based on a Pass Phrase"
    Version: 1.0
    Author: "Cybarite"
    Source: {
        Greg's REBOL implementation of a password JavaScript function.
        Maxim's UI from AltME
    }    
    library: [
        level: 'beginner
        platform: 'all
        type: [tool]
        domain: [security ]
        tested-under: [view 1.3.1.3.1 on W2K]
        support: [AltME]
        license: none
        see-also: none
    ]
]

generate-password-value: func [
    {Creates a password based on the MD-5 value from 
    a pass-phrase phrase, a site or device name,
    and an optional date-variable}
    pass-phrase [string!]
    site-or-device  [string!]
    {The name of a site or device}
    date-variable  [string!]
    {Allows the password to vary by month where you are required to change monthly}
    
    /include-special-character  ; this is for passwords that require some special character to be included
][
    third-parm: either date-variable = "None" [
        {}
    ][
        join ":" date-variable
    ]
    result: to-hex to-integer checksum/method rejoin [pass-phrase ":" site-or-device third-parm] 'md5
    either include-special-character [
        join result "%"
    ][
        result
    ]
]
        
clearing: does [
    if not clip-only/data [
        password-text-field/text: copy {}
        show password-text-field
    ]
    write clipboard:// {} ; clear the clipboard too 
]

bg-color: 65.125.175

view layout [
    size 400x326
    tabs [130 160]
    backdrop effect [gradient 1x1 bg-color 45.75.115 grid 500x4 499x4 70.130.190 blur]  ; from Didier
    style label label white
    style TL text-list
    with [
        size: 200x60        ; default these text-list sizes for consistency
        update-slider: does [
            sld/redrag lc / max 1 length? head lines
        ]
        picked: 1
    ]   
    across 
    image logo.gif  (bg-color)   [browse http://www.rebol.com]   ; the rebol logo with a page background color
    return
    clip-only: check [
        either value [
            hide [label-password password-text-field]
        ][
            show [label-password password-text-field]
        ]
    ] 
    
    label 300 "Write password to clipboard only" 
    return
    special-check: check [] label "Add special character '%'"
    return

    label 100 "Your Secret Pass Phrase " tab pass-phrase-phase: area 200x40  wrap [
        clearing
    ] 
    toggle 46 "Hide" "Show" effect [
        gradient 1x1 bg-color 45.75.115 grid 500x4 499x4 70.130.190 blur
        ][
            either value [
                hide pass-phrase-phase
            ][
                show pass-phrase-phase
            ]
        ]
    return
    label 100 "Site/Device" tab 
    sites: TL data [  ; replace this list of sites or devices with your values
        "VPN"
        "email" 
        "Server" 
        "ISP" 
        "AltME REBOL"
        "Router"
    ][
        clearing
    ]
    do [append clear sites/picked first sites/data]

    return
    label 100 "Dates" tab dates: TL data [
        "None" 
        "Jun-2005"     ; replace this list of dates with your values (keep "None" first)
        "Jul-2005" 
        "Aug-2005" 
        "Sep-2005" 
        "Oct-2005" 
        "Nov-2005" 
        "Dec-2005" 
        "Jan-2006"
    ][
        clearing
    ]
    do [append clear dates/picked first dates/data]
    
    btn "Help" [alert 
        {For expirying passwords enter a date value here e.g. Jun-2005. Use a standard convention whatever it is.}
    ]

    return 
    label-password: label "Password" tab password-text-field: info "" 200 silver white 
    
    btn "Go" [
        password-text-field/text: either special-check/data [
            generate-password-value/include-special-character pass-phrase-phase/text first sites/picked first dates/picked       
        ][
            generate-password-value pass-phrase-phase/text first sites/picked first dates/picked    
        ]
        
        write clipboard:// form password-text-field/text
        if not clip-only/data [
            show [password-text-field]
        ]
    ]
    
    do [focus pass-phrase-phase]
]



