REBOL [
   File: %profile-timer.r
   Title: "Event profile timer"
   Author: "Sunanda"
   Date: 6-oct-2004
   Version: 0.0.0
   Purpose: {Helps you time events when tuning code}
   Library: [
       level: 'beginner
       platform: 'all
       type: [tool]
       domain: [testing]
       tested-under: [win]
       support: none
       license: [gpl]
       see-also: none
     ]
    ]

profile-timer: func [event-name [string!]
                     /start
                     /stop
                     /show
                     /show-all
                     /reset
                     /local
                      timer-block
                      current-event
                      now-time
                      event-template
][
 now-time: now/time/precise
 event-template: make object!
                 [event-id: ""
                  total-completed-events: 0
                  total-time: 0:0:0
                  current-event: none
                 ]

 timer-block: []

 if show-all [return timer-block]
 if reset [clear timer-block return true]

 ;; Must be start or stop or show
 ;; -----------------------------

 current-event: none
 foreach event timer-block
     [
      if event/event-id = event-name
         [
          current-event: event
          break
         ]
     ]

 if all [none? current-event stop] [make error! "trying to stop timing of an unknown event"]
 if all [none? current-event show] [make error! "trying to show an unknown event"]

 if show [return current-event]

 if all [stop none? current-event/current-event] [make error! "trying to stop an unstarted event"]

 if stop
    [
     current-event/total-completed-events: 1 + current-event/total-completed-events
     current-event/total-time: current-event/total-time + (now-time - current-event/current-event/1)
     current-event/current-event: none
     return current-event
    ]

 ;; only possibility left is a start
 ;; --------------------------------

 if none? current-event
   [
    current-event: make event-template []
    current-event/event-id: event-name
    insert timer-block current-event
   ]


 if not none? current-event/current-event [make error! "trying to start an already started event"]

 current-event/current-event: copy reduce [now-time]
 return current-event

]




