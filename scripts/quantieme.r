REBOL[
    Title: "Quantieme"
    Date:  10-Jun-2004
    Version:  1.0.0
    File: %quantieme.r
    Author: "Philippe Le Goff "
    Purpose: "the day of year"
    Email: %lp--legoff--free--fr
    note: {- v. 1.0.0 : This script return the day of year }
    library: [
        level: 'beginner 
        platform: all 
        type: 'tool 
        domain: [user-interface] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]

]


img-logo: load 64#{
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
}

view/new/title center-face layout [
style texto text 100 font-size 18 font-name "Courrier new" font-color yellow 

at 0x0
backdrop black effect [ gradient 0x1 10.10.0 254.10.0  ]

at 20x0
;across
;image img-logo
;vh1 "Quantième"

vh3 rejoin [ "today ? : " now/date ] white 
return
at 90x25
quantieme: texto "" 

return
across
at 70x60
btn "Quantiéme ?" 80 [ 
	today: now 
	quantieme/text: today/julian
	show quantieme
]

]  "Quantiéme" 

do-events
