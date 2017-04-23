REBOL [
    Title: "YARM - Yet Another Rebol Messenger"
    Date: 2-Jan-2002
    Version: 1.0.2
    File: %yarm.r
    Author: "Tommy Giessing Pedersen"
    Purpose: "An email-client with a browser front-end"
    Email: nite_dk@bigfoot.com
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [cgi email markup tcp GUI web] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

d: request-list "Select where to install YARM" load %/
while [ not-equal? d none ] [
   change-dir d
   list: make block! [ %../ ]
   foreach file load %./ [
      if dir? file [ append list file ]
   ]
   sort list
   d: request-list make string! what-dir list
]
d: request-text/title "Create new folder here?"
if not-equal? d none [
   make-dir make file! d
   change-dir make file! d
]
flash rejoin [ "You can now start YARM from " what-dir "yarm.r" ]
write %yarm.r read http://www.lillekriger.person.dk/yarm.r
d: wait 5
unview
do %yarm.r
                               