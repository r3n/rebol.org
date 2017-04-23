rebol [
  Library: [
     level: 'beginner
     platform: []
     type: [tool how-to function]
     domain: [file-handling text]
     tested-under: none
     support: none
     license: pd
     see-also: none
   ]
    file: %extend-an-object.r
    date: 20-nov-2003
    author: "Sunanda"
    title: "Extend an object"
    purpose: "Dyamically add fields (and sub-objects) to an object from a template"

]



;;	-----------------------------------------------
;;	Extends an object according to a template of
;;	all fields that must exist in it.
;;
;;	Intended for use immediately after reading a file
;;	that contains the object. 
;;	So use with caution if the object is aleady in
;;	memory and has other (or circular) references
;;
;;	-------------------------------------------------
extend-an-object: func [
        obj [object!]
        template [object!]
        ]
        
[
  foreach field next first template
  [
     if  error? try [obj/:field]
        [obj: construct/with  reduce [to-set-word field template/:field] obj]

    if object? template/:field
        [obj: construct/with   reduce [to-set-word field extend-an-object obj/:field template/:field] obj]

 ] ;; for


return do mold obj

] ;; func