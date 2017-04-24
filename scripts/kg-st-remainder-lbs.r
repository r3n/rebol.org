REBOL [
    File:  %kg-st-remainder-lbs.r
    Date: 4-September-2005
    title: "Kilos to Stones & Pounds"
    Purpose: { To convert weight from kg to stone & lbs.}
    Author: "Leke"
    Library: [
        level: 'beginner
        platform: 'all
        type: [how-to]
        domain: [math]
        tested-under: none
        support: none
        license: none
        see-also: none ]
    ]


; kg = 6.35 | pounds = 14 | stone = 1 | (= same weight)

input-kg: to-decimal ask "WEIGHT IN KG " ; gets user input -> converts string from input-kg to decimal.

convert2stone: input-kg / 6.35 ; converts kg to stone.

stone: to-integer convert2stone ; rounds down conversion to return only Stone.
lbs: to-integer ((convert2stone - stone) * 14) + 0.5 ; gets decimal remainder -> converts remainder to correct ammount in pounds (lbs) -> rounds to closest integer.

print [input-kg "Kg is..." newline stone "St" lbs "lbs"]

halt
