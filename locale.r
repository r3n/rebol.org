REBOL [
    Title:   "Dynamic Script Localization"
    Date:    06-Sep-2004
    Author:  ["Marco"]
    Version: 1.0.1
    Email:   [marco@ladyreb.org]
    File:    %locale.r
    Category: [tool]
    Library: [
        level: 'beginner
        platform: 'all
        type: [function tool]
        domain: [gui]
        tested-under: [win]
        support: marco@ladyreb.org
        license: PD
        see-also: none
    ]
    Purpose: {
        Locale.r extends the system/locale objet in order to supply a
        dynamique localization of applications
    }
    Modified: [
        [1.0.0 5-May-2004 marco@ladyreb.org {Création du programme}]
        [1.0.1 06-Aug-2004 marco@ladyreb.org {Add windows title automatic update}]
    ]
    Usage: {
    	do %locale.r
    	view/title layout [
 			rotary "English" "Français" [
 				set-locale/show  pick [french english] index? find face/texts face/text system/view/screen-face
			]
			text add-locale my-text [english "English text" french "Texte français"]
		]
    }
]

; ****************************
; Declare the public interface
; ****************************

set-locale: add-locale: load-locale: save-locale: none
slt: sla: none

; ***********************
; system/locale extension
; ***********************
system/locale: make system/locale [
    language: [english french] ; default translation languages, other language can be added
    default: 'english ; default is english
    current: none ; current is none. This value is set by the set-locale function
    text: []
    set 'slt :text

; *****************
; Translation table
; *****************

    translation: [
    
; General translation
		days [
	    	english ["Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday"]
	    	french ["Lundi" "Mardi" "Mercredi" "Jeudi" "Vendredi" "Samedi" "Dimanche"]
    	]
    	months [
    		english ["January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December"]
    		french ["Janvier" "Février" "Mars" "Avril" "Mai" "Juin" "Juillet" "Août" "Septembre" "Octobre" "Novembre" "Décembre"]
    	]
    	
; Translation for Rebol functions

        dialog [english "Dialog" french "Dialogue"] 
        yes [english "Yes" french "Oui"] 
        no [english "No" french "Non"] 
        cancel [english "Cancel" french "Annuler"]
        what-is-your-choice [english "What is your choice?" french "Quel est votre choix ?"]
        ok [english "OK" french "OK"]
        downloading-file [english "Downloading File:" french "Téléchargemnt de fichier :"]
		bytes [english "bytes" french "octets"]
		select-a-file [english "Select a File:"	french "Choisissez un fichier :"]
		select [english "Select" french "Selection"]
		custom [english "Custom" french "Custom"]
		enter-password [english "Enter password:" french "Entrez votre mot de passe :"]
		enter-username-and-password [english "Enter username and password:" french "Entrez votre nom et votre mot de passe:"]
		enter-user [english "User:" french "Utilisateur :"]
		enter-text-below [english "Enter text below:" french "Entrez du texte ci-dessous :"]

; Translation for standard window menu        

        file [english "File" french "Fichier"] 
            new [english "New" french "Nouveau"] 
            open [english "Open" french "Ouvrir"] 
            close [english "Close" french "Close"] 
            save [english "Save" french "Enregistrer"] 
            save-as [english "Save as" french "Enregistrer sous"] 
            print [english "Print" french "Imprimer"] 
            print-preview [english "Print preview" french "Apperçu avant impression"]
            print-setup [enplish "Print setup" french "Mise en page"]
        edit [english "Edit" french "Edition"]
            view [english "View" french "Vue"]
            cut [english "Cut" french "Couper"]
            copy [english "Copy" french "Copier"]
            paste [english "Paste" french "Coller"]
            find [english "Find" french "Rechercher"]
            replace [english "Replace" french "Remplacer"]
        insert [english "Insert" french "Insertion"]
        format [english "Format" french "Format"]
            font [english "Font" french "Police"]
            paragraph [english "Paragraph" french "Paragraphe"]
        tools [english "Tools" french "Outils"]
	    	options [english "Options" french "Options"]
	    windows [english "Windows" french "Fenêtre"]
	    	cascade [english "Cascade" french "Cascade"]
	    	tile-horizontal [english "Tile horizontal" french "Horizonzal"]
	    	tile-vertical [english "Tile vertical" french "Vertical"]
	    	mozaic [english "Mozaic" french "Mosaique"]
	]

; *******************************************************************************
; Add a localization for a word to the base and return the current language value
; *******************************************************************************

	set 'add-locale func [
		"Add a word localization"
		'word [word!] "A localized word"
		value [block!] "Block of Translation pair [language value ...]"
	][
		if not find translation word [
			insert tail translation reduce [word copy []]
		]
		change/only next find translation word value: union/skip value translation/:word 2
		set-text word value
		select text word
	]
	set 'sla :add-locale

