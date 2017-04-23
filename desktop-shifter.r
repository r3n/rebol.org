REBOL [
   File: %desktop-shifter.r
   Name: [{Daniel Sirotzke} {Izkata}]
   Version: 1.0
   Date: 2-Feb-2008
   Title: "Desktop Shifter"
   Notes: {
      Please note that this script uses 'call with the terminal command gconftool-2, so
      I'm fairly certain this script will only work under Gnome on Linux.

      This was also an experiment of mine in putting the daemon, client, and datafile all
      in a single file, as well as using the datafile to store the port number - just in case
      another program was using it, so that the client knows where to connect to.

      To start the daemon, "Serve" must be used as an argument:
      Command Line/Run Command:
         $  ./rebol desktop-shifter.r Serve
      From Rebol:
         >> do/args %desktop-shifter.r {Serve}

      Also, the Client will throw a script error if the daemon is not running on the port last
      saved in the datafile.
   }
   Warnings: {
      Because of save/load working the way they do, all comments vanish from the file after
      every use!  That's why I'm using 'Comment instead of semicolons for comments!

      The Data block must always be the second thing in the file, this header being the first.

      If you want a #!/path/to/rebol line at the beginning, you'll have to add it yourself.  There's
      a comment that tells you where to add it - I've left mine there as an example.
   }
   Purpose: {
      To change the desktop wallpaper at specified intervals.

      There's a modifiable default time that a wallpaper will stay before switching.
      Each wallpaper has separate settings for:
         *Stretched versus Centered
         *Solid color versus Top/Bottom Gradient versus Left/Right gradient background
         *The two colors that can be chosen
         *A box for the time the wallpaper stays up before shifting - it says "Default" if it's
            using the default setting
   }
   Library: [
      level: 'advanced
      platform: [linux]
      type: [tool]
      domain: [gui user-interface vid]
      tested-under: [
         {Rebol/View 2.7.5.4.2} {Ubuntu 7.10 (Gnome Desktop Environment)}
      ]
      support: none
      license: none
      see-also: none
   ]
]

[8998 
    0:10 true
] 

