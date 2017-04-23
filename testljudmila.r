REBOL [
    Title: "copy to Ljudmila"
    Date: 21-May-2001
    Version: 1.1.1
    File: %testLjudmila.r
    Author: "Iztok"
    Purpose: "xx."
    Email: iztok@mail.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'one-liner
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

write/binary ftp://lolita:6CpdtP@ljudmila.org/public_html/lolita/aaa.jpg   read/binary %lulu.jpg
            