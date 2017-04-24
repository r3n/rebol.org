REBOL [
    title:   "Clipboard"
    name:    'clipboard
    file:    %clipboard.r
    author:  "Christian Ensel"
    version: 0.3.1
    date:    18-12-2008
    purpose: "(Microsoft/Windows only:) Read and write text, bitmaps and files from and to the clipboard."
    example: [
        clip: read-clip
        write-clip "Test"
        write-clip logo.gif
    ]
    library: [
        level:          'intermediate
        Platform:       'win
        type:           [function]
        code:           'function
        domain:         [win-api graphics]
        license:        'BSD
        support:        none
        see-also:       none
        tested-under:   [view 2.7.6.3.1 on [WinXP] "CHE"]
    ]
]

context [
    user32.dll:   load/library %user32.dll
    gdi32.dll:    load/library %gdi32.dll
    shell32.dll:  load/library %shell32.dll
    kernel32.dll: load/library %kernel32.dll

    &bi-rgb:         0
    &dib-rgb-colors: 0

    &cf-text:             1
    &cf-bitmap:           2
    &cf-hdrop:            15

;   &cf-metafilepict:     3
;   &cf-sylk:             4
;   &cf-dif:              5
;   &cf-tiff:             6
;   &cf-oemtext:          7
;   &cf-dib:              8
;   &cf-palette:          9
;   &cf-pendata:          10
;   &cf-riff:             11
;   &cf-wave:             12
;   &cf-unicodetext:      13
;   &cf-enhmetafile:      14
;   &cf-locale:           16
;   &cf-max:              17
;   &cf-ownerdisplay:     128
;   &cf-dsptext:          129
;   &cf-dspbitmap:        130
;   &cf-dspmetafilepict:  131
;   &cf-dspenhmetafile:   142

    bitmap!:              make struct! [Type [integer!] Width [integer!] Height [integer!] WidthBytes [integer!] Planes [short] BitsPixel [short] Bits [char*]] none
    bitmap-info-header!:  make struct! [Size [integer!] Width [integer!] Height [integer!] Planes [short] BitCount [short] Compression [integer!] SizeImage [integer!] XPelsPerMeter [integer!] YPelsPerMeter [integer!] ClrUsed [integer!] ClrImportant [integer!]] none

    open-clipboard:       make routine! [h.Window [integer!] return: [integer!]] user32.dll "OpenClipboard"
    in-clipboard?:        make routine! [format [integer!] return: [integer!]] user32.dll "IsClipboardFormatAvailable"
    read-clipboard:       make routine! [format [integer!] return: [integer!]] user32.dll "GetClipboardData"
    clear-clipboard:      make routine! [return: [integer!]] user32.dll "EmptyClipboard"
    write-clipboard:      make routine! [format [integer!] h.mem [integer!] return: [integer!]] user32.dll "SetClipboardData"
    close-clipboard:      make routine! [return: [integer!]] user32.dll "CloseClipboard"

    create-bitmap:        make routine! [width [integer!] height [integer!] planes [integer!] bits-per-pel [integer!] lpv-bits [image!] return: [integer!]] gdi32.dll "CreateBitmap"

    get-desktop:          make routine! [return: [integer!]] user32.dll "GetDesktopWindow"
    get-dc:               make routine! [h.Window [integer!] return: [integer!]] user32.dll "GetDC"
    release-dc:           make routine! [h.Window [integer!] DC [integer!] return: [integer!]] user32.dll "ReleaseDC"
    delete-dc:            make routine! [DC [integer!] return: [integer!]] gdi32.dll "DeleteDC"
    create-compatible-dc: make routine! [DC [integer!] return: [integer!]] gdi32.dll "CreateCompatibleDC"
    get-object:           make routine! [Object [integer!] Count [integer!] Object [struct* [(first BITMAP)]] return: [integer!]] gdi32.dll "GetObjectA"
    get-dibits:           make routine! [DC [integer!] Bitmap [integer!] StartScan [integer!] ScanLines [integer!] Bits [image!] BI [struct* [(first BITMAPINFO)]] Usage [integer!] return: [integer!]] gdi32.dll "GetDIBits"

    drag-query-file:      make routine! [h.Drop [integer!] File [integer!] buffer [integer!] size [integer!] return: [integer!]] shell32.dll "DragQueryFileA"
    drag-query-filename:  make routine! [h.Drop [integer!] File [integer!] buffer [string!]  size [integer!] return: [integer!]] shell32.dll "DragQueryFileA"

    string-length?:       make routine! [string [integer!] return: [integer!]] kernel32.dll "lstrlen"

    copy-memory:          make routine! [dest [string!] source [integer!] length [integer!] return: [integer!]] kernel32.dll "RtlMoveMemory"
    lock-global:          make routine! [address [integer!] return: [integer!]] kernel32.dll "GlobalLock"
    unlock-global:        make routine! [address [integer!] return: [integer!]] kernel32.dll "GlobalUnlock"

    require:  func ["Throws NONE if condition isn't met." [throw] argument] [unless not zero? argument [throw none]]
    success?: func [value] [not zero? value]

    set 'read-clip func [
        "[Microsoft/Windows] Retrieve text, bitmaps and files from the clipboard (NONE otherwise)."

        /local clip clipboard format h.bitmap h.desktop h.desktop-dc h.compatible-dc bitmap image bitmap-info-header
        h.drop files count size name
    ][
        clip: catch [
            require clipboard: open-clipboard 0

            any [
                if success? in-clipboard? &cf-bitmap [
                    require h.bitmap: read-clipboard &cf-bitmap

                    require h.desktop: get-desktop
                    require h.desktop-dc:     get-dc h.desktop
                    require h.compatible-dc:  create-compatible-dc h.desktop-dc

                    bitmap: make struct! bitmap! none
                    require get-object h.bitmap (length? third bitmap) bitmap

                    bitmap-info-header: make struct! bitmap-info-header! reduce [40 bitmap/width bitmap/height bitmap/planes 32 &bi-rgb 0 0 0 0 0]
                    image: make image! as-pair bitmap/width bitmap/height
                    require get-dibits h.compatible-dc h.bitmap 0 bitmap/height image bitmap-info-header &dib-rgb-colors

                    to image! layout/tight compose [image (image/alpha: 0 image) (image/size) effect [flip 0x1]]
                ]

                if success? in-clipboard? &cf-hdrop [
                    require h.drop: read-clipboard &cf-hdrop
                    require count: drag-query-file h.drop -1 0 0

                    files: make block! count
                    for file 0 count - 1 1 [
                        all [
                            success? size: drag-query-file h.drop file 0 0
                            name: head insert/dup copy "" "^@" size: size + 1
                            success? drag-query-filename h.drop file name size
                            append files to-rebol-file to file! copy/part name size - 1
                        ]
                    ]

                    any [if empty? files [none] if empty? next files [first files] files]
                ]

                if success? in-clipboard? &cf-text [
                    ;require address: read-clipboard &cf-text
                    ;require length: string-length? address
                    ;
                    ;string: head insert/dup copy "" "^@" length
                    ;require lock-global address
                    ;
                    ;string: if success? copy-memory string address length [string]
                    ;require unlock-global address
                    ;
                    ;string

                    read clipboard://
                ]

            ]
        ]

        if h.desktop-dc    [release-dc h.desktop h.desktop-dc]
        if h.compatible-dc [delete-dc h.compatible-dc]
        if clipboard       [close-clipboard]

        clip
    ]

    set 'write-clip func [
        "[Microsoft/Windows] Write text or bitmaps to the clipboard."
        clip [any-string! image!] "Clip to write"

        /local clipboard format h.bitmap h.desktop h.desktop-dc h.compatible-dc bitmap image bitmap-info-header
        h.drop files count size name
    ][
        clip: catch [
            require clipboard: open-clipboard 0

            any [
                if image? clip [
                    require clear-clipboard
                    require h.bitmap: create-bitmap clip/size/x clip/size/y 1 32 clip
                    require write-clipboard &cf-bitmap h.bitmap

                    clip
                ]

                if any-string? clip [
                    write clipboard:// clip

                    clip
                ]

            ]
        ]

        if h.desktop-dc    [release-dc h.desktop h.desktop-dc]
        if h.compatible-dc [delete-dc h.compatible-dc]
        if clipboard       [close-clipboard]

        clip
    ]
]
