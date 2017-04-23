REBOL [
    title: "calculator"
    date: 28-feb-2009
    file: %calculator-tutorial.r
    purpose: {
        A little GUI calculator example, with printout.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

prev-val: cur-val: 0 cur-eval: "+" display-flag: false
print "0"
view center-face layout/tight [
    size 300x350 space 0x0 across
    display: field 300x50 font-size 28 "0" return
    style butn button 100x50  [
        if display-flag = true [display/text: "" display-flag: false]
        if display/text = "0" [display/text: ""]
        display/text: rejoin [display/text value] 
        show display
        cur-val: display/text
    ]
    style eval button 100x50 brown font-size 13 [
        prev-val: cur-val
        display/text: "" show display
        cur-eval: value
    ]
    butn "1"  butn "2"  butn "3"  return
    butn "4"  butn "5"  butn "6"  return
    butn "7"  butn "8"  butn "9"  return 
    butn "0"  butn "."  eval "+" return
    eval "-" eval "*" eval "/" return
    button 300x50 gray font-size 16 "=" [
        if display-flag <> true [ 
            if ((cur-eval = "/") and (cur-val = "0")) [
                alert "Division by 0 is not allowed." break
            ]
            prin rejoin [prev-val " " cur-eval " " cur-val " = "]
            print display/text: cur-val: do rejoin [
                prev-val " " cur-eval " " cur-val
            ]
            show display
            display-flag: true
        ]
    ]
]