REBOL [
	File: %tray.r
	Date: 1-Sep-2009
	Title: "Advanced Windows tray support"
	Version: 0.1.3
	Author: "Richard Smolak aka Cyphre"
	Purpose: "Handler for advanced system tray features"
	Notes: {
		Done by Cyphre, sponsored by -pekr-, donated to the famous REBOL community :-)
	}
	History: [
		0.1.2 [1-Sep-2009 "First public release"]
		0.1.3 [1-Sep-2009 "fixed issue with set-hook/unhook, added more generic SHOW wrapper"]
	]
	Library: [
		level: 'advanced
		platform: 'windows
		type: [tool module dialect]
		domain: [external-library win-api dialects extension parse user-interface]
		tested-under: [
			view 2.7.6.3.1 on "Windows XP" by "Cyphre"
		] 
		support: ["Richard Smolak aka Cyphre"]
		license: 'bsd
		see-also: none
	]	
]

ctx-tray: context [
	shell32.dll: load/library %shell32.dll
	user32.dll: load/library %user32.dll
	kernel32.dll: load/library %kernel32.dll
	gdi32.dll: load/library %gdi32.dll

	make-char-array: func [
		word-base [string!]
		length [integer!]
		/local result
	][
		result: copy []
		repeat n length [
			insert tail result reduce [to-word join word-base n [char]] 
		]
		result
	]
	
	string-to-chars: func [
		text [string!]
		/length ln [integer!]
		/local result
	][
		result: copy []
		ln: any [ln length? text]
		repeat n ln [
			insert tail result any [text/:n #"^@"] 
		]
		result
	]

	create-window: make routine! [
		dwExStyle [int]
		lpClassName [string!]
		lpWindowName [string!]
		dwStyle [int]
		x [int]
		y [int]
		nWidth [int]
		nHeight [int]
		hWndParent [int]
		hMenu [int]
		hInstance [int]
		lpParam [int]
		return: [int]
	] user32.dll "CreateWindowExA"

	destroy-window: make routine! [
		hwnd [int]
	] user32.dll "DestroyWindow"

	
	BI_RGB: 0
	DIB_RGB_COLORS: 0
	NULL: 0
	
	bmi-header-def: [
		biSize [integer!]
		biWidth [integer!]
		biHeight [integer!]
		biPlanes [short]
		biBitCount [short]
		biCompression [integer!]
		biSizeImage [integer!]
		biXPelsPerMeter [integer!]
		biYPelsPerMeter [integer!]
		biClrUsed [integer!]
		biClrImportant [integer!]
	]
	
	get-window-dc: make routine! [
		hWnd [integer!]
		return: [integer!]
	] user32.dll "GetWindowDC"

	release-dc: make routine! [
		hWnd [integer!]
		hDC [integer!]
	] user32.dll "ReleaseDC"

	create-dib-section: make routine! [
		hdc [integer!]
		pbmi [struct! []]
		iusage [integer!]
		ppvbits [struct! []]
		hsection [integer!]
		dwOffset [integer!]
		return: [integer!]
	] gdi32.dll "CreateDIBSection"
	
	delete-object: make routine! [
		hObject [int]
		return: [int]
	] gdi32.dll "DeleteObject"
	
	copy-memory: make routine! [
		dest [int]
		src [binary!]
		length [int]
	] kernel32.dll "RtlMoveMemory"
	
	
	create-dib: func [image [image!] /local img sx sy pix bitmap-info ppvbits hscreendc hbitmap][
		img: copy #{}
		sx: image/size/x
		sy: image/size/y
		
		repeat n sx * sy [
			pix: pick image n
			insert tail img to-binary reduce [
				pix/3
				pix/2
				pix/1
				255 - pix/4
			]
		]

		bitmap-info: make struct! bmi-header-def none
		bitmap-info/biSize: length? third bitmap-info
		bitmap-info/biWidth: sx
		bitmap-info/biHeight: - sy
		bitmap-info/biPlanes: 1
		bitmap-info/biBitCount: 32
		bitmap-info/biCompression: BI_RGB
		bitmap-info/biSizeImage: 0
		bitmap-info/biXPelsPerMeter: 0
		bitmap-info/biYPelsPerMeter: 0
		bitmap-info/biClrUsed: 0
		bitmap-info/biClrImportant: 0
		
		ppvbits: make struct! [i [integer!]] none
		hscreendc: get-window-dc NULL
		hbitmap: create-dib-section hscreendc bitmap-info DIB_RGB_COLORS ppvbits NULL 0
		copy-memory ppvbits/i img sx * sy * 4

		release-dc NULL hscreendc 
		free bitmap-info
		free ppvbits

		return hbitmap
	]
	
	;-----------------------
	
	icon-info-def: [
		fIcon [char]
		xHotspot [int]
		yHotspot [int]
		hbmMask [int]
		hbmColor [int]
	]
	
	create-icon-indirect: make routine! compose/deep [
		s [struct! [(icon-info-def)]]
		return: [int]
	] user32.dll "CreateIconIndirect"
	
	create-bitmap: make routine! [
		nWidth [int]
		nHeight [int]
		cPlanes [int]
		cBitsPerPel [int]
		lpvBits [binary!]	
		return: [int]
	] gdi32.dll "CreateBitmap"

	mask: create-bitmap 16 16 1 1 head insert/dup #{} to-char 0 16 * 16
	
	create-icon: func [
		img [image!]
		/local hbitmap result ii
	][
		if any [img/size/x <> 16 img/size/y <> 16][
			img: draw make image! [16x16 0.0.0.255] [image img 0x0 16x16]
		]
		hbitmap: create-dib img
		ii: make struct! icon-info-def reduce [to-char 1 0 0 mask hbitmap]
		result: create-icon-indirect ii
		delete-object hbitmap
		free ii
		return result
	]
	
	;-----------------------
	
	NIM_ADD: 0
	NIM_MODIFY:	1
	NIM_DELETE:	2
	NIM_SETFOCUS: 3
	NIM_SETVERSION: 4
	
	NIF_MESSAGE: 1
	NIF_ICON: 2
	NIF_TIP: 4
	NIF_STATE: 8
	NIF_INFO: 16
	NIF_GUID: 32
	
	NIS_HIDDEN: 1
	NIS_SHAREDICON: 2
	
	NIIF_NONE: 0
	NIIF_INFO: 1
	NIIF_WARNING: 2
	NIIF_ERROR: 3
	NIIF_ICON_MASK: 15
	NIIF_NOSOUND: 16

	WM_CREATE: 1
	WM_DESTROY: 2
	WM_CLOSE: 16
	WM_QUIT: 18	
	WM_APP: 32768
	WM_TRAY: WM_APP
	
	SWM_ITEM: WM_APP + 17

	WM_LBUTTONDOWN: 513
	WM_LBUTTONDBLCLK: 515
	WM_RBUTTONDOWN: 516
	WM_RBUTTONDBLCLK: 518
	WM_CONTEXTMENU: 123

	MF_GRAYED: 1
	MF_CHECKED: 8	
	MF_POPUP: 16
	MF_BYPOSITION: 1024
	MF_SEPARATOR: 2048
	
	TPM_BOTTOMALIGN: 32
	TPM_NONOTIFY: 128
	TPM_RETURNCMD: 256
	
	WH_KEYBOARD: 2
	WH_CALLWNDPROC: 4
	WH_MOUSE: 7
	WH_MSGFILTER: -1
	WH_SHELL: 10
	WH_GETMESSAGE: 3
	WH_CALLWNDPROCRET: 12
	
	HC_ACTION: 0
	
	msg-def: [
		lParam [int]
		wParam [long]
		message [int]
		hwnd [int]
	]
	
	point-def: [
		x [long]
		y [long]
	]
	
	get-thread: make routine! [
		return: [int]
	] kernel32.dll "GetCurrentThreadId" 

	make-windows-hook-def: func [
		cb [word!]
	][
		return make routine! compose/deep [
			idHook [int]
			lpfn [(cb) [int int struct! [(msg-def)] return: [int]]]
			hMod [int]
			dwThreadId [int]
			return: [int]
		] user32.dll "SetWindowsHookExA"
	]
	
	if error? try [
		set-windows-hook: make-windows-hook-def	'callback
	][
		set-windows-hook: make-windows-hook-def	'callback!
	]
	
	call-next-hook: make routine! [
		hhk [int]
		nCode [int]
		wParam [int]
		lParam [int]
		return: [int]
	] user32.dll "CallNextHookEx"
	
	unhook-windows-hook: make routine! [
		hhk [int]
		return: [int]
	] user32.dll "UnhookWindowsHookEx"
	
	get-cursor-pos: make routine! compose/deep [
		lpPoint [struct! [(point-def)]]
		return: [int]
	] user32.dll "GetCursorPos"
	
	set-foreground-window: make routine! [
		hwnd [int]
		return: [int]
	] user32.dll "SetForegroundWindow"
	
	create-popup-menu: make routine! [
		return: [int]
	] user32.dll "CreatePopupMenu"
	
	destroy-menu: make routine! [
		hMenu [int]
		return: [int]
	] user32.dll "DestroyMenu"
	
	insert-menu: make routine! [
		hMenu [int]
		uPosition [int]
		uFlags [int]
		uIDNewItem [int]
		lpNewItem [string!]
		return: [int]
	] user32.dll "InsertMenuA"
	
	track-popup-menu: make routine! [
		hMenu [int]
		uFlags [int]
		x [int]
		y [int]
		nReserved [int]
		hWnd [int]
		prcRect [int]
		return: [int]
	] user32.dll "TrackPopupMenu"
	
	load-icon: make routine! [
		hInstance [int]
		lpIconName [int]
		return: [int]
	] user32.dll "LoadIconA"
	
	destroy-icon: make routine! [
		hIcon [int]
	] user32.dll "DestroyIcon"
	
	findwindow: make routine! [
		class [int]
		name [string!]
		return: [int]
	] user32.dll "FindWindowA"
	
	NOTIFYICONDATA-spec: compose [
		cbSize [int]
		hWnd [int]
		uID [int]
		uFlags [int]
		uCallbackMessage [int]
		hIcon [int]
		(make-char-array "szTip" 64)
	]
	
	shell-notify-icon: make routine! compose/deep [
		dwMessage [int]
		lpdata [struct! [(NOTIFYICONDATA-spec)]]
		return: [int]
	] shell32.dll "Shell_NotifyIcon"
	
	proc: func [nCode [integer!] wParam [integer!] lParam [struct!] /local tray err][
		if nCode = HC_ACTION [
			if find close-events lParam/message [
				unhook
				foreach [msgid tray] trays [
					shell-notify-icon NIM_DELETE tray/NOTIFYICONDATA
				]
			]

			if tray: select trays lParam/message [
				if any [
					lParam/lParam = WM_RBUTTONDOWN
					lParam/lParam = WM_CONTEXTMENU
				][
					unhook
					tray/on-alt-click
					if tray/menu [
						if error? err: try [tray/show-menu][print ["show-menu error" newline mold disarm err] halt]
					]
					set-hook
				]
				if lParam/lParam = WM_LBUTTONDOWN [
					tray/on-click
				]
				if lParam/lParam = WM_LBUTTONDBLCLK [
					tray/on-doubleclick
				]
				if lParam/lParam = WM_RBUTTONDBLCLK [
					tray/on-alt-doubleclick
				]

			]
		]
		call-next-hook hook nCode wParam lParam
	]

	set-hook: has [thread][
		if not hook [
			thread: get-thread
			hook: set-windows-hook WH_CALLWNDPROC :proc 0 thread
		]
	]
	
	unhook: does [
		if hook [
			unhook-windows-hook hook
			hook: none
		]
	]

	set 'remove-tray func [
		tray [object!]
		/local tmp
	][
		if tmp: find trays tray [
			shell-notify-icon NIM_DELETE tray/NOTIFYICONDATA
			insert free-tray-ids tray/NOTIFYICONDATA/uCallbackMessage
			free tray/NOTIFYICONDATA
			remove/part back tmp 2
			return true
		]
		return false
	]

	set 'add-tray func [
		tray-tip [string!]
		tray-icon [image! integer!]
		/local result
	][
		if empty? free-tray-ids [make error! "maximum number of trays exceeded"]
		set-hook 
		result: context [
		
			;public stuff
			on-click: none
			on-alt-click: none
			on-doubleclick: none
			on-alt-doubleclick: none
			
			;private stuff
			NOTIFYICONDATA: make struct! NOTIFYICONDATA-spec join [0 0 0 0 0 0] join string-to-chars/length tray-tip 63 to-char 0 
			tip: tray-tip
			icon: tray-icon
			menu: none
			items: copy []
			selected-id: none

			get-tip: does [
				 first parse/all to-string at third NOTIFYICONDATA 25 "^@"
			]
						
			set-tip: func [
				tray-tip [string!]
			][
				tray-tip: copy/part tray-tip 63
				clear at third NOTIFYICONDATA 25
				change/part at third NOTIFYICONDATA 25 tray-tip length? tray-tip

				NOTIFYICONDATA/hIcon: either image? icon [create-icon icon][icon]

				shell-notify-icon NIM_MODIFY NOTIFYICONDATA  

				destroy-icon NOTIFYICONDATA/hIcon
				NOTIFYICONDATA/hIcon: 0 
			]
			
			set-icon: func [
				tray-icon [image! integer!]
			][
				icon: tray-icon
				NOTIFYICONDATA/hIcon: either image? icon [create-icon icon][icon]
	
				shell-notify-icon NIM_MODIFY NOTIFYICONDATA
	
				destroy-icon NOTIFYICONDATA/hIcon
				NOTIFYICONDATA/hIcon: 0 
			]
			
			selected: does [
				second find items selected-id
			]

			set-menu: func [
				blk [block!]
			][
				menu: blk
			]

			insert-item: func [
				path [string!]
				item [block!]
				/local data
			][
				parse-items
				if data: find items path [
					insert data/2 item
				]
			]

			remove-item: func [
				path [string!]
				/local data
			][
				parse-items
				if data: find items path [
					remove/part data/2 data/3
				]
			]
			
			toggle-item: func [
				path [string!]
				keyword [word!]
				/local data tmp
			][
				parse-items
				if data: find items path [
					either tmp: find/part data/2 keyword data/3 [
						remove tmp
					][
						insert at data/2 data/3 + 1 keyword
					]
				]
			]

			parse-items: has [
				rules lab sub-menu checked? grayed? mark mark2 idx path
			][
				idx: 0
				path: []
				clear items
				parse menu rules: [
					some [
						(grayed?: checked?: false)
						mark: set lab string! block! opt ['checked (checked?: true)] opt ['grayed (grayed?: true)] mark2: (
							idx: idx + 1
							insert tail items reduce [SWM_ITEM	replace/all reform [path idx] " " "." mark (index? mark2) - (index? mark)]
							SWM_ITEM: SWM_ITEM + 1
						)
						| 'bar
						| mark: 'sub set lab string! set sub-menu block! mark2:(
							idx: idx + 1
							insert tail items reduce [SWM_ITEM	replace/all reform [path idx] " " "." mark (index? mark2) - (index? mark)]
							SWM_ITEM: SWM_ITEM + 1
							insert tail path idx
							idx: 0
							parse sub-menu rules
							idx: last path
							remove back tail path
						)
					]
				]
			]

			show-menu: has [
				menu-id menus actions rules lab act sub-menu stack checked? grayed? mark mark2 idx path
			][
			
				get-cursor-pos pnt

				idx: 0
				path: []
				menus: copy []
				actions: copy []
				stack: copy []
				clear items
				if not menu-id: create-popup-menu [
					make error! "Cannot create tray menu"
				]
				insert tail menus menu-id
			
				parse menu rules: [
					some [
						(grayed?: checked?: false)
						mark: set lab string! set act block! opt ['checked (checked?: true)] opt ['grayed (grayed?: true)] mark2: (
							idx: idx + 1
							insert-menu menu-id -1 MF_BYPOSITION or (either checked? [MF_CHECKED][0]) or (either grayed? [MF_GRAYED][0])  SWM_ITEM lab
							insert tail actions reduce [SWM_ITEM act]
							insert tail items reduce [SWM_ITEM	replace/all reform [path idx] " " "." mark (index? mark2) - (index? mark)]
							SWM_ITEM: SWM_ITEM + 1
						)
						| 'bar (
							insert-menu menu-id -1 MF_BYPOSITION or MF_SEPARATOR 0 ""
						)
						| mark: 'sub set lab string! set sub-menu block! mark2:(
							idx: idx + 1
							insert tail items reduce [SWM_ITEM	replace/all reform [path idx] " " "." mark (index? mark2) - (index? mark)]
							SWM_ITEM: SWM_ITEM + 1
							insert/only tail stack reduce [idx menu-id]
							insert tail path idx
														
							insert tail menus menu-id: create-popup-menu
							insert-menu second last stack -1 MF_BYPOSITION or MF_POPUP menu-id lab
							
							idx: 0
							parse sub-menu rules
							idx: first last stack
							menu-id: second last stack
							remove back tail stack
							remove back tail path
						)
					]
				]
				if not empty? menus [
					set-foreground-window NOTIFYICONDATA/hWnd
					switch selected-id: track-popup-menu menus/1 TPM_BOTTOMALIGN or TPM_RETURNCMD or TPM_NONOTIFY pnt/x pnt/y 0 NOTIFYICONDATA/hWnd 0 actions 
					foreach m menus [destroy-menu m]
				]
			]
			
			init: does [
				id: id + 1
				
				NOTIFYICONDATA/cbSize: length? third NOTIFYICONDATA
				NOTIFYICONDATA/hWnd: win
				NOTIFYICONDATA/uID: id
				NOTIFYICONDATA/uFlags: NIF_ICON or NIF_MESSAGE or NIF_TIP
				NOTIFYICONDATA/hIcon: either image? icon [create-icon icon][icon] 
				NOTIFYICONDATA/uCallbackMessage: first free-tray-ids
;				WM_TRAY: WM_TRAY + 1
				remove free-tray-ids
	
				shell-notify-icon NIM_ADD NOTIFYICONDATA
				
				destroy-icon NOTIFYICONDATA/hIcon
				NOTIFYICONDATA/hIcon: 0 
			]		
		]
		result/init
		insert tail trays reduce [result/NOTIFYICONDATA/uCallbackMessage result]
		return result
	]

	;public stuff
	close-to-tray?: true
	minimize-to-tray?: false
	default-icons: [
		app 32512
		hand 32513
		question 32514
		exclamation 32515
		asterisk 32516
		winlogo 32517
	]


	;private stuff
	id: 1
	trays: copy []
	hook: none
	pnt: make struct! point-def none
	close-events: reduce [WM_QUIT WM_DESTROY]
	free-tray-ids: copy []
	
	;init stuff
	repeat n 16 [
		insert tail free-tray-ids WM_TRAY
		WM_TRAY: WM_TRAY + 1
	]
	win: create-window 512 "REBOL" "" 0 0 0 0 0 0 0 0 0

	any [
		system/view/screen-face/feel
		system/view/screen-face/feel: make object! [
			redraw: none
			detect: func [face event][
				foreach evt-func event-funcs [
					if not event? (evt-func: evt-func face event) [
						return either evt-func [event] [none]
					]
				]
				event
			]
			over: none
			engage: none
			event-funcs: []
		]
	]

	insert-event-func func [f e][
		if any [
			all [
				ctx-tray/close-to-tray?
				e/type = 'close
			]
			all [
				ctx-tray/minimize-to-tray?
				e/type = 'minimize
			]
		][
			unview/only e/face
			do-events
			return none
		]
		e
	]

	;little wrapper for SHOW
	use [show][
		show: get in system/words 'show
		system/words/show: func [
			"Display a face or block of faces."
			face [object! block!]
		][
			either any [
				face = system/view/screen-face
				all [
					block? face 
					find face system/view/screen-face
				]
			][
				unhook
				show face
				set-hook
			][
				show face
			]
		]
	]
	
	;little patch to quitting functions
	use [quit][
		quit: get in system/words 'quit
		system/words/q: system/words/quit: func [
			"Stops evaluation and exits the interpreter."
			/return "Returns a value (to OS command shell)"
			value [integer!]
		][
			unhook
			foreach [msgid tray] trays [
				shell-notify-icon NIM_DELETE tray/NOTIFYICONDATA
			]
			either return [
				quit/return value
			][
				quit
			]
		]
	]
];end ctx-tray
