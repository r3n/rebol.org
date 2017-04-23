REBOL [
    Title: "MySQL database interfacing logic."
    Date: 18-May-2001/9:24:31+2:00
    Version: 1.0.0
    File: %mysql_all.r
    Author: "Maarten Koopmans, Ernie van der Meer"
    Purpose: {Interface to the mysql libs, needs /Pro or /Command}
    Email: m.koopmans2@chello.nl
    dependant: "Depends on contract.r"
    Limititations: "NO error handling yet"
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'DB 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

; Make sure we know about contract and such.
system/error/user: make system/error/user [ pre-error: [ "The precondition " :arg1 " was not met" ]  ]
system/error/user: make system/error/user [ post-error: [ "The postcondition " :arg1 " was not met" ]  ]


block-all: func [ { Block variant on all.  Evaluates al netsed blocks as conditions.} a [any-block!]][

    ;Are we @ the tail? Then we have evaluated all the conditions succesfully. Return true.
    either tail? a
    ; We are at the end of the conditions, return true
    [ return true]
    [
      ; Is the block empty or does it contain none
      either any [ empty? first a none? first first a]
      [
        ;yes, skip and do the next condition
        block-all next a
      ]
      [
        ;Continue... we have a valid condition
        ;If the first condition is true, recursively call block-all on the next
        either do first a
        [ block-all next a]
        [return false]
      ];either any
    ]
]

find-false: func [ {Finds the first false block in a block of blocks and return at the start of it.}  a [any-block!] ]
                 [
                   ;Initialize. Skip all empty and none! conditions
                   ;until [ either any [ empty? first a none? first first a]  [a: next a ] [true ] ]
                   while [all [(not tail? a) (do first a)] ]
                   [
                     ;go to the next element and skip empty ones and ones of type none!
                     until [ either any [ empty? first a none? first first a]  [a: next a false] [a: next a true ] ]
                   ]
                   return  copy a
                 ]

contract: func [ {Contracts are functions that support pre and post conditions, aka design by contract.
                                    Note that your code should return a value (at least none) for this to work.}
                 args [any-block!] {Function arguments.}
                 conditions [any-block!] { conditions in the format: [ pre [ [cond1] [cond2]] post [[cond3] ..]}
                 locals [any-block!] {Local variables to the function.}
                 body [any-block!] {The body of the function, should ALWAYS return a value (at least none).}
                 /local pre-cond post-cond pre-code post-code func-args func-body
                                    cond-block do-func inner-func do-body
               ]
               [
                 pre-code: copy []
                 post-code: copy []

                 ;Find the pre conditions
                 pre-cond: select conditions 'pre
                 if (not none? pre-cond)
                 [
                    ;Pre-code is the code for the precondition.
                    pre-code: copy compose/deep [ if not block-all compose/deep [(pre-cond)]]
                    ;Append some code. We need to split the compose because we use a compose again in the resulting code :)
                    append cond-block: copy compose/deep [ cond: mold first find-false compose/deep [(pre-cond)]] [ make error! compose [ user pre-error (cond)]]
                    ;And append the cond-block to pre-code. Now we have our pre-code ready.
                    append/only pre-code cond-block
                 ]

                 post-cond: select conditions 'post
                 ;Find the pre conditions
                 if (not none? post-cond)
                 [
                    ;Pre-code is the code for the precondition.
                    post-code: copy compose/deep [ if not block-all compose/deep [(post-cond)]]
                    ;Append and compose some code. We need to split the compose because we use a compose again in the resulting code :)
                    append cond-block: copy compose/deep [ cond: mold first find-false compose/deep [(post-cond)]] [ make error! compose [ user post-error (cond)]]
                    ;And append the cond-block to pre-code. Now we have our pre-code ready.
                    append/only post-code cond-block
                 ]

                                 ;Append the local variables to the argument block
                 append func-args: copy args /local
                                 append func-args [ __return __ret_err]
                                 append func-args locals

                                 ;if the body is empty, make sure it returns none
                                 if body = []
                                 [
                                    body: copy [ none ]
                                 ]

                                 ;We evaluate the body as an anonymous function with access to all or locals
                                 do-body:  copy compose/deep [ __innerfunc: func [] [(:body)]]


                 ; Change the function body to include the conditions
                                 func-body: copy []
                                 ; we at least return none
                                 insert func-body copy [ __return: none ]
                                 append func-body copy pre-code
                                 append func-body do-body
                                 append func-body copy [ __return: __innerfunc ]
                 append func-body copy post-code
                                 append func-body copy [ __return ]

                 ;Create and return the function
                 return func func-args func-body

               ]

