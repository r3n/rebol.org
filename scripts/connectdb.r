#!/path/to/rebol -cs
REBOL [
    Title: "connectdb"
    File: %connectdb.r
    Date: 27-jul-2012
    Author: "Arnold van Hofwegen"
    Purpose: {  Example how to use mysql-protocol.r  }
    library: [
       level: 'intermediate 
       platform: none 
       type: none 
       domain: 'DB 
       tested-under: none 
       support: none 
       license: none 
       see-also: "%nice-urls.r"
    ]
]
dbHost: "hostnaam:port";   
dbUser: "gebruikersnaam";  
dbPswd: "*********";       
dbName: "testdatabase";    

do %/path/to/mysql-protocol.r

dbopen: rejoin ["mysql://" db-user ":" db-pswd "@" db-host "/" db-name ] 

open-db: does [db: open to-url dbopen]

close-db: does [close db]

; Use like
;    do %/path/to/connectdb.r
;    open-db    
;    insert db "SELECT field1, field-2 FROM table-name ORDER BY field-2"
;    resultaat: copy db 
;    close-db