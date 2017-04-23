REBOL [
    Title: "Very Short Webserver"
    Date: 17-Oct-2003
    File: %oneliner-webserver.r
    Purpose: {Webserver serving files from the current directory.}
    One-liner-length: 308
    Author: "Cal Dixon"
    Library: [
        level: 'advanced
        platform:  'all
        type: [tool demo one-liner idiom]
        domain: [http internet web]
        tested-under: [view 1.2.10.3.1 W2K]
        support: none
        license: 'PD
        see-also: none
    ]
   one-liner-length: 308
   ]

secure[net allow library throw shell throw file throw %. [allow read]]p: open/lines tcp://:80 forever[attempt[s: length? b: read/binary to-file next pick parse pick c: p/1 1 none 2 write-io c b: rejoin[#{}"HTTP/1.0 200 OK^M^JServer: Rebol^M^JContent-length: "s"^M^JContent-type: text/html^M^J^M^J"b]length? b close c]]
