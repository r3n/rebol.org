REBOL [
    title: "Guitar Chords"
    date: 9-Dec-2009
    file: %guitar-chords.r
    author:  Nick Antonaccio
    purpose: {
       Create and print instant guitar chord diagram charts for songs.
       Taken from the tutorial at http://re-bol.com
    }
]

help: {
    This program creates guitar chord diagram charts for songs.  It was
    written to help students in highschool jazz band quickly play all of
    the common extended, altered, and complex chord types.  It can also
    be used to create chord charts for any other type of music (with
    simpler chords):  folk, rock, blues, pop, etc.

    To select chords for your song, click the root note (letter name:  A,
    Bb, C#, etc.), and then the sonority (major, minor, 7(#5b9), etc.) of
    each chord.  The list of chords you've selected will be shown in the 
    text area below.  When you've added all the chords needed to play your
    song, click the "Create Chart" button.  Your browser will open, with a
    complete graphic rendering of all chords in your song.  You can use
    your browser's page settings to print charts at different sizes.

    Two versions of each chord are presented:  1 with the root note on the
    6th string, and another with the root note on the 5th string.  Chord
    lists can be saved and reloaded with the "Save" and "Load" buttons.
    The rendered images and the HTML that displays them are all saved to
    the "./chords" folder (a subfolder of wherever this script is run).
    You can create a zip file of all the contents of that folder to play
    your song later, upload it to a web server to share with the world,
    etc.


    -- THEORY --

    Here are the formulas and fingering patterns used to create chords in
    this program:


    6th string notes:               5th string notes:
    
    0  1  3  5  7  8  10  12        0  2  3  5  7  8  10  12
    E  F  G  A  B  C  D   E         A  B  C  D  E  F  G   A
    
    The sharp symbol ("#") moves notes UP    one fret
    The flat  symbol ("b") moves notes DOWN  one fret
    
    
    Root 6 interval shapes:         Root 5 interval shapes:     
    ___________                     ___________
    | | | | 4 |                     | | | | | |
    | 3 6 9 | 7                     | | | | | |
    1 | | | 5 1                     | | | | 1 4
    | | 7 3 | |                     | | 3 6 | |
    | 5 1 4 6 9                     5 1 4 | 9 5
    | | | | | |                     | | | 7 | |
    | | 9 | 7 |                     | | 5 1 3 6
    
    
    To create any chord, slide either shape up the fretboard until the
    number "1" is on the correct root note (i.e., for a "G" chord, slide
    the root 6 shape up to the 3rd fret, or the root 5 shape up to the
    10th fret).  Then pick out the required intervals:
    
    
    CHORD TYPE:           INTERVALS:           SYMBOLS:

    Power Chord           1    5                5
    Major Triad           1    3    5           none  (just a root noot)
    Minor Triad           1   b3    5           m, min, mi, -
    Dominant 7            1    3   (5)  b7      7
    Major 7               1    3   (5)   7      maj7, M7, (triangle) 7
    Minor 7               1   b3   (5)  b7      m7, min7, mi7, -7
    Half Diminished 7     1   b3   b5   b7      m7b5, (circle with line) 7
    Diminished 7          1   b3   b5  bb7 (6)  dim7, (circle) 7
    Augmented 7           1    3   #5   b7      7aug, 7(#5), 7(+5)
    
    
    Add these intervals to the above 7th chords to create extended chords:
    
    9 (is same as 2)   11 (is same as 4)   13 (is same as 6)   
    
    Examples:              9          =    1   3  (5)  b7    9
                           min9       =    1  b3  (5)  b7    9
                           13         =    1   3   5   b7   13
                           9(+5)      =    1   3  #5   b7    9
                           maj9(#11)  =    1   3  (5)   7    9  #11


    Here are some more common chord types:
    
    "sus"       =  change 3 to 4
    "sus2"      =  change 3 to 2
    "add9"      =  1 3 5 9  (same as "add2", there's no 7 in "add" chords)
    "6,  maj6"  =  1 3 5 6
    "m6, min6"  =  1 b3 5 6
    "6/9"       =  1 3 5 6 9
    11          =  1 b7 9 11
    "/"         =  Bassist plays the note after the slash


    NOTE:  When playing complex chords (jazz chords) in a band setting,
    guitarists typically SHOULD NOT PLAY THE ROOT NOTE of the chord
    (the bassist or keyboardist will play it).  In diagrams created by 
    this program, unnecessary notes are indicated by light circles, and
    required notes are indicated by dark circles.  Here are the formulas
    and fingering patters used to create chords in this program:
}

root6-shapes: [
    "." "major triad, no symbol (just a root note)" [1 3 5 11 55 111]
    "m" "minor triad, min, mi, m, -" [1 b3 5 11 55 111]
    "aug" "augmented triad, aug, #5, +5" [1 3 b6 11 111]
    "dim" "diminished triad, dim, b5, -5" [1 b3 b5 11]
    "5" "power chord, 5" [1 55]
    "sus4" "sus4, sus" [1 4 5 11 55 111]
    "sus2" "sus2, 2" [1 99 5 11]
    "6" "major 6, maj6, ma6, 6" [1 3 5 6 11]
    "m6" "minor 6, min6, mi6, m6" [1 b3 5 6 11]
    "69" "major 6/9, 6/9, add6/9" [1 111 3 13 9]
    "maj7" "major 7, maj7, ma7, M7, (triangle) 7" [1 3 5 7 11 55]
    "7" "dominant 7, 7" [1 3 5 b7 11 55]
    "m7" "minor 7, min7, mi7, m7, -7" [1 b3 5 b7 11 55]
    "m7(b5)" "half diminished, min7(b5), (circle w/ line), m7(-5), -7(b5)"
        [1 b3 b5 b7 11]
    "dim7" "diminished 7, dim7, (circle) 7" [1 b3 b5 6 11]
    "7sus4" "dominant 7 sus4 (7sus4)" [1 4 5 b7 55 11]
    "7sus2" "dominant 7 sus2 (7sus2)" [1 b7 99 5 11]
    "7(b5)" "dominant 7 flat 5, 7(b5), 7(-5)" [1 3 b5 b7 11]
    "7(+5)" "augmented 7, 7(#5), 7(+5)" [1 3 b6 b7 11]
    "7(b9)" "dominant 7 flat 9, 7(b9), 7(-9)" [1 3 5 b7 b9]
    "7(+9)" "dominant 7 sharp 9, 7(#9), 7(+9)" [1 111 3 b77 b33]
    "7(b5b9)" "dominant 7 b5 b9, 7(b5b9), 7(-5-9)" [1 3 b5 b7 b9]
    "7(b5+9)" "dominant 7 b5 #9, 7(b5#9), 7(-5+9)" [1 3 b5 b7 b33]
    "7(+5b9)" "augmented 7 flat 9, aug7(b9), 7(#5b9)" [1 3 b6 b7 b9]
    "7(+5+9)" "augmented 7 sharp 9, aug7(#9), 7(#5#9)" [1 3 b6 b7 b33]
    "add9" "add9, add2" [1 3 5 999 55 11]
    "madd9" "minor add9, min add9, m add9, m add2" [1 b3 5 999 55 11]
    "maj9" "major 9, maj9, ma9, M9, (triangle) 9" [1 3 5 7 9]
    "maj9(+11)" "major 9 sharp 11, maj9(#11), M9(+11)" [1 3 7 9 b5]
    "9" "dominant 9, 9" [1 3 5 b7 9 55]
    "9sus" "dominant 9 sus4, 9sus4, 9sus" [1 4 5 b7 9 55]
    "9(+11)" "dominant 9 sharp 11, 9(#11), 9(+11)" [1 3 b7 9 b5]
    "m9" "minor 9, min9, mi9, m9, -9" [1 b3 5 b7 9 55]
    "11" "dominant 11, 11" [1 b7 99 44 11]
    "maj13" "major 13, maj13, ma13, M13, (triangle) 13" [1 3 55 7 11 13]
    "13" "dominant 13, 13" [1 3 55 b7 11 13]
    "m13" "minor 13, min13, mi13, m13, -13" [1 b3 55 b7 11 13]
]
root6-map:  [
    1 20x70 11 120x70 111 60x110 3 80x90 33 40x50 b3 80x70 5 100x70
    55 40x110 b5 100x50 7 60x90 b7 60x70 9 120x110 99 80x50 6 60x50
    13 100x110 4 80x110 44 100x30 999 60x150 b77 100x130 b33 120x130
    b9 120x90 b6 100x90 b55 40x90
]
root5-shapes: [
    "." "major triad, no symbol (just a root note)" [1 3 5 11 55]
    "m" "minor triad, min, mi, m, -" [1 b3 5 11 55]
    "aug" "augmented triad, aug, #5, +5" [1 3 b6 11 b66]
    "dim" "diminished triad, dim, b5, -5" [1 b3 b5 11]
    "5" "power chord, 5" [1 55]
    "sus4" "sus4, sus" [1 4 5 11 55]
    "sus2" "sus2, 2" [1 9 5 11 55]
    "6" "major 6, maj6, ma6, 6" [1 3 55 13 11]
    "m6" "minor 6, min6, mi6, m6" [1 b3 55 13 11]
    "69" "major 6/9, 6/9, add6/9" [1 33 6 9 5]
    "maj7" "major 7, maj7, ma7, M7, (triangle) 7" [1 3 5 7 55]
    "7" "dominant 7, 7" [1 3 5 b7 55]
    "m7" "minor 7, min7, mi7, m7, -7" [1 b3 5 b7 55]
    "m7(b5)" "half diminished, min7(b5), (circle w/ line), m7(-5), -7(b5)"
        [1 b3 b5 b7 b55]
    "dim7" "diminished 7, dim7, (circle) 7" [1 b33 b5 6 111]
    "7sus4" "dominant 7 sus4, 7sus4" [1 4 5 b7 55]
    "7sus2" "dominant 7 sus2, 7sus2" [1 9 5 b7 55]
    "7(b5)" "dominant 7 flat 5, 7(b5), 7(-5)" [1 33 b5 b7 111]
    "7(+5)" "augmented 7, 7(#5), 7(+5)" [1 33 b6 b7 111]
    "7(b9)" "dominant 7 flat 9, 7(b9), 7(-9)" [1 33 5 b7 b9]
    "7(+9)" "dominant 7 sharp 9, 7(#9), 7(+9)" [1 33 b7 b3]
    "7(b5b9)" "dominant 7 b5 b9, 7(b5b9), 7(-5-9)" [1 33 b5 b7 b9]
    "7(b5+9)" "dominant 7 b5 #9, 7(b5#9), 7(-5+9)" [1 33 b5 b7 b3]
    "7(+5b9)" "augmented 7 flat 9, aug7(b9), 7(#5b9)" [1 33 b6 b7 b9]
    "7(+5+9)" "augmented 7 sharp 9, aug7(#9), 7(#5#9)" [1 33 b7 b3 b6]
    "add9" "major add9, add9, add2" [1 3 5 99 55]
    "madd9" "minor add9, min add9, m add9, m add2" [1 b3 5 99 55]
    "maj9" "major 7, maj9, ma9, M9, (triangle) 9" [1 33 5 7 9]
    "maj9(+11)" "major 9 sharp 11, maj9(#11), M9(+11)" [1 33 b5 7 9]
    "9" "dominant 9, 9" [1 33 5 b7 9]
    "9sus" "dominant 9 sus4, 9sus4, 9sus" [1 44 5 b7 9]
    "9(+11)" "dominant 9 sharp 11, 9(#11), 9(+11)" [1 33 b5 b7 9]
    "m9" "minor 9, min9, mi9, m9, -9" [1 b33 5 b7 9]
    "11" "dominant 11, 11" [1 b7 9 44 444]
    "maj13" "major 13, maj13, ma13, M13, (triangle) 13" [1 3 55 7 13]
    "13" "dominant 13, 13" [1 3 55 b7 13]
    "m13" "minor 13, min13, mi13, m13, -13" [1 b3 55 b7 13]
]
root5-map:  [
    1 40x70 11 80x110 111 100x30 3 100x110 33 60x50 b33 60x30 5 120x70
    55 60x110 b5 120x50 7 80x90 b7 80x70 9 100x70 6 80x50 13 120x110
    4 100x130 44 60x70 444 120x30 99 80x150 b3 100x90 b9 100x50 b6 120x90
    b66 60x130 b55 60x90
]
root6-notes:  [
    "e" {12} "f" {1} "f#" {2} "gb" {2} "g" {3} "g#" {4} "ab" {4}
    "a" {5} "a#" {6} "bb" {6} "b" {7} "c" {8} "c#" {9} "db" {9} "d" {10}
    "d#" {11} "eb" {11}
]
root5-notes: [
    "a" {12} "a#" {1} "bb" {1} "b" {2} "c" {3} "c#" {4} "db" {4}
    "d" {5} "d#" {6} "eb" {6} "e" {7} "f" {8} "f#" {9} "gb" {9} "g" {10}
    "g#" {11} "ab" {11}
]

f: copy []
for n 20 160 20 [append f reduce ['line (as-pair 20 n) (as-pair 120 n)]]
for n 20 120 20 [append f reduce ['line (as-pair n 20) (as-pair n 160)]]
fretboard: to-image layout/tight [box white 150x180 effect [draw f]]
; spacer: to-image layout/tight [box white 20x20]

view center-face layout [
    across
    t1: text-list 60x270 data [
        "E" "F" "F#" "Gb" "G" "G#" "Ab" "A" "A#" "Bb" "B" "C" "C#" "Db"
        "D" "D#" "Eb"
    ]
    t2: text-list 330x270 data extract/index root6-shapes 3 2 [
        either empty? a/text [
            a/text: rejoin [
                copy t1/picked " "
                pick root6-shapes ((index? find root6-shapes value) - 1)
            ]
        ] [
            a/text: rejoin [
                a/text newline copy t1/picked " " 
                pick root6-shapes ((index? find root6-shapes value) - 1)
            ]
        ]
        show a
    ]
    return
    a: area
    return
    btn "Create Chart" [if error? try [
        make-dir %chords
        delete/any %chords/*.*
        ; save/bmp %./chords/spacer.bmp spacer
        html: copy "<html><body bgcolor=#ffffffff>"
        foreach [root spacer1 spacer2 type] (parse/all form a/text " ") [
            diagram: copy [image fretboard]
            diagram2: copy [image fretboard]
            root1: copy root
            foreach itvl (third find root6-shapes type) [
                either find [1 55] itvl [
                    append diagram reduce [
                        'fill-pen white 'circle (select root6-map itvl) 5
                    ]
                ] [
                    append diagram reduce [
                        'fill-pen black 'circle (select root6-map itvl) 5
                    ]
                ]
            ]
            append diagram reduce ['text (trim/all join root1 type) 20x0]
            append diagram reduce [
                'text 
                trim/all to-string (
                    select root6-notes trim/all to-string root1
                )
                130x65
            ]
            save/png
                to-file trim/all rejoin [
                    %./chords/ (replace/all root1 {#} {sharp}) type ".png"
                ]
                to-image layout/tight [
                box white 150x180 effect [draw diagram]
            ]
            append html rejoin [
                {<img src="./} 
                trim/all rejoin [
                    replace/all copy root1 {#} {sharp} type ".png"
                ]
                {">}
            ]

            foreach itvl (third find root5-shapes type) [
                either find [1] itvl [
                    append diagram2 reduce [
                        'fill-pen white 'circle (select root5-map itvl) 5
                    ]
                ] [
                    append diagram2 reduce [
                        'fill-pen black 'circle (select root5-map itvl) 5
                    ]
                ]
            ]
            append diagram2 reduce ['text (trim/all join root type) 20x0]
            append diagram2 reduce [
                'text 
                trim/all to-string (
                    select root5-notes trim/all to-string root
                )
                130x65
            ]
            save/png 
                to-file trim/all rejoin [
                    %./chords/ (replace/all root {#} {sharp}) 
                    type "5th.png"
                ]
                to-image layout/tight [
                box white 150x180 effect [draw diagram2]
            ]
            append html rejoin [
                {<img src="./} (trim/all rejoin [
                    replace/all root {#} {sharp} type "5th.png"
                ]) {">}
                ; {<img src="./spacer.bmp">}
            ]
        ]
        append html [</body></html>]
        write %./chords/chords.html trim/auto html
        browse %./chords/chords.html 
    ] [alert "Error - please remove improper chord labels."]]
    btn "Save" [
        savefile: to-file request-file/file/save %/c/mysong.txt
        if exists? savefile [
            alert "Please choose a file name that does not already exist."
            return
        ]
        if error? try [save savefile a/text] [alert "File not saved"]
    ]
    btn "Load" [
        if error? try [
            a/text: load to-file request-file/file %/c/mysong.txt
            show a
        ] []
    ]
    btn "Create Zip" [
        if not exists? %chords/ [alert "Create A Chart First" return]
        ; rebzip by Vincent Ecuyer:
        do to-string to-binary decompress 64#{
        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
        j9hfoGv6L0cgfyluTAAA
    }
    zipfile: to-file request-file/file/save %/c/mysong.zip
    if exists? zipfile [
        alert "Please choose a file name that does not already exist." 
        return
    ]
    zip/deep zipfile %chords/
    ]
    btn "Help" [editor help]
]

quit

