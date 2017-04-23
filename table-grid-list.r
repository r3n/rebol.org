REBOL [
    title: "Resizeable Table/Grid/Multi-column List Widget Example"
    date: 13-Jul-2011 
    file: %table-grid-list.r
    author: Nick Antonaccio 
    purpose: {
        One of the greatest things about REBOL/View is the built in GUI dialect
            ("VID").  It's great for building simple GUI layouts quickly and
            easily, but the native list widget can be confusing for newcomers.
        THIS EXAMPLE IS A FULL FEATURED TABLE/GRID/LIST WIDGET FOR VID GUIs.
            KEYS:  INSERT  DELETE  ARROWS  PAGE UP/DOWN  - +  F1  CTRL+R M S O F U
            MOUSE: click header to sort, RIGHT-CLICK/DRAG to RESIZE, click to edit
        Columns can be SORTED and *RESIZED* by clicking the headers.  Data can be
            EDITED by clicking cells.  Rows can be added, removed, and moved with
            the INSERT, DELETE, and CTRL+M keys.  Data blocks can be loaded and
            saved to/from files, in both "flattened" and sub-block formats, using
            the CTRL+S CTRL+L CTRL+F and CTRL+U keys.  Column format (color, font,
            etc.) can be easily specified in the column code.  Alternate rows are
            automatically shaded, and mousing-over a row highlights the current
            row.  Up and down arrow keys, and page up/down keys can be used to
            scroll.  The mouse can also be used to scroll (with the scroll bar).
            Data can be reverted to the last saved change (by clicking the "r"
            button in the GUI).  The entire grid can be resized to any percentage,
            with automatic sizing of columns (use the "+" and "-" keys to resize
            this example).  The entire grid size will also automatically adjust to
            fit a resized screen.  Press [F1] for help.
        The compressed code adds all necessary functionality to VID's native list
            widget - paste it as-is into your script (uncompress to see how it
            works, or to make changes).
        Keep the variables and naming coventions as they are in the GUI code (the
            variables gui, gui-size, t-size, x, y, li, list-size, sl, sl-size,
            s-pos, and my-supply need to be changed in the compressed code if ever
            changed in the GUI layout).
        You can add as many columns as needed to your own GUI grids:
            Headers must be labeled h1, h2, h3...  Put DIFFERENT TEXT in each.
            Columns must be labeled col1, col2, col3...  Format each as needed.
        "header-block" must be edited to contain each of the header labels (i.e.,
            if your table has headers h1, h2, and h3, the header block should be
            [h1/text h2/text h3/text]).
        "x" holds the data displayed in the table - you can save, load, and
            manipulate it directly, then refresh the display (try the CTRL+S and
            CTRL+O keys in the GUI example to save and load the grid data).
        Rows of data are each stored in a SEPARATE block within the "x" block.
            To "flatten" the block (i.e., to save the grid data in one large
            block, without sub-blocks), try the CTRL+F keys in this GUI example.
            To load a flattened block, try the CTRL+U keys.
        "y" holds a copy of the original data (click the "r" button in the GUI
            example to reload it and refresh the display to its last saved state).
        "feel editstyle" is used to make a column EDITABLE.  Click any cell in the
            GUI example to edit.  These changes are made directly to the "x" block
            and then the GUI is refreshed.
        "feel slidestyle" is used to make a column RESIZABLE (RIGHT CLICK/drag the 
            header to expand or contract any column width).  This function also
            contains the "sort-column" function, which allows the user to sort
            columns of data by clicking the header.
        "sort-column" sorts the selected column number.  Each call to this
            function alternates between ascending and descending sort order.
        "key-scroll" enables keyboard scrolling (use the up/down cursor keys, and
            page up/down keys in this GUI example).
        "add-line" adds a row of data to the grid, at a chosen index (use the
            [INSERT] key in this GUI example).
        "remove-line" removes a selected row of data (use the [DELETE] key in this
            GUI example).
        "move-line" moves a row of data from one selected index to another (use
            the CTRL+M keys in this GUI example to move rows).
        "resize-fit" resizes the table to fit the GUI, with equally sized columns.
            The compressed code contains an insert-event-function which 
            automatically resizes the table to fit the GUI window, when resized.
            Press CTRL+R in this GUI example to execute the function manually.
        "resize-grid" resizes the table a given percentage (press the "+" and "-"
            keys in this GUI example to see it work).
        Notice that the majority of user-editable code in the GUI consists of
            headers, column names and formatting, and "key" widgets to run the
            desired functions.  In this example GUI, the user presses keystroke
            combinations to activate the desired features, but those functions
            could also be added to the action blocks of buttons, and/or executed
            by any other typical trigger.
    }
]

