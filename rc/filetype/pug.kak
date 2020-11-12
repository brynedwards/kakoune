# http://pugjs.org
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](pug) %{
    set-option buffer filetype pug
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=pug %{
    require-module pug

    hook window ModeChange pop:insert:.* -group pug-trim-indent  pug-trim-indent
    hook window InsertChar \n -group pug-indent pug-indent-on-new-line

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window pug-.+ }
}

hook -group pug-highlight global WinSetOption filetype=pug %{
    add-highlighter window/pug ref pug
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/pug }
}


provide-module pug %{

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/pug regions
add-highlighter shared/pug/text          default-region                                                 group
add-highlighter shared/pug/tag           region ^\h*(#?|\.?)[a-zA-Z0-9_-]+#?(\.[a-zA-Z0-9_-]+)? (\s|\() group
add-highlighter shared/pug/double_string region '"'  (?:(?<!\\)(\\\\)*"|$)                              fill string
add-highlighter shared/pug/single_string region "'"  (?:(?<!\\)(\\\\)*'|$)                              fill string
add-highlighter shared/pug/comment       region '//' '$'                                                fill comment
add-highlighter shared/pug/attribute     region \(   \)                                                 group

add-highlighter shared/pug/tag/ regex \b([a-zA-Z0-9_-]+)\b 1:keyword
add-highlighter shared/pug/tag/ regex (#[a-zA-Z0-9_-]+)\b  1:meta
add-highlighter shared/pug/tag/ regex (\.[a-zA-Z0-9_-]+)   1:attribute
add-highlighter shared/pug/tag/ regex \b(\block|extends|include|append|prepend|if|unless|else|case|when|default|each|while|mixin|of|in)\b 0:keyword

add-highlighter shared/pug/attribute/ regex '.*' 1:attribute

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden pug-trim-indent %{
    # remove trailing white spaces
    try %{ execute-keys -draft -itersel <a-x> s \h+$ <ret> d }
}

define-command -hidden pug-indent-on-new-line %{
    evaluate-commands -draft -itersel %{
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # filter previous line
        try %{ execute-keys -draft k : pug-trim-indent <ret> }
        # copy '//', '|', '-' or '(!)=' prefix and following whitespace
        try %{ execute-keys -draft k <a-x> s ^\h*\K[/|!=-]{1,2}\h* <ret> y gh j P }
        # indent unless we copied something above
        try %{ execute-keys -draft <a-gt> <space> b s \S <ret> g l <a-lt> }
    }
}

}
