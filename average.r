REBOL [
    Title: "Average"
    Date: 3-Jul-2002
    Name: 'Average
    Version: 1.0.0
    File: %average.r
    Author: "Andrew Martin"
    Needs: [%Accumulate.r]
    Purpose: "Averages the values in the Block."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner
        platform: none
        type: 'function
        domain: 'math
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

Average: func [
	"Averages the values in the Block."
	Block [block!] "Block of values."
	] [
	divide accumulate 0 Block :+ length? Block
	]
