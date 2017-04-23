REBOL [
    title: "Tip Calculator"
    date: 4-Dec-2013
    file: %tipcalculator.r
    author:  Nick Antonaccio
]
view layout [ 
     f: field "49.99" 
     t: field ".20" [ 
         x/text: to-money ((to-decimal f/text) * (1 + (to-decimal t/text))) show x 
     ] 
     x: title "Total, with tip:" 
] 