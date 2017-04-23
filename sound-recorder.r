    REBOL [
        title: "Sound Recorder"
        date: 4-nov-2009
        file: %sound-recorder.r
        author:  Nick Antonaccio
        purpose: {
            Demonstrates how to record sounds using MCI.  Plays back the recorded
            sound using a native REBOL sound port.
            From the tutorial at http://musiclessonz.com/rebol.html
        }
    ]

    lib: load/library %winmm.dll

    mciExecute: make routine! [ 
        command [string!]
        return: [logic!] 
    ] lib "mciExecute"

    filename: to-local-file to-file request-file/save/title/file "Save as:" "" %rebol-recording.wav

    mciExecute "open new type waveaudio alias buffer1 buffer 6"
    mciExecute "record buffer1"

    ask "RECORDING STARTED (press [ENTER] when done)...^/"

    mciExecute "stop buffer1"
    mciExecute join "save buffer1 " filename

    free lib

    print "Recording complete.  Here's how it sounds:^/"

    insert port: open sound:// load to-rebol-file filename wait port close port
    print "DONE.^/"

    halt