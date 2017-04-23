REBOL [
    Title:   "FTPGadget Package Script"
    Date:    29-Jun-2006
    File:    %ftpgadget-package.r
    Author:  "Gregg Irwin"
    Version: 0.0.1
    Purpose: "Package script for FTPGadget"
    Library: [
        level: 'advanced
        platform: 'all
        type: [package]
        domain: [FTP]
        tested-under: [win]
        support: none
        license: MIT
        see-also: none
    ]
]

;;  This script is a *package*. What you see here is just the
;;  stub.  

;;  To download and install the files in the package you need to
;;  run a installation program.  

;;  If you are running View (1.3 or later):

    do http://www.rebol.org/library/public/repack.r 

;;  If you are running Core:
 
    do http://www.rebol.org/library/public/repack-core.r
