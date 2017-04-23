REBOL [
  Title:    "Demonstration of a Package on REBOL.org"
  Date: 18-feb-2004
  File: %lds-demo1-package.r
  Author:   "Sunanda"
  Version: 0.0.1
  Purpose: "Demonstration of a package, and competition"
  History: [0.0.0   18-feb-2004 {First version. Sunanda}
                0.0.1  28-Apr-2004 {Add note about choice of downloader/installers. Sunanda}
  ]
  Library: [
     level: 'beginner
     platform: 'all
     type: [package demo]
     domain: [game vid]
     tested-under: [win]
     support: none
     license: bsd
    comment: {images in this package are copyright Sunanda}
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