; Get the method signatures for MySQL
;Change to whatever is the path to your MySQL client lib
mysql-lib: load/library %libmysql.dll


mysql-error-map:
[ ER_HASHCHK 1000
  ER_NISAMCHK 1001
  ER_NO 1002
  ER_YES 1003
  ER_CANT_CREATE_FILE 1004
  ER_CANT_CREATE_TABLE 1005
  ER_CANT_CREATE_DB 1006
  ER_DB_CREATE_EXISTS 1007
  ER_DB_DROP_EXISTS 1008
  ER_DB_DROP_DELETE 1009
  ER_DB_DROP_RMDIR 1010
  ER_CANT_DELETE_FILE 1011
  ER_CANT_FIND_SYSTEM_REC 1012
  ER_CANT_GET_STAT 1013
  ER_CANT_GET_WD 1014
  ER_CANT_LOCK 1015
  ER_CANT_OPEN_FILE 1016
  ER_FILE_NOT_FOUND 1017
  ER_CANT_READ_DIR 1018
  ER_CANT_SET_WD 1019
  ER_CHECKREAD 1020
  ER_DISK_FULL 1021
  ER_DUP_KEY 1022
  ER_ERROR_ON_CLOSE 1023
  ER_ERROR_ON_READ 1024
  ER_ERROR_ON_RENAME 1025
  ER_ERROR_ON_WRITE 1026
  ER_FILE_USED 1027
  ER_FILSORT_ABORT 1028
  ER_FORM_NOT_FOUND 1029
  ER_GET_ERRNO 1030
  ER_ILLEGAL_HA 1031
  ER_KEY_NOT_FOUND 1032
  ER_NOT_FORM_FILE 1033
  ER_NOT_KEYFILE 1034
  ER_OLD_KEYFILE 1035
  ER_OPEN_AS_READONLY 1036
  ER_OUTOFMEMORY 1037
  ER_OUT_OF_SORTMEMORY 1038
  ER_UNEXPECTED_EOF 1039
  ER_CON_COUNT_ERROR 1040
  ER_OUT_OF_RESOURCES 1041
  ER_BAD_HOST_ERROR 1042
  ER_HANDSHAKE_ERROR 1043
  ER_DBACCESS_DENIED_ERROR 1044
  ER_ACCESS_DENIED_ERROR 1045
  ER_NO_DB_ERROR 1046
  ER_UNKNOWN_COM_ERROR 1047
  ER_BAD_NULL_ERROR 1048
  ER_BAD_DB_ERROR 1049
  ER_TABLE_EXISTS_ERROR 1050
  ER_BAD_TABLE_ERROR 1051
  ER_NON_UNIQ_ERROR 1052
  ER_SERVER_SHUTDOWN 1053
  ER_BAD_FIELD_ERROR 1054
  ER_WRONG_FIELD_WITH_GROUP 1055
  ER_WRONG_GROUP_FIELD 1056
  ER_WRONG_SUM_SELECT 1057
  ER_WRONG_VALUE_COUNT 1058
  ER_TOO_LONG_IDENT 1059
  ER_DUP_FIELDNAME 1060
  ER_DUP_KEYNAME 1061
  ER_DUP_ENTRY 1062
  ER_WRONG_FIELD_SPEC 1063
  ER_PARSE_ERROR 1064
  ER_EMPTY_QUERY 1065
  ER_NONUNIQ_TABLE 1066
  ER_INVALID_DEFAULT 1067
  ER_MULTIPLE_PRI_KEY 1068
  ER_TOO_MANY_KEYS 1069
  ER_TOO_MANY_KEY_PARTS 1070
  ER_TOO_LONG_KEY 1071
  ER_KEY_COLUMN_DOES_NOT_EXITS 1072
  ER_BLOB_USED_AS_KEY 1073
  ER_TOO_BIG_FIELDLENGTH 1074
  ER_WRONG_AUTO_KEY 1075
  ER_READY 1076
  ER_NORMAL_SHUTDOWN 1077
  ER_GOT_SIGNAL 1078
  ER_SHUTDOWN_COMPLETE 1079
  ER_FORCING_CLOSE 1080
  ER_IPSOCK_ERROR 1081
  ER_NO_SUCH_INDEX 1082
  ER_WRONG_FIELD_TERMINATORS 1083
  ER_BLOBS_AND_NO_TERMINATED 1084
  ER_TEXTFILE_NOT_READABLE 1085
  ER_FILE_EXISTS_ERROR 1086
  ER_LOAD_INFO 1087
  ER_ALTER_INFO 1088
  ER_WRONG_SUB_KEY 1089
  ER_CANT_REMOVE_ALL_FIELDS 1090
  ER_CANT_DROP_FIELD_OR_KEY 1091
  ER_INSERT_INFO 1092
  ER_INSERT_TABLE_USED 1093
  ER_NO_SUCH_THREAD 1094
  ER_KILL_DENIED_ERROR 1095
  ER_NO_TABLES_USED 1096
  ER_TOO_BIG_SET 1097
  ER_NO_UNIQUE_LOGFILE 1098
  ER_TABLE_NOT_LOCKED_FOR_WRITE 1099
  ER_TABLE_NOT_LOCKED 1100
  ER_BLOB_CANT_HAVE_DEFAULT 1101
  ER_WRONG_DB_NAME 1102
  ER_WRONG_TABLE_NAME 1103
  ER_TOO_BIG_SELECT 1104
  ER_UNKNOWN_ERROR 1105
  ER_UNKNOWN_PROCEDURE 1106
  ER_WRONG_PARAMCOUNT_TO_PROCEDURE 1107
  ER_WRONG_PARAMETERS_TO_PROCEDURE 1108
  ER_UNKNOWN_TABLE 1109
  ER_FIELD_SPECIFIED_TWICE 1110
  ER_INVALID_GROUP_FUNC_USE 1111
  ER_UNSUPPORTED_EXTENSION 1112
  ER_TABLE_MUST_HAVE_COLUMNS 1113
  ER_RECORD_FILE_FULL 1114
  ER_UNKNOWN_CHARACTER_SET 1115
  ER_TOO_MANY_TABLES 1116
  ER_TOO_MANY_FIELDS 1117
  ER_TOO_BIG_ROWSIZE 1118
  ER_STACK_OVERRUN 1119
  ER_WRONG_OUTER_JOIN 1120
  ER_NULL_COLUMN_IN_INDEX 1121
  ER_CANT_FIND_UDF 1122
  ER_CANT_INITIALIZE_UDF 1123
  ER_UDF_NO_PATHS 1124
  ER_UDF_EXISTS 1125
  ER_CANT_OPEN_LIBRARY 1126
  ER_CANT_FIND_DL_ENTRY 1127
  ER_FUNCTION_NOT_DEFINED 1128
  ER_HOST_IS_BLOCKED 1129
  ER_HOST_NOT_PRIVILEGED 1130
  ER_PASSWORD_ANONYMOUS_USER 1131
  ER_PASSWORD_NOT_ALLOWED 1132
  ER_PASSWORD_NO_MATCH 1133
  ER_UPDATE_INFO 1134
  ER_CANT_CREATE_THREAD 1135
  ER_WRONG_VALUE_COUNT_ON_ROW 1136
  ER_CANT_REOPEN_TABLE 1137
  ER_INVALID_USE_OF_NULL 1138
  ER_REGEXP_ERROR 1139
  ER_MIX_OF_GROUP_FUNC_AND_FIELDS 1140
  ER_NONEXISTING_GRANT 1141
  ER_TABLEACCESS_DENIED_ERROR 1142
  ER_COLUMNACCESS_DENIED_ERROR 1143
  ER_ILLEGAL_GRANT_FOR_TABLE 1144
  ER_GRANT_WRONG_HOST_OR_USER 1145
  ER_NO_SUCH_TABLE 1146
  ER_NONEXISTING_TABLE_GRANT 1147
  ER_NOT_ALLOWED_COMMAND 1148
  ER_SYNTAX_ERROR 1149
  ER_DELAYED_CANT_CHANGE_LOCK 1150
  ER_TOO_MANY_DELAYED_THREADS 1151
  ER_ABORTING_CONNECTION 1152
  ER_NET_PACKET_TOO_LARGE 1153
  ER_NET_READ_ERROR_FROM_PIPE 1154
  ER_NET_FCNTL_ERROR 1155
  ER_NET_PACKETS_OUT_OF_ORDER 1156
  ER_NET_UNCOMPRESS_ERROR 1157
  ER_NET_READ_ERROR 1158
  ER_NET_READ_INTERRUPTED 1159
  ER_NET_ERROR_ON_WRITE 1160
  ER_NET_WRITE_INTERRUPTED 1161
  ER_TOO_LONG_STRING 1162
  ER_TABLE_CANT_HANDLE_BLOB 1163
  ER_TABLE_CANT_HANDLE_AUTO_INCREMENT 1164
  ER_DELAYED_INSERT_TABLE_LOCKED 1165
  ER_WRONG_COLUMN_NAME 1166
  ER_WRONG_KEY_COLUMN 1167
  ER_WRONG_MRG_TABLE 1168
  ER_DUP_UNIQUE 1169
  ER_BLOB_KEY_WITHOUT_LENGTH 1170
  ER_PRIMARY_CANT_HAVE_NULL 1171
  ER_TOO_MANY_ROWS 1172
  ER_REQUIRES_PRIMARY_KEY 1173
  ER_NO_RAID_COMPILED 1174
  ER_UPDATE_WITHOUT_KEY_IN_SAFE_MODE 1175
  ER_KEY_DOES_NOT_EXITS 1176
  ER_CHECK_NO_SUCH_TABLE 1177
  ER_CHECK_NOT_IMPLEMENTED 1178
  ER_CANT_DO_THIS_DURING_AN_TRANSACTION 1179
  ER_ERROR_DURING_COMMIT 1180
  ER_ERROR_DURING_ROLLBACK 1181
  ER_ERROR_DURING_FLUSH_LOGS 1182
  ER_ERROR_DURING_CHECKPOINT 1183
  ER_NEW_ABORTING_CONNECTION 1184
  ER_DUMP_NOT_IMPLEMENTED    1185
  ER_FLUSH_MASTER_BINLOG_CLOSED 1186
  ER_INDEX_REBUILD  1187
  ER_MASTER 1188
  ER_MASTER_NET_READ 1189
  ER_MASTER_NET_WRITE 1190
  ER_FT_MATCHING_KEY_NOT_FOUND 1191
  ER_LOCK_OR_ACTIVE_TRANSACTION 1192
  ER_ERROR_MESSAGES 193
];mysql-error-map

