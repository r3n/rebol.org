#!/Local/Applications/core024/rebol -cs

REBOL [
  Title: "OTA bitmap to GIF converter"
  Date: 25-Sep-2004
  Version: 1.1
  File: %converter.r
  Author: "HY"
  Purpose: {
           Converts so-called operator logos for cell phones, i.e. OTA bitmaps
           into ordinary two-colour GIFs.
  }
  Comment: {
            This script is heavily inspired by java code. I used Adam Doppelts
            GifEncoder (cf. http://www.gurge.com/amd/old/java/GIFEncoder/index.html),
            which in turn is based upon Sverre H. Huseby's gifsave.c
            (cf. http://www.scintilla.utwente.nl/users/frank/gifsave.txt), as
            a template.

            I wrote this script in part to learn rebol. LZW compression is, I believe,
            subject to licencing (Unisys). See http://www.unisys.com/unisys/lzw/
            for details. I don't have any licence, and so if you want to use the script
            in an application, don't blame me if you get in any trouble. This code is
            revealed to the public only because someone (e.g. myself!) could learn
            something from it, NOT because I have a licence.
           }
  History: [
     1.0 [ 10-Sep-2001 "Created the script." "HY" ]
     1.1 [ 25-Sep-2004 "Added the script library header." "HY" ]
  ]
  Library: [
    level: 'intermediate
    domain: [compression graphics]
    license: none
    Platform: 'all
    Tested-under: none
    Type: [function]
    Support: none
  ]
]


codesize: 0
compression-block: make binary! #{}

shift-left: func [value shift-count] [to-integer (value * (2 ** shift-count))]
shift-right: func [value shift-count] [to-integer (value / (2 ** shift-count))]


bit-holder: make object! [

  get-ready: func[] [
    buffer: copy array 256
    bindex: 0
    bitsleft: 8
  ]

  flush: func [/local numberofbytes] [
    numberofbytes: either bitsleft = 8 [bindex] [bindex + 1]
    if numberofbytes > zero [
      append compression-block load rejoin ["#{" pick to-hex numberofbytes 7
                                                 pick to-hex numberofbytes 8
                                            "}"]
      buffer: head buffer
      loop numberofbytes [
        append compression-block first buffer
        buffer: next buffer
      ]
      change at head buffer 0 #{00}
      bindex: 0
      bitsleft: 8
    ]
  ]

  append-bits: func [bits number-of-bits /local bits-written numberofbytes] [
    bits-written: 0
    numberofbytes: 255
    while [
      ; this was a java do-block. I put the whole thing into the
      ; while-evaluation, and then nothing into the execution block.

      if ((bindex = 254) and (bitsleft = zero)) or (bindex > 254) [
        append compression-block load rejoin ["#{" pick to-hex numberofbytes 7
                                                   pick to-hex numberofbytes 8
                                              "}"]
        buffer: head buffer
        loop numberofbytes [
          append compression-block first buffer
          buffer: next buffer
        ]
        change at head buffer 0 #{00}
        bindex: 0
        bitsleft: 8
      ]

      either number-of-bits <= bitsleft [
        a: (to-integer pick head buffer (bindex + 1)) or shift-left (bits and ((shift-left 1 number-of-bits) - 1)) (8 - bitsleft)
        b: load rejoin ["#{" pick to-hex a 7 pick to-hex a 8 "}"]
        change at head buffer (bindex + 1) b
        bits-written: bits-written + number-of-bits
        bitsleft: bitsleft - number-of-bits
        number-of-bits: 0
      ] [
        a: (to-integer pick head buffer (bindex + 1)) or shift-left (bits and ((shift-left 1 bitsleft) - 1)) (8 - bitsleft)
        b: load rejoin ["#{" pick to-hex a 7 pick to-hex a 8 "}"]
        change at head buffer (bindex + 1) b
        bits-written: bits-written + bitsleft
        bits: shift-right bits bitsleft
        number-of-bits: number-of-bits - bitsleft
        bindex: bindex + 1
        change at head buffer (bindex + 1) #{00}
        bitsleft: 8
      ]

      number-of-bits <> zero

    ] [ comment { empty while execution block } ]
  ]
]

  LZW-stringtable: make object! [
    res-codes: 2
    hash-free: -1
    next-first: -1
    maxbits: 12
    maxstr: shift-left 1 maxbits
    hashsize: 9973
    hashstep: 2039
    num-strings: 0

    get-ready: func[] [
      str-chr: copy array maxstr
      str-nxt: copy array maxstr
      str-hsh: copy array hashsize
    ]


    clear-table: func [codesize /local w] [
      num-strings: 0
      str-hsh: copy array/initial hashsize hash-free

      w: (shift-left 1 codesize) + res-codes
      repeat current w [
        add-char-string -1 (current - 1)
      ]
    ] ; end clear-table


    add-char-string: func [aindex byte /local hashindex hash-plus-one] [

      if num-strings >= maxstr [ return -1 ]

      hashindex: hash-it aindex byte
      hash-plus-one: hashindex + 1
      while [ str-hsh/:hash-plus-one <> hash-free] [
        hashindex: remainder (hashindex + hashstep) hashsize
      ]

      change at str-hsh (hashindex + 1) num-strings
      change at str-chr (num-strings + 1) byte
      change at str-nxt (num-strings + 1) either aindex = hash-free [next-first] [aindex]

      num-strings: num-strings + 1
      return num-strings

    ] ; end add-char-string


    find-char-string: func [findex byte /local hashindex nextindex] [

      if findex = hash-free [ return byte ]

      hashindex: hash-it findex byte

      while [ nextindex: to-integer pick head str-hsh (hashindex + 1)
              hash-free <> nextindex ]
            [
        if ((to-integer (pick head str-nxt (nextindex + 1))) = findex) and
           ((to-integer (pick head str-chr (nextindex + 1))) = byte) [
             return nextindex ]
        hashindex: remainder (hashindex + hashstep) hashsize
      ]

      return -1

    ]


    hash-it: func [hindex lastbyte] [
      return remainder (((shift-left lastbyte 8) xor hindex) and to-integer #{FFFF}) hashsize
    ] ; end hash-it


] ; end LZW-stringtable



 bits-needed: func [n [integer!] ] [
  ret: 1

  if n - 1 = zero [ return zero ]

  while [(n: to-integer n / 2) <> zero] [
    ret: ret + 1
  ]

  ret
]

LZW-compress: func [tobecompressed [string!] the-size [integer!] /local index] [
  prefix: -1

  holder: make bit-holder []
  holder/get-ready
  stringtable: make LZW-stringtable []
  stringtable/get-ready

  clearcode: shift-left 1 the-size
  endofinfo: clearcode + 1
  numberofbits: the-size + 1
  limit: (shift-left 1 numberofbits) - 1

  stringtable/clear-table the-size
  holder/append-bits clearcode numberofbits

  foreach c tobecompressed [
    index: stringtable/find-char-string prefix to-integer to-string c
    either index = -1 [
      holder/append-bits prefix numberofbits
      gg: (stringtable/add-char-string prefix to-integer to-string c) - 1
      if gg > limit [
        numberofbits: numberofbits + 1
        if numberofbits > 12 [
          holder/append-bits clearcode (numberofbits - 1)
          stringtable/clear-table
          numberofbits: codesize + 1
        ]
        limit: (shift-left 1 numberofbits) - 1
      ]
      prefix: (to-integer to-string c) and (to-integer #{FF})
    ][ prefix: index ]
  ]

  if prefix <> -1 [
    holder/append-bits to-integer prefix numberofbits
  ]

  holder/append-bits endofinfo numberofbits
  holder/flush

  compression-block

]


imagedescriptor: func [separator [char!] w [integer!] h [integer!]] [

  descriptor: make block! 10
  append descriptor to-binary separator

  infobyte: 0
  infobyte: infobyte or 0  ; The rightmost bit: Local Color Table (OFF)
  infobyte: infobyte or 0  ; Interlace flag (next bit) (OFF)
  infobyte: infobyte or 0  ; Sort flag (1 bit) (not sorted)
  infobyte: infobyte or 24 ; Two reserved bits - OFF or ON -- no difference
  infobyte: infobyte or 7  ; Size of Local Colour Table (3 last bits)
                           ; (No local colour table, so this may be whatever pleases the most)

  ; simply setting left and top offsets to zero:
  append descriptor #{0000}
  append descriptor #{0000} ; two bytes for each offset value

  ; width and height parameters:
  append descriptor load rejoin ["#{" pick to-hex w 7
                                      pick to-hex w 8
                                      pick to-hex w 5
                                      pick to-hex w 6
                                 "}"]

  append descriptor load rejoin ["#{" pick to-hex h 7
                                      pick to-hex h 8
                                      pick to-hex h 5
                                      pick to-hex h 6
                                 "}"]

  append descriptor load rejoin ["#{"  pick to-hex infobyte 7
                                       pick to-hex infobyte 8
                                 "}"]

  descriptor
]

graphiccontrolextension: func [] [

  extension: make block! 7

  infobyte: 0 ; this infobyte contains lots of unimportant, unspecified information
  infobyte: infobyte or 0 ; The rightmost bit: Transparent Colour Flag.

  ; First, two bytes with fixed values:
  append extension #{21} ; Extension introducer
  append extension #{F9} ; Graphic Control Label

  append extension #{04} ; Block Size - fixed value, according to the GIF89 spec

  append extension load rejoin ["#{" pick to-hex infobyte 7
                                     pick to-hex infobyte 8
                                "}"]

  append extension #{00} ; Delay Time (we don't use animation)
  append extension #{00} ; Delay Time (we don't use animation) (two bytes, unsigned)

  append extension #{00} ; Transparency index (if  not transparent, this will be the Block Terminator instead)

  rejoin extension
]

screendescriptor: func [] [

  descriptor: make block! 7

  infobyte: 0
  infobyte: infobyte or 128 ; Global Colour Table flag (first bit)
  infobyte: infobyte or 112 ; Colour resolution (next 3 bits)
  infobyte: infobyte or zero ; Sort flag (fifth bit; set to 0, since our Global Colour Table is _not_ sorted)
  infobyte: infobyte or ((bits-needed(2) - 1) and 7) ; Global Colour Table size (last 3 bits)

  append descriptor load rejoin ["#{" pick to-hex width 7
                                      pick to-hex width 8
                                      pick to-hex width 5
                                      pick to-hex width 6
                                 "}"]

  append descriptor load rejoin ["#{" pick to-hex height 7
                                      pick to-hex height 8
                                      pick to-hex height 5
                                      pick to-hex height 6
                                 "}"]

  append descriptor load rejoin ["#{"  pick to-hex infobyte 7
                                       pick to-hex infobyte 8
                                 "}"]

  append descriptor load rejoin ["#{"  skip tail reverse to-hex zero -2 "}"] ; index of background colour in colour table

  append descriptor load rejoin ["#{"  skip tail reverse to-hex zero -2 "}"] ; i.e. no pixel aspect ratio information is given

  comment {
    Something is very wrong here, but I use this script for OTA bitmap conversion only,
    and it works for that purpose. I recommend anyone who want to use this script for
    any other purpose to completely rewrite the screendescriptor method!
  }

  rejoin descriptor

]

convert: func [ bitmap /local gif ] [

  if not (length? bitmap) = 260 [
    print "Wrong length of argument."
    ;return
  ]

  gif-header: to-binary "GIF89a"
  gif: gif-header

  if (first bitmap) <> #"0" [ print "First character is non-null!" ]
  if (second bitmap) <> #"0" [ print "Second character is non-null!" ] ; both of which are wrong, in OTAs...
  bitmap: skip bitmap 2

  ; first the width parameter as hex,
  width: to-integer to-issue append to-string first bitmap second bitmap
  bitmap: skip bitmap 2

  ; then the height,
  height: to-integer to-issue append to-string first bitmap second bitmap
  bitmap: skip bitmap 2

  ; and finally the number of colours. This number should be 1, in OTAs:
  colours: to-integer to-issue append to-string first bitmap second bitmap
  bitmap: skip bitmap 2
  if colours > 1 [ print "Bitmap claims to have more than two colours!" ]

  raster: make block! width * height
  loop (width * height) / 4 [
    append raster to-string skip (to-string enbase/base load rejoin ["#{0" first bitmap "}"] 2) 4
    bitmap: next bitmap
  ]

  if (length? bitmap) > 0 [ print "There seems to be unread bytes left in the input bitmap!" ]


  append gif #{48000E00F00000} ; should be: append gif screendescriptor

  ; I could have made a sub-routine to set the colour table,
  ; but since I know this is a two-colour gif, I'll simply add
  ; it statically, like this:
  append gif #{FFFFFF000000}

  append gif #{21F90400000000} ; should be: append gif graphiccontrolextension

  append gif #{00} ; Block Terminator for Graphic Control Extension

  append gif #{2C0000000048000E001F} ; should be: append gif imagedescriptor #"," width height

  codesize: bits-needed(2) ; LZW Minimum Code Size (for two colours)
  if codesize = 1 [ codesize: 2 ]

  append gif load rejoin ["#{" pick to-hex codesize 7
                               pick to-hex codesize 8
                          "}"]

  append gif LZW-compress to-string raster codesize

  append gif #{00}

  append gif #{3B00000000000000001F} ; should be: append gif imagedescriptor #";" 0 0

  append gif to-binary "!þImage generated with REBOL"

  append gif #{00} ; closes the comment block

  gif

]

get-bitmap: func [query /local bitmap] [
  bitmap: find query "bitmap="
  if not none? bitmap [ bitmap: skip bitmap 7 ]
  to-string bitmap
]

print "Content-Type: image/gif^/"
OTA-bitmap: get-bitmap system/options/cgi/query-string
bytes: convert OTA-bitmap
write-io system/ports/output bytes length? bytes

; example OTA bitmap follows underneath. Replace the four lines above with the one underneath to se the result.
;write %converted.gif convert "00480E0118000000F80FC007F818003803FC0FF007F818006F03BC0EF807F018007F83000E3C07F00800C382001C1403E01800C1C2001C1C03E01800C0C2000C1C01E01801C0C6000E1C01C01801C1C61F063800C01801C1821F03F800801800E3820101F0000019C0FF0387000000001FE03E01FF000001C01FC00000FB000001C0"

