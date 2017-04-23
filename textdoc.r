REBOL [
    Title: "Example Text Document"
    Date: 5-Jun-1999
    File: %textdoc.r
    Author: "Carl Sassenrath"
    Usage: {
        Evaluate this script to create a file called
        net-setup.txt.  Then do %text-html.r and provide
        it with this file to convert.
    }
    Purpose: {
        Creates an example for text-to-html doc language.
        Shows how natural and readable it is -- the reason we
        prefer it for writing our how-to documentation.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [markup text-processing file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

write %net-setup.txt {Network Setup

Some of the networking functions of REBOL require you to
specify default settings prior to use.  For instance, the
email SEND function needs your server name and your email
FROM address before email can be sent.


=== Simple Setup

The SET-NET function is provided to make this easy.  It takes
an argument block that specifies your preferred setup and can
be placed in your user.r file to give you a consistent server
configuration each time you run REBOL.  An example of using
SET-NET is:

    set-net [user@domain.dom mail.server.dom]

The first field specifies your FROM address and the second
indicates your default server (notice that it does not need
quotes here).  For most networks, this will be enough and no
other settings are necessary.  Your default server will be
used whenever a specific server is not provided. For
instance, in the SEND below the default server will be used:

    send luke@rebol.com "Use the force."


=== Specifying A POP Server

In addition, if you use a POP server (incoming email) that
is different from your SMTP server (outgoing email), you can
specify that as well:

    set-net [
        user@domain.dom
        mail.server.dom
        pop.server.dom
    ]

However, if your SMTP and POP servers are the same, then
this is not necessary.


=== Specifying a Socks Proxy Server

If you use a firewall with a Socks-5 proxy server, you can
also specify its settings:

    set-net [
        user@domain.dom
        mail.server.dom
        pop.server.dom
        proxy.server.dom
        1080
    ]

In some cases a proxy server may require additional
information.  This will be discussed in a later document.


=== Advanced Settings

The SET-NET function is a shortcut for configuring the
network protocols directly.  In addition to the settings
described above, many other configurations are possible. For
instance, you can specify default servers and login accounts
for other protocols such as FTP or NNTP.  You can also use
separate proxies and timeout values for different protocols.
Many combinations are possible, and each will be described in
a later document.

    system/schemes/smtp/timeout: 0:05
}

print "Now do %texthtml.r with a filename of texthtml.txt"
