REBOL [
    Title: "Lowercase All Tags"
    Version: 1.0.0
    Author: "Carl Sassenrath"
    File: %lowertag.r
    Date: 21-Jan-2005
    Purpose: {
        Given an HTML or XML file, shifts all tags to lowercase.
        Everything in the tag is lowercased, so you will need to
        inspect the resulting file names, etc. But, for most
        files this is easier than doing it manually. (Also shows
        how easy it is to do this kind of conversion.)
    }
    Library: [
        level: 'beginner
        platform: 'all
        type: [tool]
        domain: [html text markup]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

file: request-file/only
if not file [quit]

content: load/markup file
foreach tag content [
    if tag? tag [lowercase tag]
]

insert find file "." 2 ; do not overwrite source file
write file content