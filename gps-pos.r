REBOL [
  Library: [
     level: 'intermediate
     platform: 'all
     type: 'demo
     domain: 'http
     tested-under: {view 1.2 on xp}
     support: none
     license: none
     see-also: none
   ]

     Title: "gps_pos" Version: 1.0.0
     Date: 8-Aug-2004
     Author: "Jean-Nicolas Merville"
     File: %gps-pos.r
     Purpose: {
       print position from gps devices
       find corresponding map on mapquest
       (gps device must be nmea compliant)
     }
]

;- mapquest url
murl: "http://www.mapquest.com/maps/map.adp?latlongtype=decimal"

;- add ports if needed '
;- (i need com4 for my usb to serial adapter)
append system/ports/serial 'com3
append system/ports/serial 'com4
append system/ports/serial 'com5

cls: "^(1B)[J"
print "please wait..."

;- open serial port (same speed as gpd device)
listen: open serial://port4/1200/8/none/1 /string

;- i need to wait because the usb adapter is tricky -
wait 3

sentence: ""
while [on] [
   conn: first wait listen 
   sentence: rejoin [sentence conn]
   if conn = #"^(line)" [
     exp: parse sentence ","
     st: first exp
     ;- ignore all gps sentence except location -
     if st = {$GPGLL} [

     ;- transform to decimal degrees
     lat: second exp
     ddeglat: ( to-decimal copy/part lat 2 ) + ( 1 / 60 * to-decimal at lat 3 )
     n: third exp


     long: fourth exp
     ddeglong: ( to-decimal copy/part long 3 ) + ( 1 / 60 * to-decimal at long 4 ) 
     e: fifth exp

     print cls
     print now
     print rejoin [ "Latitude : " ddeglat n ]
     print rejoin [ "longitude : " ddeglong e ]
     
     ;- make full url and browse mapquest
     furl: rejoin [murl "&latitude=" ddeglat "&longitude=" ddeglong "&zoom=10"]
     browse/only furl

      ]
     wait 10
     sentence: "" 
   ]
] 
close listen
quit