REBOL [
    title: "Room Poll (HTML Survey Generator for LANs)"
    date: 30-Dec-2013
    file: %room-poll.r
    author:  Nick Antonaccio
    purpose: {
        Demonstrates a useful app created from the formserver.r script. 
        This app generates an HTML form based on user specs (any number of
        check, radio, and text entry items), and starts a server to receive survey
        responses from the audience (they all connect to the LAN server using
        phones or any other Wifi Internet device).  The survey responses are all 
        saved to a user-specified file and an included demo report displays all
        submitted entries, plus a total list of all check items and radio selections.
        Then it presents a bar chart displaying the survey's check and radio results.
    }
]
view center-face layout [
    style area area 500x100
    across
    h4 200 "SURVEY TOPIC:" 
    h4 200 "Response File:" return
    f1: field 200 "Survey #1"
    f2: field 200 "survey1.db"
    below
    h4 "SURVEY CHECK BOX OPTIONS:"
    a1: area "Check Option 1^/Check Option 2^/Check Option 3"
    h4 "SURVEY RADIO BUTTON OPTIONS:"
    a2: area "Radio Option 1^/Radio Option 2^/Radio Option 3"
    h4 "SURVEY TEXT ENTRY FIELDS:"
    a3: area "Text Field 1^/Text Field 2^/Text Field 3"
    btn "Submit" [
        checks: parse/all a1/text "^/" remove-each i checks [i = ""]
        radios: parse/all a2/text "^/" remove-each i radios [i = ""]
        texts: parse/all a3/text "^/" remove-each i texts [i = ""]
        title: join uppercase f1/text ":"
        response-file: to-file f2/text
        unview
    ]
]
write response-file ""
write %poll-report.r rejoin [{
rebol [title: "Poll Report"]
view center-face layout [
    btn 100 "Generate Report" [
        all-checks: copy []
        all-radios: copy []
        print newpage
        print {All Entries:^/}
        foreach response load %} response-file {[
            x: construct response
            ?? x
            if find first x 'checks [
                either block? x/checks [
                    foreach check x/checks [
                        append all-checks check
                    ]
                ][
                    append all-checks x/checks
                ]
            ] 
            if find first x 'radios [
                either block? x/radios [
                    foreach radio x/radios [
                        append all-radios radio
                    ]
                ][
                    append all-radios x/radios
                ]
            ]            
        ]
        alert rejoin [
            "All Checks: "  mold all-checks
            " All Radios: " mold all-radios
        ]
        check-count: copy []
        foreach i unique all-checks [
            cnt: 0
            foreach j all-checks [
                if i = j [cnt: cnt + 1]
            ]
            append check-count reduce [i cnt]
        ]
        radio-count: copy []
        foreach i unique all-radios [
            cnt: 0
            foreach j all-radios [
                if i = j [cnt: cnt + 1]
            ]
            append radio-count reduce [i cnt]
        ]
        bar-size: to-integer request-text/title/default
            "Bar Chart Size:" "40"
        g: copy [backdrop white text "Checks:"] 
        foreach [m v] check-count [
            append g reduce ['button m v * bar-size]
        ]
        append g [text "Radios:"]
        foreach [m v] radio-count [
            append g reduce ['button gray m v * bar-size]
        ]
        view/new center-face layout g
    ]
    btn 100 "Edit Raw Data" [
       alert "Be careful!"
       editor %} response-file {
    ]
]
}]
launch %poll-report.r
poll: copy ""
repeat i len: length? checks [
    append poll rejoin [
        {<input type="checkbox" name="checks" value="} i {">}
        checks/:i {<br>} newline
    ]
]
append poll {<br>}
repeat i len: length? radios [
    append poll rejoin [
        {<input type="radio" name="radios" value="} i {">}
        radios/:i {<br>}
        newline
    ]
]
append poll {<br>}
repeat i len: length? texts [
    append poll rejoin [
        texts/:i {:<br><INPUT TYPE="TEXT" NAME="text} i 
        {" SIZE="35"><br>} newline
    ]
]
append poll {<br><INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">}
l: read join dns:// read dns://
print join "Waiting on:  " l
port: open/lines tcp://:80
browse join l "?"
responses: copy []
forever [
    q: first port
    if error? try [
        z: decode-cgi replace next find first q "?" " HTTP/1.1" ""
        if not empty? z [
            append/only responses z
            save response-file responses
            print newpage
            entry-received: construct z
            ?? entry-received
        ]
        d: rejoin [
            {HTTP/1.0 200 OK^/Content-type: text/html^/^/
            <HTML><BODY><FORM ACTION="} l {">} title {<br><br>}
            poll
            {</FORM></BODY></HTML>}
        ]
        write-io q d length? d
    ] [] ;[print "(empty submission)"]
    close q
]
halt