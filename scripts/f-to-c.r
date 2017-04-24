REBOL [
    Title: "Temperature Converter"
    Date: 27-May-2007
    File: %f-to-c.r
    Author: "Nelson Benavides"
    Purpose: "Practicing Rebol/View"
    Email: nelsonbenavides22@gmail.com
	library: [
        level: 'beginner
        platform: 'all
        type: 'tool
        domain: 'gui
        tested-under: [view 1.3.2.3.1 on "Windows XP"]
        support: none
        license: none
        see-also: none
    ]
]

convert: does [
	temp: to-integer fahr/text
	celsius: (temp - 32) / 1.8
	celsius-f/text: round/to celsius .05 ;shows the result with two decimal places
	show lay
]

lay: layout [
	backdrop effect [gradient 1x1 190.0.0 0.0.100]
	title orange "Temperature Converter from Fahrenheit to Celsius"  bold italic underline
 	across
 	tabs 145
	text font-size 15 yellow "Please enter the temperature in Fahrenheit: " bold
	fahr: field 50 edge [size: 4x2]
	tab
	button "Show Celsius" [convert] return
	tab tab tab
	button "Clear" [clear-fields lay show lay focus fahr] return
	tab tab tab
	button "Close" [quit] return
	text font-size 15 yellow "The temperature in Celsius is: " bold return
	tab tab
	celsius-f: area 200x70 font-size 50 font-color green colors none edge none return
]

focus fahr
view lay