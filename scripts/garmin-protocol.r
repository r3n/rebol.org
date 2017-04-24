REBOL [
  Title: "Garmin GPS protocol handler"
  Purpose: "Garmin eTrex Legend protocol handler"
  Date: 2004-12-12
  Version: 0.4.2
  Author: "Piotr Gapinski"
  Email: news@rowery.olsztyn.pl
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  File: %garmin-protocol.r
  Url: "http://www.rowery.olsztyn.pl/wspolpraca/rebol/gps/"
  License: "GNU Lesser General Public License (Version 2.1)"
  Library: [
    level: 'advanced
    platform: 'all
    type: [protocol tool]
    domain: [protocol]
    tested-under: [
      view 1.2.8 on [Linux WinXP]
    ]
    support: none
    license: 'LGPL
  ]
]

; system/ports/serial: [ttyS0 ttyS1]

garmin: context [
  ; link L1 protocol
  Pid_Etx_Byte: 03
  Pid_Ack_Byte: 06
  Pid_Command_Data: 10
  Pid_Xfer_Cmplt: 12
  Pid_Date_Time_Data: 14
  Pid_Dle_Byte: 16
  Pid_Position_Data: 17
  Pid_Prx_Wpt_Data: 19
  Pid_Nack_Byte: 21
  Pid_Records: 27
  Pid_Rte_Hdr: 29
  Pid_Rte_Wpt_Data: 30
  Pid_Almanac_Data: 31
  Pid_Trk_Data: 34
  Pid_Wpt_Data: 35
  Pid_Pvt_Data: 51
  Pid_Rte_Link_Data: 98
  Pid_Trk_Hdr: 99
  Pid_Protocol_Array: 253
  Pid_Product_Rqst: 254
  Pid_Product_Data: 255

  ; application A10 protocol
  Cmnd_Abort_Transfer: 0   ; abort current transfer
  Cmnd_Transfer_Alm: 1     ; transfer almanac
  Cmnd_Transfer_Posn: 2    ; transfer position
  Cmnd_Transfer_Prx: 3     ; transfer proximity waypoints
  Cmnd_Transfer_Rte: 4     ; transfer routes
  Cmnd_Transfer_Time: 5    ; transfer time
  Cmnd_Transfer_Trk: 6     ; transfer track log
  Cmnd_Transfer_Wpt: 7     ; transfer waypoints
  Cmnd_Turn_Off_Pwr: 8     ; turn off power
  Cmnd_Transfer_Display: 32; transfer gps display
  Cmnd_Start_Pvt_Data: 49  ; start transmitting PVT data
  Cmnd_Stop_Pvt_Data: 50   ; stop transmitting PVT data


  packet-size: func [bin [binary!]] [bin/3]
  packet-cmd: func [bin [binary!]] [bin/2]
  packet-data: func [bin [binary!]] [copy/part (skip bin 3) (packet-size bin)]
  get-long: func [bin [binary!]] [to-integer head reverse copy/part bin 4]

  encode-packet: func [
   "Zamienia block! danych na pakiet garmin gps"
    cmd [block!] "blok danych (PID CMD DATA)"
   /local simplify buffer csum][

    ; splaszcza zagniezdzone bloki
    simplify: func [dat [block!] /local buffer][buffer: copy [] foreach x dat [repend buffer x]]

    buffer: simplify reduce [cmd/1 ((length? cmd) - 1) (next cmd)]
    csum: 0   ; oblicz sume kontrolna (zanegowana dwojkowo) oryginalnych danych
    foreach byte buffer [csum: csum + (to-integer byte)]
    csum: to-binary reduce [256 - csum]

    ; bajty PID_DLE_BYTE musza zostac zdublowane! dotyczy to pol SIZE, DATA, CHKSUM (trzeba pominac pole CMD)
    replace/all next buffer Pid_Dle_Byte reduce [Pid_Dle_Byte Pid_Dle_Byte]
    to-binary simplify reduce [Pid_Dle_Byte buffer (to-integer csum) Pid_Dle_Byte Pid_Etx_Byte]
  ]

  sequence: func [[catch] buf [block!] /locl cmd dat][
    ; rozkazy obslugiwane przez sterownik
    dat: [
        'get 'waypoints (cmd: encode-packet reduce [Pid_Command_Data Cmnd_Transfer_Wpt 0])
      | 'get 'datetime (cmd: encode-packet reduce [Pid_Command_Data Cmnd_Transfer_Time 0])
      | 'get ['tracklogs | 'tracklog] (cmd: encode-packet reduce [Pid_Command_Data Cmnd_Transfer_Trk 0])
      | 'get ['routes | 'route] (cmd: encode-packet reduce [Pid_Command_Data Cmnd_Transfer_Rte 0])
      | 'get 'display (cmd: encode-packet reduce [Pid_Command_Data Cmnd_Transfer_Display 0])
      | 'get 'product 'info (cmd: encode-packet reduce [Pid_Product_Rqst Pid_Product_Rqst 0])
      | 'abort (cmd: encode-packet reduce [Pid_Command_Data Cmnd_Abort_Transfer 0])
      | 'power-off (cmd: encode-packet reduce [Pid_Command_Data Cmnd_Turn_Off_Pwr 0])
      | 'check (cmd: encode-packet reduce [28 0 0])
    ]
    either parse/all buf dat [cmd] [none]
  ]

  from-ieee: func [[catch]
   "Konwertuje binary! float ieee-32 na decimal!"
    dat [binary!] "liczba w formacie ieee-32"
   /local ieee] [

   ieee: make struct! [f [float]] none
   change third ieee dat
   return ieee/f
  ]

  from-semicircle: func [
   "Konwertuje liczbe czalkowita w formacie semicircle na decimal!"
    bin [binary!] "4 bajty"][

    (to-integer head reverse bin) * (180 / (power 2 31))
  ]

  from-timestamp: func [
   "Konwertuje liczbe sekund od 1989-12-31/00:00:00 do rebol date!"
    bin [binary!] "4 bajty"
   /local reference days dt][

    if (to-integer bin) <= 0 [return now]
    reference: 31-12-1989/00:00
    days: (to-integer bin) / 86400 ; 86400 = 24 * 3600 = sekund w ciagu dnia

    dt: reference + (to-integer days) ; czesc calkowita to liczba dni
    dt: dt + to-time to-integer ((days - (to-integer days)) * 86400) ; czesc ulamkowa to czas
  ]

  make-wpt: func [
   "Tworzy block! dla waypointa [nazwa lat lon alt]"
    bin [binary!] "pakiet D108"
   /local dat][

    ; dane zgodnie z protoko&#322;oem D108
    ; wspolrzedne geograficzne s&#353; zakodowane jako semicircle (po 4 bajty na wspolrzedna)
    dat: packet-data bin
    reduce [
      ;; dodac ID typu waypointa
      (to-string trim copy/part (skip dat 48) 51) ; name 26
      (to-decimal from-semicircle copy/part (skip dat 24) 4) ; latitude
      (to-decimal from-semicircle copy/part (skip dat 28) 4) ; longitude
      (to-decimal from-ieee copy/part (skip dat 32) 4) ; altitude
    ]
  ]

  make-rte: func [
   "Tworzy block! dla trasy [rte [wpt lat lon alt] [wpr lat lon alt] ...]"
    bin [binary!] "pakiet D202 (hdr), D108 (data), D210 (link)"
   /local dat cmd][

    ; dane zgodnie z protokolem D202 (header), D108 (waypoint) oraz D210 (rte-link)
    cmd: packet-cmd bin
    dat: packet-data bin
    return switch cmd reduce [
      Pid_Rte_Hdr [ reduce [trim to-string copy/part (skip dat 0) 51] ] ;  (name)
      Pid_Rte_Wpt_Data [ make-wpt bin ] ; (D108 waypoint)
      ; Pid_Rte_Link_Data [ "??" ] ; ??
    ]
  ]

  make-trk: func [
   "Tworzy block! dla tracklogu [trk [wpt lat lon alt d-time] [wpt lat lon alt d-time] ...]"
    bin [binary!] "pakiet D301 (hdr), D310 (data)"
   /local dat][

    ; dane zgodnie z protokolem D310 (track) oraz D301 (header)
    cmd: packet-cmd bin
    dat: packet-data bin
    either (cmd = Pid_Trk_Hdr) [
      reduce [ (trim to-string copy/part (skip dat 2) 51) ] ; trk_ident
    ]
    [
      reduce [
        (to-decimal from-semicircle copy/part dat 4) ; latitude
        (to-decimal from-semicircle copy/part skip dat 4 4) ; longitude
        (to-decimal from-ieee copy/part (skip dat 12) 4) ; altitude
        (to-date from-timestamp head reverse copy/part (skip dat 8) 4) ; datetime GMT
      ]
    ]
  ]
  
  make-display: func [
   "Tworzy image! z binarnych danych zakodowanych"
    dat [binary!] "dane binarne"
    img-size [pair!] "wielkosc obrazka po zdekodowaniu"
    bpp [integer!]  "ile bitow na piksel"
   /local x rc chunks part img to-pixel cnt ind][
    
    bpp: any [bpp 2] ; ile bitow na piksel (dla wyswietlaczy b/w bedzie od 2 do 4)
    rc: copy []

    ; podziel odebrane dane na piksele (kazdy bajt na 8 / bpp pikseli)
    foreach x dat [
      chunks: split-byte x bpp
      foreach part chunks [append rc (255.255.255 / (part + 1))] ; zamien piksele na informacje o kolorze
    ]
    
    img: make image! img-size
    to-pixel: func [p [pair!]] [(p/y * img/size/x) + p/x + 1]
    cnt: 1
    ind: 0x0
  
    ; nanies kazdy piksel na przygotowany obrazek; uwzglednij szerokosc obrazka
    foreach x rc [
      either zero? (cnt // img/size/y) [
        ind: as-pair (ind/x + 1) 0
      ][
        poke img (to-pixel ind) x
        ind: ind + 0x1
      ]
      cnt: cnt + 1
    ]
    to-image layout [origin 0x0 image img effect [rotate 180 flip]]
  ]

  split-byte: func [
   "Dzieli bajt na bpp bitowe czesci"
    byte [binary! integer!] "bajt danych"
    bpp [integer!] "ile bitow w czesci"
   /local x tmp rc bit-test bit-set bit-clear][
  
    bit-test: func [byte [integer!] bit][either (byte and (to-integer power 2 bit)) <> 0 [true][false]]
    bit-set: func [byte [integer!] bit][(byte or (to-integer power 2 bit))]
    bit-clear: func [byte [integer!] bit][(byte and complement (to-integer power 2 bit))]
      
    if (binary? byte) [byte: to-integer byte]
    tmp: 0
    rc: copy []

    repeat x 8 [
      if (bit-test byte (x - 1)) [tmp: bit-set tmp ((x - 1) // bpp)]
      if zero? (x // bpp) [append rc tmp tmp: 0]
    ]    
    rc
  ]
]


make Root-Protocol [
  scheme: 'garmin
  port-id: 8882
  port-flags: system/standard/port-flags/pass-thru
  awake: none
  device: 'port1
  port: none
  lcmd: none


  init: func [[catch] port spec /local tmp] [
    if not parse/all spec [
      "garmin://" [
         copy tmp ["port" ["1" | "2" | "3" | "4"]] (port/device: to-word tmp)
         | end   (port/device: 'port1)
       ]
    ][
       throw make error! [user message "Bad Garmin-URL"]
    ]
    port/locals: make object! [item: 0 packets: 0 lcmd: none ldat: none]
  ]

  open: func [[catch] port] [
    throw-on-error [
      port/sub-port: system/words/open/binary/direct compose [
        scheme: 'serial
        device: (to-lit-word port/device)
        speed: 9600
        data-bits: 8
        parity: 'none
        stop-bits: 1
        rts-cts: no
        timeout: 2 ; 2 sekundy
      ]
      port/state/flags: port/state/flags or port-flags
      self/port: port
    ]
  ]

  insert: func [[catch] port buf [block! binary!] /local e cmd] [
    either block? buf [
      if error? set/any 'e try [cmd: garmin/sequence buf][throw e]
      if none? cmd [throw make error! [user message "Bad Garmin Protocol Command"]]
    ] [ cmd: buf ]
    send-packet self/lcmd: cmd
    none
  ]

  copy: func [[catch] port [port!] /part count [integer!]
   /local bin trk wpt packets rc dat time a b x gps protocol tmp][

    rc: system/words/copy []
    bin: recv-packet ; ack
    gps: self/port
    if not equal? garmin/Pid_Ack_Byte (garmin/packet-cmd bin) [throw none]

    net-utils/net-log ["LAST CMD" self/lcmd]
    net-utils/net-log ["LAST PACKET" first garmin/packet-data self/lcmd]

    switch/default (first garmin/packet-data self/lcmd) reduce [

      garmin/Cmnd_Transfer_Wpt [
        dat: garmin/packet-data bin: recv-packet
        port/locals/packets: packets:  to-integer head reverse system/words/copy/part dat 2 ; dwa bajty
        repeat i packets [
          port/locals/item: i
          send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
          bin: recv-packet
          if (gps/awake gps) [repend/only rc garmin/make-wpt bin]
        ]
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        bin: recv-packet
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        rc
      ]

      garmin/Cmnd_Transfer_Time [
        dat: garmin/packet-data bin: recv-packet
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        time: now/zone + to-time reduce [
          to-integer to-binary reduce [dat/6 dat/5]
          to-integer dat/7
          to-integer dat/8
        ]

        to-date reduce [
          to-integer to-binary reduce [dat/4 dat/3] ; year
          to-integer dat/1 ; month
          to-integer dat/2 ; day
          time
        ]
      ]

      garmin/Cmnd_Transfer_Trk [
        dat: garmin/packet-data bin: recv-packet
        port/locals/packets: packets: to-integer head reverse system/words/copy/part dat 2 ; dwa bajty
        repeat i packets [
          port/locals/item: i
          send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
          trk: garmin/make-trk bin: recv-packet
          if (gps/awake gps) [repend/only either (length? trk) > 1 [last rc] [rc] trk]
        ]
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        bin: recv-packet
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        rc
      ]

      garmin/Pid_Product_Rqst [
        dat: garmin/packet-data bin: recv-packet
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        
        repend rc [
          (to-integer head reverse system/words/copy/part dat 2) ; id
          (to-integer head reverse system/words/copy/part skip dat 2 2) / 100 ; version
          (to-string skip dat 4) ; product
        ]
        if error? try [dat: garmin/packet-data bin: recv-packet][return rc] ; protocol array
        protocol: dat
        
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        comment { zamiana Pid_Protocol_Array na blok danych [ tag id ] }
        tmp: system/words/copy []
        while [not tail? protocol][
          a: to-binary reduce [protocol/3]
          b: to-binary reduce [protocol/2]
          repend tmp [(to-char protocol/1) (to-integer (rejoin [a b]))]
          protocol: skip protocol 3
        ]
        repend/only rc tmp
      ]

      garmin/Cmnd_Transfer_Display [
        dat: garmin/packet-data bin: recv-packet ; display info
        bits-per-pixel: garmin/get-long skip dat 12 ; ile pikseli w jednym bajcie danych
        img-lines: garmin/get-long skip dat 16 ; y
        img-pixels: to-integer garmin/get-long skip dat 20 ; x
        img-line-data: garmin/get-long skip dat 8; ile bajtow danch w pakiecie z GPS
        ; print ["bpp" bits-per-pixel "lines" img-lines "pixels" img-pixels "data" img-line-data]
        
        port/locals/item: 0
        port/locals/packets: packets: (img-pixels * img-lines) / (img-line-data * (8 / bits-per-pixel))
        gps/awake gps

        repeat i packets [
          port/locals/item: i
          send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
          if error? try [bin: recv-packet] [throw make error! [user message "Bad Garmin Display Data"]]
          if (gps/awake gps) [repend (either (empty? rc) [rc] [last rc]) skip (garmin/packet-data bin) 8]
        ]
        net-utils/net-log ["DISPLAY PACKETS" port/locals/packets]
        garmin/make-display rc/1 (to-pair reduce [img-pixels img-lines]) bits-per-pixel
      ]
      
      garmin/Cmnd_Transfer_Rte [
        dat: garmin/packet-data bin: recv-packet
        port/locals/packets: packets: to-integer head reverse system/words/copy/part dat 2 ; dwa bajty
        repeat i packets [
          port/locals/item: i
          send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
          rte: garmin/make-rte bin: recv-packet
          if not none? rte [if (gps/awake gps) [repend/only either (length? rte) > 1 [last rc] [rc] rte]]
        ]
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        bin: recv-packet
        send-packet reduce [garmin/Pid_Ack_Byte (garmin/packet-cmd bin) 0]
        rc
      ]

      0 [true] ; check

    ][rc]
  ]

  send-packet: func [[catch]
   "wysyla pakiet danych do gps (bez obslugi potwierdze&#324; ACK/NACK)"
    cmd [block! binary!] "blok danych (PID CMD DATA) lub binarny pakiet"
   /local packet][

    either (block? cmd) [packet: garmin/encode-packet cmd] [packet: cmd]
    throw-on-error [system/words/insert port/sub-port packet]
    net-utils/net-log ["send-packet" packet]
    self/port/locals/lcmd: packet
  ]

  recv-packet: func [[catch]
   "zwraca pakiet DANYCH pobranych z GPS"
   /local buffer byte prev][

    buffer: system/words/copy []
    byte: prev: 0
    while [true] [
      byte: to-integer (system/words/copy/part self/port/sub-port 1)
      append buffer byte
      if all [(byte = garmin/Pid_Etx_Byte) (prev = garmin/Pid_Dle_Byte)] [break]
      prev: byte
    ]
    ; usun zdublowane bajty Pid_Dle_Byte
    replace/all buffer reduce [garmin/Pid_Dle_Byte garmin/Pid_Dle_Byte] garmin/Pid_Dle_Byte
    net-utils/net-log ["recv-packet" (to-binary buffer)]
    self/port/locals/ldat: to-binary buffer
  ]

  read: write: none

  net-utils/net-install :scheme self :port-id
  system/schemes/garmin/awake: does [true] ; default awake func
]


comment {  
  Example1: {
    ; GPS product informations (model, software)
    gps: open garmin://port1
    insert gps [check]
    if error? try [copy gps] [print "no GPS - no fun" halt]
    insert gps [get product info]
    print copy gps
    close gps
  }
  Example2: {
    ; GPS waypoints
    gps: open garmin://port1
    insert gps [check]
    if error? try [copy gps] [print "no GPS - no fun" halt]
    gps/awake: func [gps [port!]] [print ["waypoint" 1 + gps/locals/packets - gps/locals/item] return true]
    insert gps [get waypoints]
    wpts: copy gps
    either not empty? wpts [foreach location wpts [print first location]] [print "no waypoints"]
    close gps
  }
  Example3: {
    ; GPS screen shot
    gps: open garmin://port1
    insert gps [check]
    if error? try [copy gps] [print "no GPS - no fun" halt]
    gps/awake: func [gps [port!]] [print ["L" 1 + gps/locals/packets - gps/locals/item] return true]
    insert gps [get display]
    img: copy gps
    view layout [origin 0x0 image img]
    close gps
  }
  Example4: {
    ; GPS current date and time
    gps: open garmin://port1
    insert gps [check]
    if error? try [copy gps] [print "no GPS - no fun" halt]
    insert gps [get datetime]
    print copy gps
    close gps
  }
  Example5: {
    ; GPS routes
    gps: open garmin://port1
    insert gps [check]
    if error? try [copy gps] [print "no GPS - no fun" halt]
    gps/awake: func [gps [port!]] [print ["rte/packet" 1 + gps/locals/packets - gps/locals/item] return true]
    insert gps [get routes]
    rts: copy gps
    either not empty? rts [foreach route rts [print first route]] [print "no routes"]
    close gps
  }

  Changelog: [
    0.4.2 2004-12-12
      nowe
      - mozliwosc pobrania trasy (route, protokol A201/D202/D108/D210); komenda [get route|get routes];
        format zwracanych danych analogiczny jak przy tracklogu
      zmiany
      - tworzenie zrzutu ekranu (make-display) w oparciu o informacje o GPS (liczba linii danych do odczytu,
        bits-per-pixel i wymiary obrazka); mala optymalizacja funkcji przez rezygnacje z head reverse na
        danych (obrocenie obrazka jest teraz robione jako effect przy tworzeniu layout)
    0.4.1 2004-06-13
      nowe
      - mozliwosc pobrania zrzutu ekranu GPS (screen shot); nie obsluguje kolorowych GPS (tylko do 8bpp);
        komendy do pobierania danych [get display]
      zmiany
      - metoda insert wykorzystuje teraz funkcje send-packet
      - metoda insert moze operowac na binarnym pakiecie (nie tylko na bloku danych)
      usuniete usterki
      - przy pobieraniu tracklogu wysokosc byla blednie dekodowana; poprawione
    0.3.0 2004-06-10
      nowe
      - mozliwosc pobrania product-info (protokol A001); komenda [get product info]
      - obsluga awake callback wywolywanego dla kazdego odebranego pakietu z GPS; callback musi zwrocic true
        gdy dany pakie ma byc obsluzony (false gdy pominiety)
      zmiany
      - przy pobieraniu tracklogu (protokol A301/D301/D310); pobierane sa wspolrzedne, czas i wysokosc
    0.2.0 2004-02-02
      nowe
      - mozliwosc pobierania waypointow (protokol A100/D108); komenda [get waypoints]
      - mozliwosc pobierania tracklogu (protokol A301/D301/D310); komenda [get trakclog]
      - mozliwosc pobierania biezacej daty z GPS (protokol A600/D600); komenda [get datetime]
  ]
}
