Rebol [
    title: "Display IP Addresses"
    date: 29-june-2008
    file: %display-ip-addresses.r
    purpose: {
        Display the WAN and LAN addresses of your PC.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

parse read http://whatsmyip.org/ [thru <title> copy my-ip to </title>]
parse my-ip [thru "Your IP is " copy stripped-ip to end]
alert to-string rejoin ["WAN: " stripped-ip " ---- LAN: " read join dns:// read dns://]