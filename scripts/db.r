REBOL [
    Title: "Simple Rebol DBMS"
    Date: 11-Sep-2001
    Name: "RebolBase"
    Version: 1.2.0
    File: %db.r
    Author: "Jamey Cribbs"
    Purpose: {RebolBase is a simple database managment system
               written entirely in Rebol.  Its main feature is
               that it stores its data in plain, newline delimited
               text files.  This allows the database to be accessed
               and modified by other programs.
   }
    History: {
         7-Sep-2001 1.0.0 "Posted initial version to Rebol.com"
         7-Sep-2001 1.0.1 "Had to move some comments and repost."
         8-Sep-2001 1.0.2 "Added db-flush function."
         9-Sep-2001 1.1.0 "Added sort, subset criteria to db-select."
        10-Sep-2001 1.2.0 "Cleaned up internals a bit."
    }
    Email: "cribbsj@oakwood.org"
    Features: {
        * Stores data in plain, newline delimited text files.
        * Built in auto-increment field.
        * Insert, update, delete, flush, select functions.
        * Uses regular parse syntax for string queries.
        * Ability to specify sort criteria in db-select.
        * Ability to specify a subset of fields to include in result
          set of db-select.
    }
    To-do: {
        * Improve db-select query criteria syntax and processing.
        * Speed improvements for larger tables.
    }
    Example: {

        do %db.r
        plane: make-table
        plane/db-open/new %plane.tbl [["name" "string"]["country"
         "string"]["speed" "integer"]["range" "integer"]]
        plane/db-insert ["P-51" "USA" 403 1255]
        plane/db-insert ["Spitfire" "Great Britain" 333 556]
        foreach record plane/db-select [["country" ["Great Britain" to
         end]]][
            poke record 3 "England"
            recno: first head record
            record: next head record
            plane/db-update recno record
        ]
        plane/db-close

        *Note*  No changes are saved to disk until you db-close.
    }
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [DB file-handling text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

; Main function.  Call this function first to create the table object.
make-table: func [
    "Returns table object."
][
    make object! [
        status: 'closed
        file: copy []
        fields-type: copy []
        fields-pos: copy []
        rows: copy []


        ; This is an internal object function used by db-insert and
        ; db-update to validate the data being put into the table.
        validate-fields: func [
            "Validates values and returns success."
            values [block!]
        ][
            ; Does number of values equal number of fields? I subtract
            ; 1 from fields so that we don't count the auto-increment
            ; field that is system generated.  The user does not have
            ; the ability to change this field once it is created.
            if (length? values) <> ((length? fields-pos) - 1) [
                return make error!
                 "ERROR: (validate) Wrong number of fields."
            ]

            ; Does type of each value match type specified in table
            ; header for that field?  I have to multiply count by 2
            ; because I need to skip every other field in fields-type.
            ; Then, I have to add 2 because I need to skip over
            ; the auto-increment entry at the beginning of the fields-
            ; type block.
            repeat count length? values [
                if (to-string type? pick values count) <>
                 (pick fields-type ((count * 2) + 2)) [
                    return make error! reform
                     ["ERROR: (validate) Invalid data type for"
                     (pick fields-pos ( + 1))]
                ]
            ]
            return true
        ]

        ;Table manipulation functions.

        ;-------------------------------------------------------------
        ; db-open
        ;-------------------------------------------------------------
        db-open: func [
            "Reads in file to table and returns success or error."
            input-file [file!]
            /new
            "Use new if you want it to create a new file."
            input-fields [block!]
            /local row temp-block
        ][
            temp-block: copy []

            ; If table not closed, don't open it.
            if not status = 'closed [
                return make error!
                 "ERROR: (open) Table status not closed!"
            ]

            ; If new refinement is specified, create the external
            ; file before opening the table.
            if new [
                if exists? input-file [
                    return make error!
                     "ERROR: (open/new) File already exists!"
                ]

                ; Insert the auto-increment field at the front of the
                ; fields block.
                insert/only input-fields ["recno" "integer"]

                input-fields: head input-fields

                ; Write the header line to a new file.
                if error? try [write/lines input-file remold
                 [0 input-fields]][
                    return make error!
                     "ERROR: (open/new) Writing to file."
                ]
            ]

            if not exists? input-file [
                return make error! "ERROR: (open) File doesn't exist!"
            ]

            ; Read in each molded line and append it to a temporary
            ; block.
            if error? try [foreach row read/lines input-file [
                            append/only temp-block load row
                          ]
            ][
                return make error! "ERROR: (open) Reading in file."
            ]

            ; Now, set up the object variables.  Status is now open,
            ; file is set to the external file name, auto-inc is set
            ; to the last record number used to insert a record,
            ; fields is set to a block containing the name and type of
            ; each column, rows is set to a block containing all
            ; table rows.
            status: 'open
            file: input-file
            auto-inc: first first temp-block

            fields-pos: copy []
            fields-type: copy []

            ; Now, we set up a couple of blocks, fields-type and
            ; fields-pos.  fields-type look like this: ["recno"
            ; "integer" "name" "string" "country" "string"].  fields-
            ; pos looks like this: ["recno" "name" "country"].
            repeat count length? second first temp-block [
                append fields-type first (pick (second first
                 temp-block) count)
                append fields-type second (pick (second first
                 temp-block) count)
                append fields-pos first (pick (second first
                 temp-block) count)
            ]
            rows: copy next temp-block

            return true
        ]

        ;-------------------------------------------------------------
        ; db-insert
        ;-------------------------------------------------------------
        db-insert: func [
            "Adds a record to table.  Returns recno or error."
            values [block!]
            /local try-result temp-values
        ][
            if status = 'closed [
                return make error! "ERROR: (insert) Table closed!"
            ]

            ; Validate input data.
            if (error? try-result: validate-fields values) [
                return try-result
            ]

            ; Needed to have this temp-values field because I insert
            ; values into this block.  I found that if I loop through
            ; this function multiple times and don't copy the values
            ; block to a temporary block, then I proprogate each
            ; inserted value into the subsequent loop's block.
            temp-values: copy values

            ; Increment auto-increment field.
            auto-inc: auto-inc + 1

            ; Insert auto-increment field at front of new record.
            insert temp-values auto-inc

            ; Append new record to table.
            append/only rows temp-values

            ; Change status to dirty.  I'm not sure what I will use
            ; this for.  Maybe in the future, I will add some code
            ; to check for dirty status before exiting an app or
            ; closing the table.  Dirty just means that the data in
            ; the table does not match the data in the physical file.
            ; I may be using the term incorrectly.
            status: 'dirty

            return auto-inc
        ]

        ;-------------------------------------------------------------
        ; db-delete
        ;-------------------------------------------------------------
        db-delete: func [
            "Deletes a record from table. Returns success or error."
            recno [integer!]
        ][
            if status = 'closed [
                return make error! "ERROR: (update) Table closed!"
            ]

            rows: head rows
            forall rows [
                ; If the recno supplied to function matches the recno
                ; for this row, remove the row.
                if (first first rows) = recno [
                    remove rows
                    status: 'dirty
                    return true
                ]
            ]

            ; If it gets to here, means did not find record number.
            return make error! "ERROR: (delete) Record no. not found!"
        ]

        ;-------------------------------------------------------------
        ; db-update
        ;-------------------------------------------------------------
        db-update: func [
            "Updates a record in table.  Returns success or error."
            recno [integer!]
            values [block!]
            /local try-result temp-values
        ][
            if status = 'closed [
                return make error! "ERROR: (update) Table closed!"
            ]

            ; Validate input data.
            if (error? try-result: validate-fields values) [
                return try-result
            ]

            ; See comment in db-insert.
            temp-values: copy values

            rows: head rows
            forall rows [
                ; If found the correct record number.
                if (first first rows) = recno [
                    ; Insert correct recno at front of input data so
                    ; that it makes a proper table record.
                    insert temp-values recno
                    ; And change the table row.
                    change/only rows temp-values
                    status: 'dirty
                    return true
                ]
            ]

            ; If it gets to here, didn't find the record number.
            return make error! "ERROR: (update) Record no. not found!"
        ]

        ;-------------------------------------------------------------
        ; db-close
        ;-------------------------------------------------------------
        db-close: func [
            "Writes table to disk.  Returns success or error."
            /local header-block
        ][
            fields-type: head fields-type
            header-block: copy []

            forskip fields-type 2 [
                append/only header-block reduce [first fields-type
                 second fields-type]
            ]

            ; First overwrite the old file with a new file just
            ; holding the header record.
            if error? try [write/lines file remold [auto-inc
             header-block]][
                return make error! "ERROR: (db-close) Writing header!"
            ]

            ; Now, append a molded line for every table row.
            rows: head rows
            forall rows [
                if error? try [write/lines/append file mold first
                 rows][
                    return make error!
                     "ERROR: (db-close) Closing file."
                ]
            ]

            ; Change the status to closed.  This will ensure that we
            ; don't subsequently insert or update the table until we
            ; have re-opened it.
            status: 'closed

            return true
        ]

        ;-------------------------------------------------------------
        ; db-flush
        ;-------------------------------------------------------------
        db-flush: func [
            "Writes table to disk. Does not close. Returns success."
            /local try-result
        ][
            if (error? try-result: db-close) [
                return try-result
            ]
            status: 'open

            fields-type: head fields-type
            fields-pos: head fields-pos
            rows: head rows

            return true
        ]

        ;-------------------------------------------------------------
        ; db-select
        ;-------------------------------------------------------------
        db-select: func [
            "Returns block of records based on query criteria."
            criteria [block!]
            /subset
            "Include only a subset of all fields in record."
            subset-block [block!]
            "Fields to include."
            /sorted
            sort-block [block!]
            /local result found search-block
        ][
            ; Criteria is a block that specifies the selection
            ; criteria.  The format is:
            ; [["field to search on" ["selection criteria"]]...].
            ; The selection criteria block format depends on the field
            ; type.
            ;
            ; For string! fields the format is standard parse match
            ; criteria. For example, plane/db-select
            ; [["country" ["Great Britain" to end]]].
            ;
            ; For numeric fields the format uses keywords such as EQ,
            ; LT, LE, GT, GE, NE.  For example, plane/db-select
            ; [["recno" [EQ 5678]]].
            ;
            ; You can combine as many selection criteria blocks as you
            ; wish.  For example, plane/db-select [["country"
            ; ["Germany" | "Japan" to end]]["speed" [GT 350]]] will
            ; return all the planes from Germany and Japan with a
            ; maximum speed greater than 350 mph.
            ;
            ; The subset refinement allows you to specify which fields
            ; you want included in the result set.  If you use this
            ; refinement, then you must include a block of field names
            ; that you want to include.  For example, 
            ; plane/db-select/subset [["country" ["USA" to end]]]
            ; ["name" "speed"] will select all US planes and include
            ; only the name and speed for each record.
            ;
            ; The sorted refinement allows you to specify sort
            ; criteria for the result set.  It uses the standard sort/
            ; compare syntax.  If you use this refinement, you must
            ; include a comparison block.  However, instead of field
            ; offsets, you specify field names instead.  For example,
            ; plane/db-select/sorted [["country" ["USA" to end]]]
            ; [reverse "country" forward "name"] will select all US 
            ; planes and
            ; sort them in descending order by country and then
            ; ascending order by name.  If you specify the subset
            ; refinement, then you can only sort on fields included
            ; in the subset block.

            if status = 'closed [
                return make error! "ERROR: (select) Table closed!"
            ]

            search-block: copy []
            result: copy []

            ; First, I create a temporary block to hold what we are
            ; searching on and for.  To create the block, I will step
            ; through each search criteria specified by the user.
            foreach criterion criteria [
                ; Is the field to search on a valid field name?
                either find fields-pos criterion/1 [
                    ; If so, then add the field's column position,
                    ; the field type (i.e. "integer") and the actual
                    ; data to search on (i.e. "GT 350") to the search
                    ; block.
                    append/only search-block reduce [(index? find
                     fields-pos criterion/1)(select fields-type
                     criterion/1) criterion/2]
                ][
                    return make error! reform ["ERROR: (select)"
                     "Invalid field name in search criteria:"
                     criterion/1]
                ]


            ]
            ; If the subset refinement was specified, check the
            ; subset block to see if it contains valid field names.
            either subset [
                forall subset-block [
                    if not find fields-pos (first subset-block) [
                        return make error! reform ["ERROR: (select)"
                         "Invalid field name in subset block:"
                         first subset-block]
                    ]
                ]
                ; If subset was specified, use the subset-block to
                ; determine which fields to include in the result set.
                include-fields: copy head subset-block

            ][
                ; Otherwise, use fields-pos which will ensure that all
                ; fields are in the result set.
                include-fields: copy fields-pos
            ]
            ; If the sorted refinement was specified, check the sort
            ; criteria block to make sure the field names in it are
            ; valid.
            if sorted [
                sort-criteria: copy []
                forall sort-block [
                    ; Is this a field name or a compare parameter
                    ; (i.e. "reverse" or "forward").
                    either (type? first sort-block) = string! [
                        ; Is it a valid field name?
                        either find include-fields first sort-block [
                            ; If so, find its position in the list of
                            ; fields that will be in the result set
                            ; and add that to the sort-criteria block.
                            ; I do this because the compare refinement
                            ; uses field positions.
                            append sort-criteria (index? find
                             include-fields
                             first sort-block)
                        ][
                            return make error! reform
                             ["ERROR: (select) Invalid field name"
                             "in sort block:" first sort-block]
                        ]
                    ][
                        ; If it is a compare parameter, simply add it
                        ; to the sort-criteria block.
                        append sort-criteria first sort-block
                    ]
                ]
            ]

            ; This code block will be used in the switch statement
            ; below.  I can probably do it a lot cleaner if I think
            ; about it long enough.
            numeric-comparison: [
                switch pick (pick first search-block 3) 1 [
                    ; If the numeric comparison operator matches EQ...
                    EQ [
                        ; Grab the field value from the table column
                        ; we are searching on and see if it is equal
                        ; to the value that the user specified.  If
                        ; not, set the found flag to false.
                        if not (pick first rows
                         (pick first search-block 1)) =
                         (second (pick first search-block 3)) [
                            found: false
                        ]
                    ]
                    NE [
                        if (pick first rows
                         (pick first search-block 1)) =
                         (second (pick first search-block 3)) [
                            found: false
                        ]
                    ]
                    GT [
                        if not (pick first rows
                         (pick first search-block 1)) >
                         (second (pick first search-block 3)) [
                            found: false
                        ]
                    ]
                    GE [
                        if not (pick first rows
                         (pick first search-block 1)) >=
                         (second (pick first search-block 3)) [
                            found: false
                        ]
                    ]
                    LT [
                        if not (pick first rows
                         (pick first search-block 1)) <
                         (second (pick first search-block 3)) [
                            found: false
                        ]
                    ]
                    LE [
                        if not (pick first rows
                         (pick first search-block 1)) <=
                         (second (pick first search-block 3)) [
                            found: false
                        ]
                    ]
                ][
                    return make error! join "ERROR: (select) Invalid "
                     "numeric comparison operator."
                ]
            ]

            rows: head rows

            ; Step through each table row checking to see if it
            ; matches all search criteria from search-block.
            forall rows [
                ; We start out assuming it does and then check each
                ; row against all search criteria to see if it
                ; doesn't.
                found: true

                search-block: head search-block

                ; Step through each search criteria.
                forall search-block [
                    ; Search differently based on the type of field
                    ; we are searching on.  Right now, there are only
                    ; two types of searches, string and everything
                    ; else, but this could be expanded in the future
                    ; if need be.
                    switch/default pick first search-block 2 [
                        "integer" numeric-comparison
                        "date" numeric-comparsion
                        "decimal" numeric-comparison
                        "time" numeric-comparison
                        "money" numeric-comparison
                    ][
                        ; Defaults to string! comparison.
                        if not (parse (pick first rows
                         (pick first search-block 1))
                         pick first search-block 3) [
                            found: false
                        ]
                    ]
                ]
                ; If, after all of the comparsions, the row still
                ; qualifies as a search match, then add it to the
                ; result set.
                if found [
                    temp-row: copy []
                    ; Here is where we use the include-fields block we
                    ; built earlier.  For each field in the include-
                    ; fields block we find out what column position
                    ; it is in and grab the correspond field from the
                    ; table to a temporary block.
                    foreach member include-fields [
                        append temp-row pick (first rows) (index? find
                        fields-pos member)
                    ]
                    ; Add that temporary block to the result set.
                    append/only result temp-row
                ]
            ]
            ; If the sort refinement was specified, sort the result
            ; set using the sort-criteria block we built earlier.
            if sorted [
                if error? try [sort/compare result sort-criteria][
                    return make error! form ["ERROR: (select) Invalid"
                     "sort criteria!"]
                ]
            ]

            ; Return the result set to the user.
            return result
        ]
    ]
]






                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          