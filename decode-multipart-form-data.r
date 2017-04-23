REBOL [
    Title:
        "decode-multipart-form-data"
    Authors:
        ["Andreas Bolka"]
    Contributors:
        []
    Date:
        2014-05-21
    History:
        [
            2002-06-18 abolka "initial release"
            2003-02-21 abolka "major bugfixes and cleanup. example improved."
            2003-02-22 abolka "another parsing bug fixed"
            2003-09-12 abolka "fixed n/v-handling bug, noted by Marc Meurrens"
            2004-07-18 abolka "major restructuring"
            2014-05-21 abolka "relicense under apache license, version 2.0"
        ]
    Rights: {
        Copyright (C) 2002-2014 Andreas Bolka

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
    }
    File:
        %decode-multipart-form-data.r
    Version:
        1.5
    Purpose: {
        Decodes POST-data used in "Form-based File Upload in HTML" as specified
        in RFC 1867, encoded as "multipart/form-data" as specified in RFC 2388.
    }
    Usage: {
        decode-multipart-form-data's output is compatible to decode-cgi
        wherever possible. So the output contains a list of set-word's and
        values, one pair for each data field. example:

            [field1: "foo" field2: "bar"]

        Parts of the form-data with content-type text/plain and no filename
        attribute in the content dispostition will be translated to basic name
        value pairs as in the example above.

        Parts having with a content-type different from text/plain and/or a
        filename attribute in their content disposition will be translated to
        object!'s with the following fields: filename, type, content.

        An example. Imagine an HTML form like the following:

            <form method="post" enctype="multipart/form-data">
            <input type="text" name="field1" value="foo" />
            <input type="file" name="field2" />
            </form>

        Once this form is submitted with "foo" in field1 and a file called
        "bar.txt" containing the three bytes "nuf" in field2, this will result
        in the following to be returned from 'decode-multipart-form-data:

            [
                field1: "foo"
                field2: make object! [
                    filename: "bar.txt"
                    type: "text/plain"
                    content: "nuf"
                ]
            ]

        A typical call of decode-multipart-form-data looks like the following
        example:

            decode-multipart-form-data system/options/cgi/content-type post-data
    }
]

;
; @@
; - add multipart/mixed support
; - add content-transfer-encoding support
; - improve parse-multipart (handle arbitrary header)
;

context [

    parse-boundary: func [content-type /local boundary] [
        boundary: none
        parse/all content-type [
            thru "boundary="
            opt #"^""
            copy boundary
            [to #"^"" | to #";" | to #"," | to end]
        ]
        return boundary
    ]

    parse-multipart: func [
        boundary
        entity-body
        /local parts part-beg part-end dispo type content
    ] [
        parts: copy []

        part-beg: rejoin ["--" boundary crlf]
        part-end: rejoin [crlf "--" boundary]

        parse/all entity-body [
            to part-beg
            some [
                (dispo: none type: copy "text/plain" content: none)

                part-beg
                "content-disposition: " copy dispo to crlf crlf
                opt ["content-type: " copy type to crlf crlf]
                crlf
                copy content
                to part-end crlf

                (repend parts [dispo type content])
            ]
            "--" crlf
        ]

        parts
    ]

    set 'decode-multipart-form-data func [
        content-type
        entity-body
        /local bd parts r n v p
    ] [
        if any [
            (not find content-type "multipart/form-data")
            (none? bd: parse-boundary content-type)
        ] [
            make error! "Invalid Content-Type or no boundary parameter."
        ]

        parts: parse-multipart bd entity-body

        r: copy []
        foreach [pdispo ptype pcontent] parts [
            pdispo: next parse pdispo {;="}

            n: to-set-word select pdispo "name"
            v: pcontent
            if any [
                (select pdispo "filename")
                (not find ptype "text/plain")
            ] [
                v: make object! compose [
                    filename: (select pdispo "filename")
                    type: (ptype)
                    content: (pcontent)
                ]
            ]

            either p: find r n
                [change/only next p reduce [(first next p) v]]
                [repend r [n v]]
        ]
        r
    ]
]

;;

context [
    ct1: {multipart/form-data; boundary=---------------------------5884326489707}
    eb1:
{-----------------------------5884326489707^M
Content-Disposition: form-data; name="name"^M
^M
asdf^M
-----------------------------5884326489707^M
Content-Disposition: form-data; name="name"^M
^M
bsdf^M
-----------------------------5884326489707^M
Content-Disposition: form-data; name="file"; filename="test.txt"^M
Content-Type: text/plain^M
^M
test:^M
^M
-----------------------------5884326489707^M
Content-Disposition: form-data; name="text"^M
^M
^M
-----------------------------5884326489707--^M
}

    exp1: compose [
        (to-set-word 'name) ["asdf" "bsdf"]
        (to-set-word 'file)
            (make object! [
                filename: "test.txt"
                type: "text/plain"
                content: "test:^M^/"
            ])
        (to-set-word 'text) (none)
    ]

    regress: has [got1] [
        either = mold/all exp1 mold/all got1: decode-multipart-form-data ct1 eb1
            [print "OK"]
            [print "ERR: " probe got1]
    ]

]