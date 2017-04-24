REBOL [
    title: "REBOL/flash Build Tool"
    date: 8-Apr-2010
    file: %flash-build.r
    author:  Nick Antonaccio
    purpose: {
        A simple script to help new users experiment with editing, compiling and viewing
        .swf files created with REBOL/flash.   It uses the built-in REBOL text editor to
        repeatedly run through the edit/compile/run process, so that code changes can
        be made quickly and easily, and the compiled results viewed immediately in the
        browser.

        Taken from the tutorial at http://re-bol.com
    }
]

write %test.rswf {
REBOL [
	type: 'swf
	file: %shape.swf
	background: 230.230.230
	rate: 40
	size: 320x240
]
a-rectangle: Shape [
    Bounds 0x0 110x50
    fill-style [color 255.0.0]
    box 0x0 110x50
]
place [a-rectangle] at 105x100
showFrame
end
}

; The following folder should be set to where you keep your REBOL/flash
; project files: 

my-rswf-folder: %./
; my-rswf-folder: %/C/.../rswf/
change-dir my-rswf-folder
do decompress first to-block read http://re-bol.com/rswf250.r
; do %rswf.r
current-source: to-file request-file/filter/file "*.rswf" %test.rswf
unset 'output-html

do edit-compile-run: [
    editor current-source
    if error? err: try [make-swf/save/html current-source] [
        err: disarm :err
        alert reform [
            "The following compile error occurred: "
            err/id err/where err/arg1
        ]
        either true = request "Edit/Compile/Run Again?" [
            do edit-compile-run quit
        ] [
            quit
        ]
    ]
    unless value? 'output-html [
        output-html: to-file request-file/filter "*.html"
    ]
    browse output-html
    if true = request "Edit/Compile/Run Again?" [do edit-compile-run]
]