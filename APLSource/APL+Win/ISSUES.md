# Issues when converting from APL+Win to Dyalog APL

## Primitives and syntax

- Monadic `←` is sink, but we cannot just blanket replace `←` with `⍙LeftArrow` — it has to be replaced only if nothing is between `←` and a `⋄` on the left or the beginning of the line.

- For `(a a)←1 2` APL+Win sets `a←1` but Dyalog sets `a←2`. This is hard to fix, but probably a rare occurrence.

- If both arguments are empty `,` and `⍪` return their left argument in Dyalog but their right argument in APL+Win

- `"`-delimited character constants can be automatically transformed to use `'` quotes but `⍎` will fail on a `'`-delimited expression that contains `"`-delimited text.

## System constants

- `∆SYSVER` looks at the executable timestamp, but the interpreter does actually know when it was created, as shown in the About box

- `⎕SINL` cannot be modelled, but is unlikely to appear in code; use `)SINL`.

- `⎕NOVALUE` is only used from `:Return` and `:Res` both of which are not in Dyalog. It is simply `⎕EX` on the return variable names.

## System variables

- `⎕RL` not fully modelled (missing two RNGs and `∆RL` is not updated when generating); only `⎕RL←` should be replaced with `∆RL←`.

- `⎕PR` is impossible to model. R is a character singleton or empty vector. If R is empty, `⍞` input is returned with the prompt included in the result, including any changes user has made. If R is a character, that character replaces each unmodified element of the prompt in the result. `⎕PR` has no effect when `⎕ARBOUT ⍳0` is used.

* `⎕WATCHPOINTS` would be very nice to have

## System functions

- Dyadic `⎕DR` is complex and does multiple advanced things, including data (de-)serialisation using binary or XML form.

- `⎕CALL` and ``⎕STPTR` cannot be modelled, but is usually easy to rewrite to pure APL.

- Skipping `⎕DEFL` for now as not worth the effort, though totally doable.

- `⎕IDLOC` is hard (WIP)

- User commands are different, so `∆UCMD` is unlikely to work as `⎕UCMD`

- `∆INBUF` isn't perfect, but it does allow basic things.

- `∆CRLPC` cannot read public comments from locked functions

- `⎕LOG` is part of the larger logging system.

## Keywords

- `:Assert expr` is a comment at runtime, but an assertion when running in debug mode

- `:Debug expr` is a comment at runtime, but an `:if DEBUGMODE ⋄ {}…` if in debug mode

## Control structures

### Conditionals

- `:And` and `:Or` are short-circuiting `∧` and `∨` like `:AndIf` and `:OrIf` but for inline expressions, and `:Ex` allows intermediary execution (like statements between `:If` and `:AndIf`/`:OrIf`)

- `:IfTest` is `:If TESTMODE`

- `:ContinueIf`, `:LeaveIf`, `:ReturnIf` are short forms of `:If`…`:Continue` etc.

### Error Trapping

- Rather than `:Case` by error number, APL+Win has `:CatchIf` 

### Select

- `:NextCase` is the opposite of `break` in C-like languages, i.e. where C continues the the next case, APL jumps to `:EndSelect` at the end of a `:Case` block, but `:NextCase` allows continuation.

- `:Like` is like `:Case` except

