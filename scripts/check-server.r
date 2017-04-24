REBOL [
    Title: "Check Web Servers"
    Date: 16-Sep-1999
    File: %check-server.r
    Author: "James Rathbun"
    Purpose: {This script can be used to query a web server, and email webmaster if it fails.}
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

secure none

database: [
         http://www.prolific.com "Prolific Publishing" jr@prolific.com
         http://www.silentsoftware.com "Silent Software" jr@prolific.com
]

forever [foreach [site name email] database [either exists? site[print rejoin ["The " name " Web Server is running on " now]][send email rejoin["The " name " is not running!!!!! " now]]] wait 0:1:0]
