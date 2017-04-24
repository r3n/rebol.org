REBOL [
    Library: [
        level: 'intermediate
        platform: 'all
        type: [tool]
        domain: [graphics]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]

    Title:   "EAN-13 Barcode Image Generator"
    Date:    15-Mar-2005
    Name:    'EAN13  ; For window title bar

    Version: 0.1.0
    File:    %ean13.r
    Home:    http://www.hmkdesign.dk/rebol/ean13.r

    Author:  "Henrik Mikael Kristensen"
    Owner:   "HMK Design"
    Rights:  "Copyright (C) HMK Design 2005"

    Purpose: {
        Generates EAN-13 barcode images as image! which can be used for
        print out and later read with a barcode reader.
        It's means to the the basic first version of a fuil barcode generator script
        for support of mulitple barcode types.

        Usage: gencode "1234567890123"
        Any 13-digit can be used, but must be valid 13-digit barcode
        to be read by a barcode reader.
        See '? gencode' for help on options

        Example: gencode "7501031311309"
    }

    Note: {
        Highly unoptimized prototype version. Doesn't print the EAN number
        in the correct place yet, but places the number above the barcode.
        Still only tested with one barcode reader, but it works. :-)
        Doesn't yet check for a valid barcode.
        
        Feel free to edit/optimize, but please send revisions to me. Thanks!
    }

    History: [
        0.1.0 [6-Mar-2005 "Prototype version." "Henrik"]
    ]

    Language: 'English
]

; generate EAN-13 barcodes
; highly unoptimized prototype version

codes-left-odd: copy [
  "0001101" "0011001" "0010011" "0111101"
  "0100011" "0110001" "0101111" "0111011"
  "0110111" "0001011"
]

codes-left-even: copy [
  "0100111" "0110011" "0011011" "0100001"
  "0011101" "0111001" "0000101" "0010001"
  "0001001" "0010111"
]

; right codes are left odd codes reversed, so the right output is simply inverted

parity: copy [
  "111111" "110100" "110010" "110001"
  "101100" "100110" "100011" "101010"
  "101001" "100101"
]

ean13checksum: func [input][
  ; will be implemented later
]

to-int: func[input][to-integer to-string input]

guard: copy [
  box guardbarsize black
  box guardbarsize
  box guardbarsize black
]

gencode: func [
  "Outputs a bitmapped EAN-13 barcode in a view window"
  input [string!] "Must be 13 digit EAN-13 barcode"
  /big "Prints 2 times larger barcode."
  /bigger {Prints 4 times larger barcode.
           Combine with /big for 8 times larger barcode.}
][
  barsize: 1x50
  guardbarsize: 1x60
  spacesize: 1x0
  if big [
    barsize: barsize * 2
    guardbarsize: guardbarsize * 2
    spacesize: spacesize * 2
  ]
  if bigger [
    barsize: barsize * 4
    guardbarsize: guardbarsize * 4
    spacesize: spacesize * 4
  ]
  either 13 == length? input [
  t: copy [backdrop white space 0 origin 0 across]

  ; left guard
  append t guard

  ; left half
  parityidx: first skip parity to-int first input
  for i 2 7 1 [ ; digit
    digit: to-int input/:i
    ; read parityidx for this digit
    code: either odd? first at parityidx (i - 1) [
      first skip codes-left-odd digit
    ][
      first skip codes-left-even digit
    ] (i - 1)
    for j 1 7 1 [
      append t either zero? to-int code/:j [[box barsize]][[box barsize black]]
    ]
  ]

  ; center guard
  append t [box guardbarsize]
  append t guard
  append t [box guardbarsize]

  ; right half
  for i 8 13 1 [ ; digit
    idx: 1 + to-int input/:i
    foreach code codes-left-odd/:idx [
      append t either zero? to-int code [[box barsize black]][[box barsize]]
    ]
  ]

  ; right guard
  append t guard

  ; generate image
  r: to-image layout t
  view layout [backdrop white text input image r button "Close" [unview]]
  ][
    print "Invalid code! not 13 digits..."
  ]
]