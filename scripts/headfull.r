REBOL [
    Title: "Full REBOL Header"
    Date: 29-Apr-1999
    Name: 'Full-Header
    Version: 0.1.2
    File: %headfull.r
    Home: http://www.rebol.com/
    Author: "Carl Sassenrath"
    Owner: "REBOL Headquarters"
    Rights: "Copyright (C) Carl Sassenrath 1997"
    Tabs: 4
    Purpose: {
      Shows the optional definitions that can be
      used within a REBOL header.
   }
    Comment: {
      The purpose or general reason for the script
      should go above and important comments or notes
      about the script can go here.
   }
    History: [
    0.1.0 [5-Nov-1997 "Created this example" "Carl"] 
    0.1.1 [8-Nov-1997 { Moved the header up, changed
         comment on extending the header, added advanced
         user comment.} "Carl"]
]
    Language: 'English
    Email: carl@sassenrath.com
    Need: 0.1.4
    Charset: 'ANSI
    Example: "Show how to use it."
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print {
   The REBOL header identifies your script as text that
   can be interpreted by REBOL. It is used as the source
   of information for title bars, selection menus, web
   documents, archives, configuration, preferences,
   editors, and authoring systems.

   NOT EVERY FIELD NEEDS TO BE SUPPLIED!  And, some fields,
   such as the date and version require certain datatypes
   (see docs). It is suggested that you give all scripts at
   least a TITLE and a DATE.  Other fields can be supplied
   as in the example below.  The fields may appear in any
   order, and new fields may be defined in the future.

   If you need to provide more than one value in a field
   put it in a block (but keep the field word the same):

      Author: ["John Smith" "Bob Able" "Ted Baker"]

   There is also be a way to provide your own "extended"
   header words, without confusing them with the "official
   words". This will be described in the documentation.
}

advanced-users: {
   The REBOL header is actually a MODULE object.  It is
   translated and executed prior to the translation of the
   rest of your script. This means that it can provide special
   options to the translation process, such as alternate
   charsets or other yet-to-be-defined preferences.
}