notify {
    Be sure to RIGHT-CLICK AND DRAG headers to RESIZE COLUMNS.
    Click headers to sort columns.
    You can also insert, delete, and move rows, click cells to edit,
    resize the grid, scroll with keyboard and mouse, save and load
    all data to/from files, and more.  Create your own tables with
    all the same features by editing just a few lines.
    Press F1 for more info.
}

x: copy []             ; The data shown in the grid is labeled "x", by default
random/seed now/time   ; Generate 5000 rows of random data:
repeat i 5000 [
    append/only x reduce [
        random "abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*(),.';" 
        form random 1000 
        form random 1000 
        random "abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*(),.';"
        form i
    ]                  ; all data is stored in string format
]  y: copy x           ; "y" holds a backup copy of the original grid data

header-block: [h1/text h2/text h3/text h4/text h5/text] ; EDITED FOR 5 COLUMNS

do decompress list-widget-functions: #{
789CAD574B6F1B3710BEFB570CD443B50D362B1971806EFD407F402EB90A3AD0
DA59890D45AEB95C5B4AE0FFDE21B9A448594214B7060C899C996F1E9C977AA5
4DB95262D8CA1ADA41AE60D17214CD121657407FC8CD0635F4964DE906750D52
99E43CF2D93F7B59ADD4B6631A6137A2317824AC2933C0C02117700FF6F8381E
974E7EF90E9CDB9338E03EFB8D7A01C1AF9657DF705FF62BAD84080EFA53C9B6
6A902628EECB4EF5B5FF800F90F13806DE8E44325FA05C9BCD03EC0A42F382F1
6A9973DFC22CF2CC3CAD1755C30C0BCAAA0C2F337FFCD20BF24363CFBF63B9D6
BC098E74A857280D5B63F0623DF0D2B211F6BE37B8AD9E39BE54E40CA22C5BB6
C2AA6312AB796599E02F28613EDBCD9CA8E0BD71B2D5BC4E0FF0071CF41C715E
D75163754D607FDE380633DAA029780D79978025CE6E9051FE948F42ADBE15C5
18995192516818D730FF9C6A733C83743E2929F65639F85367B8923D583309D3
7A0A82EDD5609C814E072C7C08978760B6DCD4D028ECDF133E2791BC0A4C632C
AC9FA9D7257C9C17A496354D29B8C4A0941952D299513B97CDAE06A34A4E4EAC
A9B4343E0D48280677A632DC08AC1A6CD9200C4CFE6E1A786682E84045A0294B
7EAB27B1845AA5B729927AD6E5EA90C85613DCD9CCD468062D7D5E4A7C293D64
0D2BD5ED61E1EF090C38CCCFBC1C1116ACEB905EFA00E0E52793B118648F54D2
EEC96CC9EE9C0145CA7F2858FB385BF58CFF57A0BE12AE51E041EB09FCB71811
C1E801E1F63E28A5CF7F1497B0987CF52A60021DA774F35EC2E461B2CC31BC29
592452F7DF38EF849468CA5FF2FB8BD5D16AB5FDA5E4B04F72819A11DEC63501
A7E04CA701C1C6AE004A9D6930DDDD1497C7F34B1ECD08F336A236641519E343
1A188BE84D3A0FB6340E86AE13FB3A1F71F88CF281F296FA3DCD405BEB341615
CDBB970D37B6C1A677D79F661FDDFFCD8DB7C0C9D5A3F807DFD9838352497C80
A73A3892EAB021AD43B500EEB88971199F85A276C2A8EB19299F250638A21F2B
AB38B312154EF7934D37DC51147AC11B0AF65E600C835C53838F4B008D594C87
32B73777F0FBD0D1383B2C0D1EF0816630D5BFC666A0C69BB607689DFE65C459
0DBE3DD7174AA6060459B8BF8353BD284F8AD46A264CD9A817CAAADE30673C2D
2F3560A5DAB6C7C43C6B4D49F930DAF823125CE1F6DF6923B0EFDC724D992A71
CD0C1532F53E8F488D3EC12F3261CA3BF71C61C4E667920CE8991445791ADC2E
A2ECA9DB4B102833E7C5E8F3314E4EBB1CED944D2985BE9F44DA9CB5EA1CE59C
4DC7FCC1A2D3F7E7EC711D627C94E305EC08C9EE0951F6357ED3D809CB92E510
FC38BCD46BCCE08B659CBE57C8CF27D3DB16E6A984A364CDAE63B21ED21F3286
46E5D644E2B86153F7C0869BAC7950FFD587D6A18E1AC75401B38B60E868D4EC
5BD7ABEC34182FEBF12A443E28F3265FDC9A324FDAB1F765F32B0C484F8C83E1
AD937E6B29ED5C30A5579D8C0A1A84FB0EAD5ABF0286EDD2EE94AEE393858E8F
26FACFD74A8750C26C7733BB8A8BE361B926D2E7D98EB6EB9F2DC8EFDABCC3AF
13C87EE6B9B10CF175AC4B57FF0285CB5B342E0E0000
}

