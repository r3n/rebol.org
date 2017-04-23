REBOL [
    title:   "Capture Screen"
    name:    'capture-screen
    file:    %capture-screen.r
    author:  ["Gregg Irwin" "Christian Ensel"]
    version: 0.3.0
    date:    5-Apr-2007
    purpose: "(Microsoft/Windows only:) Returns screenshot as an image (or NONE in case of failure)."
    example: [
        if snapshot: capture-screen [
            view center-face layout/tight compose [img: image snapshot (snapshot/size) [quit] effect [colorize coal]]
        ]
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
        tested-under:   [view 1.3.2.3.1 on [WinXP] "CHE"]
    ]
]                   

context [
    user32.dll:   load/library %user32.dll
    gdi32.dll:    load/library %gdi32.dll
   
    &SM_CXSCREEN:             0       
    &SM_CYSCREEN:             1       
    &SRCCOPY:          13369376 #{CC0020}
    &CAPTUREBLT:     1073741824 #{40000000}
    &CLR_INVALID:         65535 #{FFFF}
    &BI_RGB:                  0
    &DIB_RGB_COLORS:          0
    
    BITMAP:             make struct! [Type [integer!] Width [integer!] Height [integer!] WidthBytes [integer!] Planes [short] BitsPixel [short] Bits [char*]] none
    BITMAPINFOHEADER:   make struct! [Size [integer!] Width [integer!] Height [integer!] Planes [short] BitCount [short] Compression [integer!] SizeImage [integer!] XPelsPerMeter [integer!] YPelsPerMeter [integer!] ClrUsed [integer!] ClrImportant [integer!]] none
;   RGBQUAD:            make struct! [Blue [char!] Green [char!] Red [char!] Reserved [char!]] none
;   BITMAPINFO:         make struct! compose/deep/only [Header [struct! (first BITMAPINFOHEADER)] Colors [struct! (first RGBQUAD)]] none                
                                                         
    GetSystemMetrics:       make routine! [Index [integer!] return: [integer!]] user32.dll "GetSystemMetrics"
    GetDesktopWindow:       make routine! [return: [integer!]] user32.dll "GetDesktopWindow"     
    GetDC:                  make routine! [Wnd [integer!] return: [integer!]] user32.dll "GetDC"
    CreateCompatibleDC:     make routine! [DC [integer!] return: [integer!]] gdi32.dll "CreateCompatibleDC"
    CreateCompatibleBitmap: make routine! [DC [integer!] Width [integer!] Height [integer!] return: [integer!]] gdi32.dll "CreateCompatibleBitmap"
    SelectObject:           make routine! [DC [integer!] Object [integer!] return: [integer!]] gdi32.dll "SelectObject"
    BitBlt:                 make routine! [DCDest [integer!] XDest [integer!] YDest [integer!] Width [integer!] Height [integer!] DCSrc [integer!] XSrc [integer!] YSrc [integer!] ROp [integer!] return: [integer!]] gdi32.dll "BitBlt"
    GetPixel:               make routine! [DC [integer!] x [integer!] y [integer!] return: [integer!]] gdi32.dll "GetPixel"
    ReleaseDC:              make routine! [Wnd [integer!] DC [integer!] return: [integer!]] user32.dll "ReleaseDC"
    DeleteDC:               make routine! [DC [integer!] return: [integer!]] gdi32.dll "DeleteDC"
    DeleteObject:           make routine! [Object [integer!] return: [integer!]] gdi32.dll "DeleteObject"
    GetObject:              make routine! [Object [integer!] Count [integer!] Object [struct* [(first BITMAP)]] return: [integer!]] gdi32.dll "GetObjectA"
    GetDIBits:              make routine! [DC [integer!] Bitmap [integer!] StartScan [integer!] ScanLines [integer!] Bits [image!] BI [struct* [(first BITMAPINFO)]] Usage [integer!] return: [integer!]] gdi32.dll "GetDIBits" 
  
    require: func ["Throws NONE if condition isn't met." [throw] argument] [unless not zero? argument [throw none]]
    
    set 'capture-screen func [
        "(Microsoft/Windows 32bit-screens only:) Returns screenshot as an image (or NONE in case of failure)." 
        /local 
            n.ScreenWidth n.ScreenHeight h.DesktopWnd h.DesktopDC h.CaptureDC s
            h.CaptureBitmap h.Bitmap h.BitmapInfo h.BitmapInfoHeader img.Snapshot
    ][  
        img.Snapshot: catch [
            require n.ScreenWidth:   GetSystemMetrics &SM_CXSCREEN                
            require n.ScreenHeight:  GetSystemMetrics &SM_CYSCREEN
            require h.DesktopWnd:    GetDesktopWindow
            require h.DesktopDC:     GetDC h.DesktopWnd
            require h.CaptureDC:     CreateCompatibleDC h.DesktopDC
            require h.CaptureBitmap: CreateCompatibleBitmap h.DesktopDC n.ScreenWidth n.ScreenHeight
            
            require SelectObject h.CaptureDC h.CaptureBitmap
            require BitBlt h.CaptureDC 0 0 n.ScreenWidth n.ScreenHeight h.DesktopDC 0 0 &SRCCOPY or &CAPTUREBLT 
            
            h.Bitmap:           make struct! BITMAP none            
            require GetObject h.CaptureBitmap (length? third h.Bitmap) h.Bitmap 
            
            img.Snapshot:       make image!  as-pair h.Bitmap/Width h.Bitmap/Height
            h.BitmapInfoHeader: make struct! BITMAPINFOHEADER reduce [40 h.Bitmap/Width h.Bitmap/Height h.Bitmap/Planes 32 &BI_RGB 0 0 0 0 0]
                               
            ;-- The docs say GEtDIBits expects a BITMAPINFO, not a -HEADER, but I wasn't able to get this working. Additionally, the scanlines
            ;   copied are reversed vertically, which is why that at EFFECT [FLIP 0x1] is necessary.
            ;
;           h.BitmapInfo:       make struct! BITMAPINFO       compose [(second h.BitmapInfoHeader) (second RGBQuad)]

            require GetDIBits h.CaptureDC h.CaptureBitmap 0 h.Bitmap/Height img.Snapshot h.BitmapInfoHeader &DIB_RGB_COLORS
            
            img.Snapshot/alpha: 0
            to image! layout/tight compose [image img.Snapshot (img.Snapshot/size) effect [flip 0x1]]
        ]
        
        if h.DesktopDC     [ReleaseDC h.DesktopWnd h.DesktopDC]                             
        if h.CaptureDC     [DeleteDC h.CaptureDC]                                                   
        if h.CaptureBitmap [DeleteObject h.CaptureBitmap]   
    
        img.Snapshot
    ]
]
