REBOL [
    Title: "List FTP upload"
    Date: 22-Jun-1999
    Version: 1
    File: %listftpupload.r
    Home: http://www.qsl.net/n0ukf/
    Author: "Elliott Olson"
    Purpose: {
      FTP upload multiple files using login and password.
      Supports a full upload or partial for updates
      from lists in %sitedata.reb and %siteupdate.reb.
      }
    Comment: {
      Edit the site: line for username, password, site address and directory
      Edit filepath: line to direct the script to the directory containing files for the site
      Change sitedata.reb and siteupdate.reb to your list filenames. 
      Make 2 files, one for full site upload containing the names of all files starting with %,
      one per line, and one for updates containing the names of only those files that will be updated
      (html pages, other changed or added files), one per line.  Save as ASCII text files.
      }
    Email: ejolson@means.net
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [other-net ftp] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

which: ask " Is this a full site upload (y/n)? "
site: ftp://username:password@ftp.site.dom/directory/
filepath: %/c/full/path/filedir/   ;path to directory containing files for the site

files: load either which = "y" [%sitedata.reb] [%siteupdate.reb]
;change sitedata.reb and siteupdate.reb to your list filenames.

foreach file files [
    print file
    write/binary join site file read/binary file
]

