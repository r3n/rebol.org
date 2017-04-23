Rebol [
   file: %samman.r
   date: 1-Jan-2012
   title: "Sammy's manager"
   purpose: {To generate Sammy.js files using a dialect}
   library: [
   author: "Sabu Francis, India"
   copyright: "Sabu Francis, 2012"
   license: "GPL 2.0"
   platform: 'all
   type: [tool]
   level: 'intermediate
   see-also: http://sammyjs.org 
   revision: 0.0.1
   description: {
   Sammy's Manager is a Dialect to create a
   Sammy.js application which hopefully is simpler
   than writing a Sammy.js app directly in javascript.
   
   It uses a rough and ready dialect written over an afternoon
   I wrote it to come to grip with Sammy.js which is actually
   quite elegant and many may believe that it need not be 
   further simplified. As Einstien said, "You should make things
   simple but not simpler"
   
   But I wanted ot bring it kicking and 
   screaming somehow into the Rebol world ...and wanted to see
   what emerged with the powerful dialecting feature of Rebol
   
   Eventually, my dream is to invent a 'declarative' kind
   of web language that internally uses sammy.js and jquery
   something like Opa or Prolog
   
   Hope you like it. This was tested with the JSON-STORE
   example given in the Sammy.js website
   
   It would be very easy to use this as a CGI-Script, so
   you can have your work done in this dialect, and internally
   everything actually gets done via Sammy
   
   My rough estimate tells me that this is around 65% of the
   original javascript written code and it is far more cleaner
   to read
   
   Concepts:
   --------
   The basic idea of this module is to use a Rebolish way
   of writing Sammy apps. i.e. avoid delimiters as much 
   as possible. I've used it to delineate some blocks so that
   code-folding editors can work nicely
   
   Rebol kind of syntax. No parathensis whatsoever unless you use
   native Javascript embedded inside
   
   There are 4 code blocks within a Sammy app 
   (I have not yet put the "put" and "delete" code-blocks
   in this version. I am not an expert in sammy.js)
    
   The blocks all follow the same pattern:
   first is the verb, second is the route string, third is the code
   to be executed which is given as a Rebol block!
   
   Verbs defined are: 
   "around", "get", "put", "bind" (though strictly 
   "around" and "bind" are sammy's inventions...not verbs)
   
   If a code block contains unavoidable javascript, put that
   inside curly braces (i.e. Rebol string) ...and if your
   javascript for some strange reason has a dangling brace
   put that inside as ^(7b) ...which is the escape code for
   the opening brace
   
   so if you want to go Javascript mostly the whole way then
   you can just write this kind of code
   
   get "#/" [ 
   {
    javascript;
    javascript;
    javascript;
   }]
   
   but then Sammy's manager will feel he is not getting fully
   utilized to make Sammy's performances better. He will stand
   backstage and weep but won't hinder Sammy's show.
   
   For other functionality like fetching (and creating) a
   session variable, updating the session variable, updating
   HTML inside some Jquery selectable container, there are
   nice helpers in this Sammy's manager dialect.
   
   Updating HTML is specially delectable. It takes a block
   of jquery selectors. The very first one is the parent
   one, and others coming after it are "found" and daisy-chained
   using the usual Jquery dot operator. The HTML
   is deposited right after all that finding. So if you 
   used a "class" selector (which starts with a dot) 
   instead of an "id" selector (which starts with a #) then
   you will find jquery has updated the text in all of those
   elements of that it found with that class. I can imagine
   this to be quite magical, actually
   
   
   So Sammy, go on stage and do your classy act! The manager
   is with you!
   -------------
   
   After parsing your loaded string with "sam_man" dialect
   the "accumulator" string variable would contain the
   generated SammyJS app. Make sure you clean it up for
   next round
   
   -----
   Request
   As this is GPL, kindly put your head on this and
   improve this code
   
   }
   ]
  ]


;;;"Sam's Manager" Dialect spec

accumulator: copy "" 

addtostr: func[ str ] [
  append accumulator str
 ]

putuse: func [ plugins /local i] [
  foreach i plugins
  [
   
    addtostr replace copy {
    this.use('~');
    } "~" i
     
   ]
  

 ]

putapp: func [] [
  
  addtostr copy {
(function($) ^(7b)
  var app = $.sammy('#main', function() }
  addtostr "{"

 ]
 
putappdef: func [ def ] [

  addtostr replace copy {
  
  ^});//app defined
  
    $(function() {
      app.run('~');
    });
  
  ^})(jQuery);
  
  } "~" def
  
 ] 

