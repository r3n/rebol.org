REBOL [
    Title: "Time Web Pages"
    Date: 18-Dec-1997
    File: %timewebs.r
    Purpose: {Time how long it takes to get each of the web pages listed in a block.}
    Comment: {
        Although REBOL stores time to the 1000th of a second,
        most systems don't return this information... We will
        find a way to add it in the future.
    }
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'tool 
        domain: [web other-net DB] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

sites: [
    http://www.pacific.net
    http://www.rebol.com
    http://www.sassenrath.com
    http://www.cucug.org
    http://www.cnn.com
    http://www.cnet.com
]

times: copy [] ; store times and sizes in this block

;Gather timings:

foreach site sites [
    start: now/time
    size: length? read site
    insert tail times now/time - start
    insert tail times size
]

;Print time, site, and home page size for each site:

foreach site sites [
    print [first times site second times]
    times: skip times 2
]

