rebol [
    Library: [
            level: 'intermediate
         platform: 'all
             type: [tool]
           domain: [cgi html web]
     tested-under: [apache xitami]
          support: none
          license: [mit]
         see-also: none
        ]

         file: %acgiss.r
       author: "Sunanda"
      version: 0.0.1
         Date: 12-jan-2005
      purpose: "Provide basic cookie support for CGI scripts"
        Title: "Anonymous CGI session services"
       license: 'mit
 documentation: http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=acgiss.r
  ]



acgiss: make object! [

 ;; ---------------------------
 ;; Session-related data fields
 ;; ---------------------------
 ;; FOR SECURITY, WE RECOMMEND YOU CHANGE ALL OF THESE
 ;; BEFORE DEPLOYING.....SEE DOCUMENTATION FOR DETAILS.

_parameters: reduce [
  "session-cookie-id" "acgiss"
  "session-folder" join what-dir %../acgiss-work-folder/
  "session-duration" 24:00:00
]

set-parameter: func [
    id [string!]
    value
   /local
    pointer
][
pointer: find/skip _parameters id 2
either none? pointer [
    append _parameters id
    append _parameters value
   ][
    pointer: next pointer
    poke _parameters index? pointer value
    ]
return true

]

get-parameter: func [
    id [string!]
][
return select _parameters id
]

 ;; --------------------------------
 ;; Session-related public functions
 ;; --------------------------------

get-session-record: func [
   /local
    cookie
    session-file-name
    session-record
][
     ;; Find the incoming cookie, if there is one
     ;; -----------------------------------------
cookie: select system/options/cgi/other-headers "HTTP_COOKIE"
if none? cookie [return _make-session-template-object]

     ;; If it's one of ours,
     ;; winkle out the session id
     ;; -------------------------
cookie: parse/all cookie "="
if not all [
    2 = length? cookie
    cookie/1 = get-parameter "session-cookie-id"
    ][return _make-session-template-object]


    ;; Retrieve the saved session file, if any
    ;; ---------------------------------------
session-file-name: _get-session-file-name join get-parameter "session-cookie-id" ["=" cookie/2]
if error? try [
    session-record: first reduce load/all decompress read/binary session-file-name
    ][return _make-session-template-object]


    ;; Check the session file ain't expired
    ;; ------------------------------------
    probe session-record
if all [not none? session-record/session-expires
        session-record/session-expires < now ][
    end-session session-record
    return _make-session-template-object
   ]

return session-record
]

;; ===========================

save-session: func [
    session-record [object!]
   /force-cookie-write    ;; print cookie even if we may not need to
   /local
    pointer
    expiry-details
    session-file-name
    cookie
    temp
][

       ;; add expires= to cookie if needed
       ;; --------------------------------
expiry-details: copy ""
if not none? session-record/session-expires [
    expiry-details: rejoin ["; expires " to-idate session-record/session-expires]
   ]
cookie: rejoin [
        "set-cookie: "
         session-record/session-id
         expiry-details
         ]

pointer: find  system/options/cgi/other-headers "HTTP_COOKIE"


        ;; write the cookie header, if needed
        ;; ----------------------------------
        ;; the pointer test means this function
        ;; can be called multiple times, but
        ;; will write the cookie header at
        ;; most once.
        ;; -----------------------------------
if any [
    force-cookie-write     ;; [need to]/[want to] print cookie header regardless
    none? pointer          ;; new session, so hasn't been written yet
    ][print cookie]


       ;; update the HTTP header
       ;; ----------------------
       ;; So any later calls to
       ;; get-session-data will
       ;; not create a new session
       ;; ------------------------
either none? pointer [
    append system/options/cgi/other-headers "HTTP_COOKIE"
    append system/options/cgi/other-headers session-record/session-id
    ][
     poke system/options/cgi/other-headers (1 + index? pointer) session-record/session-id
    ]

       ;; update or create the session data record
       ;; ----------------------------------------
session-record/session-status: "old"
session-file-name: _get-session-file-name session-record/session-id
if not exists? temp: get-parameter "session-folder" [make-dir/deep temp]
write/binary session-file-name compress mold session-record

return true
]


;; ===========================

end-session: func [
    session-record [object!]
   /local
    pointer
    session-file-name
][

        ;; remove HTTP header, if any
        ;; --------------------------
pointer: system/options/cgi/other-headers "HTTP_COOKIE"
if not none? pointer [remove remove pointer]

        ;; remove session file, if any
        ;; ---------------------------
session-file-name: _get-session-file-name session-record/session-id
error? try [delete session-file-name]

        ;; sneak some folder purging in on the sly
        ;; ---------------------------------------
purge-expired-sessions/limit 5
return true
]

;; ===========================

extend-session: func [
    session-record [object!]
    extra-time [time!]    ;; can be negative to shorten or end a session
][
session-record/session-expires: now + extra-time
save-session/force-cookie-write session-record
return true
]

;; ===========================

purge-expired-sessions: func [
   /limit max-to-purge
   /local
    session-file-name
    session-record
    session-folder
][

if not limit [max-to-purge: 999'999'999]
session-folder: get-parameter "session-folder"
if not all [exists? session-folder dir? session-folder] [return true]

foreach file-name read session-folder [
   session-file-name: join session-folder file-name

   error? try [
       session-record: first reduce load/all decompress read/binary session-file-name
       if session-record/scads-record-type = "acgiss" [
           if session-record/session-expires < now [
               delete session-file-name
               max-to-purge: max-to-purge - 1
               if max-to-purge < 1 [return true]
              ] ;; if
           ] ;; if
       ] ;; try
   ] ;; for

 return true
]



 ;; ---------------------------------
 ;; Session-related private functions
 ;; ---------------------------------

_make-session-template-object: func [
   /local
    ent-fields
    session-expiry
][
      ;; entrophy fields
      ;; ---------------
      ;; To create a session id that is not easily
      ;; guessable by someone who knows some external
      ;; details (like session start time, user ip address)
      ;; etc.

ent-fields: copy []
error? try [append ent-fields to-tuple system/options/cgi/remote-addr]
error? try [append ent-fields length? read get-parameter "session-folder"]
append ent-fields now/precise
append ent-fields mold _parameters
random/secure ent-fields

session-expiry: none
error? try [session-expiry: now + get-parameter "session-duration"]

return make object! [
    scads-record-type: "acgiss"
       session-status: "new"
      session-expires: session-expiry
           session-id: rejoin [
                    ""
                     get-parameter "session-cookie-id"
                    "="
                     _checksum-string
                        random/secure
                           mold ent-fields
                     ] ;; rejoin
    user-data: copy []
 ]
]


;; ===========================

_get-session-file-name: func [
    session-id
][
return rejoin [get-parameter "session-folder" session-id ".ssd"]
]

;; ===========================

_checksum-string: func [
    item
   /local
    str
    letters
][

       ;; Converts a checksum/secure field into
       ;; something that is usable as part of a
       ;; file name on all known REBOL platforms:
       ;; also adds a little extra randomness for
       ;; luck
letters: "abcdef"
str: form checksum/secure item
replace str "#" random/secure copy/part letters random/secure 5
replace str "}" random/secure copy/part letters random/secure 5
replace str "{" random/secure copy/part letters random/secure 5
return uppercase str
]



] ;; end of acgiss object