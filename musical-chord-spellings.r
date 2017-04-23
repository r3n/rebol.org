REBOL [
    title: "Musical Chord Spellings"
    date: 12-Dec-2013
    file: %musical-chord-spellings.r
    author:  Nick Antonaccio
    purpose: {
        Prints out the notes that comprise many common types of chords, with all 12 root note variations.
        Sharps are used to label all accidental notes (no flat notes).
    }
]
]
notes: [
    "A" "A#" "B" "C" "C#" "D" "D#" "E" "F" "F#" "G" "G#"
    "A" "A#" "B" "C" "C#" "D" "D#" "E" "F" "F#" "G" "G#" 
    "A" "A#" "B" "C" "C#" "D" "D#" "E" "F" "F#" "G" "G#"
]
chords: [
    "major triad" [4 7]
    "minor triad" [3 7]
    "major7" [4 7 11]
    "dominant7" [4 7 10]
    "minor7" [3 7 10]
    "half diminished" [3 6 10]
    "fully diminished" [3 6 9]
    "major6" [4 7 9]
    "minor6" [3 7 9]
    "(major)add9" [4 7 14]
    "dominant9" [4 7 10 14]
    "dominant7(b9)" [4 7 10 13]
    "dominant7(#9)" [4 7 10 15]
    "major9" [4 7 11 14]
    "major9(#11)" [4 7 11 14 18]
]
spellings: copy {}
foreach [type intervals] chords [
    repeat i 12 [
        spelling: rejoin [pick notes i " " type ":" newline "    "] 
        append spelling copy join pick notes i " " 
        foreach interval intervals [ 
            append spelling join pick notes (i + interval) " "
        ]
        append spellings rejoin [spelling  " | " newline]
    ]
    append spellings "^/^/"
]
editor spellings