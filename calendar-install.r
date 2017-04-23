REBOL [
   Author: {Izkata}
   Email: Izkata@gmail.com
   File: %calendar-install.r
   Date: 24-Jul-2005
   RealCreationDates: [1-Jul-2005 to 19-Jul-2005]
   Title: {Synchronizable Calendar/Scheduler}
   Purpose: {Easy-to-use Calendar/Scheduler that can be synchronized over a network, and has popup-alerts.}
   Info: {
      Interesting tidbits:
         The original installer was 32.3 KB large.
         Then I added comments to the (amazingly confusing) code, and it increased to 43.9 KB
         Then I fixed the sync'ing section (%Networking.r) to work nicer, and it shrank: 43.6 KB
         Finally, I added a nice Help section that allows comments and editing: 50.9 KB

      If there are more problems, I do try to check the Rebol3 AltME world at least once a day...
   }
   History: [
      21-Jan-2008 {A couple of problems found that crash View 1.3.2...  Both fixed}
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