REBOL [
    Title: "Load-Parse-Tree (Parse-Analysis)"
    Date: 17-June-2006
    File: %load-parse-tree.r
    Purpose: "Load a block structure representing your input as matched by Parse."
    Version: 1.0.0
    Author: "Brett Handley"
    Web: http://www.codeconscious.com
    Comment: "Requires parse-analysis.r (see rebol.org)"
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: [dialects parse text-processing]
        tested-under: [
            View 1.3.2.3.1 on [WinXP] {Basic tests.} "Brett"
        ]
        support: none
        license: none
        comment: {
Copyright (c) 2006, Brett Handley
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* This program must not be used to run websever CGI or other server processes.

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer. 
  
* Redistributions in binary form must reproduce the above
  copyright notice, this list of conditions and the following
  disclaimer in the documentation and/or other materials provided
  with the distribution. 

* The name of Brett Handley may not be used to endorse or
  promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
}
        see-also: parse-analysis.r
    ]
]

load-parse-tree: func [
    "Tokenises the input using the rule names."
    body [block!] "Invoke Parse on your input. The block must return True in order to return the result."
    hook-context [object!] "Hook context returned by the Hook-Parse function."
    /block input [any-block!] "For block input, supply the input block here so it can be indexed."
] [
    use [stack result fn-b fn-e block-list index-fn] [
	index-fn: :index?
        stack: make block! 20
        result: copy []
        fn-b: does [
		insert/only tail stack result
		result: copy []
	]
        fn-e: func [context-stack begin-context end-context /local content tk-len tk-ref] [
	    ; Restore state to parent of just completed term.
	    content: result
            result: last stack
            remove back tail stack

	    ; Term has just completed - insert it into the result or discard it.
            if 'pass = end-context/status [
                either 1 + begin-context/step = end-context/step [
			tk-len: subtract index? end-context/last-end index? begin-context/last-begin ; Length
			tk-ref: begin-context/last-begin ; Input position
			content: copy/part tk-ref tk-len
		][new-line/all/skip content 1 2]
                insert tail result reduce [end-context/current content]
            ]
        ]
        explain-parse/begin/end body hook-context :fn-b :fn-e
        new-line/all/skip result true 2
    ]
]
