REBOL [
    Title: "Small Mail Sender by Freakzen-LX"
    Date: 4-Jul-2001
    Version: 1.0.0
    File: %smail.r
    Author: "Freakzen-LX"
    Purpose: "small mail client with timer and logging function "
    Email: freakzen-lx@haekchenadmin.de
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'email 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

write/append %adds.txt ""

;The right-clicks

ba: layout [text "Go to Main-Menu."
button "Back" [hide-popup]
]
ad: layout [text "Add an address to your list."
button "Back" [hide-popup]
]
cl: layout [text "Clear Address & Subject if both available."
button "Back" [hide-popup]
]
co: layout [text "Go to your contact list."
button "Back" [hide-popup]
]
se: layout [text "Send the Mail once."
button "Back" [hide-popup]
]
tm: layout [text "Send timed Mails."
button "Back" [hide-popup]
]
st: layout [text "Stop sending timed Mails."
button "Back" [hide-popup]
]
he: layout [text "Go to Help-Menu."
button "Back" [hide-popup]
]
ab: layout [text "See who made this Stuff."
button "Back" [hide-popup]
]
qu: layout [text "Leave Smailsen"
button "Back" [hide-popup]
]

;the sub-menus

inf: layout[backcolor black
text-list 315x80 wrap edge [effect: 'bevel]"Small Mail Sender by Freakzen-LX" 
"This little prog is made for sending E-Mails ;-) It's a" 
"little buggy, but I will work on it *g*. For comments" 
"write to Freakzen-LX@haekchenadmin.de" black
button "Back" [hide-popup] [inform ba] 
]

adr: layout[
area 315x200 wrap read %adds.txt
text "Add new address"
new: field 315x25
across
button "Add" [write/append/lines %adds.txt reduce new/text value ] [inform ad]
button "Clear" [clear-fields adr show adr inform adr] [inform cl]
button "Back" [hide-popup] [inform ba]
]

hil: layout[
text-list 315x250 wrap edge [effect: 'bevel]"Smailsen Help-Section"
" "
"Here I will tell you something about the Bugs in " "Smailsen :)"
" "
"1) If you add a contact to your list, you have to reload" 
"     Smailsen to see the address in the contact list."
" "
"2) If you want to stop the timed mailing, you have to "
"     click on the Stop Button until an error message "
"     appears."
" "
"If you want to change the interval for timed mailing"
"you have to edit the source code. Search for the String"
"wait 0:0:10. The original setting is send a mail every"
"ten seconds. Replace 10 with a number of your "
"choice. The syntax is hour:minute:second."
"Smailsen has also a logging function. All sendings"
"are logged in Smailsen's Folder. Log.txt shows the"
"normal sended Mails. Log2.txt the timed Mails."
" "
"You can do a right-click on the buttons to receive a"
"short help of the menu."
"That's all. Short programm - short help :)"
" "
"Greetz Freakzen-LX"
button "Back" [hide-popup][inform ba]
]

;Main Menu
 
view stuff: layout [
vh1 "Smailsen" black 
text "Send E-Mail to:" 
mail: field 315x25 
across
button "Clear" [clear-fields stuff show stuff] [inform cl]
button "Contacts" [inform adr write/append/lines %adds.txt reduce " "] [inform co]
across return
text "Subject:" return
top: field 315x25
return
text "Message:" return mess: area wrap 315x200 return
across
button "Send it..."[send/header user: load/all mail/text mess/text
make system/standard/email [subject: top/text] write/append/lines %log.txt reduce "Here starts a new MAil:" write/append/lines %log.txt reduce mail/text write/append/lines %log.txt reduce top/text write/append/lines %log.txt reduce mess/text] [inform se]
button "Timed Mail" [forever [server-port: open/lines tcp://:smtp send/header user: load/all mail/text mess/text make system/standard/email [subject: top/text] wait 0:0:10 write/append/lines %log2.txt reduce "Here starts a new MAil:" write/append/lines %log2.txt reduce mail/text write/append/lines %log2.txt reduce top/text write/append/lines %log2.txt reduce mess/text]] [inform tm]
button "Stop" [close server-port] [inform st]
across return
across
button "Help" [inform hil][inform he]
button "About..." [inform inf] [inform ab]
button "Quit" [quit] [inform qu]

]                                                                                                                        