Rebol [
    Title: "Console history"
    Date: 20-Jul-2003
    File: %oneliner-dohist.r
    Purpose: "Allow you to use the history just by index."
    One-liner-length: 129
    Version: 1.0.0
    Author: "Fabrice Vado"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: []
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
dohist: does [d: copy system/console/history forall d [print rejoin [index? d " : " first d]] do pick head d to-integer ask "->"]
