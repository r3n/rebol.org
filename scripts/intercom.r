REBOL [
    Title: "Intercom (Voice Communicator)"
    date: 7-nov-2009
    file: %intercom.r
    author:  Nick Antonaccio
    purpose: {
        A walkie-talkie push-to-talk type of VOIP application.  Extremely simple -
        just records sound from mic to .wav file, then transfers the wave file to
        another IP (where the same program is running), for playback.  Sender
        and receiver open in separate processes, and both run in forever loops
        to enable continuous communication back and forth.  (Can be run hands
        free by removing the the two "Ask" lines and uncommenting the "wait 2"
        comment, in the second forever loop).
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

write %wt-receiver.r {
    REBOL []
    ; print join "Listening at " read join dns:// read dns://  ; (show IP)
    if error? try [port: first wait open/binary/no-wait tcp://:8] [quit]
    wait 0  speakers: open sound://
    forever [
        if error? try [mark: find wav: copy wait port #""] [quit]
        i: to-integer to-string copy/part wav mark
        while [i > length? remove/part wav next mark] [append wav port]
        insert speakers load to-binary decompress wav
    ]
}
launch %wt-receiver.r
lib: load/library %winmm.dll
mciExecute: make routine! [c [string!] return: [logic!]] lib "mciExecute"
if (ip: ask "Connect to IP (none = localhost):  ") = "" [ip: "localhost"]
if error? try [port: open/binary/no-wait rejoin [tcp:// ip ":8"]] [quit]
mciExecute "open new type waveaudio alias buffer1"
forever [
    if (ask "^lPress [ENTER] to send sound ('q' to quit):  ") = "q" [quit]
    mciExecute "record buffer1"  ; wait 2  ; for handsfree, remove ASKs
    ask "^l*** YOU ARE NOW RECORDING SOUND ***   Press [ENTER] to send:  "
    mciExecute "save buffer1 r"
    mciExecute "delete buffer1 from 0"
    insert wav: compress to-string read/binary %r join l: length? wav #""
    insert port wav  ; if l > 6000 [insert port wav]  ; handsfree squelch
]




{

Just for fun, here's an ultra compact obfuscated version.  It features port
error handling, automatic localhost testing (just press [ENTER] to use
localhost as the IP address), hands-free operation, audio data compression
before send and decompress on receive, and automatic minimum volume
testing (squelch - data not sent unless a given volume is detected, to save
bandwidth).  It can be pasted directly into the REBOL console, or saved to
a file and run.  The file size is 667 bytes!

REBOL[]do[write %w{REBOL[]if error? try[p: first wait open/binary/no-wait
tcp://:8][quit]wait 0 s: open sound:// forever[if error? try[m: find v:
copy wait p #""][quit]i: to-integer to-string copy/part v m while[i >
length? remove/part v next m][append v p]insert s load to-binary
decompress v]}launch %w b: load/library %winmm.dll x: make routine![c[
string!]return:[logic!]]b"mciExecute"if(i: ask"IP:")=""[i:"localhost"]if
error? try[p: open/binary/no-wait rejoin[tcp:// i":8"]][quit]x
"open new type waveaudio alias b"forever[x"record b"wait 2 x"save b r"x
"delete b from 0"insert v: compress to-string read/binary %r join l:
length? v #""if l > 4000[insert p v]]]

}