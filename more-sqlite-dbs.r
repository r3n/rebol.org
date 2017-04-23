Rebol [
Title: "How to attach two or more db files in SQLITE"
Purpose: { Simple script demonstrates how to attach second(or more) db files in SQLITE database }
file:    %more-sqlite-dbs.r
date:   11-Jan-2011
author: "Robert Paluch alias BobikCZ"

]

do %sqlite3.r                           ;; load sqlite driver

db: sqlite-open %myfirstdb.db   ;; open first db file

sqlite-exec db {attach database 'myseconddb.db' as myseconddb} ;; attach my second db file

res: sqlite-exec db {select * from myseconddb.mytable}               ;;resulting select etc..

;; there can be use also joins of tables