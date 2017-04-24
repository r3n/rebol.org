REBOL [
  Title: "clipboard handler"
  Purpose: "Share clipboard between Linux/KDE klipper and Rebol"
  Author: "Piotr Gapinski"
  Email: {news [at] rowery! olsztyn.pl}
  File: %klipper.r
  Date: 2005-02-18
  Version: 0.2.0
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl/"
  License: "GNU Lesser General Public License (Version 2.1)"
  Library: [
    level: 'intermediate
    platform: 'all
    type: [protocol tool]
    domain: [protocol]
    tested-under: [
      view 1.2.48 on [Linux]
      view 1.2.56 on [WinXP]
    ]
    support: none
    license: 'LGPL
  ]
]

make root-protocol [
  scheme: 'clip
  port-id: 8883
  port-flags: system/standard/port-flags/direct
  awake: none
  open-check: none

  linux?: does [equal? fourth system/version 4]
  init: func [[catch] port spec /local tmp] [
    port/device: "0"
    if not parse/all spec [
      "clip://" 
       opt [copy tmp ["0" | "1" | "2" | "3" | "4"] (port/device: tmp)]
    ] [
       throw make error! [user message "clip-url error"]
    ]
  ]
  open: func [port] [none]
  close: func [port] [none]
  read: func [port data [string!]] [
    port/state/inBuffer: make string! 100
    either linux? [
      call/wait/output reduce [{dcop klipper klipper getClipboardHistoryItem} port/device] port/state/inBuffer
      system/words/write clipboard:// port/state/inBuffer
    ][
      port/state/inBuffer: system/words/read clipboard://
    ]
    port/state/num: port/state/tail: length? port/state/inBuffer
    append data port/state/inBuffer
  ]
  write: func [port data] [
    any [
      not linux?
      call/wait reduce [{dcop klipper klipper setClipboardContents "} data {"}]
    ]
    system/words/write clipboard:// data
  ]
  net-utils/net-install :scheme self :port-id
]

comment {  
; example
  print read clip://1
  write clip:// {rebol clipboard}
}

comment {
; changelog
  2005-02-18
  - obsluga KDE (klipper) i Windows (clipboard://)
  - mozliwosc pobrania danych z historii schowka (np. clip://1); przy zapisie dodatkowe informacje sa ignorowane
}