REBOL [
   Author: {Izkata}
   Email: Izkata@Comcast.net
   File: %entity.r
   Date: 29-Jul-2005
   Title: {Beware the Entity}
   Purpose: {Little creature that runs around faces playing around}
   Info: {
      It's a simple entity (creature) that runs around a face and does random things.

      Currently does: Shake other subfaces, create and kick a red ball, or draw on the face.

      Problem:  It's -very- glitchy right now.

      Use: view layout [Entity %Path/To/An/Image] ;Preferably an animated GIF.
   }
   History: [
      29-Jul-2005 {Initial Upload}
   ]
   Library: [
      level: 'advanced
      platform: [win windows]
      type: [fun package]
      domain: [ai animation]
      tested-under: {Rebol/View 1.3.1 in WinXP}
      support: none
      license: none
      see-also: none
   ]
]

Instructions: {
            This is the stub... Run to open the packager, and choose Entity.r for the real thing  ^^.^^
}

view/new layout/tight [backdrop white text Instructions]

do http://www.rebol.org/library/public/repack.r