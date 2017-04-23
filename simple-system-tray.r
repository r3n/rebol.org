REBOL [
   Author: {Izkata}
   Email: Izkata@Comcast.net
   File: %simple-system-tray.r
   Date: 5-Jul-2005
   Title: {Simple System Tray}
   Purpose: {
      After learning Rebol 1.3 could place itself in the System Tray on Windows,
      and after finding Graham's example, I decided to make a slightly simpler
      version of the System Tray dialect....

      Since it's based on Graham's example, it may well be missing stuff...

      Feel free to email me anything about it, I'll likely edit and repost it!   (^.-)
   }
   Example: {
      -->I am a dolt<--  (Forgot to include how to use it!)
      Pretty simple, really, hence the reason I made it:

      ToSystemTray [
         {I am the little help-bubble that appears while the mouse hovers over the icon} [
            {Item 1 (Also done when icon left-clicked on)} [   alert [{I do stuff} {riight..}]   ]
            bar
            {Item 2 - Remove from System Tray} [RemoveSystemTray]
            {Quit} [quit]
            bar
            bar
            bar
         ]
      ]

      And, of course, there's no length requirement (that I know of!) for the number
      of items in the list - and no specifiied order.
   }
   Library: [
      level: 'intermediate
      platform: [windows win]  ;Is the system tray anywhere else?
      type: [dialect tool]
      domain: [dialects ui parse]
      tested-under: {Windows XP Home, Rebol/View 1.3.1}
      support: none
      license: none
      see-also: none
   ]
]

MySysTray: make object! [
   Defines: none
   Tray: none

   Parse-Systray: func [Systray][
      Defines: copy []
      Tray: compose/deep [add main [help: (first Systray) menu: []]]
      parse second Systray [
         some [
            'bar (append Tray/3/4 'bar) |
            set Str string! set Blk block! (
               append Tray/3/4 compose [(to-word rejoin [{Defines} 1 + length? Defines {:}]) (Str)]
               append Defines compose/only [(to-word join copy {Defines} 1 + length? Defines) (Blk)]
            )
         ]
      ]
      return Tray
   ]

   set 'ToSystemTray func [
      {Send REBOL to the System Tray}
      Systray [block!]
      /return {Return immediately}
   ][
      Tray: Parse-Systray Systray
      system/ports/system: open [scheme: 'system]
      append system/ports/wait-list system/ports/system

      system/ports/system/awake: func [port /local Which][
         if all [
            r: pick port 1
            r/1 = 'tray
         ][
            if r/3 = 'menu [do select Defines r/4]
            if r/3 = 'activate [do second Defines]
         ]
         return false
      ]
      set-modes system/ports/system compose/only [tray: (load mold Tray)]
      if not return [do-events]
   ]

   set 'RemoveSystemTray func [{Remove REBOL from the System Tray}][
      remove find system/ports/wait-list system/ports/system
      close system/ports/system
      system/ports/system: open [scheme: 'system]
   ]
]