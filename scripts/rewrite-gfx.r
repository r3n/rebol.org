REBOL [
  Title: "rewrite-gfx"
  Purpose: {   
    Using a (forth-featured) rewrite-grammar to plot 
    recursive (turtle) graphics
  }
  Date: 2005-01-02
  Version: 0.0.2
  Author: "Piotr Gapinski"
  Url: http://www.rowery.olsztyn.pl/wspolpraca/rebol/rewrite-gfx/
  Comment: "Based on AmigaE/RewriteGfx.e by Wouter"
  File: %rewrite-gfx.r
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  License: "GNU General Public License (Version II)"
  Library: [
    level: 'intermediate
    platform: 'all
    type: [tool]
    domain: [graphics dialects]
    tested-under: [
      view 1.2.48 on [Linux WinXP]
    ]
    support: none
    license: 'GPL
  ]
  Usage: {
    a graphics plotting system that uses rewrite-grammars. the idea is
    that the description of an image (much like some fractals i know)
    is denoted in a grammar, which is then used to plot the gfx.
    the system uses turtlegraphics for plotting, and some forth-heritage
    for additional power. the program is not meant to actually "used";
    change to different graphics with the CUR-GRAPH in the sources, to
    see what the grammars do.

    next to normal context-free grammars like S->ASA,
    following (forth-lookalike) turtle commands may be used:

    up                 pen up
    down               pen down
    <x> <y> set        set absolute position
    <d> move           move relative to last coordinates, distance <d>
                      in direction <angle>, draw line if pen is down
    <angle> degr       set initial angle
    <angle> rol        rotate relative counter-clockwise (left)
    <angle> rol        rotate relative clockwise (right)
    <nr> col           set colour to plot with
    push               save x/y/angle/pen status at this point on stack
    pop                restore status
    dup                duplicate last item on stack
    <int> <int> add    add two integers
    <int> <int> sub    substract two integers (first-second)
    <int> <int> mul    multiply two integers
    <int> <int> div    divide two integers
    <int> <int> eq     see if two integers are equal
    <int> <int> neq    see if two integers are not equal
    <bool> if <s> end  conditional statement
  }
]

R: 20
graphs: compose/deep [
  [
     [S 160 188 "set" 90 "degr" 30 A 1 "col" 1 "move"] ; drzewko-1
     [A "dup" "dup" "move" "if" "dup" 115 "mul" 150 "div" "dup" 45 "rol" A 90 "ror" A 45 "rol" "end" 180 "rol" "move" 180 "rol"]
  ]
  [
     [S 160 188 "set" 90 "degr" 60 A 1 "col" 1 "move"] ; drzewko-2
     [A "dup" "dup" "move" "if" "dup" 100 "mul" 150 "div" "dup" 40 
        "rol" A 69 "ror" 196 "mul" 191 "div" A 29 "rol" "end" 180 "rol" "move" 180 "rol"]
  ]
  [
     [S 160 180 "set" 90 "degr" 32 A 1 "col" 1 "move"] ; drzewko-3
     [A "dup" "dup" "move" "if" "dup" 85 "mul" 150 "div" "dup" "dup"
        25 "rol" A 25 "ror" 150 "mul" 100 "div" A
        25 "ror" A 25 "rol" "end" 180 "rol" "move" 180 "rol"]
  ]
  [
     [S 160 120 "set" 100 A] ; rozeta
     [A 1 "sub" "dup" "col" "dup" 0 "neq" "if" B "end"]
     [B C C C C D A]
     [C 40 "move" 90 "ror"] 
     [D "up" 6 "rol" 3 "move" "down"]
  ]
  [
     [S 160 100 "set" 2 A] ; spirala
     [A 1 "add" "dup" "dup" 220 "neq" "if" 73 "ror" "move" A "end"]
  ]
  [
     [S A A A] ; trojkatne gwiazdy
     [A 25 "ror" D D D D D D "up" 50 "move" "down"]
     [D F G F G F G E]
     [E "up" (R) "move" 30 "rol" 5 "move" 30 "rol" "down"]
     [F (R) "move"]
     [G 120 "rol"]
  ]
  [
     [S 100 20 "set" 30 A] ; muszla
     [A "dup" "move" 1 "sub" "dup" 0 "neq" "if" B "end"]
     [B "dup" "dup" 90 "ror" "move" 180 "ror" "up" "move" 90 "ror" "down" 20 "ror" A]
  ]
]

colors: reduce [red green blue black]

CUR-GRAPH: 2
CUR-COLOR: 4

x: 50
y: 60
pen: true
col: colors/:CUR-COLOR
lcol: white
degr: 0

stack: make block! 100
test: true

push: func [value] [append stack value]

pop: has [tm rc] [
  either not empty? stack [
    tm: back tail stack 
    rc: first tm remove tm 
    rc
  ][none]
]

lines: make block! 100

img: make image! reduce [600x400 white]

view-graph: does [view layout [origin 0x0 image img effect [draw lines]]]

draw-line: func [x y dx dy color] [
  if color <> lcol [append lines compose [pen (color)] lcol: color]
  append lines compose [line (to-pair reduce [x y]) (to-pair reduce [dx dy])]
]

do-rewrite: func [startsym [word!]] [foreach i graphs/:CUR-GRAPH [if startsym = first i [do-list next i]]]

do-list: func [list [block!] /local cnt sym xo yo xd yd cosa sina a] [
  cnt: 1
  forever [
    sym: list/:cnt
    switch type?/word sym [
      integer! [push sym]
      word!    [do-rewrite sym]
      none!    [break]
      string!  [
        switch/default sym [
         "down"   [pen: true]
         "up"     [pen: false]
         "set"    [y: pop x: pop]
         "col"    [a: (abs pop // (length? colors)) + 1 col: colors/:a]
         "rol"    [degr: pop + degr]
         "ror"    [degr: - pop + degr]
         "degr"   [degr: pop]
         "push"   [push x push y push degr push pen]
         "pop"    [pen: pop degr: pop y: pop x: pop]
         "dup"    [a: pop push a push a]
         "add"    [push (pop + pop)]
         "sub"    [a: pop push (pop - a)]
         "mul"    [push (pop * pop)]
         "div"    [a: pop push (pop / a)]
         "eq"     [push to-integer (equal? pop pop)]
         "neq"    [push to-integer (not-equal? pop pop)]
         "end"    []
         "if"     [if (0 = to-integer pop) [while ["end" <> list/:cnt] [cnt: cnt + 1]]]
         "move"   [
                     xo: x yo: y dx: pop
                     x: xo + (dx * cosine degr)
                     y: yo - (dx * sine degr)
                     if pen [draw-line 2 * xo 2 * yo 2 * x 2 * y col]
                  ]
        ][print "WARNING: unknown opcode"]
      ]
    ]
    cnt: cnt + 1
  ]
]

do-rewrite 'S
view-graph
quit

comment {
 0.0.2 2005-01-02
    nowe
    - uaktualnione definicje rozety i drzewka z oryginalnego programu rewritegfx
    usuniete usterki 
    - przekszalcenia wykresu ("move") dostosowane do rebol; uproszczenie funkcji trygonometrycznych;
      przyklady z oryginalnego programu dzialaja z nowa funkcja przeksztalcania wykresow
 0.0.1 2004-12-18
    nowe
    - pierwsza wersja bazujaca na programie AmigaE (c) Wouter
}
