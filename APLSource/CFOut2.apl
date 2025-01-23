failed←sourcePath CFOut2 outPath;file;tn;first;last;⎕IO;vals;files;name;vars;val;i;expr
⍝∇ Export source component files as nested vectors
⍝∇ Out'C:\tmp' ⍝ creates C:\tmp\source.ATF from C:\source
⍝∇ left argument is path to source installation (default: C:\source)
⍝∇ Needs RepArr from COM/RepArr.txt
⎕IO←0
:If ⎕MONADIC
  sourcePath←'C:\source'
:EndIf

sourcePath,←'\'↓⍨'/\'∊⍨¯1↑sourcePath
outPath,←'\'↓⍨'/\'∊⍨¯1↑outPath

failed←0⍴⊂''

3 ⎕CMD'dir /b /s ',sourcePath,'*.sf* > ',outPath,'source.DIR'
tn←¯1+⌊/⎕XNNUMS,⎕NNUMS,0
tn ⎕NTIE⍨outPath,'source.DIR'
files←⎕NREAD tn 82(⎕NSIZE tn)0
tn ⎕NERASE⍨outPath,'source.DIR'

:For file :In ⎕CN files
  name←file↓⍨⍴sourcePath ⋄ ((name∊'/\. ')/name)←'_'
  :Try
    tn←1+⌈/⎕XFNUMS,⎕FNUMS,0
    file ⎕XFTIE tn
    (first last)←2↑⎕FSIZE tn
    vals←⎕FREAD¨tn,¨first+⍳last-first
    ⎕FUNTIE tn
    :For val i :In (⊂¨vals),¨⍳⍴vals
      ⍞←'.'
      expr←RepArr val
      :If 100000≤⍴expr
        expr←RepArr¨val
      :EndIf
      ⍎name,'_',(¯6↑'00000',⍕i),'←expr'
    :EndFor
    ⍞←⎕TCNL
  :CatchAll
    failed,←⊂file
  :EndTry
:EndFor

3 ⎕CMD'del ',outPath,'source.ATF'
vars←⎕NL 2
⎕UCMD(0⍴⎕EX(~∨/'_'=vars)⌿vars),'out ',outPath,'source'
