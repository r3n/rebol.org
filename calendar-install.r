REBOL [
   Author: {Izkata}
   Email: Izkata@Comcast.net
   File: %calendar-install.r
   Date: 24-Jul-2005
   RealCreationDates: [1-Jul-2005 to 19-Jul-2005]
   Title: {Synchronizable Calendar/Scheduler}
   Purpose: {Easy-to-use Calendar/Scheduler that can be synchronized over a network, and has popup-alerts.}
   Info: {
      Scary how easy it was to make something like this.... It took so long because I had
      to discover algorithms for the schedules..  And I kept adding/discarding ideas as I
      created it and changing the main datafile format... BAD, BAD idea if you want to get
      it done quickly!!

      Interesting tidbits:
         The original installer was 32.3 KB large.
         Then I added comments to the (amazingly confusing) code, and it increased to 43.9 KB
         Then I fixed the sync'ing section (%Networking.r) to work nicer, and it shrank: 43.6 KB
         Finally, I added a nice Help section that allows comments and editing: 50.9 KB

      Also... If you find bugs with the Networking parts... TELL ME! (Please?)  I wasn't able to
      get to the family desktop for very long to test it much.  (dern brothers!)
   }
   History: [
      24-Jul-2005 {Initial Upload}
      26-Jul-2005 {A few fixes... Changed to a Package}
   ]
   Library: [
      level: 'advanced
      platform: [win windows]
      type: [tool package]
      domain: [gui ]
      tested-under: {Rebol/View 1.3.1 in WinXP}
      support: none
      license: none
      see-also: none
   ]
]

Instructions: {
            This is the stub... Run to open the packager, and choose Calendar-Install.r for the real thing  ^^.^^
}

view/new layout/tight [backdrop white text Instructions]

do http://www.rebol.org/library/public/repack.r