; **********************************
; Set text to current language value
; **********************************

	set-text: func [
		word [word!]
		value [block!]
		/locale v
	][
		if not find text word [
			insert tail text reduce [
				word
				either block? second value [copy []] [copy ""]
			]
		]
		change clear head select text word v: any [
			select value current
			select value default
			either block? select text word [
				["< Undefined >"]
			][
				"< Undefined >"
			]
		]
		if word = 'months [
			repeat i 12 [
				change clear head months/:i v/:i
			]
		]
		if word = 'days [
			repeat i 7 [
				change clear head days/:i v/:i
			]
		]
	]
	
; ************************
; Load a localization file
; ************************

	set 'load-locale func [
		source [file! url! string! any-block! binary!]
	][
		foreach [word value] load source [
			add-locale :word probe value
		]
	]

; *************************
; Save to localization file
; *************************

	set 'save-locale func [
		where [file! url! binary!] "Where to save it."
	][
		save/header where translation compose [Title: "Rebol localization" Date: (now)]
	]

; *************
; Show the face
; *************

	show-face: func [
		face [object! block!]
	][
		if face = system/view/screen-face [
			face: face/pane
		]
		face: to-block face
		foreach item face [
			if item/text [
				item/changes: either item/changes [
					union [text]  to-block item/changes
				][
					[text]
				]
			]
			show item
		]
	]

; ********************
; Set current language
; ********************

	set 'set-locale func [
		language [word!] "Language to set"
		/show face [object! block!] "Face to show"
	][
		current: language
		foreach [word value] translation [
			set-text word value
		]
		if show [
			show-face face
		]
		language
	]
	set-locale default
]

; ***********************
; btn-enter redefinition
; ***********************

	use [tmp] [
		tmp: get-style 'btn-enter
		tmp/text: system/locale/text/ok
		tmp/texts: reduce [system/locale/text/ok]
	]

; ***********************
; btn-cancel redefinition
; ***********************

	use [tmp] [
		tmp: get-style 'btn-cancel
		tmp/text: system/locale/text/cancel
		tmp/texts: reduce [system/locale/text/cancel system/locale/text/cancel]
	]

; ****************************
; inform function redefinition
; ****************************

inform: func [
    {Display an exclusive focus panel for alerts, dialogs, and requestors.}
    panel [object!]
    /offset where [pair!] "Offset of panel"
    /title ttl [string!] "Dialog window title"
    /timeout time][
    panel/text: any [ttl system/locale/text/dialog]
    panel/offset: either offset [where] [system/view/screen-face/size - panel/size / 2]
    panel/feel: system/view/window-feel
    show-popup panel
    either time [wait time] [do-events]]


; *****************************
; request function redefinition
; *****************************

