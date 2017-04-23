REBOL [
    Title: "Updating and Creating links in INDEX files"
    Date: 14-Jan-2002
    Version: 1.0.0
    File: %update_index.r
    Author: "JL MEYRIAL"
    Purpose: "Update/create links in index files"
    Comment: { To create links in index files or to edit index files }
    Email: jl_meyrial@ciriel.fr
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: [file-handling GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
] 

maj_ind: context [

   ipath: join system/options/home "desktop/icons/"

   instructions: { Make your choice:
               - "ADD A LINK" to add a link in an index file
                 and then:
                   . choose a link type "Folder", "File" or "WWW"
                   . input the data fields
                   . click the button "Update Index file" and make the file selection

            or - "EDIT A FILE" to edit a file
                 and then click the button "Edit" and make the file selection
   }  
   l_titre1: copy "ADD A LINK"
   l_titre2: copy "EDIT A FILE"
   l_act1: copy "Update Index File"
   l_act2: copy "Edit"
   l_act: copy l_act1
   l_encours: copy l_titre1
   p_titre: func [n_choix /local files ]
   [
      if n_choix <> l_encours
      [
         l_encours: n_choix
         either n_choix = l_titre1
         [
            f_pan/pane: l_pan
            remove find l_lay/pane f_act2
            append l_lay/pane f_act1
         ]
         [
            f_pan/pane: none
            remove find l_lay/pane f_act1
            append l_lay/pane f_act2
         ]
         show l_lay
      ]
   ]
   p_choix: func [n_choix /local files ]
   [
      if n_choix = "local"
      [
         if files: request-file
         [
            f_lien/text: files show f_lien
         ]
      ]
   ]
   p_edit: func [ /local file_index ]
   [
      if file_index: request-file/only/keep/file/title %index.r "Edit File Index:" "Select"
      [
         if exists? file_index
         [   editor file_index ]
      ]
   ]
   p_maj: func [ /local file_index file out date size name t_fic b_fic]
   [
      if file_index: request-file/only/keep/file/title %index.r "Update/Create File Index:" "Save"
      [
         if not exists? file_index
         [
            out: reform ["REBOL [type: 'index date:" now "]" newline newline]
            write file_index out
         ]
         out: copy ""
         b_fic: to-block f_lien/text
         foreach file b_fic
         [
            either f_type/text = "URL"
            [
               if type? file <> 'url
               [ file: to-url file ]
            ]
            [
               if type? file <> 'file
               [ file: to-file file ]
            ]
        if all [ exists? file not dir? file ]
            [
               t_fic: switch/default t_lien/text
                      [
                        "Folder" [ 'folder ]
                        "WWW"     [ 'link ]
                      ]
                      [
                         'file
                      ]
               either t_fic = 'link
               [
              append out mold/only reduce [t_fic f_lib/text file ]
               ]
               [
              date: modified? file
              size: size? file
              append out mold/only reduce [t_fic f_lib/text file reduce [size date] ]
               ] 
               if choix_icon <> "default"
               [
                  append out " "
              append out mold/only reduce ['icon to-word choix_icon ]
               ]
           append out newline
           append out mold/only reduce ['info f_info/text ]
           append out newline
        ]
         ]
         write/append file_index out
         request/ok "UPDATING IS MADE"
      ]
   ]
   show-help: does [
      request layout [ txt as-is instructions
                       button "CLOSE" [hide-popup]
                     ] 
   ]
   choix_icon: copy "default"
   p_icon: func [ n_icon]
   [
      choix_icon: copy n_icon
      either n_icon <> "default"
      [
         if not find l_pan/pane f_icon [ append l_pan/pane f_icon ]
         f_icon/image: load to-file reduce [ipath  join n_icon ".gif" ]
      ]
      [
         remove find l_pan/pane f_icon
      ]
      show l_lay
   ]
   bloc_lay: make block!
   [
      across
      choice 100x50 :l_titre1 :l_titre2 [p_titre first value]
      tab tab button "HELP" [show-help ] button "QUIT" [quit]
      return
      f_pan: box 500x200
      return
      f_act1: button 100x50 l_act1 [ p_maj]
      f_act2: button 100x50 l_act2 [ p_edit]
   ]
   b_pan: make block! [
      across
      t_lien: choice "Folder" "File" "WWW"
      return
      f_type: choice "URL" "local" [p_choix first value]
      tab f_lien: field "File Name or URL"
      return
      h1 "Label"
      tab tab f_lib: field "Link Label"
      return
      h1 "Help Text"
      tab f_info: field "Help Text"
      return
      h1 "Icon"
      rotary "default"
   ]
   r_icon: open ipath
   forall r_icon
   [
      if head? r_icon
      [
         ifile: to-file reduce [ipath (first r_icon)]
      ]
      parse (first r_icon) [ copy st to #"."]
      append b_pan st
   ]
   close r_icon
   append b_pan [
      [p_icon value]
      f_icon: image ifile effect [key 174.154.122]
   ]
   l_pan: layout b_pan
   l_pan/offset: 0x0
   l_lay: layout bloc_lay
   f_pan/pane: l_pan
   remove find l_pan/pane f_icon
   f_act2/offset: f_act1/offset
   remove find l_lay/pane f_act2
]

view/options maj_ind/l_lay [resize]
 

                                                                                                                                                                                                     