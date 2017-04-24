REBOL [
    title: "HTML Form Server"
    date: 30-Dec-2013
    file: %formserver.r
    author:  Nick Antonaccio
    purpose: {
        Creates a web server which serves an HTML form, and then
        processes the data input by users.  This can be useful when tallying
        information from users on a Local Area Network.  The users can use
        any device (iPhone, Android, netbook, etc.) to enter information into
        a shared system, as long as the device has a basic web browser
        and Wifi (or other network) connectivity. 
        Just edit the HTML form example, and do what you want with the 'z
        variable returned by the user(s).
    }
]
l: read join dns:// read dns://
print join "Waiting on:  " l
port: open/lines tcp://:80
browse join l "?"
forever [
    q: first port
    if error? try [
        z: decode-cgi replace next find first q "?" " HTTP/1.1" ""
        prin rejoin ["Received: " mold z newline]
        d: rejoin [
            {HTTP/1.0 200 OK^/Content-type: text/html^/^/
            <HTML><BODY><FORM ACTION="} l {">Server:  } l {<br><br>
                Name:<br><INPUT TYPE="TEXT" NAME="name" SIZE="35"><br>
                Address:<br><INPUT TYPE="TEXT" NAME="addr" SIZE="35"><br>
                Phone:<br><INPUT TYPE="TEXT" NAME="phone" SIZE="35"><br>
                <br><input type="checkbox" name="checks" value="i1">Item 1
                <input type="checkbox" name="checks" value="i2">Item 2
                <input type="radio" name="radios" value="yes">Yes
                <input type="radio" name="radios" value="no">No<br><br>
                <INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
            </FORM></BODY></HTML>}
        ]
        write-io q d length? d
    ] [print "(empty submission)"]
    close q
]
halt