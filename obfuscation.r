REBOL [
    File: %obfuscation.r
    Date: 22-Aug-2009
    Title: "Obfuscation"
    Author:  Nick Antonaccio
    Description: {
        An exercise in obfuscation - the Snake Game in 761 bytes.  Any
        function used several times is renamed with a shorter word label 
        (r: :random, p: :append, etc.).  Spaces surrounding all parentheses
        and brackets are also removed. Taken from the tutorial at
        http://musiclessonz.com/rebol.html
    }
]

do[p: :append u: :reduce k: :pick r: :random y: :layout q: 'image z: :if
g: :to-image v: :length? x: does[alert join{SCORE: }[v b]quit]s: g y/tight
[btn red 10x10]o: g y/tight[btn tan 10x10]d: 0x10 w: 0 r/seed now b: u[q
o(((r 19x19)* 10)+ 50x50)q s(((r 19x19)* 10)+ 50x50)]view center-face
y/tight[c: area 305x305 effect[draw b]rate 15 feel[engage: func[f a e][z a
= 'key[d: select u['up 0x-10 'down 0x10 'left -10x0 'right 10x0]e/key]z a
= 'time[z any[b/6/1 < 0 b/6/2 < 0 b/6/1 > 290 b/6/2 > 290][x]z find(at b
7)b/6[x]z within? b/6 b/3 10x10[p b u[q s(last b)]w: 1 b/3:((r 29x29)*
10)]n: copy/part b 5 p n(b/6 + d)for i 7(v b)1 [either(type?(k b i)=
pair!)[p n k b(i - 3)][p n k b i]]z w = 1[clear(back tail n)p n(last b)w:
0]b: copy n show c]]]do[focus c]]]