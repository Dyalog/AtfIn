- Monadic `←` is sink, but we cannot just blanket replace `←` with `⍙LeftArrow` — it has to be replaced only if nothing is between `←` and a `⋄` on the left or the beginning of the line.
* For `(a a)←1 2` APL+Win sets `a←1` but Dyalog sets `a←2`. This is hard to fix, but probably a rare occurrence.

* `⎕PR` is impossible to model. R is a character singleton or empty vector. If R is
   empty, ⍞ input is returned with the prompt included in the result, 
  including any changes user has made. If R is a character, that character
   replaces each unmodified element of the prompt in the result. ⎕PR has 
  no effect when ⎕ARBOUT ⍳0 is used.

* Dyadic `⎕DR` is complex and does multiple advanced things, including data (de-)serialisation using binary or XML form.
