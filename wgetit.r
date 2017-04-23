REBOL [
    Title: "Web-GetIt!"
    Name: "Web-GetIt! Tool"
    File: %wgetit.r
    Type: 'view-app
    Version: 1.8.0
    Date: 04-Feb-2006
    Author: "Dirk Weyand"
    Owner: "Dirk Weyand"
    Rights: "TGD-Consulting"
    Home: http://www.TGD-Consulting.DE/Download.html
    Purpose: "Saves content of web pages to local disk."
    Comment: {Web-GetIt! is a tool like wget using REBOL/View. It gets the content of HTML conforming web pages and stores it to local disk.}
    History: [
        {0.1.0 ^-26-Aug-2002  ^-"initial release"^/}
        {0.2.0 ^-27-Aug-2002  ^-"fixed scrollbar issue"^/}
        {0.3.0 ^-28-Aug-2002  ^-"changed faces layout"^/}
        {0.4.0 ^-29-Aug-2002  ^-"added Del-button"^/}
        {0.5.0 ^-31-Aug-2002  ^-"added Option face"^/}
        {0.6.6 ^-06-Sep-2002  ^-"added pre DNS-check"^/}
        {0.7.0 ^-07-Sep-2002  ^-"new message function"^/}
        {0.8.0 ^-12-Sep-2002  ^-"added GetIt!-Log face"^/}
        {0.8.1 ^-13-Sep-2002  ^-"added Overwrite Option"^/}
        {0.9.0 ^-15-Sep-2002  ^-"new logit function"^/}
        {0.9.1 ^-17-Sep-2002  ^-"added Log-level Option"^/}
        {1.0.0 ^-18-Sep-2002  ^-"follow remote Links"^/}
        {1.1.0 ^-19-Sep-2002  ^-"first public release"^/}
        {1.1.1 ^-07-Oct-2002  ^-"added hide-req Option"^/}
        {1.2.0 ^-20-Oct-2002  ^-"changed history layout"^/}
        {1.3.0 ^-26-Oct-2002  ^-"added www,email link"^/}
        {1.4.0 ^-14-Nov-2002  ^-"removed some bugs"^/}
        {1.4.1 ^-19-Nov-2002  ^-"changed version format"^/}
        {1.4.2 ^-13-Jan-2003  ^-"changed comment"^/}
        {1.4.3 ^-07-Feb-2003  ^-"fixed an URL-bug"^/}
        {1.4.4 ^-09-Feb-2003  ^-"fixed remote-URL bug"^/}
        {1.4.5 ^-15-Feb-2003  ^-"fixed anchor(#) bug"^/}
        {1.4.6 ^-21-Nov-2003  ^-"changed copyright-note"^/}
        {1.4.7 ^-13-Dec-2003  ^-"orthographical fixes"^/}
        {1.4.8 ^-16-Feb-2004  ^-"fixed, dehex ESC-char"^/}
        {1.4.9 ^-14-Dec-2005  ^-"enhanced URL-download"^/}
        {1.5.0 ^-15-Dec-2005  ^-"added ESC-key control"^/}
        {1.5.1 ^-16-Dec-2005  ^-"changed layout backdrop"^/}
        {1.5.2 ^-18-Dec-2005  ^-"enhanced logging 2 file"^/}
        {1.5.3 ^-05-Jan-2006  ^-"fixed history-slider"^/}
        {1.5.4 ^-06-Jan-2006  ^-"enhanced tag parsing"^/}
        {1.6.0 ^-07-Jan-2006  ^-"added content decoding"^/}
        {1.7.0 ^-08-Jan-2006  ^-"added REBOL/View check"^/}
        {1.7.1 ^-09-Jan-2006  ^-"fixed POST URL-download"^/}
        {1.7.2 ^-16-Jan-2006  ^-"fixed relative pathes"^/}
        {1.7.3 ^-30-Jan-2006  ^-"changed User-Agent"^/}
        {1.7.4 ^-01-Feb-2006  ^-"fixed tag parsing"^/}
        {1.8.0 ^-04-Feb-2006  ^-"follow sub domains"^/}
    ]
    Library: [ level: 'advanced
         platform: 'all
         type: [tool]
         domain: [http html web]
         tested-under: [view 1.2.1.1.1 on "AmigaOS 68k"] 
         support: "See website http://www.TGD-Consulting.de/Download.html"
         license: 'PD 
         see-also: http://www.TGD-Consulting.de/index.r ]
]

do load decompress 64#{
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
}