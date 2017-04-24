REBOL [
    Title: "Time Several Web Sites"
    Date: 24-Apr-1999
    File: %timesites.r
    Purpose: {Time how long it takes to read several web home pages. (Just the HTML file, not the images.)}
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'Tool 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

sites: [
    http://www.rebol.com
    http://www.cnet.com
    http://www.hotwired.com
]

foreach site sites [
    start: now/time
    read site
    print ["Time for" site "was" now/time - start]
]

