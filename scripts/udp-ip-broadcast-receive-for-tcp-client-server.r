REBOL [
    title: "UDP IP Broadcast/Receive for TCP Client/Server"
    date: 26-jan-2014
    file: %udp-ip-broadcast-receive-for-tcp-client-server.r
    author:  Nick Antonaccio
    purpose: {
        This script demonstrates a solution to a typical problem encountered
        with TCP network apps.  A TCP server needs to be found at a known
        IP address.  One solution is to configure your server machine with a
        static IP address in the router.  This setup step is different for every
        router manufacturer, is often beyond the technical ability of the app
        user, the router may not be accessible due do to security concerns in an
        enterprise environment, etc.  Another solution is to upload the server's
        current IP address to a server at a known URL (web server, FTP, etc.
        managed off site), but this just extends the problem to another
        network server, requires an Internet connection, etc.  Another solution
        could potentially be to save the server IP address to a file on a
        mapped network drive, but this stills requires some configuration which
        may be out of the user's capability (mapping network drives to a
        folder on the server machine, on each client computer).  A crude solution
        for simple applications could be to manually enter the IP address of the
        server (i.e., Joe yells to John down the hall "the server IP address is
        192.168.1.10").
        This example demonstrates a consistently usable solution for all TCP
        apps.  It creates two separate scripts which run on the client and server,
        to manage all server IP address updates.  The %send-ip.r script runs on
        the server machine and continuously broadcasts the IP address over UDP.
        The %receive-ip.r script runs on the client, receives the current IP and
        writes it to a file.  Because UDP is a broadcast protocol, no known IP
        addresses are required for this to work.  Once the server script is
        running, the clients can all simply start and receive the current IP
        address being broadcast.
        This example includes a separate TCP chat app which simply reads the
        saved IP address and connects to the server.  No other network
        configuration is required.
        To implement this routine in any TCP application, just run the %send-ip.r
        script on any server, run the %receive-ip.r script on any client(s), and
        you can read the %local-ip.r file in your client apps to connect to the
        current IP address of the server.
    }
]
write %receive-ip.r {rebol []
net-in: open udp://:9905
print "waiting..."
forever [
    received: wait [net-in]
    probe join "Received: " trim/lines ip: copy received
    write %local-ip.r ip
    wait 2
]}
launch %receive-ip.r
write %send-ip.r {rebol []
net-out: open/lines udp://255.255.255.255:9905
set-modes net-out [broadcast: on]
print "Sending..."
forever [
    insert net-out form read join dns:// read dns://
    wait 2
]}
launch %send-ip.r
write %tcp-chat.r {rebol [title: "TCP-Chat"]
view layout [ across
    q: btn "Serve"[focus g p: first wait open/lines tcp://:8 z: 1]text"OR"
    k: btn "Connect"[focus g p: open/lines rejoin[tcp:// i/text ":8"]z: 1]
    i: field form read %local-ip.r  return  ; read join dns:// read dns://
    r: area rate 4 feel [engage: func [f a e][if a = 'time and value? 'z [
        if error? try [x: first wait p] [quit]
        r/text: rejoin [x newline r/text] show r
    ]]]  return
    g: field "Type message here [ENTER]" [insert p value  focus face]
]}
wait 2
launch %tcp-chat.r
launch %tcp-chat.r