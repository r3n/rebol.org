REBOL [
    Title: "TFTP Get"
    Date: 3-Aug-2003
    Version: 1.0.1
    File: %tftp-get.r
    Author: "ND"
    Purpose: {get file from tftp daemon, could be modified as scheme, needs perfection on write to disk!}
    Email: none
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: [file-handling files ftp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

iofile: "tst.exe"       ; filename to get from tftpd
tftpd:  "192.168.80.1:69"   ; tftpd address:port

;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

packet-timeout: 0:0:5
block-size: 516
block-cnt: 0
finished: false


errorcode: [
    "Error not defined, see error message (if any?!)."
    "File not found."
    "Access violation."
        "Disk full allocation exceeded."
        "Illigal TFTP operation."
        "Unknown tranfser ID."
        "File already exists."
        "No such user."
    "Network error."
    "No connection with remote host."
]


opcode: make object! [
    nul:  to-char 00
    rrq:  to-char 01
    wrq:  to-char 02
    dat:  to-char 03
    ack:  to-char 04
    err:  to-char 05
]


send-rrq:     func [ port [port!] filename [string!] mode [string!] ][ { sends the RRQ packet } if error? try [ insert port rejoin [ opcode/nul opcode/rrq filename opcode/nul mode opcode/nul ]] [ print errorcode/9 ] ]
send-ack:     func [ port [port!] value] [ { send ACK  } insert port rejoin [ opcode/nul opcode/ack block-id value ] ]
block-id:     func [ value ][ { returns block id from data packet } return block-cnt: join value/3 value/4 ]
data-packet?: func [ value { return true if value is data package } ][ either equal? value/2 opcode/dat [ true ][ false ] ]
full-packet?: func [ value { check data packet size } ][ either equal? length? value block-size [ true ][ false ] ]
print-error:  func [ value { print error type } ][ print rejoin [ "Error: " pick errorcode (to-integer value/4) + 1 ] ]
perror:       func [integer { print tftp error } ][ print rejoin [ "Error: " pick errorcode integer ]]


;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
; read from tftpd
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

tftp-get: func [ {get a file by tftp }
    port [port!] { port to connect to}
    filename [string!] { filename to get }
    mode [string!] { octet ascii }
    /local got [any-type!]
][

    send-rrq port filename mode
    either got: wait [ port packet-timeout ] [ got: copy port ] [print errorcode/10 exit ]

    ;-- Until last package or error.
    while [ not finished ] [

       either data-packet? got [
     either full-packet? got [

          ;print rejoin [ "sent ACK" ",<block=" to-integer to-binary block-cnt">" ]
          prin "."
              send-ack port got
          write/binary/append to-file iofile remove/part got 4
          either got: wait [ port packet-timeout ] [ got: copy port ] [print errorcode/10 exit ]

          ][  ;-- not a full packet? then last packet!

           prin "."
               send-ack port got
           write/binary/append to-file iofile remove/part got 4
           finished: true   ]

       ][  ;-- got error

         perror (to-integer got/4) + 1
         finished: true  ]

    ]
]





;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
; main starts here
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    unset 'udp

    if exists? to-file iofile [ delete to-file iofile ]
    print rejoin [ "Writing to: " iofile ]

    udp: open/no-wait/binary/direct rejoin [ udp:// tftpd ]
    tftp-get udp iofile "octet"
    close udp