svv/vid-face/color: white
view/options center-face gui: layout gui-block: [
    size gui-size  across  space 0x0
    style header button as-pair t-size 20 black white bold
    h1: header "Text1" feel slidestyle  ; EDIT THESE FOR YOUR OWN NEEDS.  EACH
    h2: header "Num1" feel slidestyle   ; HEADER MUST CONTAIN UNIQUE TEXT.
    h3: header "Num2" feel slidestyle   ; YOU CAN HAVE AS MANY OR AS FEW
    h4: header "Text2" feel slidestyle  ; COLUMNS AS NEEDED (ALL RESIZEABLE).
    h5: header "Key" feel slidestyle    ; THEY MUST BE LABELED:  H1, H2, H3...
    h6: button black "r" 17x20 [if true = request "Reset?"[x: copy y show li]]
    return
    li: list list-size [
        style cell text t-size feel editstyle    ; EVERY CELL IS NOW EDITABLE
        across  space 0x0
        col1: cell blue    ; EDIT THE LOOK AND FEEL OF EACH COLUMN AS NEEDED.
        col2: cell         ; COLUMNS MUST BE LABELED:  COL1, COL2, COL3...
        col3: cell red     ; THEY CONTAIN THE *DATA* LABELED BY HEADERS ABOVE.
        col4: cell blue    ; THEY ARE TYPICALLY TEXT FIELDS, BUT CAN BE ANY
        col5: cell         ; OTHER TYPE OF GUI WIDGET DESIRED.
    ] supply my-supply
    sl: scroller sl-size [s-pos: (length? x) * value  show li]
    key keycode [up] [key-scroll -1]         ; EACH OF THESE KEYS DEMONSTRATES
    key keycode [down] [key-scroll 1]        ; A FEATURE.  THESE FUNCTIONS
    key keycode [page-up] [key-scroll -20]   ; COULD ALSO BE ADDED TO THE
    key keycode [page-down] [key-scroll 20]  ; ACTION BLOCKS OF GUI BUTTONS OR
    key keycode [insert] [add-line]          ; OTHER WIDGETS, OR OTHERWISE
    key #"^~" [remove-line]                  ; ACTIVATED...
    key #"^M" [move-line]
    key #"^R" [resize-fit]
    key #"+" [resize-grid 1.333]
    key #"-" [resize-grid .75]
    key #"^S" [save to-file request-file/save x]
    key #"^O" [attempt [y: copy x: copy load request-file/only  show li]]
    key #"^F" [fx: copy [] foreach row x [append fx reduce row]save %f.txt fx]
    key #"^U" [attempt [  ; load a 'flattened' block
        fx: load request-file/only/file %f.txt
        x: copy [] foreach [a b c d e] fx [append/only x reduce [a b c d e]] 
        show li
    ]]
    key keycode [f1] [editor system/script/header/purpose]
] [resize]



; Here's a simpler, typical implementation:


REBOL [title: "Table/Grid/List Widget Example"]

x: copy [] random/seed now/time repeat i 1000 [append/only x reduce [random "abcdef" form random 1000 form i]] y: copy x

header-block: [h1/text h2/text h3/text] 

