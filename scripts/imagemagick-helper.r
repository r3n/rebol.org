REBOL [
   Title: "ImageMagick Support"
   Author: "Edgar Tolentino"
   Company: "Prolific Publishing, Inc."
   Date: 19-Aug-2006
   File: %imagemagick-helper.r
   Purpose: {Support minimal needs for image processing using ImageMagick MagickWand and MagickCore DLLs 
            Note: DLL's calls tend to change so this is specifically for version 6.2.9
            Note: Original uses only MagickCore DLL. This version required MagickWand DLL because they 
                moved the calls to a different DLL}
   Library: [
        level: 'advanced 
        platform: 'windows 'linux
        type: [demo module]
        domain: [animation external-library graphics]
        tested-under: [view/pro 1.3.2.3.1 XPHome ImageMagick-6.2.9-Q16]
        license: 'MIT
        support: none
        see-also: none
      ]
   ]


homedir: %./

imagemagicklib: %CORE_RL_magick_.dll          ; uncomment for windows version
imagemagickwandlib: %CORE_RL_wand_.dll          ; uncomment for windows version

; imagemagicklib: %/usr/lib/libMagick.so      ; uncomment for linux version, try to find where it is installed
; imagemagickwandlib: %/usr/lib/libWand.so      ; uncomment for linux version, try to find where it is installed


integer-to-stringptr: func [
    anyptr 
    ][
    change second first :anyptr [string!]
    ]
    
ptr-to-integer: func [
    anyptr 
    ][
    change second first :anyptr [integer!]
    ]

dynstruct: func [
    {creates a struct datatype based on input data}
    value [block!]
    /defval
    /local specs len cnt var t1 t2 t3 
    ][
    var: make string! 0
    t1: make block! 0
    t2: make string! 0
    t3: make block! 0
    specs: make block! 0
    len: length? value
    cnt: 0
    repeat data value [
        cnt: cnt + 1
        var: rejoin ["p" cnt " "]
        t1: reduce [type? data]
        t2: rejoin [var mold :t1]
        t3: load t2
        insert tail specs t3
        ]
    either defval [
        make struct! specs none
        ][
        make struct! specs copy/deep value
        ]
    ]
    
ExceptionInfo-def: [
    severity        [integer!]
    error_number    [integer!]
    reason          [integer!]
    description     [integer!]
    signature       [integer!]
    ]
     
pExceptionInfo: make struct! ExceptionInfo-def none


imMagick: load/library imagemagicklib
imMagickW: load/library imagemagickwandlib

;; Magick Core calls
func-im: func [
    {Creates a lib routine for ImageMagick libarary}
    specs [block!]          {lib function parameters}
    identifier [string!]    {lib function name}
    ][
    set to-word rejoin ["im" identifier] make routine! specs imMagick identifier
    ]
;; Magick Wand calls    
func-imw: func [
    {Creates a lib routine for ImageMagick libarary}
    specs [block!]          {lib function parameters}
    identifier [string!]    {lib function name}
    ][
    set to-word rejoin ["im" identifier] make routine! specs imMagickW identifier
    ]

func-im [
    {Initializes ImageMagick}
    lpargs [struct! []]     {module path}
    ] "InitializeMagick"
func-im [
    {Releases ImageMagick}
    ] "DestroyMagick"
func-im [
    {Gets an exception structure handle}
    pexception [struct! []] {ptr to ptr to an exception structure}
    ] "GetExceptionInfo"
func-im [
    {Creates an ImageInfo if passed NULL}
    pimageinfo [integer!]   {ptr to an ImageInfo structure}
    return: [integer!]      {ptr to an ImageInfo structure}
    ] "CloneImageInfo"
func-imw [
    {Identifies information about passed image}
    pimageinfo [integer!]   {ptr to an ImageInfo structure}
    argc [integer!]         {number of arguments}
    pargv [struct! []]      {array of strings}
    ptext [struct! []]      {ptr to ptr}
    pexception [struct! []] {ptr to ptr to an exception structure}
    return: [integer!]      {status}
    ] "IdentifyImageCommand"
func-imw [
    {Process convertion commands}
    pimageinfo [integer!]   {ptr to an ImageInfo structure}
    argc [integer!]         {number of arguments}
    pargv [struct! []]      {array of strings}
    pnull [integer!]        {NULL val}
    pexception [struct! []] {ptr to ptr to an exception structure}
    return: [integer!]      {status}
    ] "ConvertImageCommand"
func-imw [
    {Process composition commands}
    pimageinfo [integer!]   {ptr to an ImageInfo structure}
    argc [integer!]         {number of arguments}
    pargv [struct! []]      {array of strings}
    pnull [integer!]        {NULL val}
    pexception [struct! []] {ptr to ptr to an exception structure}
    return: [integer!]      {status}
    ] "CompositeImageCommand"
