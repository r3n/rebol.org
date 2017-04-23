REBOL [
    title: "Postal Barcode"
    date: 9-Feb-2011
    file: %postal-barcode.r
    author:  Nick Antonaccio
    purpose: {
        Demonstrates how to use the Intelligent Mail encoder dll from 
        the US postal service.
        This script can also be found in the tutorial at http://re-bol.com
    }
]

unless exists? %usps4cb.dll [write/binary %usps4cb.dll read/binary http://re-bol.com/usps4cb.dll]

GEN-CODESTRING: make routine! [
    t [string!]  r[string!]  c [string!]  return: [integer!]
]  load/library request-file/only/file %usps4cb.dll "USPS4CB"

t: request-text/title/default "Tracking #:" "00700901032403000000"
r: request-text/title/default "Routing #:" "55431308099"
GEN-CODESTRING t r (make string! 65)
alert first second first :GEN-CODESTRING