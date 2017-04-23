REBOL [
    title: "FTP CHMOD"
    date: 31-jul-2010
    file: %ftp-chmod.r
    author:  Nick Antonaccio
    purpose: {
        This is a workaround for REBOL's inability to chmod files (set permissions)
        with the built in FTP protocol.  This script is for MS Windows, but Macintosh
        and Linux also have command line FTP programs built into the OS that can
        be used similarly with REBOL's "call" function.
    }
]
website: request-text/title/default "Web Site:" "site.com (or IP address)"
username: request-text/title/default "User Name:" "user"
password: request-text/title/default "Password:" "pass"
folder: request-text/title/default "Folder:" "public_html"
file: request-text/title/default "File:" "example.cgi"
permission: request-text/title/default "Permission:" "755"
write %ftpargs.txt trim rejoin [{
    open } website {
    user } username { } password {
    cd } folder {
    literal chmod } permission { } file {
    bye
}]
call/show "ftp -n -s:ftpargs.txt"