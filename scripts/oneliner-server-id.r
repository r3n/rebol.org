Rebol [
    Title: "Display server name"
    Date: 20-Jul-2003
    File: %oneliner-server-id.r
    Purpose: "Prints the name and version of a website's server."
    One-liner-length: 69
    Version: 1.0.0
    Author: "Sunanda"
    Library: [
        level: 'beginner
        platform: 'all
        type: [How-to FAQ one-liner]
        domain: [web other-net]
        tested-under: none
        support: none
        license: pd
        see-also: none
    ]
]
p: open http://www.rebol.com:80 print p/locals/headers/server close p
