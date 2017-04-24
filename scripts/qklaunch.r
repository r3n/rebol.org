REBOL [
  file:        %qklaunch.r
  date:        2007-06-06
  title:       "QkLaunch - Quick Program Launcher"
  author:      "Arie van Wingerden"
  purpose:     "Easily launch programs from folder structure acting as a menu."
  description: {To appreciate this program, setup a folder (directory) structure
                which resembles the menu structure you like to have.
                Now, change the variable *basedir to the top-level folder
                of that structure.
                When you execute this program, you can navigate through the
                structure and open any folder and start any program within
                that structure.}
  web:         http://rebolution.esmartweb.com/index.html
  e-mail:      "xapwing-at-gmail-dot-com"
  library: [
    level:          'beginner
    platform:       'all
    type:           [tool]
    domain:         [file-handling]
    tested-under:   [REBOL/View 2.7.5.3.1]
    support:        none
    license:        none
    see-also:       none
  ]
  version:     0.2
  history: [
    version: [
      [0.2 2007-06-06 "Added colors to text-list - thanks to Anton Rolls"]
      [0.1 2007-05-30 "Initial release"]
    ]
  ]
]

fill-choicelist: func [a-dir /local a-choicelist an-item][
  a-choicelist: read/lines a-dir
  foreach an-item a-choicelist [
    an-item: to-string an-item
  ]
  if *menu-level > 0 [
    insert head a-choicelist *back-txt
  ]
  insert tail a-choicelist *quit-txt
  a-choicelist: head a-choicelist
]

menu-hit: func [face /local fchoice schoice][
  schoice: first face/picked
  if schoice = *quit-txt [
    quit
  ]
  fchoice: to-file schoice
  either schoice = *back-txt [
    *menu-level: *menu-level - 1
    change-dir %..
    *choices: fill-choicelist %.
  ][
    either dir? fchoice [
      *menu-level: *menu-level + 1
      change-dir fchoice
      *choices: fill-choicelist %.
    ][
      call rejoin [{""} fchoice {""}]
      quit
    ]
  ]
  face/data: *choices
  show face
]

;==============================
;    M a i n   P r o g r a m
;
;    NOTE: global variables
;          begin with a *
;==============================
*menu-level: 0
*back-txt: "=== back ==="
*quit-txt: "=== quit ==="
*basedir: %/d/data/menu+/
change-dir *basedir
*choices: fill-choicelist *basedir

view center-face
  gui: layout/size [
  origin 0x0
  space 0x0
  menu: text-list data *choices 900x699 [menu-hit face] with [
	  append init [
      iter/feel: make iter/feel [
		    redraw: func [face action into][
          either find picked iter/text [
            iter/color: svvc/field-select
          ][
            switch/default last iter/text [
              #"/" [iter/color: 142.255.192]
              #"=" [iter/color: red]
            ] [iter/color: 172.240.255]
          ]
				]
			]
		]
  ]
] 900x700
