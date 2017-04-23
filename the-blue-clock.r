REBOL  [
    File: %the-blue-clock.r
    Date: 22-Nov-2005
    Title: "Time"
    Version: 1.0.0
    Author: "R. v.d.Zee"
    Purpose: {This script is a demonstration of an analog clock  & of a clock movement.}
    Notes:     {This script requires View 1.3}
    History: [1.0.0 [22-Nov-2005 "First Version"] ]
    Library: [
        level: intermediate
        platform: 'all
        type: [demo tool]
        domain: [sdk GUI]
        tested-under: [view 1.3.1.3.1  on [WinXP] ]
        support: none
        license: none
        see-also: %analog-clock.r
    ]
]


minuteHandRadius:  93  
hourHandRadius: 75
center: 110x110
minuteHandPosition: 0x0 
hourHandPosition: 0x0  

clockWorks:  [    
    currentTime: now/time 
    theMinute: currentTime/2 
    minuteHandTravel: theMinute * 6                           ; 1 minute is 6 degrees
    minuteHandAngle: 90 - minuteHandTravel              ; from the required angle of the right triangle
    minuteHandPosition/1:   center/1 +  ( (cosine minuteHandAngle) * minuteHandRadius)
    minuteHandPosition/2:   center/2  -  (     (sine minuteHandAngle) * minuteHandRadius)
    
    theHour: currentTime/1
    if  theHour > 12  [theHour: theHour - 12]
    hourHandTravel: theHour * (30) + ( (theMinute / 60) * 30 )
    hourHandAngle: 90 - hourHandTravel
    hourHandPosition/1:   center/1 +  ( (cosine hourHandAngle) * hourHandRadius)
    hourHandPosition/2:   center/2  -  (     (sine hourHandAngle) * hourHandRadius)
]

clockFace: copy (make block! 40 [])                        ; vectorial text improved over  "copy []"
bold20: make face/font [style:  size: 20]
append clockFace compose [
    pen navy line-width 5
    fill-pen 40.40.168
    circle center 100
    line center minuteHandPosition
    line center hourHandPosition
    circle center 3
    font bold20 
    pen green  line-width 1
    text vectorial "12"   98x15
    text vectorial   "3"   195x96                     
    text vectorial   "6"   103x180
    text vectorial   "9"   17x97

]

k: layout [
    size 220x220
    clock: origin 0x0 box black 220x220 effect reduce ['draw clockFace] rate 0:01:00 feel [
        engage: func [face act evt] [ 
            do clockWorks
            show face
         ]
    ]

]
do clockWorks
view k 