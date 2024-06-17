# Execute APL+Win expressions from Dyalog via COM

1. Make sure `A2KExec.aplf` and `RepArray.aplf` are available in the workspace e.g. using Link

2. Call `{}'path to a2kexec.w3'A2KExec''` (it returns `⎕NULL`)

3. Now call `A2KExec'⍳10'` etc. (`A2KExec` will prompt for the path of step 2 if you skipped that step)

4. To send an array value, use `RepArr` to embed an expression that generates the desired array

### Sample session

```
      A2KExec'"C:\tmp\compfile"⎕FCREATE 1'
Enter location of a2kexec.w3
C:\G\AtfIn\APLSource\COM\a2kexec.w3
[Null]
      A2KExec'⎕FAPPEND 1',⍨RepArr⍳2 3
1
      A2KExec'⎕FREAD 1 1'
┌───┬───┬───┐
│1 1│1 2│1 3│
├───┼───┼───┤
│2 1│2 2│2 3│
└───┴───┴───┘
```


