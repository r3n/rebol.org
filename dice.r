REBOL [
    Title: "Dice"
    Date: 3-Jul-2002
    Name: 'Dice
    Version: 1.0.0
    File: %dice.r
    Author: "Andrew Martin"
    Purpose: "Dice."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'game 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

DF: does [D3 - 2]
D2: does [random 2]
D3: does [random 3]
D4: does [random 4]
D6: does [random 6]
D8: does [random 8]
D10: does [random 10]
D12: does [random 12]
D20: does [random 20]
D30: does [random 30]
D50: does [random 50]
D100: does [random 100]
D1000: does [random 1000]
D10000: does [random 10000]

Roll: function [
	{Roll a Number of Dice and return their total. Example: Roll 3 D6}
	Number [integer!]	"Number of dice to roll."
	:Dice [function!]	"Dice to roll."
	][
	Total
	][
	Total: 0
	loop Number [
		Total: Total + Dice
		]
	]

TwoD6: does [Roll 2 D6]
ThreeD6: does [Roll 3 D6]
FourDF: does [Roll 4 DF]
