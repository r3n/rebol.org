REBOL [
    File: %lds-local.r
   Title: "Library data services"
    Author: "Sunanda"
    Date: 19-jan-2004
    Version: 0.0.4
    Purpose: {Provides the client end of the REBOL.org Library Data Services interface}
   Library: [
       level: 'intermediate
       platform: 'all
       type: [tool]
       domain: [file-handling user-interface web]
       tested-under: [win linux]
       support: none
       license: [bsd]
       see-also: none
     ]
    ]
;; Note Script is now a Library Public Resource.
;; Best to execute it from there -- that way, you
;; can be sure to have the latest version.

 do http://www.rebol.org/library/public/lds-local.r