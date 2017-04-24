REBOL [
    title: "Play AVI Video with MCI"
    date: 9-nov-2009
    file: %mci-play-avi-.r
    purpose: {
        Demonstrates how to play AVI video files using Windows API mciExecute.
        (Video codec in demo video is MS-CRAM (Microsoft Video 1), audio is PCM).
        For more information about mciExecute commands, Google "multimedia
        command strings" and see:
        http://msdn.microsoft.com/en-us/library/dd743572(VS.85).aspx

        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

lib: load/library %winmm.dll
mciExecute: make routine! [c [string!] return: [logic!]] lib "mciExecute"

if not exists? %test.avi [
    flash "Downloading test video..."
    write/binary %test.avi read/binary http://re-bol.com/test.avi
    unview
]
video: to-local-file %test.avi

mciExecute rejoin ["OPEN " video " TYPE AVIVIDEO ALIAS thevideo"]
mciExecute "PLAY thevideo WAIT"
mciExecute "CLOSE thevideo"

mciExecute rejoin ["OPEN " video " TYPE AVIVIDEO ALIAS thevideo"]
mciExecute "PUT thevideo WINDOW AT 200 200 0 0"  ; at 200x200
mciExecute "SET thevideo SPEED 2000"  ; play twice a fast
mciExecute "PLAY thevideo WAIT"
mciExecute "CLOSE thevideo"

free lib
quit