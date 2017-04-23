REBOL [
    Title: "Bouncing ball"
    Date: 15-Sep-1999
    File: %ball.r
    Usage: {
        rebol -cs ball.r

        Pass in an arbitrary argument to the start machine,

            ie:

            rebol -cs ball.r do-it!
    }
    Purpose: { 
        A ball bounces from one networked computer's screen to the next.
    }
    Comment: "^/        Requires VT100 compatible terminal.^/    "
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [other-net tcp] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

screen-width: 79 screen-height: 39
macho: copy machines: [tcp://one:9009 tcp://two:9009 tcp://three:9009]
reb-i: 0 tail-box: copy []

coords: load decompress #{
789C5D96CB91E34A0C04EFCF0A99207CF8B36563FD77E37190D9CB91E6D01523
1245B095AAC69F3FEF57FC7DFD49E4FDCA7B8D5973D69AB567DD66DD673D663D
67BDA8B298EAA03CA80F0C0287C022F0084C0297C4E5FDAA69A4A691FF5EFED5
7454D3514D47351DD57454D3514D471F25A11D7E776B456B456B456B9F259806
AE81EDDD63D1634D8F8D6963DA5CEAE9629B2E361EBE71DFBF076C146C146CF3
22FBBCC83E2FB28FC5FEF9223B5E3B5E3B163B16FBB473CC661DB347C7ECD131
D6C7581F637D8CF541F541F531D5E76CF8391EE7789CE3718EC749C5C9C69D6C
C649FD39F5D7D45F9F5FD8C5FD171B7DB1D117FB7BB1BF17FBFB59728DDC50BE
294177F540DF4F512C88A138C038E038003920F9A981E900EA80EA00EB80EB10
ECCF9AD039B40EBDEF370C310F390F410F490F510F598FFC7A0FB00FB80F780F
800F880F90FF2C399013B9F479AB1A868EA165E8199AFEF42BF45F0DE91B1AA7
C6B7C87E08FFE82D121E223E7A8BD43EEEF21B001C87DDCA67086840689CBED4
E96D42195219F2F8D84366806648D668FAF11D3783D45334FF27525E3DD453BD
BCCBEA5BE42F4D5163D41C35484D52A3D42C354C4D53E374E5E90AD495A82B52
A5EDE979A5EB8AD795AF2B6057C2AE8805BB84B684B684B684B684B684B604B2
04B204B214B214B214B214B214B214B214B2A76D694B214B214B214B204B214B
214B204B214B21CBEDF3B794D29642964096072F2D6B296B296BEB3241982297
22F798CB5ECA5E1A892983FCFF4AF270A490463664470EE4442EE4E7B906689A
A069843E7D18A6699AA6719AC2EE93EB3D4F1ED9901D399013B990F09EF0A678
EE0AEE8ABF9FC1C807A1267A3F10D80BD80BD89F22A82FA82FA92FA92FA92FA9
2FA92F612F612F7E6505BE8FB96382738283829382A3C2F7ACB08685352DAC71
61CD0B6B6010E85A93C21A15D6ACE0F032BCFEB26F2F37DF0DFA2AF92DF82D71
1DBDAFCA65C165C1E5C8EF53B3E46F5DF76B07B802B802B8A706F20AF20AF24A
F2D050750C2D43CFD0F4670F04F0D33DCED543835E835E835E03D5BF9A86C191
BB0734D4544BD533340D5DEF3253AEBF0ED7E66B69E2AEE1A5C1A4C1A4BF0ED7
8697869786971693169316931693169316931693FE3E5C5B5EDADC6B73AF1D2F
E1A3C168A490463664470EE4442ECB978D3EA151FCFAA5F0819EA169E81ADA86
BEA1716A7C8BFC36FCF6FEB5EB1CDECD59DC1CBA1B87EEC617B64D68FC9A8FE7
3445EA47FEFBFB3F127FB053A90C0000
}

; vt-100 movement codes defined
movement: [up "A" down "B" right "C" left  "D"]
foreach [name letter] movement [
    set name func [arg] reduce bind [
        'rejoin reduce ["^(escape)[" 'arg letter]
    ] 'letter
]
prin clr: "^(escape)[H^(escape)[J"
jump: func [x y][
    rejoin ["^(escape)[" x ";" y "H"]
]

reverse: func [blk][aux-reverse blk copy []]
aux-reverse: func [blk end][
    if empty? blk [return end] aux-reverse next blk head insert end first blk
]

reblet: func [][pick "REBOL " reb-i: either reb-i < 6 [reb-i + 1][1]]
bounce: func [/foo][
    prin clr
    while [true][
        x: x + x-delta y: y + y-delta
        if x = exit-side [transmit break]
        insert tail-box reduce [x y]
        if x < 1 [x: 0] if x > screen-width: [x: screen-width]
        if y < 1 [y: 0] if y > screen-height: [y: screen-height]
        all [any [x >= screen-width x < 1] x-delta: -1 * x-delta]
        all [any [y >= (screen-height - 1) y <= 3] y-delta: -1 * y-delta]
        prin rejoin [jump y x reblet]   
        if (40 + random 20) < length? tail-box [
            foo: back back tail tail-box prin reform [jump foo/2 foo/1 #]
            loop 2 [remove foo]
        ]
        repeat i 5000 [i] ;- a little slow down code
    ]    
]

transmit: func [][
    porto: open first macho
    any [all [x = 0 x: screen-width - 1]
         all [x = screen-width x: 1]]
    insert porto reform [x x-delta y y-delta mold next macho]
    close porto
]        

do-idle: func [][
    some-numbers: copy coords
    until [
        mark: skip some-numbers random ((length? some-numbers) - 1)
        set [a b] first mark
        prin jump (25 - a) (b + 1) prin pick "RrEeBbOoLl" random 10    
        remove mark
        if all [2 > random 25 not empty? tail-box][
            foo: back back tail tail-box prin reform [jump foo/2 foo/1 #]
            loop 2 [remove foo]
        ]
        1 = length? some-numbers        
    ]
]

wait-to-bounce: func [][
    porto: open/lines tcp://:9009
    while [none? listen: wait reduce [porto 0:00:00.5]][do-idle]
    set [x x-delta y y-delta macho] load pick listen: first listen 1
    close listen close porto    
    prin rejoin [jump y x]
    either empty? macho [
        exit-side: either x = 1 [0][screen-width]
        macho: next either start-machine [copy machines][reverse machines]      
    ][
        exit-side: either x = 1 [screen-width][0]
    ]
    bounce wait-to-bounce
]

if start-machine [
    exit-side: screen-width x: 1 y: 3 x-delta: 1 y-delta: 1 
    macho: next macho prin clr bounce
]

wait-to-bounce 
