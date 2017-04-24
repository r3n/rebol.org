REBOL [
        file: %r3-rehash.r
       title: "R3 Hash function"
      author: "Sunanda" 
        date: 19-nov-2010 
     version: 0.0.2 
     purpose: {Provide a hash function (case sensitive map) for R3}
     library: [
         level: 'beginner
      platform: 'all
          type: [tool function]
        domain: [math scientific financial] 
  tested-under: [win]
       support: none
       license: 'BSD
      see-also: none 
       history: [
                 0.0.1 19-Nove-2010 {First release}
                 ]
      ]
] 


rehash: context [
  create: func ["Creates a new hash block"
      data [block!]
     /local
      hash
     ][
     
     hash: make map! []
     foreach [key item] data [
        append hash reduce [__make-key key item]
        ]
      return hash
      ]
   retrieve: func ["Given a key, retrieves its data"
       hash [map!]
       key
      ][
       return select hash __make-key key
      
      ]
   update: func ["Add/remove key and data (set data to none to remove)"
      hash [map!]
      key
      data
     ][
       append hash reduce [__make-key key data]
       return true
 ]    
 
   __make-key: func ["Internal function to convert key to binary"
       key
     ][
       return either binary? key [key][to-binary form key]
       ]
      
   ]
     
     
  comment [
  ;;    example of usage
  ;; ======================  

        do %r3-rehash.r

     ;; create a hash with various datatypes as both key and data  
  
        hash: rehash/create ["key1" 1111 #key2 "2222" 3x3 %data-3]

        rehash/retrieve hash #key2       ;; retrieve a value
        == "2222"

        rehash/update hash #key2 none     ;; delete a [key value] pair
        == true

        rehash/retrieve hash #key2        ;; check it has gone
        == none
        
      ]