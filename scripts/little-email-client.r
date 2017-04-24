Rebol [
    title: "Little Email Client"
    date: 29-june-2008
    file: %little-email-client.r
    purpose: {
        A very small graphical email client that can be used to send and receive messages.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

m: system/schemes/default q: system/schemes/pop
view layout [ style f field
u: f "username" p: f "password" s: f "smtp.address" o: f "pop.address"
btn bold "Save Server Settings" [
    m/user: u/text m/pass: p/text m/host: s/text q/host: o/text
] tab
e: f "user@website.com" j: f "Subject" t: area 
btn bold "SEND" [
    send/subject to-email e/text t/text j/text alert "Sent"
] tab
y: f "your.email@somesite.com"               
btn bold "READ" [foreach i read to-url join "pop://" y/text [ask i]]
]