dothen: func [ cb] [          	   
      
      either (type? cb) = word! [
          	    addtostr replace copy {
              .then(~)} "~" to-string cb 
          	     ][
		addtostr replace copy {
              .then(function(items) ^(7b)
                    ~   	
          	    }"~" cb
          	    addtostr "})"  ;;;no semi-colon! hmmm
          	     ]
		]

getblkparams: func [ somevars /local sblki sblklen sblkstr s][
                 sblki: 1
                 sblklen: length? somevars
                 sblkstr: copy ""
                 foreach s somevars [
                   append sblkstr s
                   if sblki < sblklen [ append sblkstr ","  ]
                   sblki: sblki + 1
	           ]                   
		sblkstr
                 ]

funcend: func [comm] [
  addtostr "^/   });"
  addtostr comm
 ]

doRendAppendTo: func [ whichtemplate somevars somevars2 /local m jsonstr le v ][
                    m: 1
                    jsonstr: copy ""
                    le: length? somevars
                    foreach v somevars [
                     append jsonstr somevars2/:m
                     append jsonstr ": "
                     append jsonstr v
                     if m < le [append jsonstr ", "]
                     m: m + 1
                     ]
                    
                    addtostr
                    replace
                    replace copy {
               context.render('~1', {~2})
               	  .appendTo(context.$element());} "~1" whichtemplate
               	       "~2" jsonstr
			               	       
                    ]


formupdatehtmlstr: func [ jquerysel thevalue /local qstr qs ][
              qstr: copy replace copy "          $('~')" "~" jquerysel/1
              foreach qs next jquerysel
                [
              append qstr replace copy ".find('~')" "~" qs
                 ]
      	      append qstr replace copy ".text(~).end()" "~" thevalue
      	      qstr 
      	     ] 
sam_man: [

 'app set defroute string! 
      (putapp )
 '=== 
 'use set plugins block! ( putuse plugins  )
  some  [
           aroundFunc
          
           |
         
           getRoute
           
           |
           
           postRoute
           
           |
           
           bindRoute

        ]
  
   (putappdef defroute)

   ]



aroundFunc: [ 'around set aroundCallBack word! 
		(
		addToStr {
   this.around(function(callback) ^(7B)
		}
		)
			set
			  aroundStatsBlk
			block!
			 ( 
			 parse aroundStatsBlk aroundStats
			 funcend "//around over!" 
			 ) 
	     ] 

getRoute:  [  'get set routeStr string! 
		(
		addToStr replace copy {
	        
   this.get('~', function(context)^(7b) } "~" routeStr
	        )
		  set
		    routeStatsBlk
		  block!
		   (
		    parse routeStatsBlk routeStats
		    funcend "// get over!"
		    )
            ]
postRoute: [ 'post set postStr string! 
		(
		addToStr replace copy {
	        
   this.post('~', function(context)^(7b) } "~" postStr
	        )

		  set
		    routeStatsBlk
		  block!
		   (parse routeStatsBlk routeStats
		    funcend "// post over!"
		   )
	    ]
bindRoute: [ 'bind set bindStr string! 
		(
		addToStr replace copy {
	        
   this.bind('~', function()^(7b) } "~" bindStr
	        )

		  set
		    routeStatsBlk
		  block!
		   (parse routeStatsBlk routeStats
		    funcend "//bindover!"
		   )
	    ]


loadStats:[
              some [
       	
       	   'then set cb string!
          	    (
          	   dothen cb
          	    
          	     
          	    )
          	    
	   	 |
      	   'then set cb word!
          	    (
          	   dothen cb
          	     
          	    )
          	    
	        (addtostr {
               ;} )
      	   	 
      	        ] 
    	
	]

thenstrs: [
   
      some [ set js string!  ( addtostr js )] 

    ]

aroundStats: [
     some [
      set str string! ( addtostr str) 
      |
      'load set loadurl string! (addtostr 
      				 copy replace {
         this.load('~')
             } "~" loadurl)
             
       set
       
       	 loadStatsBlk
       
        block! ( parse loadStatsBlk loadStats)
       	  
      ]
     
     ]


                 

 

routeStats: [

             some [
              
              'cleanApp 
               (
                addToStr {
                context.app.swap('');
                }
               )
              |
              'witheach set somevars block!
                (
                 sblkstr: getblkparams somevars
                 
                 addToStr replace copy
                 {
                 $.each(this.items, function(~) ^(7b)
                 } "~" sblkstr
                )
                
                'renderAndAppendToContext
                    set whichtemplate string!
                    set
                      somevars2
                    block!
                    (
                    doRendAppendTo whichtemplate 
                    		somevars somevars2

                    )
                    
                    
              (funcend "")
              
              |
              'renderPartial set whichTemplate string!
	       (
	       
	       addToStr replace copy
	       {
	       this.partial('~');
	       } "~" whichTemplate
	       
	       )
              |
              'fetchSession set sessvar word!
              (
               
               addtostr replace/all
      		copy {
      		var ~  = this.session('~', function() {
	              return {};
      		});
      		} "~" to-string sessvar
              
              )
              |
              'updateSession set sessVar word!
              (
              addtostr replace/all copy {
               this.session('~', ~);
              } "~" to-string sessVar 
              
              )
              |
              'trigger set bind-event word!
              (
              addtostr replace copy {
               this.trigger('~');
              } "~" to-string bind-event
             
              )
              |
              'updateHTML 
                 set jquerysel  block!
                 set thevalue word!
                 set animstrsBlock block! 
                 (
            
               qstr: formupdatehtmlstr jquerysel thevalue
	       addtostr qstr
	       ;;;now the animation or other effects
	       foreach animstr animstrsBlock [
	       addtostr replace copy {
	          .animate({~})} "~" animstr
      	        ] 
      	        addtostr ";"
      	        )
                 
              |
              set js string!
              (
              addToStr js
              )
              ] 
            ]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;             SAMMY's Manager dialect done!
;;;;;             (can't u see the stage lights?)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;sample below:

parse [

app "#/"
===
use [Template Session]

around callback
 [
  
  {
   var context = this;
  }
  
  load "data/items.json"
   [
    
    then {
     context.items = items; 
      }
     then callback
   ] 
 ] 

get "#/" [
 
  cleanapp
  witheach  [i item] 
     renderAndAppendToContext "templates/item.template" 
        [id item ]
  
  


]

get "#/item/:id" [
 {
      this.item = this.items[this.params['id']];
      if (!this.item) { return this.notFound()}
 }
 renderPartial "templates/item_detail.template"

] 

post "#/cart" [
 
 {
 
   var item_id = this.params['item_id'];
 
 }
 
 fetchSession cart
 
 {
       if (!cart[item_id]) {
         // this item is not yet in our cart
         // initialize its quantity with 0
         cart[item_id] = 0;
       }
       cart[item_id] += parseInt(this.params['quantity'], 10);

 }
 updateSession cart
 trigger update-cart
 

]

bind "update-cart" [
{
       var sum = 0;
           $.each(this.session('cart') || {}, function(id, quantity) {
             sum += quantity;
      });
}

  updateHTML  [".cart-info" ".cart-items"] sum
 	[
 	 "paddingTop: '30px'"
 	 "paddingTop: '10px'"
 	]

]

bind "run" [

 trigger update-cart
]


] sam_man


;;;To test, uncomment the string below and generate the javascript
;;;rename the old json_store.js to something else
;;;and rename the generated one to json_store.js and put it 
;;;in the "javascripts" folder of the Sammy JSON STORE sample application
{
  write %samtest.js accumulator
}