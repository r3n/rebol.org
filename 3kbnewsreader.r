REBOL [
    Title: "3KB News Reader"
    Date: 28-Jun-2000
    Version: 0.1.1
    File: %3kbnewsreader.r
    Author: "Ryan C. Christiansen"
    Owner: "Ryan C. Christiansen"
    Rights: "Copyright (C) Ryan C. Christiansen 2000"
    Tabs: 4
    Purpose: "Simple CLI news reader."
    Comment: {
      Requires %nntp.r interpreter.
      
      News Reader options include:
      
      G - new group
      N - next message
      P - previous message
      S - post
      Q - quit
   }
    History: [
        0.1.0 [28-Jun-2000 "First version." "Ryan"] 
        0.1.1 [28-Jun-2000 {Fixed UI bug. Script now asks
        	 for newsgroup name and sets parameters up front.} "Ryan"]
    ]
    Email: norsepower@uswest.net
    library: [
        level: 'intermediate 
        platform: none 
        type: 'Tool 
        domain: 'other-net 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

do %nntp.r

print rejoin [newline newline newline
		 "Welcome to the 2.16KB News Reader 0.1"
		 newline newline "What is the name of your news server?"]
news-server: input
open-server: reform [rejoin ["np: open news://" news-server]]
do open-server

valid-options: ["G" "N" "P" "S" "Q"]
option: copy ""

display-options: func [
    "display newsreader options and seek input"
][
    print rejoin [newline "OPTIONS:"
    			 newline "G - new group"
    			 newline "N - next msg"
    			 newline "P - previous msg"
    			 newline "S - post"
    			 newline "Q - quit"
    			 newline newline "What next?"]
    clear option
    option: input
]

print "Name of newsgroup?"
newsgroup-name: input
group-stats: insert np [count from newsgroup-name]
msg-list: copy []
for i group-stats/2 group-stats/3 1 [append msg-list form i]
msg-position: 0
print rejoin ["There are "
			 group-stats/1
			 " messages on the server for this newsgroup."]

forever [

    display-options

    either error? try [find/any option valid-options
        ][
        print rejoin ["invalid choice - try again"
        			 newline "OPTIONS:"
        			 newline "G - new group"
        			 newline "N - next msg"
        			 newline "P - previous msg"
        			 newline "S - post"
        			 newline newline "What next?"]
        clear option
        option: input
        ][
        switch option [
        
            "G" [   print "Name of newsgroup?"
                    newsgroup-name: input
                    group-stats: insert np [count from newsgroup-name]
                    msg-list: copy []
                    for i group-stats/2 group-stats/3 1
                    	 [append msg-list form i]
                    msg-position: 0
                    print rejoin ["There are " group-stats/1
                    		" messages on the server for this newsgroup."]
                ]
                
            "N" [   either msg-position = group-stats/1 [
                        "You're already at the last message."
                        ][
                        msg-position: msg-position + 1
                    ]
                    next-message: reform [
                    		rejoin ["msg-list/" msg-position]]
                    new-message: reform [
                    	rejoin [{msg-to-display:insert np
                    		[headers-bodies of }
                    		next-message { from "}
                    		newsgroup-name {"]}] ]
                    do new-message
                    print msg-to-display
                ]
                
            "P" [   either msg-position = 1 [
                        "You're already at the first message."
                        ][
                        msg-position: msg-position - 1
                    ]
                    previous-message: reform [
                    	rejoin ["msg-list/" msg-position]]
                    new-message: reform [
                    	rejoin [{msg-to-display: insert np
                    		 [headers-bodies of }
                    		 previous-message { from "}
                    		 newsgroup-name {"]}] ]
                    do new-message
                    print msg-to-display
                ]
                
            "S" [   print {What would you like to say?
            			(<ENTER> will send your message.)}
                    body: input
                    msg-id: insert np [post body to newsgroup-name]
                ]
                
            "Q" [   quit
                ]
        ]
    ]
]
