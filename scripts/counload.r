REBOL [
    Title: "Count and Download"
    Date: 20-Jul-2001
    Version: 1.0.0
    File: %counload.r
    Author: "Tommy Giessing Pedersen"
    Purpose: "Downloads numbered filenames from the internet."
    Email: nite_dk@bigfoot.com
    Web: http://www.bigfoot.com/~nite_dk
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [ftp other-net web GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

secure none

setup: make object! [
   webpath: http://
   destination: %./
   filestart: "image"
   fileend: ".jpg"
   startnum: 0
   mindig: 2
   fails: 10
]
if exists? %counload.ini [ setup: do load %counload.ini ]

view layout [
   across tabs 150
   label "Webpath:"          tab wp: field make string! setup/webpath return
   label "Destination:"      tab ds: field make string! setup/destination
   button 50x24 "dir" [ append ds/text request-list ds/text load make file! ds/text show ds ] return
   label "Filename start:"   tab fs: field make string! setup/filestart return
   label "Filename end:"     tab fe: field make string! setup/fileend return
   label "Initial number:"   tab sn: field make string! join "" setup/startnum return
   label "Minimum digits:"   tab md: field make string! join "" setup/mindig return
   label "Failures allowed:" tab fa: field make string! join "" setup/fails return
   button "Start" [
      setup/webpath: make url! wp/text
      setup/destination: make file! ds/text
      setup/filestart: make string! fs/text
      setup/fileend: make string! fe/text
      setup/startnum: make integer! sn/text
      setup/mindig: make integer! md/text
      setup/fails: make integer! fa/text
      save %counload.ini setup
      unview
   ]
]

num: make integer! setup/startnum
err: make integer! 0

while [ greater? setup/fails err ] [
   numstr: make string! join "" num
   while [ greater? setup/mindig length? numstr ] [ numstr: join "0" numstr ]
   remote: make url! rejoin [ setup/webpath setup/filestart numstr setup/fileend ]
   local: make file! rejoin [ setup/destination setup/filestart numstr setup/fileend ]
   prin rejoin [ setup/filestart numstr setup/fileend tab ]
   either exists? local [
      print "skipped"
   ] [ 
      either exists? remote [
         write/binary local read/binary remote
         print "ok"
      ] [
         err: err + 1
         print rejoin [ "not found" tab err "/" setup/fails ]
      ]
   ]
   num: num + 1
]





                                                                           