mysql-init: make routine!
[
  [save]
  in [integer!]
  return: [integer!]
] mysql-lib "mysql_init"

mysql-connect: make routine!
[
  [save]
  mysql       [integer!]
  host        [string!]
  user        [string!]
  passwd      [string!]
  db          [string!]
  port        [integer!]
  socket      [integer!]
  clientflag  [integer!]
  return:     [integer!]
] mysql-lib "mysql_real_connect"

mysql-close: make routine!
[
  mysql       [integer!]
] mysql-lib "mysql_close"

mysql-query: make routine!
[
  mysql       [integer!]
  query       [string!]
  return:     [integer!]
] mysql-lib "mysql_query"

mysql-ping: make routine!
[
  mysql       [integer!]
  return:     [integer!]
] mysql-lib "mysql_ping"

mysql-store-result: make routine!
[
  mysql       [integer!]
  return:     [integer!]
] mysql-lib "mysql_store_result"

mysql-errno: make routine!
[
    mysql [integer!]
    return: [integer!]
] mysql-lib "mysql_errno"

mysql-error: func [ num [integer!] /local ind msg]
[
    either (found? find mysql-error-map num)
    [
        ind: (index? find mysql-error-map num) - 1
        return (to-string pick mysql-error-map ind)
    ]
    [
        return "No matching error message found"
    ]
]

