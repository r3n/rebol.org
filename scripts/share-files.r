REBOL [
    title: "Simple File Sharer"
    date: 19-Jan-2014
    file: %share-files.r
    author:  Nick Antonaccio
    purpose: {
        I use it to send lists of files to clients' phones, PCs, or any other
        Internet device they may use.  I text or email them the single short
        personal html file link created by the script, and they click the 
        contained file links to download all their files. It's a stupid simple
        script and setup which requires only a single unstructured folder on
        any available web server, to handle all the files for any number of
        potential clients, but it's a huge time saver that gets used for so
        many different practical purposes, with so many people, in so many
        situations. It's much more universally usable and straightforward
        than a service such as Dropbox.  No client software needs to be
        installed (just use any browser to download the files).
    }
]
login: request-text/default "ftp://user:pass@site.com/public_html/files/"
filename: join request-text/default "links" ".html"
html: copy {}
foreach f request-file [
    print file: last split-path f
    write/binary to-url join login file read/binary f
    append html rejoin [
        {<a href="} file {">} file {</a><br>} newline
    ]
]
write/append html-file: to-url join login filename html
editor html-file  ; sometimes I re-arrange the order of the links
browse join "http://" replace next find html-file "@" "public_html/" ""




quit 

; Not totally secure, but to hide your login info from prying eyes, you can do this:

encloak to-binary "ftp://user:pass@site.com/public_html/files/" request-text/title "Password:"

; To use that encloaked data in your script:

to-string decloak#{
00764ECD0A953D0FF90B29F1E1337DE4BC380A7BC0A186529555FDDE21C8B344
5D88D86D69E2CDB5453453
} request-text/title "Password:"