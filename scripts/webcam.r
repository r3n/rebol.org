REBOL [
  Title: "webcam style"
  Description: "webcam-style"
  Purpose: "style for webcam images"
  Date: 2004-06-10
  Version: 0.0.2.0
  Author: "Piotr Gapinski"
  Email: news@rowery.olsztyn.pl
  File: %webcam.r
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  License: "GNU Lesser General Public License (Version 2.1)"
  Example: { ;; images from Olsztyn/Poland
    view layout [
      styles webcam-style
      webcam http://topexpert.pl/webcam/webcam32.jpg rate 20 
    ]
  }
  Library: [
    level: 'intermediate
    platform: 'all
    type: [tool]
    domain: [web]
    tested-under: [
      view 1.2.1 on [Winxp]
      view 1.2.46 on [Winxp]
    ] 
    support: none
    license: 'LGPL
  ]
  History: [
    0.0.3.0 2004-06-10 "proxy aware"
  ]
]

webcam-style: stylize [
  webcam: image with [
    weburl: im: none

    init: append init [
      weburl: first facets
      refresh: def-refresh: 1 + to-time third facets
      rate: 1
      if ((type? weburl) = url!) [im: image: load read/binary/direct rejoin [weburl "?r=" random 1000]]
    ]

    feel/engage: func [face act evt] [
      if act = 'time [
        refresh: refresh - 1
        if not none? face/im [
          time-info: either zero? refresh ["refreshing"][mold refresh]
          face/image: to-image layout [
            origin 0x0 
            at 0x0 image face/im
            at to-pair reduce [10 (face/im/size/y - 20)] 
            vtext time-info font [size: 10] effect [merge luma -40]
          ]
          show face
        ]
      ]

      if zero? refresh [
        face/im: load read/binary/direct rejoin [face/weburl "?r=" random 1000]
        face/image: face/im
        refresh: def-refresh
      ]
    ]
  ]
]

view layout [
  styles webcam-style
  at 0x0 origin 0x0
  key (escape) [quit]
  webcam http://topexpert.pl/webcam/webcam32.jpg rate 20 
]
