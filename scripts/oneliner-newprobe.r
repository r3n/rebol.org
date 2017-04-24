Rebol [
    Title: "Improved probe"
    Date: 20-Jul-2003
    File: %oneliner-newprobe.r
    Purpose: {Requires last beta versions. A more usable probe. Try: view newprobe layout
[button "probe"]}
    One-liner-length: 41
    Version: 1.0.0
    Author: "Romano Paolo Tenca"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner function]
        domain: []
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
newprobe: func [value][help value :value]
