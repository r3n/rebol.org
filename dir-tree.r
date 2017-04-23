REBOL [
    Title: "dir-tree"
    Date: 20-Jun-1999
    Version: 1.0.0
    File: %dir-tree.r
    Author: "Stephane Bagnier"
    Tabs: 4
    Usage: {
        "dir-tree %My-Directory" echoes a block containing the whole
        hierarchy of files and directories starting from %My-Directory.
        The depth refinement allows you to set a maximum depth to the
        recursive search: "dir-tree/depth %My-Directory 3". Note you can
        use 'dir-tree on a ftp site: "dir-tree ftp://www.rebol.com/".
    }
    Purpose: {
        Recursively build a rebol and human readable tree
                from a directory or a ftp site. Maximum depth can be set.
    }
    Organization: "D2SET french association"
    Web-Site: http://www.multimania.com/d2set/
    Email: bagnier@physique.ens.fr
    Need: 2
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

dir-tree: func [
    current-path [file! url!] "directory to explore"
    /inner
    tree [block!] "useful to avoid stack overflow"
    /depth "recursion depth, 1 for current level, -1 for infinite"
    depth-arg [integer!]
    /local
    current-list
    sub-tree
    item
][
    if all [not inner not block? tree] [tree: copy []]
    depth-arg: either all [depth integer? depth-arg] [depth-arg - 1][-1]
    current-list: read current-path
    if not none? current-list [
        foreach item current-list [
            insert tail tree item
            if all [dir? current-path/:item not-equal? depth-arg 0] [
                sub-tree: copy []
                dir-tree/inner/depth current-path/:item sub-tree depth-arg
                insert/only tail tree sub-tree
            ]
        ]
    ]
    return tree
]
