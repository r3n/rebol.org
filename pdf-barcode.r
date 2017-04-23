REBOL [
    title: "PDF Bar Code Generator"
    date: 14-Mar-2010
    file: %pdf-barcode.r
    author:  Nick Antonaccio
    purpose: {
        Takes a given string and XxY coordinate (in millimeters), and outputs
        a PDF file containing a printable bar code at the given position.  The bar
        code algorithm is derived directly from Bohdan Lechnowsky's "code39.r", 
        and the PDF is generated using Gabriele Santilli's "pdf-maker.r".  This
        script was created because images output by the original code39.r
        script would become blurred when inserted and resized by pdf-maker.r.
        Here, the bars are rendered as lines, directly in pdf-maker dialect.  The
        images generated are crisp and easily scannable. 
    }
]

text-string: "item2342"
x-offset: 10    ; millimeters from the left edge of the page
y-offset: 257   ; millimeters from the bottom edge of the page

create-pdf-barcode: func [barcode-string xshift yshift] [
    barcode-width: .3  barcode-height: 12  
    code39: first to-block decompress #{
    789C5D93490EC2400C04EF794514C10504D8EC1CD9F77D07F1FF6F30C9C4E3F6
    200529E54EA91D866F92BA4FC699BB989828FF6277EB793BE7EE3EE69D322F03
    E15D9F27629BEFA9DFE4FBEA377C103CC520F021F684FC087B0227EC037C2C9E
    F209E113F1447C1AF6F503E1B3D2CF517E1EFC36BF087ECB97E221BBEF0A7B42
    7E8D3D816FB00FF0AD7A8A89F09D7A0CDFC3BEF940F841FD267F847D317F827D
    919FC3BE6C3C17E889F92BF4447E833EC8EFDE43A212FE28F2C4317F4A9EED79
    7E95F9F83CBFD56FF21FF51BDE081EFBFB36B127E453EC09BC867D80578447E7
    B3051CDF4F5DFB185ED5FF9DE7C9EF0F6518AA1B22040000
    }
    convfrom: rejoin ["*" barcode-string "*"]
    pdf-dialect-out: copy []
    x: 0
    foreach char convfrom [
        pattern: select code39 form char
        foreach bit pattern [
            x: x + 1
            if bit = #"1" [
                append pdf-dialect-out compose [
                    line width (barcode-width)
                    line
                    ((x * barcode-width) + xshift) (yshift)
                    ((x * barcode-width) + xshift) (yshift + barcode-height)
                ]
            ]
        ]
        x: x + 1
    ]
    return pdf-dialect-out
]

do http://www.colellachiara.com/soft/Misc/pdf-maker.r 
barcode-layout: copy []
current-barcode-page: copy [page size 215.9 279.4 offset 0 0]
append current-barcode-page create-pdf-barcode text-string x-offset y-offset

; The following block is not necessary.  It just adds human readable text
; to the printout:

append current-barcode-page compose/deep [
    textbox 
    (x-offset - 9.5) (y-offset - 8)
    56 8
    [
        center font Helvetica 3 
        (mold text-string)
    ]
]

append/only barcode-layout current-barcode-page
write/binary %labels.pdf layout-pdf barcode-layout
call %labels.pdf

editor barcode-layout  ; not necessary - just lets you read the pdf dialect output