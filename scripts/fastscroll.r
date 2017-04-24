REBOL [
    Title: "Fast Scrolling"
    File: %fastscroll.r
    Author: "Maxim Olivier-Adlhoch"
    Date: 05-Jun-2007
    Version: 1.0.0
    Rights: "Copyright (c) 2007 Maxim Olivier-Adlhoch"
    Usage: "do http://rebol.org/cgi-bin/cgiwrap/rebol/download-a-script?script-name=fastscroll.r"
    Purpose: "A fast scrolling technique"
    Comment: "Older demo by Maxim, prepped for rebol.org by btiffn"
    History: [
        05-Jun-2007 1.0.0 "btiffn" "First cut for Library"
        05-Jun-2007 1.0.0 "moliad" "Code written"]
    library: [
        level: 'intermediate
        platform: 'all
        type: 'how-to
        domain: 'graphics
        tested-under: [view 2.7.5.4.2 on "Debian GNU/Linux 4.0" by "btiffin"]
        support: [
            "REBOL Mailing List"
            http://www.opensource.org/licenses/mit-license.html
        ]
        license: 'MIT
        see-also: "animresize.r"
    ]
]
; just open console
print ""

glbpane: none

gblface: none

steps: 50


; a large-ish gui
gui-size: 900x600


interrupt: false


;--------------------
;-      stop-anim()
;--------------------
stop-anim: func [
    ""
][
      iface/size: 0x0
      show iface
      interrupt: true
]


;--------------------
;-      start-anim()
;--------------------
start-anim: func [
    ""
][
      iface/size: 125x30
      show iface
      interrupt: false
]


;--------------------
;-      anim-fast()
;--------------------
anim-fast: func [
    ""
    /local i
][
      start-anim
      repeat i steps [
            if interrupt [
                  break
            ]
            print i
            gblface/changes: 'offset
            gblface/offset: (i * 200 * 1x0 / steps)
            wait 0
            show gblface
      ]
]

;--------------------
;-      anim-slow()
;--------------------
anim-slow: func [
    ""
    /local i
][
      start-anim
      repeat i steps [
            if interrupt [
                  break
            ]
            print i
            gblface/offset: (i * 200 * 1x0 / steps)
            wait 0
            show gblface
      ]
]

view/new layout [
      across
      gblpane: box gui-size
      return
      button "slow" [anim-slow]
      button "fast" [anim-fast]
      iface: button "STOP!" [stop-anim] 0x0 red
]


gblface: make face [
      size: 500x500
      effect: [draw [
                  pen none
                  fill-pen diamond 863x9 0 216 225 8 8 142.128.110.213
250.240.230.179 0.48.0.128 250.240.230.128 255.228.196.160 128.128.0.192
255.255.0.189 0.255.255.191 0.128.128.203 128.0.128.193 175.155.120.202
100.136.116.163 72.0.90.199 38.58.108.192 160.180.160.131 255.0.255.179
255.228.196.184 139.69.19.135
                  box 0x0 gui-size
                  pen none
                  fill-pen conic 127x863 0 300 116 9 7 192.192.192.160
255.0.255.171 240.240.240.157 40.100.130.137 255.164.200.133 255.255.255.154
0.128.128.163 0.0.128.166 255.228.196.145 255.0.255.168
                  box 0x0 gui-size
                  pen none
                  fill-pen cubic 375x810 0 89 72 1 8 222.184.135.137 160.82.45.166
38.58.108.157 255.205.40.131 255.150.10.129 240.240.240.139 0.48.0.171
179.179.126.150 0.255.0.131 72.0.90.159
                  box 0x0 gui-size
                  pen none
                  fill-pen radial -117x-266 0 65 158 3 2 255.255.255.143
72.0.90.181 40.100.130.146 100.120.100.130 178.34.34.185 128.0.128.169
72.0.90.160 139.69.19.190 100.120.100.165 178.34.34.148 222.184.135.164
0.0.255.141 160.82.45.143
                  box 0x0 gui-size
                  pen none
                  fill-pen cubic 826x989 0 171 233 2 2 160.82.45.134
192.192.192.167 38.58.108.191 100.136.116.158 175.155.120.187
245.222.129.140 80.108.142.189 255.150.10.158 40.100.130.197 164.200.255.187
179.179.126.169 255.150.10.168 164.200.255.197 220.20.60.170 255.0.0.147
76.26.0.175
                  box 0x0 gui-size
            ]
      ]
]

gblpane/pane: gblface

show gblpane


do-events