do decompress list-widget-functions: #{
789CAD574B6F1B3710BEFB570CD443B50D362B1971806EFD407F402EB90A3AD0
DA59890D45AEB95C5B4AE0FFDE21B9A448594214B7060C899C996F1E9C977AA5
4DB95262D8CA1ADA41AE60D17214CD121657407FC8CD0635F4964DE906750D52
99E43CF2D93F7B59ADD4B6631A6137A2317824AC2933C0C02117700FF6F8381E
974E7EF90E9CDB9338E03EFB8D7A01C1AF9657DF705FF62BAD84080EFA53C9B6
6A902628EECB4EF5B5FF800F90F13806DE8E44325FA05C9BCD03EC0A42F382F1
6A9973DFC22CF2CC3CAD1755C30C0BCAAA0C2F337FFCD20BF24363CFBF63B9D6
BC098E74A857280D5B63F0623DF0D2B211F6BE37B8AD9E39BE54E40CA22C5BB6
C2AA6312AB796599E02F28613EDBCD9CA8E0BD71B2D5BC4E0FF0071CF41C715E
D75163754D607FDE380633DAA029780D79978025CE6E9051FE948F42ADBE15C5
18995192516818D730FF9C6A733C83743E2929F65639F85367B8923D583309D3
7A0A82EDD5609C814E072C7C08978760B6DCD4D028ECDF133E2791BC0A4C632C
AC9FA9D7257C9C17A496354D29B8C4A0941952D299513B97CDAE06A34A4E4EAC
A9B4343E0D48280677A632DC08AC1A6CD9200C4CFE6E1A786682E84045A0294B
7EAB27B1845AA5B729927AD6E5EA90C85613DCD9CCD468062D7D5E4A7C293D64
0D2BD5ED61E1EF090C38CCCFBC1C1116ACEB905EFA00E0E52793B118648F54D2
EEC96CC9EE9C0145CA7F2858FB385BF58CFF57A0BE12AE51E041EB09FCB71811
C1E801E1F63E28A5CF7F1497B0987CF52A60021DA774F35EC2E461B2CC31BC29
592452F7DF38EF849468CA5FF2FB8BD5D16AB5FDA5E4B04F72819A11DEC63501
A7E04CA701C1C6AE004A9D6930DDDD1497C7F34B1ECD08F336A236641519E343
1A188BE84D3A0FB6340E86AE13FB3A1F71F88CF281F296FA3DCD405BEB341615
CDBB970D37B6C1A677D79F661FDDFFCD8DB7C0C9D5A3F807DFD9838352497C80
A73A3892EAB021AD43B500EEB88971199F85A276C2A8EB19299F250638A21F2B
AB38B312154EF7934D37DC51147AC11B0AF65E600C835C53838F4B008D594C87
32B73777F0FBD0D1383B2C0D1EF0816630D5BFC666A0C69BB607689DFE65C459
0DBE3DD7174AA6060459B8BF8353BD284F8AD46A264CD9A817CAAADE30673C2D
2F3560A5DAB6C7C43C6B4D49F930DAF823125CE1F6DF6923B0EFDC724D992A71
CD0C1532F53E8F488D3EC12F3261CA3BF71C61C4E667920CE8991445791ADC2E
A2ECA9DB4B102833E7C5E8F3314E4EBB1CED944D2985BE9F44DA9CB5EA1CE59C
4DC7FCC1A2D3F7E7EC711D627C94E305EC08C9EE0951F6357ED3D809CB92E510
FC38BCD46BCCE08B659CBE57C8CF27D3DB16E6A984A364CDAE63B21ED21F3286
46E5D644E2B86153F7C0869BAC7950FFD587D6A18E1AC75401B38B60E868D4EC
5BD7ABEC34182FEBF12A443E28F3265FDC9A324FDAB1F765F32B0C484F8C83E1
AD937E6B29ED5C30A5579D8C0A1A84FB0EAD5ABF0286EDD2EE94AEE393858E8F
26FACFD74A8750C26C7733BB8A8BE361B926D2E7D98EB6EB9F2DC8EFDABCC3AF
13C87EE6B9B10CF175AC4B57FF0285CB5B342E0E0000
}
svv/vid-face/color: white
view/options center-face gui: layout gui-block: [
    size gui-size  across  space 0x0
    style header button as-pair t-size 20 black white bold
    h1: header "Text" feel slidestyle
    h2: header "Num" feel slidestyle
    h3: header "Key" feel slidestyle
    button black "r" 17x20 [if true = request "Reset?"[x: copy y show li]]
    return
    li: list list-size [
        style cell text t-size feel editstyle  across  space 0x0
        col1: cell blue
        col2: cell
        col3: cell red
    ] supply my-supply
    sl: scroller sl-size [s-pos: (length? x) * value  show li]
    key keycode [up] [key-scroll -1]
    key keycode [down] [key-scroll 1]
    key keycode [page-up] [key-scroll -20]
    key keycode [page-down] [key-scroll 20]
    key keycode [insert] [add-line]
    key #"^~" [remove-line]
    key #"^M" [move-line]
    key #"^S" [save to-file request-file/save x]
    key #"^O" [attempt [y: copy x: copy load request-file/only  show li]]
] [resize]
