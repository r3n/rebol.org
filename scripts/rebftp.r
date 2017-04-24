REBOL [
    Title: "REBftp simple ftp client"
    Date: 7-Jun-2001
    Version: 1.3.0
    File: %rebftp.r
    Author: "David Crawford"
    Purpose: {A simple program to upload and download files to/from an ftp server.}
    Email: dave_111@bellsouth.net
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

comment { This program does NOT open a port, instead it uses rebol's built in
          opening and closing before and after a read/write.  TODO: The program
          still needs to handle traversing up and down directories, preferences,
          bookmarks, mode switching (currently only does binary).
          Note: the panes used here are based on Carl Sassenrath's Example in the
          How-To section at http://www.rebol.com , many thanks go to Carl!! }

;-------- Global Vars ---------------------------------;
group: read %/    ;- get the root directory
group2: []
counter: 0
baseserv: "ftp://"
colon: ":"
atsymbol: "@"
slash: "/"
a: "current dir"
b: "remote dir"
elf: ""
bob: ""
;ralph: []
ogres: []
Kobol: []
mypath: ""
nextpath: ""
;-----------------Layout and Main Function-----------;

   start: func [][

   main: layout [
        style lab label 50 left
        across
        banner red "REB-FTP Client."
        button 30x30 coal "?" [inform man-about]
        return
        across return
        button "Remote Panel" [ panels/pane: panel1  show panels ]
        button "Local Panel  " [ panels/pane: panel2  show panels ]
        return
        box 210x2 maroon
        return
        panels: box 210x200 coal
                ]

    panel1: layout [
        origin 8x8
        h2 "FTP Server"
        servname: field "ftp.aminet.org/pub/aminet/recent/"
        servsubd: field "subdir"
        username: field "User-Name"
        passname: field "PASS"
        guide
        button "Select" [
          append bob baseserv
          append bob username/text
          append bob colon
          append bob passname/text
          append bob atsymbol
          append bob servname/text
          if (servsubd/text = NOT "subdir") [append bob "/"
                                             append bob servsubd/text
                                             append bob "/"
                                             bob: to-url bob
                                             ;groups: read bob
                                             ]
               ; alert [ "NOTE: the trailing slash MUST be on the ftp server name, or an error will occur!"]
                 panels/pane: panel3  show panels
                          ]
     return
     button 95x24 "ANON"  [
        append bob baseserv
        append bob servname/text
        bob: to-url bob
        panels/pane: panel3 show panels
        ]
   ]

    panel2: layout [
        origin 8x8
        h2 "Local Prefs"
        across
        return
        text-list 200x120 data (read %/) [append elf value]
        return
        button 80x25 "Cool!" [
               alert [elf]
               ]
        button 80x25 "Continue" [
                               inform elven
                                ]
        button 25x25 green "R" [do %rebftp.r]
        return
    ]

    panel3: layout [
        origin 8x8
        h2 "Connect Window"
        across
        text blue "Local Directory:"
        return
        info red elf
        return
        text blue "Remote Directory:"
        return
        info red bob
        return
        label "Continue?"
        return
        button 95x15 "Go" [ bob: to-url bob
                            ralph: read bob
                            elf: to-file elf
                            gnome: read elf
                            subw
                          ]
        button 95x15 "Escape" [do %rebftp.r]
       ;text-list 180x140 data (read %.) ;groups
        return
   ]

    panel1/offset: 0x0
    panel2/offset: 0x0
    panel3/offset: 0x0

    panels/pane: panel1

;********************
 view main
;********************


 ]
;------------------Sub-Func----------------;
;- This function required so that the panels
;- will be drawn AFTER the blocks are filled
;- with the variable information-----------;

   subw: func [][
     swin: layout [
        style lab label 50 left
        across
        banner red "MyFTP Client." return
        across return
        button "Recieve FROM" [ funnels/pane: panelA  show funnels ]
        button "Copy TO Serv" [ funnels/pane: panelB  show funnels ]
        return
        box 210x2 maroon
        return
        funnels: box 210x200 navy
                ]

    panelA: layout [
        origin 8x8
        h2 "Remote Files"
        across
        return
        text-list 200x120 data ralph [append ogres value]
        return
        button 80x25 "Download" [
             ; alert [ogres]
               foreach ogre ogres[
                      clear mypath
                      clear nextpath
                      append mypath bob
                     ;append mypath slash
                      append mypath ogre
                      append nextpath elf
                     ;append nextpath slash
                      append nextpath ogre
                      mypath: to-url mypath
                      nextpath: to-file nextpath
                     ;alert [mypath]
                     ;alert [nextpath]
                      write/binary nextpath read/binary mypath
                       ]
               ]
        button 80x25 "Reset" [ clear ogres
                               alert ["Download Buffer Cleared"]
                               ]
        button 25x25 red "Q" [quit]
        return
    ]
    panelB: layout [
        origin 8x8
        h2 "Local Files"
        across
        return
        text-list 200x120 data gnome [append Kobol value]
        return
        button 80x25 "Upload" [
               alert [kobol]
               foreach kobo kobol [
                     clear mypath
                     clear nextpath
                      append mypath bob
                      append mypath kobo
                      append nextpath elf
                      append nextpath kobo
                      mypath: to-url mypath
                      nextpath: to-file nextpath
                      write/binary mypath read/binary nextpath
                        ]
               ]
        button 80x25 "Reset!" [ clear Kobol
                                alert ["Upload Buffer Cleared"]
                                ]
        button 25x25 green "R" [do %rebftp.r]
        return
    ]
     panelB/offset: 0x0
     panelA/offset: 0x0
     funnels/pane: panelA

     view swin
]

;------------------------------------------------------;
elven: layout  [
    across
    backdrop effect [gradient 1x1 0.0.0 0.0.180]
    banner " SUB-Dir! " gold
    return
    text "Create a sub-directory called:" yellow
    return
    elvish: field ""
    return
    button "Continue" [hide-popup
                       either not elvish/text = "" [
                              append elf (elvish/text)
                              elf: to-file elf
                              if not (exists? elf) [
                                 make-dir elf
                                 ]
                              ][
                              elf: to-file elf
                               ]
                       hide-popup
                      ]

]

man-about: layout [
     across
     banner "RebFTP/MyFTP" red
     return
     text gold "Created 2001 using Rebel/View,"
     return
     text gold "by David Crawford.  See the "
     return
     text gold "Readme for full instructions"
     return
     text gold bold "Bug reports: "
     text "Enter problem below."
     return
     buggies: field "Bug"
     return
     button "send" [ send dave_111@bellsouth.net buggies/text ]
     return
     button "close" [hide-popup]
     ]
;------------------------------------------------------;
;------------the whole thing starts here!
start





