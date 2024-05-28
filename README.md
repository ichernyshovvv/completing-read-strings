# `crs`

The package provides a function, `crs`, that allows to read
strings in the minibuffer, with `completing-read` under the hood.

Usage:

- The candidates are chosen by pressing `RET`.
- Pressing `C-<backspace>` erases the last chosen candidate.
- Pressing `C-<return>` exits reading and returns the list of chosen candidates.

``` elisp
(crs "PROMPT: " '("first" "sec,ond" "third"))
```

## Rationale

In `completing-read-multiple`, the result list of chosen strings is made by
splitting the input string with `crm-separator` regular expression variable.

This approach is not suitable in several situations:

1. Candidates might contain the default `,` separator. In this case, the
   candidate with `,` inside will be treated as two typed candidates:

``` elisp
(completing-read-multiple "PROMPT: " '("first" "sec,ond" "third"))
;; <selecting "sec,ond">
;; => ("sec" "ond")
```

A developer has to locally rebind `crm-separator` and tell the user which
character to type to separate the candidates.

``` elisp
(let ((crm-separator "[ \t]*|[ \t]*"))
  (completing-read-multiple "Type `|' to select another candidate: "
                            '("first" "sec,ond" "third")))
```

2. Candidates might contain any characters, so it's hard to pick an easily typed
   separator. Example: Org headings, file names. In this case, a developer might
   use `\n` as a separator, which a user can enter by pressing `C-o` and moving
   the cursor 1 char forward to be able to display the list of candidates (which
   is not convenient).

``` elisp
(let ((crm-separator "[ \t]*\n[ \t]*"))
  (completing-read-multiple
   "Prompt: " '("first." "sec,ond" "third;")))
```

`crs` solves the issue by providing a function that has the
same interface for all kinds of candidates. Internally, it collects the chosen
candidates into a list during reading and then returns it (without the need to
split the input string with regular expression).