mysql-free-result: make routine!
[
  mysql_res   [integer!]
] mysql-lib "mysql_free_result"

mysql-num-rows: make routine!
[
   mysqlres [integer!]
   return: [integer!]
] mysql-lib "mysql_num_rows"

mysql-num-fields: make routine!
[
  mysqlres [integer!]
  return: [integer!]
] mysql-lib "mysql_num_fields"

mysql-database: make object! [
  connection: none
  initial: none
  sql-current-time: "now()"

  init: contract
  [
    [catch] {Initialize a database connection}
    user [string!] {User name.}
    passwd [string!] {The Password.}
    database[ string! ] {The database to connect to.}
    host[ string! ] {The host that runs the database.}
    nport [integer!] {The port to connect to}
  ]

  [ post [[not none? connection][not none? initial ] [ ( 0 = mysql-ping connection)]]]
  [ err ] ; Local variables
  [
    err: try
    [
      initial: mysql-init 0
      connection: mysql-connect initial host user passwd database nport 0 0
    ]
    if error? err [ probe disarm err ]
  ]

  auto-commit: contract
  [
    [catch] {Set autocommit on or off. Useless in current mysql versions.}
    commit? [ logic! ]
  ]
  [
  ];no conditions
  [ ];no locals
  [
  ];no logic yet

  query: contract
  [
    {Query the database with the specified query/queries}
    [catch]
    the-query [string!]
    /with-result {Return a result set.}
  ]
  [
    pre [ [ not none? connection ] [ not empty? the-query ] ]
  ]
  [
        errno errmsg
  ]
  [
    mysql-query connection the-query
        if (not ( 0 = mysql-errno connection))
        [
            errno: mysql-errno connection
            errmsg: copy mysql-error errno
            make error! rejoin [ {MySQL Error number } errno {.} newline errmsg ]
        ]

    if with-result
    [
      return result
    ]
  ]

  result: contract
  [
    {Return the result-set that is waiting from a previous query}
    [catch]
    /part {Return at most a part of the result set.}
    how-many {How many rows to return.}
  ]
  [
    pre [[ not none? connection] ]
  ]
  [
    result-set num-rows num-fields result-struct result-list
    result-row fields temp
  ]
  [
    result-set: mysql-store-result connection

        if (not ( 0 = mysql-errno connection))
        [
            errno: mysql-errno connection
            errmsg: copy mysql-error errno
            make error! rejoin [ {MySQL Error number } errno {.} newline errmsg ]
        ]


    if result-set = 0 [ return none ]

        if (not ( 0 = mysql-errno connection))
        [
            errno: mysql-errno connection
            errmsg: copy mysql-error errno
            make error! rejoin [ {MySQL Error number } errno {.} newline errmsg ]
        ]


    num-rows: mysql-num-rows result-set
    if num-rows = 0 [ return none ]

        if (not ( 0 = mysql-errno connection))
        [
            errno: mysql-errno connection
            errmsg: copy mysql-error errno
            make error! rejoin [ {MySQL Error number } errno {.} newline errmsg ]
        ]


    num-fields: mysql-num-fields result-set

        if (not ( 0 = mysql-errno connection))
        [
            errno: mysql-errno connection
            errmsg: copy mysql-error errno
            make error! rejoin [ {MySQL Error number } errno {.} newline errmsg ]
        ]


    result-list: make block! copy []

    routine-spec: make block!  [ mysql-res [integer!] return: ]
    result-struct-spec: make block! []

    for fields 1 num-fields 1
    [
      append result-struct-spec  to-word join "a" fields
      append/only  result-struct-spec copy  [string!]
    ]

    append/only routine-spec append/only copy [struct!] copy result-struct-spec

    mysql-fetch-row: make routine! :routine-spec mysql-lib "mysql_fetch_row"

    for fields 1 num-rows 1
    [
      temp: mysql-fetch-row result-set

            if (not ( 0 = mysql-errno connection))
            [
                errno: mysql-errno connection
                errmsg: copy mysql-error errno
                make error! rejoin [ {MySQL Error number } errno {.} newline errmsg ]
            ]

      result-row: copy second temp
      free temp
      append/only result-list result-row
    ]

    mysql-free-result result-set

        if (not ( 0 = mysql-errno connection))
        [
            errno: mysql-errno connection
            errmsg: copy mysql-error errno
            make error! rejoin [ {MySQL Error number } errno {.} newline errmsg ]
        ]


    either how-many
    [
      return copy/part result-list how-may
    ]
    [
      return result-list
    ]
  ]
  commit: contract
  [{Perform a commit on a queued set of statements.}[catch]]
  [ pre [ [ not none? connection] ] ]
  [ ];no local variables
  [ ]

  rollback: contract
  [ {Do a rollback on a set of transactions.} [catch] ]
  [ pre [ [ not none? connection] ] ]
  [ ] ;no local variables
  [ ]

  close-all: contract
  [ {Close all open database connections} [ catch]  ]
  [ pre [ [ not none? connection] ] ]
  [ ]
  [
    mysql-close connection
  ]
]
