Rebol [
    title: "Simple FTP file editor"
    date: 29-june-2008
    file: %ftp-file-editor.r
    purpose: {
        Download, edit, and resave files on your website, via FTP.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

view layout [
    h1 "Enter your ftp info, then click 'load' to download and edit a file:"
    p: field 600 "ftp://user:pass@website.com/public_html/filename.html"
    h: area 600x440 across 
    btn "Load" [h/text: read (to-url p/text) show h]
    btn "Save" [write (to-url p/text) h/text]
]