request: func [
    "Requests an answer to a simple question." 
    str [string! block! object! none!] 
    /offset xy 
    /ok 
    /only 
    /confirm 
    /type icon [word!] {Valid values are: alert, help (default), info, stop} 
    /timeout time 
    /local lay result msg y n c width f img][
    icon: any [icon all [none? icon any [ok timeout] 'info] 'help] 
    lay: either all [object? str in str 'type str/type = 'face] [str] [
        if none? str [str: system/locale/text/what-is-your-choice] 
        set [y n c] reduce [system/locale/text/yes system/locale/text/no system/locale/text/cancel] 
        if confirm [c: none] 
        if ok [y: system/locale/text/OK n: c: none] 
        if only [y: n: c: none] 
        if block? str [
            str: reduce str 
            set [str y n c] str 
            foreach n [str y n c] [
                if all [found? get n not string? get n] [set n form get n]]] 
        width: any [all [200 >= length? str 280] to-integer (length? str) - 200 / 50 * 20 + 280] 
        layout [f: text bold to-pair reduce [width 1000] str] 
        img: switch/default :icon [
            info [info.gif] 
            alert [exclamation.gif] 
            stop [stop.gif]] [help.gif] 
        result: copy [
            across 
            at 0x0 
            origin 15x10 
            image img 
            pad 0x12 
            guide 
            msg: text bold black str to-pair reduce [width -1] return 
            pad 4x12] 
        if y [append result [btn-enter 60 y first lowercase copy y [result: yes hide-popup]]] 
        if n [append result [btn 60 silver n first lowercase copy n [result: no hide-popup]]] 
        if c [append result [btn-cancel 60 c escape [result: none hide-popup]]] 
        layout result] 
    result: none 
    either offset [inform/offset/timeout lay xy time] [inform/timeout lay time] 
    result
]

; **************************************
; request-download function redefinition
; **************************************

request-download: func [
    {Request a file download from the net. Show progress. Return none on error.} 
    url [url!] 
    /to "Specify local file target." local-file [file! none!] 
    /local prog lo stop data stat event-port event][
    view/new center-face lo: layout [
        space 10x8 
        vh2 300 system/locale/text/downloading-file
        vtext bold center 300 to-string url 
        prog: progress 300 
        across 
        btn 90 system/locale/text/cancel [stop: true] 
        stat: text 160x24 middle] 
    stop: false 
    data: read-thru/to/progress/update url local-file func [total bytes] [
        prog/data: bytes / (max 1 total) 
        stat/text: reform [bytes system/locale/text/bytes] 
        show [prog stat] 
        not stop] 
    unview/only lo 
    if not stop [data]
]

; **********************************
; request-pass function redefinition
; **********************************

request-pass: func [
    "Requests a username and password." 
    /offset xy 
    /user username 
    /only "Password only." 
    /title title-text
][
    if none? user [username: copy ""] 
    pass-lay: layout compose [
        style tx text 40x24 middle right 
        across origin 10x10 space 2x4 
        h3 (either title [title-text] [either only [
        	system/locale/text/enter-password
        ] [
        	system/locale/text/enter-username-and-password
        ]]) 
        return 
        (either only [[]] [[tx system/locale/text/enter-user  userf: field username return]]) 
        tx "Pass:" pass: field hide [ok: yes hide-popup] with [flags: [return tabbed]] return 
        pad 140 
        btn-enter 50 system/locale/text/ok [ok: yes hide-popup] 
        btn-cancel 50 system/locale/text/cancel #"^[" [hide-popup]
    ] 
    ok: no 
    focus either only [pass] [userf] 
    either offset [inform/offset pass-lay xy] [inform pass-lay] 
    all [ok either only [pass/data] [reduce [userf/data pass/data]]]
]

; **********************************
; request-pass function redefinition
; **********************************

request-text: func [
    "Requests a text string be entered." 
    /offset xy 
    /title title-text 
    /default str
][
    if none? str [str: copy ""] 
    text-lay: layout compose [
        across origin 10x10 space 2x4 
        h3 bold (either title [title-text] [system/locale/text/enter-text-below]) 
        return 
        tf: field 300 str [ok: yes hide-popup] with [flags: [return]] return 
        pad 194 
        btn-enter 50 system/locale/text/ok [ok: yes hide-popup] 
        btn-cancel 50 system/locale/text/cancel #"^[" [hide-popup]
    ] 
    ok: no 
    focus tf 
    either offset [inform/offset text-lay xy] [inform text-lay] 
    all [ok tf/text]
]
