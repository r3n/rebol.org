REBOL [
  Title: "REBOL to POLAND ICM METEO map interface"
  Date: 2004-01-03
  Version: 1.4
  Id: "$Id: meteo.r,v 1.4 2004/01/03 11:09:00 narg Exp $"
  Author: "Piotr Gapinski"
  Email: news@rowery.olsztyn.pl
  File: %meteomap-poland.r
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  Purpose: "Show meteo maps for Poland (Central Europe)"
  License: "GNU General Public License (Version II)"
  Comment: {
    Pobiera mape pogody z serwisu http://meteo.icm.edu.pl 
    pare faktow:
    - strona http://meteo.icm.edu.pl jest strasznie pokomplikowana
    - do wyznaczenia mapy system posluguje sie dwucyfrowym numerem dnia 
      (liczac od poczatku roku) oraz godzina konwersji; mapa na ICM
      generowana jest 4 razy w ciagu 24 godzin poczawszy od 12UTC;
      schemat jest nastepujacy:
      a) o 12UTC ICM pobiera dane z Anglii - warunki brzegowe mapy pogody
      b) wzgledem danych generowane sa mapy o 18 oraz 00, 06 i 12 dnia nastepnego
  }
  Library: [
    level: 'intermediate
    platform: 'all
    type: [tool]
    domain: [web graphics]
    tested-under: [
      view 1.2.1 on [winxp]
      view 1.2.8 on [linux winxp]
      view 1.2.37 on [Winxp]
    ] 
    support: none
    license: 'LGPL
  ]
]

ctx-meteomap: context [
  meteo-delay: 03:00 ;; opoznienie w pojawieniu sie nowych map na meteo.icm.edu.pl

  meteo-map-offset: func [
   "Zwraca block! zawierajacy numer dnia i strefe czasowa mapy dla podanego czasu GMT."
    dt [date!] "datetime GMT wzgledem ktorego beda obliczone parametry mapy pogody"
   /local day-of-year time-offset to-gmt] [

    day-of-year: has [date julian] [
      date: dt/date julian: date/julian ;; numer-dnia (od poczatku roku)
      either (positive? dt/time) [julian] [julian - 1]  ;; ??
      loop (3 - length? (tmp: to-string julian)) [insert (head tmp) "0"] ;; dodaj wiodace 0 (uzupelnij do 3 cyfr)
      return tmp
    ]

    time-offset: has [time limit offset] [
      ;; zwraca aktualna strefe czasowa wygenerowania mapy ("00" "06" "12" "18")
      time: dt/time
      foreach [limit offset] [6:00 "00" 12:00 "06" 18:00 "12" 23:59 "18"] [if (limit > time) [return offset]]
    ]
    ;; print reduce [day-of-year time-offset]
    reduce [day-of-year time-offset]
  ]

  look-and-feel: stylize [
    cycle: rotary edge [size: 1x1] [change-map index? r/data]

    btn: button 20 edge [size: 1x1] [
      either none? (dat: load-map/force idx) [alert "internet error!"][
        set [ia ib na nb] dat
        change-map index? r/data
      ]
    ]

    header: vtext font [size: 18 style: 'bold] 

    map: image edge [size: 1x1 color: black]

    version: vtext system/script/header/id white font [size: 10]
  ]

  change-map: func [
   "Zmienia wyswietlana mape w GUI programu."
    num [integer!] "numer mapy do wyswietlenia (1..2)"
   /local bound] [

    bound: func [val lo hi] [
      if val > hi [return hi]
      if val < lo [return lo]
      return val
    ]

    num: bound num 1 2 ;; 1 <= num <= 2
    i/image: pick reduce [ia ib] num
    h/text: form modified? path-thru (pick reduce [na nb] num)
    show [h i]
  ]

  load-map: func [
   "Pobiera mapy z serwisu meteo.icm.edu.pl. Zwraca block! [path1 image1 path2 image2]."
    id [integer!] "strefa mapy (1..4)"
   /force "wymusza pobranie nowych map z serwera"
  ;; /local ia ib na nb idx doy tof get-map to-gmt x f] [
][

    get-map: func [url [url!]] [either all [force connected?] [load-thru/binary/update url] [load path-thru url]]
    to-gmt: func [time] [time - now/zone]

    set [doy tof] meteo-map-offset to-gmt (now - meteo-delay) ;; pobierz parametry mapy pogody na teraz
    na: rejoin [http://meteo.icm.edu.pl/pict/forecast tof "/temp" id "." doy tof ".gif"]
    nb: rejoin [http://meteo.icm.edu.pl/pict/forecast tof "/cld" id "." doy tof ".gif"] 
    fl: none

    if force [fl: flash "please wait..."]
    x: all [
      not error? try [
        ia: get-map na
        ib: get-map nb
      ]
      not none? ia
      not none? ib
    ]
    if fl [unview/only fl]
    either not none? x [reduce [ia ib na nb]] [none]
  ]

  set 'show-weather func [
   "wyswietla mape pogody pobrana z serwera http://meteo.icm.edu.pl"
   /zone  "strefa mapy" id [integer!] "strefa czasowa (1..4)"
   /local dat wnd] [

    idx: any [id 1] ;; strefa od 1 do 4 (1=dzisiaj od 6 do 18 ... 4=jutro od 18 do 6)
    if not any [
      not none? (dat: load-map idx)       ;; najpierw sprawdz w file-cache
      not none? (dat: load-map/force idx) ;; potem pobierz z internetu (i uaktualnij cache)
    ][ print "internet error and/or file-cache is empty..." halt]
    set [ia ib na nb] dat

    wnd: layout [
      styles look-and-feel
      origin 1x1 space 2x2 
      key (escape) [unview quit] 
      across
      r: cycle texts ["temperature" "clouds"] btn "!" pad 10x0 
      h: header form now return 
      i: map ia at to-pair reduce [10 (i/offset/y + i/size/y - 20)] version
    ]
    change-map index? r/data
    view center-face wnd
  ]
]

show-weather ;; prognoza pogody na "teraz"
quit