Comment {
   The above block is the datafile.  The following two functions save and load from it:

   (Place the #!/path/to/rebol line here, too:)
}
PathToRebol: {#!/home/izkata/Scripting/rebol -s}

do DataLoad: func [/SkipPort /local Data] [
    Data: first load %desktop-shifter.r 
    if not SkipPort [set 'Port first Data] 
    set 'WaitTime second Data 
    set 'Randomize get third Data 
    set 'Wallpapers copy/deep next next next Data 
    repeat X length? Wallpapers [
        if word? Wallpapers/:X/6 [remove skip Wallpapers/:X 5] 
        if none? Wallpapers/:X/6 [remove skip Wallpapers/:X 5]
    ]
] 
DataSave: func [/local AllFile TMP] [
    AllFile: load/header %desktop-shifter.r 
    AllFile/2: compose [(Port) (WaitTime) (Randomize) (Wallpapers)] 
    save %desktop-shifter.r  AllFile 
    TMP:  read %desktop-shifter.r
    replace TMP {make object!} join join copy PathToRebol {^/} {REBOL}
    write %desktop-shifter.r  TMP
] 

Comment {Due to the weirdness of the way background color is saved...}
EncodeColor: func [Color [tuple!]] [
    system/options/binary-base: 16 
    return rejoin [
        "#" 
        lowercase trim/with mold to-binary compose [(Color/1)] "#{}" 
        lowercase trim/with mold to-binary compose [(Color/1)] "#{}" 
        lowercase trim/with mold to-binary compose [(Color/2)] "#{}" 
        lowercase trim/with mold to-binary compose [(Color/2)] "#{}" 
        lowercase trim/with mold to-binary compose [(Color/3)] "#{}" 
        lowercase trim/with mold to-binary compose [(Color/3)] "#{}"
    ]
] 
random/seed now 
if system/script/args = "Serve" [
    Point: 1 
    Port: 8998 
    while [error? try [set 'Listen open join tcp://: Port]] [Port: Port + 1] 
    DataLoad/SkipPort 
    DataSave 
    forever [
        Skipit: false 
        call rejoin [
            {gconftool-2 --type string --set /desktop/gnome/background/} 
            "picture_filename " Wallpapers/:Point/1 ";" 
            {gconftool-2 --type string --set /desktop/gnome/background/} 
            "picture_options " Wallpapers/:Point/2 ";" 
            {gconftool-2 --type string --set /desktop/gnome/background/} 
            "color_shading_type " Wallpapers/:Point/3 ";" 
            {gconftool-2 --type string --set /desktop/gnome/background/} 
            "primary_color '" EncodeColor Wallpapers/:Point/4 "';" 
            {gconftool-2 --type string --set /desktop/gnome/background/} 
            "secondary_color '" EncodeColor Wallpapers/:Point/5 "'"
        ] 
        Active: wait compose [
            Listen 
            (either none? Wallpapers/:Point/6 [WaitTime] [Wallpapers/:Point/6])
        ] 
        if Active = Listen [
            Connection: first Listen 
            Data: copy "" 
Comment {
   Reload and SetWallpaper are both used by the Client side.  Shutdown was
   something I needed every once in a while during testing.
}
            while [not find Data "||"] [append Data first Connection] 
            if find Data "Reload" [DataLoad/SkipPort] 
            if find Data "Shutdown" [quit] 
            if find Data "SetWallpaper:" [
                parse Data [thru ":" copy Data to "||"] 
                Point: to-integer Data 
                Skipit: true
            ] 
            close Connection
        ] 
        if not Skipit [
            either not Randomize [Point: 1 + mod Point length? Wallpapers] [
                Point: random length? Wallpapers
            ]
        ]
    ]
] 
stylize/master [
    txt: text white
] 
Comment {
   DisplayWidth used to be 600.  Then I started having trouble seeing the filenames I was
   selecting once I'd gotten that far...  So I moved it here, so it's easier to modify.
}
DisplayWidth: 790 
view/new center-face layout compose/only [
    across origin 10x10 space 0x0 backdrop black 
    box 130x400 with [
        pane: get in layout [
            across origin 0x0 space 0x0 
            btn 130x22 "(q) Quit" #"q" [
                DataSave 
                Comment {close insert open join tcp://localhost: Port "Reload||" } 
                quit
            ] 
            return btn 130x22 "(n) New Wallpaper" #"n" [AddWallpaper] 
            return RandomCheck: check (Randomize) [RandomCheck/data: Randomize: not RandomCheck/data show RandomCheck] 
            txt "Randomized" [RandomCheck/data: Randomize: not RandomCheck/data show RandomCheck] 
            return txt "Wait Time: " 70x22 WaitTimeBox: field 60x22 (mold WaitTime)
        ] 'pane
    ] 
    box (to-pair compose [(DisplayWidth) 400]) with (
        compose/deep [
            pane: get in layout [
                origin 0x0 
                DisplayList: box (to-pair compose [(DisplayWidth) 4000]) with [pane: copy []]
            ] 'pane
        ]
    ) 
    Scroller: scroller 10x400 [
        DisplayList/offset: to-pair compose [0 (negate Scroller/data * DisplayList/pane/1/size/y)
        ] 
        show DisplayList
    ]
] 
StretchOrCenter: func [Count /local Chosen] [
    DataLoad 
    view/new center-face layout [
        origin 20x20 space 0x3 backdrop black 
        btn 100 "Centered" [
            Wallpapers/(Count + 1)/2: copy "centered" 
            unview 
            DataSave 
            LoadSettings
        ] 
        btn 100 "Stretched" [
            Wallpapers/(Count + 1)/2: copy "stretched" 
            unview 
            DataSave 
            LoadSettings
        ]
    ] 
    do-events
] 
GradientStyle: func [/Ask Count /Niceify Ugly /Datafilize /local Chosen] [
    if Ask [
        DataLoad 
        view/new center-face layout [
            origin 20x20 space 0x0 backdrop black 
            btn "Solid Color" [
                Wallpapers/(Count + 1)/3: copy "solid" 
                unview 
                DataSave 
                LoadSettings
            ] 
            btn "Top/Bottom Gradient" [
                Wallpapers/(Count + 1)/3: copy "vertical-gradient" 
                unview 
                DataSave 
                LoadSettings
            ] 
            btn "Left/Right Gradient" [
                Wallpapers/(Count + 1)/3: copy "horizontal-gradient" 
                unview 
                DataSave 
                LoadSettings
            ]
        ] 
        do-events
    ] 
    if Niceify [
        if Ugly = "solid" [return "Solid Color"] 
        if Ugly = "vertical-gradient" [return "Top/Bottom Gradient"] 
        if Ugly = "horizontal-gradient" [return "Left/Right Gradient"]
    ]
] 
ColorAsk: func [Count /One /Two] [
    DataLoad 
    if One [Wallpapers/(Count + 1)/4: request-color] 
    if Two [Wallpapers/(Count + 1)/5: request-color] 
    DataSave 
    LoadSettings
] 
Comment {
   If any of my functions drive you insane, I'm fairly certain it would be this one...

   It's dynamically generating the list that's displayed to you when modifying the settings.
   Every time you change anything, the data is saved and the screen re-generated.
}
do LoadSettings: does [
    DataLoad 
    List: copy/deep [
        across origin 0x0 space 0x0 backdrop black
    ] 
    Count: 0 
    foreach Wallpaper Wallpapers [
        append List compose/deep [
            at (to-pair compose [0 (Count * 50)]) 
            txt font-size 12 (rejoin [(Count + 1) ".   " copy Wallpaper/1]) 
            at (to-pair compose [30 (Count * 50 + 20)]) 
            btn 80 (uppercase/part copy Wallpaper/2 1) [StretchOrCenter (Count)] 
            at (to-pair compose [112 (Count * 50 + 20)]) 
            btn 120 (GradientStyle/Niceify Wallpaper/3) [GradientStyle/Ask (Count)] 
            at (to-pair compose [234 (Count * 50 + 20)]) 
            box 22x22 (Wallpaper/4) [ColorAsk/One (Count)] with [
                edge: make edge [color: gray size: 2x2]
            ] 
            at (to-pair compose [260 (Count * 50 + 20)]) 
            box 22x22 (Wallpaper/5) [ColorAsk/Two (Count)] with [
                edge: make edge [color: gray size: 2x2]
            ] 
            at (to-pair compose [286 (Count * 50 + 20)]) 
            field 70x22 (
                either none? Wallpaper/6 ["Default"] [mold Wallpaper/6]
            ) [
                either error? try [to-time face/text] [
                    probe first skip Wallpapers/:Count 5 
                    remove skip Wallpapers/:Count 5 
                    DataSave 
                    LoadSettings
                ] [
                    Count: (Count) + 1 
                    either none! = type? Wallpapers/:Count/6 [
                        append Wallpapers/:Count to-time face/text
                    ] [
                        Wallpapers/:Count/6: to-time face/text
                    ] 
                    DataSave 
                    LoadSettings
                ]
            ] 
            at (to-pair compose [(DisplayWidth - 270) (Count * 50)]) 
            btn green bold 90x48 "Make^/Current" [
                close insert open join tcp://localhost: Port rejoin [
                    "SetWallpaper:" (Count + 1) "||"
                ]
            ] 
            at (to-pair compose [(DisplayWidth - 180) (Count * 50)]) 
            btn blue bold 90x24 "Move Up" [MoveUp (Count)] 
            at (to-pair compose [(DisplayWidth - 180) (Count * 50 + 24)]) 
            btn blue bold 90x24 "Move Down" [MoveDown (Count)] 
            at (to-pair compose [(DisplayWidth - 90) (Count * 50)]) 
            btn red bold 90x48 "Remove" [RemoveWallpaper (Count)]
        ] 
        Count: Count + 1
    ] 
    DisplayList/pane: get in layout List 'pane 
    show DisplayList
] 
MoveUp: func [Num /local Wallp] [
    if Num = 0 [return] 
    DataLoad 
    Wallp: copy/deep first skip Wallpapers (Num) 
    remove skip Wallpapers (Num) 
    insert/only skip Wallpapers (Num - 1) Wallp 
    DataSave 
    LoadSettings
] 
MoveDown: func [Num /local Wallp] [
    DataLoad 
    if Num = length? Wallpapers [return] 
    Wallp: copy first skip Wallpapers (Num) 
    remove skip Wallpapers (Num) 
    insert/only skip Wallpapers (Num + 1) Wallp 
    DataSave 
    LoadSettings
] 
RemoveWallpaper: func [Num] [
    DataLoad 
    remove skip Wallpapers (Num) 
    DataSave 
    LoadSettings
] 
AddWallpaper: func [/local NewFile] [
    DataLoad 
    if none? NewFile: request-file/keep/only [return] 
    append/only Wallpapers compose [
        (to-local-file NewFile) 
        "centered" "solid" 0.0.0 0.0.0
    ] 
    DataSave 
    close insert open join tcp://localhost: Port "Reload||" 
    LoadSettings
] 
do-events
