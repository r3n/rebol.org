REBOL [
  Title: "REBOL::EXIF"
  Description: "REBOL to EXIF interface"
  Date: 2003/12/21
  Version: 1.3
  Id: "$Id: exif-core.r,v 1.3 2003/12/21 17:47:29 narg Exp $"
  Author: "Piotr Gapinski"
  Email: news@rowery.olsztyn.pl
  File: %exif-core.r
  Purpose: "obsluga plikow JPEG/EXIF"
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  License: "GNU Lesser General Public License (Version 2.1)"
  Example: { ;; simple demo program (print out info about Maker and Model)
    either all [
      not none file: request-file 
      good-file?/debug first file ]
    [ dat: exif-tag [#{010f} #{0110}] ;; Maker, Model
      probe dat ]
    [ print "sorry, not an JPEG/EXIF file" ]
  }
  library: [
    level: 'intermediate
    platform: 'all
    type: [module tool]
    domain: [files graphics]
    tested-under: [
      view 1.2.1 on [linux Win2K amiga]
      view 1.2.8 on [linux winxp]
    ] 
   support: none
    license: 'LGPL
  ]
]

exif-ctx: context [
  set 'EXIF-SOI  #{FFD8}
  set 'EXIF-APP0 #{FFE0}
  set 'EXIF-APP1 #{FFE1}
  set 'EXIF-APP2 #{FFE2}
  set 'EXIF-CMT  #{FFFE}
  set 'EXIF-EOI  #{FFD9}

  EXIF-HEADER: #{457869660000}
  TIFF-HEADER-OFFSET: 10

  EXIF-FORMS: [
    #{0001} [1 to-integer]  ;; unsigned byte (1 bajt/komponent)
    #{0002} [1 to-ascii]    ;; ascii napisy koncz sie bajtem zerowym (jest wliczony w wielko&#347;c napisu)
    #{0003} [2 to-integer]  ;; unsigned short (2 bajty/komponent)
    #{0004} [4 to-integer]  ;; unsigned long (4 bajty/komponent)
    #{0005} [8 to-rational] ;; unsigned rational (8 bajow/komponent)
    #{0006} [1 to-integer]  ;; signed byte (1 bajt/komponent)
    #{0007} [1 to-binary]   ;; undefined (1 bajt/komponent)
    #{0008} [2 to-integer]  ;; signed short (2 bajty/komponent)
    #{0009} [4 to-integer]  ;; signed long (4 bajty/komponent)
    #{000A} [8 to-rational] ;; signed rational (8 bajtow/komponent)
    #{000B} [4 to-binary]   ;; signed float (4 bajty/komponent)
    #{000C} [8 to-binary]   ;; double float (8 bajtow/komponent)
  ]

  byte-order: "" ;; MM (Motorola) lub II (Intel)
  dat: none  ;; bufor danych
  debug: false

  range: func [
   "Pobiera fragment danych z bufora (bez weryfikacji zakresu danych); zwraca binary!"
    offset [integer!] "przesuniecie od pocz&#261;tku bufora"
    length [integer!] "dlugo&#347;c danych bajtach (relatywna do offsetu)"
   /all "dlugo&#347;c danych liczona od pocztku bufora"
   /custom "bufor danych" buffer [series!] "opcjonalny bufor z danymi"
   /local d] [

    d: any [buffer dat] ;; albo bufor przekazany jako paramentr albo bufor 'dat'
    copy/part (skip d offset) (either all [length - offset] [length])
  ]

  get-content: func [
   "Pobiera size danych znajduj&#261;cych sie location bajtow za naglowkiem bufora; zwraca binary!"
    location [integer!] "przesuniecie od pocz&#261;tku bufora"
    size [integer!] "dlugo&#347;c danych bajtach (relatywna do offsetu)"] [

    range (TIFF-HEADER-OFFSET + location) size
  ]

  intel?: func [
   "Konwersja zapisu danych binarnych Intel-Motorola (zmiana kolejno&#347;ci bajtow)."
    bin [binary!] "dane binarne" ] [
    either (byte-order = "II") [head reverse bin] [bin]
  ]

  read-traverse: func [
   "Poszukuje tag w pliki JPEG; zwraca binary! (zawarto&#347;c chunk) lub none!"
    file-name [file! string!] "nazwa pliku"
    tag [binary!] "szukany chunk-id"
   /position "zwraca offset pozycji chunk od pocztku pliku"
   /local chunk-id chunk-size offset buffer] [

    file: to-file file-name
    if error? try [
      buffer: read/binary/direct/part file 2
      if not equal? EXIF-SOI (range/custom 0 2 buffer) [return none] ;; jezeli naglowek pliku <> EXIF-SOI to nie jest to plik JPEG
      ;; buffer: skip dat 2 ;; pomin SOI

      offset: 2
      forever [
        buffer: read/binary/direct/part file (offset + 4) ;; wczytaj id bloku danch i ich wielko&#347;c
        chunk-id: range/custom offset 2 buffer
        mask: to-integer #{FF00}
        if (((to-integer chunk-id) and mask) <> mask) [return none]

        chunk-size: to-integer range/custom (offset + 2) 2 buffer

        if debug [print ["znaleziono chunk" chunk-id "offset" offset "wielko&#347;c" (chunk-size + 2) "bajtow"]]

        if (chunk-id = tag) [
          buffer: skip (read/binary/direct/part file (offset + chunk-size + 2)) offset
          return either position [offset] [buffer]
        ]
        offset: offset + chunk-size + 2
      ]
    ] [return none]
  ]

  set 'exif-file? func [
   "Bada czy plik jest w formacie JPEG i zawiera dane EXIF-APP1; zwraca logic!"
    file-name [file! string!] "nazwa pliku"
   /debug "dodatkowe informacje o dzialaniu programu"
   /local size] [

    self/debug: any [(not none? debug) false]
    not none? all [
      not none? dat: read-traverse file-name EXIF-APP1
      equal? EXIF-APP1 range 0 2 ;; bajty 02:04 = FFE1
      not zero? size: to-integer range 2 2 ;; wielko&#347;c chunk APP1
      not empty? byte-order: to-string range 10 2
    ]
  ]
  set 'good-file? :exif-file? ;; synonim

  set 'exif-tag func [
   "Przeszukuje katalogi struktury EXIF; zwraca block!, binary! lub none!"
    tag [binary! block!] "poszukiwane znaczniki"
   /local ifd-first ifd-next search-ifds ifds rcs tags offset] [

    if none? dat [return none]
    ;; offsety s licznone wzgledem pocztku naglowka APP1 #{FFE1}
    ifd-first: does [TIFF-HEADER-OFFSET + to-integer (intel? range 14 4)] ;; IFD0
    ifd-next: func [
     "Zwraca integer! offset do nastepnego IFD lub none!"
      offset "aktualna pozycja katalogu"
     /local elements next] [

      ;; kazdy katalog zawiera nastepujce dane
      ;; 00-02 liczba elementow (tagow) w katalogu
      ;; ..... 12 bajtow na kazdy element w katalogu
      ;; ..... 4-ro bajtowy wskaznik do nastepnego IFD lub 0

      elements: to-integer (intel? range offset 2)
      next: to-integer (intel? range (offset + 2 + (elements * 12)) 4)
      either equal? 0 next [none] [TIFF-HEADER-OFFSET + next]
    ]
    search-ifds: func [
     "Szuka znacznika tag we wszystkich katalogach APP1."
      ifds [block!] "block! offsetow do katalogow APP1"
      tag [binary!] "szukany znacznik EXIF"
     /local offset rc] [

      foreach offset ifds [if not none? (rc: ifd-content offset tag) [break]]
      return rc
    ]

    ifds: copy [] tags: copy [] rcs: copy []

    ;; tworznie tablicy z pozycjami wszystkich katalogow EXIF v2.1
    append ifds offset: ifd-first ;; IFD0
    while [not none? (offset: ifd-next offset)] [append ifds offset] ;; IFD1,...

    ;; foreach tag [#{8769} #{A005} #{8825}] [ ;; SUBIFD0 Interoperability GPSIFD
    foreach tag [#{8769} #{A005}] [ ;; SUBIFD0 Interoperability
      offset: search-ifds ifds tag
      if not none? offset [append ifds (TIFF-HEADER-OFFSET + (to-integer offset))]
    ]
    ifds: sort ifds ;; znaczniki najcze&#347;ciej uzywane s przewaznie w pocztkowych katalogach

    if debug [print ["znalezione katalogi" mold ifds CRLF "rozpoczynam poszukiwania" CRLF]]

    ;; traktuj przekazany parametr (tag) jako block! danych
    ;; zapisuj warto&#347;c kazdego paramtru lub none! gdy nie znaleziony
    ;; pojedyncze warto&#347;ci s zwracane bez bloku (brana jest pierwsza warto&#347;c z listy)

    either block? tag [tags: tag][append tags tag]
    foreach tag tags [append rcs (search-ifds ifds tag)]
    either (block? tag) [rcs] [first rcs]
  ]
  set 'exif-ifd :exif-tag

  ifd-content: func [
   "Wyszukuje okre&#347;lony parametr w katalogu EXIF; zwraca jego warto&#347;c lub none!"
    offset [integer!] "lokalizacja (offset) katalogu"
    tag [binary!] "poszukiwany znacznik"
   /local items tag-format tag-length tag-value tag-components] [

    items: to-integer intel? range offset 2 ;; liczba parametrow w biezcym katalogu EXIF

    if debug [print ["szkukam" tag "w katalogu" offset "(" items "elementy/ow )"]]

    offset: offset + 2 ;; pomin 2 bajty z liczb elementow

    loop items [
      ;; na kazdy element w katalogu przypada 12 bajtow
      ;; 00-02 znacznik
      ;; 02-04 format danych (zobacz EXIF-FORM)
      ;; 04-08 liczb cze&#347;ci z ktorych skladaj sie dane (liczba cze&#347;ci nie oznacza liczby bajtow!)
      ;; 08-12 dane znacznika lub offset do danych gdy ich dlugo&#347;c przekracza 4 bajty

      if debug [print ["-> znaleziono znacznik" (intel? range offset 2)]]
      if equal? tag (intel? range offset 2) [

        ;; znaleziono wla&#347;ciwy tag - pobierz jego warto&#347;c
        tag-format: intel? range (offset + 2) 2
        tag-components: to-integer intel? range (offset + 4) 4
        tag-length: tag-components * EXIF-FORMS/:tag-format/1 ;; liczba bajtow przypadajca na dane jednego znacznika

        tag-value: intel? range offset + 8 4
        if (tag-length > 4) [tag-value: range (TIFF-HEADER-OFFSET + to-integer tag-value) tag-length]

        if debug [print ["-> format" tag-format tag-components "komponent/ow w buforze" tag-value "(" tag-length "bajt/y )" CRLF]]

        ;; zamien na rebol datatype
        return to-rebol tag-value tag-format tag-length
      ]
      offset: offset + 12 ;; do nastepnego znacznika w biezcym katalogu
    ]

    if debug [print ["-> znacznika" tag "nie znaleziono!" CRLF]]
    return none
  ]

  to-rebol: func [
   "Konwersja danych binarnych na Rebol datatype."
    bin [binary!] "dane binarne"
    format [binary!] "format danych"
    length [integer!] "bajtow danych (binarnych)"] [

    to-rational: func [bin [binary!] /local a b] [
      a: intel? copy/part bin 4
      b: intel? copy/part skip bin 4 4
      to-string rejoin [(to-integer a) "/" (to-integer b)]
    ]
    to-ascii: func  [bin [binary!]] [trim to-string bin]

    ;; zwracaj tylko tyle bajtow ile jest danych
    ;; zmienna bin ma 4 bajty lub wiecej a np. dla typu "unsigned short" potrzebujemy tylko 2 bajtow
    ;; proteza jest potrzebna dla typow "short", "byte" czy "ascii", ktore mog zawierac pojedyncze bajty

    return do EXIF-FORMS/:format/2 copy/part skip bin ((length? bin) - length) length
  ]
]
