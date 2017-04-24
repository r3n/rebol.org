Rebol [
    title: "Simple Dll Examples"
    date: 29-june-2008
    file: %dll-examples.r
    purpose: {
        A simple example demonstrating how to use functions inside DLLs.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

text:  ask "Please enter some text:  "
lib: load/library %User32.dll
message-box: make routine! [a [integer!] b [string!] c [string!] d [integer!]] lib "MessageBoxA"
message-box 0 text "You typed:" 0
free lib


lib: load/library %kernel32.dll
play-sound: make routine! [
    return: [integer!] pitch [integer!] duration [integer!]
] lib "Beep"
for hertz 0 5000 10 [
    print rejoin ["The pitch is now " hertz " hertz."]
    play-sound hertz 50
]
free lib
