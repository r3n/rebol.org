REBOL [
    title: "Memory Match Game"
    date: 12-oct-2015
    file: %match-game.r
    author:  Nick Antonaccio
    purpose: {
        A configurable 'concentration' type matching game.

        Enter the number of rows and columns which you want to play.
        The total number of boxes must be even (to allow pair matching), 
        max 11x10. Graphic size is automatically adjusted to fit the screen.

        To play, click on any pair of boxes.  Remember the characters
        revealed, and match all the pairs in the fewest number of moves. 
        The game ends, and your score is displayed when you've matched all
        the pairs.
    }
]
random/seed now
cols: to-integer request-text/title/default "Number of columns:" "5"
rows: to-integer request-text/title/default "Number of rows:" "4"
if not even? (cols * rows) [alert "Cols * Rows must be EVEN" quit]
chars: "123456789abcdefghijklmnopqrstuvwxyz~!@#$%^&*()_+-={}\[]:;'<>?,./|"
board: random join c: copy/part chars (rows * cols / 2) c
siz: to-pair sizer: (system/view/screen-face/size/1 / rows / 3) sizer
choices: copy []  moves: 0  done: 0
g: [
    style b box siz purple [
        moves: moves + 1
        append choices face/text: face/data
        switch length? choices [
            1 [oldface: face]
            2 [
                wait .5
                if all [choices/1 = choices/2 face <> oldface] [
                    face/color: oldface/color: gray
                    done: done + 2
                ]
                face/text: oldface/text: "" 
                show oldface 
                choices: copy []
            ]
        ]
        show face
        if done = length? board [alert rejoin ["Done in " moves " moves!"]]
    ]
]
repeat col cols [
   repeat row rows [
       append g compose/deep [
           b with [data: form pick board ((rows * col - rows) + row)]
       ]
   ]
   append g [return]
]
view center-face layout g