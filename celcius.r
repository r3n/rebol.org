REBOL [
    Title: "Celcius"
    Date: 3-Jul-2002
    Name: 'Celcius
    Version: 1.0.0
    File: %celcius.r
    Author: "Andrew Martin"
    Purpose: "Converts Temperature in Fahrenheit to Celcius."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: [
    Celcius 32 
    Celcius 212
]
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: 'math 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Celcius: func [
	"Converts Temperature in Fahrenheit to Celcius."
	Temperature [number!]	"Temperature in degrees Fahrenheit."
	][
	Temperature - 32 / 9 * 5
	]
