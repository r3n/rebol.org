Rebol [
    title: "MySql Example"
    date: 29-june-2008
    file: %mysql-example.r
    author: Nick Antonaccio
    purpose: {
        A simple example demonstrating how to use mysql-protocol from 
        http://softinnov.org/rebol/mysql.shtml.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

do %mysql-protocol.r 
db: open mysql://root:root@localhost/Contacts
; insert db {drop table Contacts} ; erase the old table if it exists
insert db {create table Contacts (
    name            varchar(100),
    address         text,
    phone           varchar(12),
    birthday        date 
)} 
insert db {INSERT into Contacts VALUES 
    ('John Doe', '1 Street Lane', '555-9876', '1967-10-10'),
    ('John Smith', '123 Toleen Lane', '555-1234', '1972-02-01'),
    ('Paul Thompson', '234 Georgetown Pl.', '555-2345', '1972-02-01'),
    ('Jim Persee', '345 Portman Pike', '555-3456', '1929-07-02'),
    ('George Jones', '456 Topforge Court', '', '1989-12-23'),
    ('Tim Paulson', '', '555-5678', '2001-05-16')
}
insert db "DELETE from Contacts WHERE birthday = '1967-10-10'"
insert db "SELECT * from Contacts"
results: copy db
probe results

view layout [
    text-list 100x400 data results [
        string: rejoin [
            "NAME:      " value/1 newline
            "ADDRESS:   " value/2 newline
            "PHONE:     " value/3 newline
            "BIRTHDAY:  " value/4
        ]
        view/new layout [
            area string
        ] 
    ] 
]
close db