func-imw [
    {Process composition commands}
    pimageinfo [integer!]   {ptr to an ImageInfo structure}
    argc [integer!]         {number of arguments}
    pargv [struct! []]      {array of strings}
    pnull [integer!]        {NULL val}
    pexception [struct! []] {ptr to ptr to an exception structure}
    return: [integer!]      {status}
    ] "MontageImageCommand"
func-im [
    {Releases the ptr to str created}
    ptext [integer!]      {ptr to string}
    return: [integer!]      
    ] "RelinquishMagickMemory"
func-im [
    {Allocates the memory requested}
    isize [integer!]      {size of memory}
    return: [integer!]      
    ] "AcquireMagickMemory"
func-im [
    {Releases the ImageInfo created}
    pimageinfo [integer!]   {ptr to an ImageInfo structure}
    return: [integer!]      
    ] "DestroyImageInfo"
func-im [
    {Releases the exception structure handle}
    pexception [struct! []] {ptr to ptr to an exception structure}
    ] "DestroyExceptionInfo"

; Add more dll calls here

imInitialize: func [
    {init imagemagick}
    ][
    modpath: dynstruct/defval [""]
    imInitializeMagick modpath
    ]    
    
imIdentify: func [
    {executes the commands strings}
    cmdstr [string!]    {command strings for Convert}
    /local str argc argv argtext result emptystr retval mem
    ][
    str: make block! 0
    str: parse cmdstr none
    argc: length? str

    argv: dynstruct str
    
    mem: imAcquireMagickMemory 4
    argtext: dynstruct/defval [mem]
    imGetExceptionInfo pExceptionInfo
    imInfo: imCloneImageInfo 0
    
    retval: imIdentifyImageCommand imInfo argc argv argtext pExceptionInfo
    if all [retval argtext/p1 <> 0][
	    integer-to-stringptr argtext
	    result: load to-string argtext/p1  
	    ptr-to-integer argtext
	    argtext/p1: imRelinquishMagickMemory argtext/p1
		]    
    imInfo: imDestroyImageInfo imInfo
    imDestroyExceptionInfo pExceptionInfo
    result
    ]
imIdentifyWHF: func [
    {Identifies image width, height and format}
    filename [string!]    {image filename to identify}
    /local str argc argv argtext result cmdstr imInfo retval
    ][
	if not find filename "://" [
		if not exists? to-rebol-file filename [
			local: rejoin [homedir filename]
			either exists? local [filename: form local][ return copy "Identify : Identify failed!" ]
			]
		]
    cmdstr: rejoin [{identify -format "%w %h %m" } filename]
    str: make block! 0
    str: parse cmdstr none
    argc: length? str

    argv: dynstruct str
    
    argtext: dynstruct/defval [0]
    imGetExceptionInfo pExceptionInfo
    imInfo: imCloneImageInfo 0
    
    
    result: copy "Identify : Identify failed!"
    retval: imIdentifyImageCommand imInfo argc argv argtext pExceptionInfo
    if all [retval argtext/p1 <> 0][
	    integer-to-stringptr argtext
	    result: load to-string argtext/p1  
	    ptr-to-integer argtext
	    argtext/p1: imRelinquishMagickMemory argtext/p1
		]
    imInfo: imDestroyImageInfo imInfo
    imDestroyExceptionInfo pExceptionInfo
    result
    ]
    
imAction: func [
    {executes the commands strings}
    cmdstr [string!]    {command strings for Convert}
    /local str argc argv imInfo retval
    ][
    str: make block! 0
    str: parse cmdstr none
    argc: length? str

    outfn: pick str argc 
    argv: dynstruct str
    
    
    imGetExceptionInfo pExceptionInfo
    imInfo: imCloneImageInfo 0
    
    
    switch argv/p1 [
        "convert" [
            retval: imConvertImageCommand imInfo argc argv 0 pExceptionInfo
            ]
        "montage" [
            retval: imMontageImageCommand imInfo argc argv 0 pExceptionInfo
            ]
        "composite" [
            retval: imCompositeImageCommand imInfo argc argv 0 pExceptionInfo
            ]
        ]

    imInfo: imDestroyImageInfo imInfo
    imDestroyExceptionInfo pExceptionInfo
    
    ;for cnt 1 5000 1 [either NOT exists? to-file outfn [wait .02][break]]
    ;if NOT exists? to-file outfn [retval: 0]
    
    retval
    ]
    
imRelease: func [
    {release imagemagick}
    ][
    imDestroyMagick
    ]
    

; test functions use start here
comment [        
imInitialize    


retval: imAction {convert logo: "logo.gif"}
retstr: imIdentifyWHF {logo.gif}

availfont: {Arial} ;{Helvetica}  ;some installations has different font support.
retval: imAction rejoin [{convert -background lightgray -font } availfont { -pointsize 9 "label: Edgardo Tolentino " "font.jpg"}]
retstr: imIdentifyWHF {font.jpg}
   
imRelease 

halt
;quit
]   
halt

