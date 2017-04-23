REBOL [
  Title: "REBOL::STEGANOGRAPHY"
  Description: "steganography functions for rebol"
  Date: 2004-03-07
  Version: 1.2
  Author: "Piotr Gapinski"
  Email: news@rowery.olsztyn.pl
  Id: "$Id: steganography.r,v 1.2 2004/03/07 15:27:09 narg Exp $"
  File: %steganography.r
  Purpose: "how text data can be hidden in the noise pixels of an image"
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  License: "GNU Lesser General Public License (Version 2.1)"
  Comment: "Based on Corinna John article found at http://www.binary-universe.net"
  Example: {
    ;; encode
    img-load
    img: img-encode "hidden text" "secret-key"
    save/png %hidden_message.png img

    ;; decode
    img: load %hidden_message.png
    print img-decode img "secret-key"
  }
  library: [
    level: 'intermediate
    platform: 'all
    type: [module tool]
    domain: [files graphics]
    tested-under: [
      view 1.2.25 on [Winxp]
    ] 
    support: none
    license: 'LGPL
  ]
  history: [
    1.2 2004-03-07 "bit level encoding; require image larger than msg-len*8 pixels"
    1.1 2004-01-11 "byte level encoding"
  ]
]

ctx-steganography: context [
  img: none
  grayscale: false

  bit-test: func [byte [integer!] bit][either (byte and (to-integer power 2 bit)) <> 0 [1][0]]
  bit-set: func [byte [integer!] bit][(byte or (to-integer power 2 bit))]
  bit-clear: func [byte [integer!] bit][(byte and complement (to-integer power 2 bit))]

  set 'img-load does [
    either not none? files: request-file
    [
      img: load first files
      if not image? img [print "niewlasciwy typ danych" halt]
    ]
    [
      print "nie wskazano pliku zdjecia" halt
    ]
  ]

  set 'img-encode func [
   "koduje message kluczem key i umieszcza w pliku graficznym zaladowanym metoda img-load"
    message [string!] "wiadomosc do zakodowania"
    key [string!]  "klucz prywatny kodowanych danych"
   /local msg-len r g b key-len key-index color-index byte k color i] [

    msg-len: length? message
    img/1: to-tuple reduce [ ;; zakoduj dlugosc wiadomosci w pierwszym pixelu
      r: (to-integer power msg-len (1 / 3)) 
      g: (to-integer power (msg-len: msg-len - power r 3) (1 / 2))
      b: (to-integer msg-len - power g 2)
    ]
    img: next img

    key-len: length? key
    key-index: color-index: j: 1 ;; sk&#322;adowa rgb w ktorej bedzie umieszczony zakodowany bit

    foreach byte message [
      repeat i 8 [
        bit: bit-test (to-integer byte) (i - 1) ;; bit wiadomosci
        bit-index: (to-integer key/:key-index // 8) + 1 ;; na podstawie klucza okresl bit koloru

        color: pick img/1 color-index ;; zmodyfikuj bajt koloru o bit danych
        color: either zero? bit [bit-clear color bit-index][bit-set color bit-index]
        img/1: either grayscale [to-tuple reduce [color color color]] [poke img/1 color-index color]
        img: next img

        key-index: (j // key-len) + 1
        color-index: (j // 3) + 1
        j: j + 1
      ]
    ]
    return head img
  ]

  set 'img-decode func [
   "rozkodowuje informacje zawarte w img na podstawie klucza prywatnego key"
    img [image!] "obrazek zawierajacy zakodowane dane"
    key [string!] "klucz prywatny zakodowanych danych"
   /local buffer pix msg-len key-len key-index color-index k i] [

    buffer: copy ""
    pix: first img
    msg-len: to-integer ((power pix/1 3) + (power pix/2 2) + pix/3)
    img: next img ; od drugiego pixela

    key-len: length? key
    key-index: color-index: j: 1 ;; sk&#322;adowa rgb w ktorej bedzie umieszczony zakodowany bit

    loop msg-len [
      byte: 0
      repeat i 8 [
        color: pick img/1 color-index ;; bajt skladowej koloru
        bit-index: (to-integer key/:key-index // 8) + 1 ;; na podstawie klucza okresl bit koloru
        bit: bit-test color bit-index ;; odtworz bit danych
        if not zero? bit [byte: bit-set byte (i - 1)]

        img: next img
        key-index: (j // key-len) + 1
        color-index: (j // 3) + 1
        j: j + 1
      ]
      append buffer to-char byte ;; zachowaj odtworzony bajt danych
    ]
    return buffer
  ]
]
