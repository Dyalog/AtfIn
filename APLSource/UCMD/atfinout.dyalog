:namespace  inout ⍝ V1.26
⍝ Transfer objects in and out of the ws
⍝ 2015 05 21 Adam: NS header
⍝ 2016 07 21 DanB: changed Help
⍝ 2016 09 23 DanB: -APL fix
⍝ 2017 03 14 Adam: changed -fliplu to -alphabets=, help updated
⍝ 2017 05 23 Adam: omit leading / when filename has no folder
⍝ 2017 05 25 Adam: Proper cased In and Out
⍝ 2017 06 19 Adam: add tip about how to non-ATF
⍝ 2017 06 22 Adam: report bad filename
⍝ 2018 04 18 Adam: ]??cmd → ]cmd -??
⍝ 2018 05 07 Adam: help tweaks
⍝ 2019 01 15 Adam: help
⍝ 2021 05 13 MKrom: handle files without extension
⍝ 2021 05 14 Adam: Add ]in -outdir
⍝ 2022 03 29 Adam: [19747] handle extensions in any case

    (⎕IO ⎕ML)←1


    AllCmds←'In' 'Out'

    APLs←'APL2PC' 'APL2MF' 'VSAPL' 'APLX' 'DYALOG' 'APLPLUS' 'STSCMF' 'SHARPMF' 'SHARPX'
    Surr←'A2K'    'AP2'    'AP2'   'APX'  'DYW'    'A2K'     'A2K'    'SAM'     'SAX'
    Xext←'xiw'    'xiw'    'xiw'   'xpw'  'xdw'    'xsw'     'xsw'    'xmw'     'xuw'
    Xext←↑Xext((¯1↓¨Xext),¨'f') ⍝ component files

    ∇ r←List
      r←⎕NS¨(⍴AllCmds)⍴⊂''
      r.Name←AllCmds
      r[1].Desc←'Import a workspace from a workspace transfer file' ⍝ descriptions
      r[2].Desc←'Export the current workspace to a workspace transfer file'
      r.Group←⊂'Transfer'                                 ⍝ same group
     ⍝ Parsing rules for each:
      r[1].Parse←'1 -atf -alphabets= -file[=] -list -noam -obj= -q -range= -replace -trans[=]0 1 2 -outdir= -apl=',⍕APLs
      r[2].Parse←'1 -atf -obj= -file[=] -range= -lock= -q'
    ∇

    ∇ r←Run(Cmd A);arg;nars;files;q;Cn;ext;msg;folder;name;n;findExt;lc;x;b;apl;TMPNS;WSID;opts;AtfIn;xfr
    ⍝ Transfer code to/from files
      Cn←AllCmds⍳⊂Cmd ⋄ lc←⎕SE.SALTUtils.(lCase⍣WIN) ⋄ findExt←{⎕C ⍵↑⍨-⊥⍨b∧0∊b←'.'≠⍵}
      (folder name)←⎕SE.SALTUtils.{'/\'splitLast ⍵}'"'~⍨arg←1⊃A.Arguments
      :If (1=Cn)∧0∊⍴ext←findExt name
      :AndIf 0∊⍴ext←(⊂(1+A.file),APLs⍳⊂A.apl)⊃Xext,⊂''
         ⍝ In input mode, if the extension has been omitted, we try to guess
          files←'f'⎕SE.SALTUtils.Dir(arg~'"'),'.*'   ⍝ all files in that folder
          ext←lc∘findExt¨files                       ⍝ their extensions
          x←ext∩(1+A.atf)⊃(,Xext⌿⍨⍲\2⍴0≡A.file)(⊂'atf')
          :If 0=n←⍴x
          :AndIf ⎕NEXISTS arg
         ⍝ File exists but SALTUtils.Dir failed to find it, move on
          :ElseIf 1=n←⍴x                                 ⍝ only one possibility?
         ⍝ If there is only one file it is easy
              (ext arg)←(ext⍳x)⊃¨ext files ⋄ arg←folder,('/'/⍨''≢folder),arg
          :Else
              ('file ',arg,' not found')⎕SIGNAL n↓22
              msg←'ambiguous filename ',arg,' (',(⍕n),' possibilities)'
              msg ⎕SIGNAL 22
          :EndIf
      :EndIf
     
      :If (ext≢'NARS')∧∨/b←'''" -'∊arg
         ⍝ The fns below will reparse the line so we need to surround the arg properly with quotes
          arg←q,((1+q=arg)/arg),q←''''
      :End
     
      :Select Cn
      :Case 1 ⍝ IN
         ⍝ We accept ATF, NARS and extended format files (DYW, APX, etc.)
           ⎕SE.Link.Create ((⍕⎕THIS),'.AtfIn') 'c:\devt\AtfIn\APLSource\AtfIn'
          :If A.atf∨('atf'≡ext←ext,(A.atf∧0∊⍴ext)/'atf')∨0≠≢A.outdir
              ⍝ ⎕FIX ⎕SE.SALT.Load'lib\atfin -source'
              b←arg,('.'∊arg)↓'.',A.Propagate'alphabets apl' ⍝ ensure '.' in name
              ((1+0≢A.outdir)⊃##.THIS A.outdir) AtfIn.ATFIN b              
          :ElseIf ext≡'nars'
              ##.⎕CY'xfrcode.dws'
              ##.THIS xfr.nars.makeWS arg
          :Else
              :If ∨/b←APLs∊⊂apl←A.apl~0 ⋄ apl←' -apl=',(b⍳1)⊃Surr ⋄ :EndIf
              ##.⎕CY'xfrcode.dws'
              ##.THIS xfr.∆xfrfrom arg,apl,A.Propagate'file list noam obj q range replace trans'
          :EndIf
     
      :Case 2 ⍝ OUT: we export to ATF if the extension is ATF or -atf has been supplied
          :If A.atf∨(⊂ext)∊'atf' 'ATF'
          ⍝ Before proceeding we check if there are any exotic objects in the ws.
          ⍝ We should also check for unusual fns accepting or returning multiple args but we don't now.
              :If 0<n←+/~2.1 3.1∊⍨##.THIS.⎕NC ##.THIS{0≡⍵:⍺.⎕NL-⍳9 ⋄ ⎕ML←3 ⋄ (','≠⍵)⊂⍵}A.obj
                  ⎕←'*** There are ',(⍕n),' objects impossible to transfer in ATF format.'
                  ⎕←'    Consider using the non-ATF format instead (do not add the .ATF extension)'
              :Else
                  ⎕FIX ⎕SE.SALT.Load'lib\atfin -source'
                  ##.THIS ⍙⍙.ATFOUT arg,A.Propagate'obj'
              :EndIf
          :Else ⍝ must be extended form
              ##.⎕CY'xfrcode.dws'
              ##.THIS ##.xfr.∆xfrto arg,A.Propagate'file range lock obj q'
          :EndIf
      :EndSelect
      r←0 0⍴''
    ∇

    ∇ r←lev Help Cmd;o;i;ix;ox;table;n;s;h3;h4;h2
      r←List.Desc[n←AllCmds⍳⊂Cmd]
      s←'    ]',Cmd,' <filename> [-atf] [-obj=<something>] [-file[=<file>]] [-range=<range>] [-q] '
      :Select n
      :Case 1
          s,←'[-alphabets=<x><y><z>] [-list] [-noam] [-replace] [-trans[={0|1|2}]] [-outdir=<dir>] [-apl={',(1↓∊'|',¨APLs),'}]'
      :Case 2
          s,←'[-lock=<names>]'
      :EndSelect
      r,←s''
      h2←']',Cmd,' -??   ⍝ for more information and examples'
      h3←']',Cmd,' -???  ⍝ for full documentation'
      :If Cmd≡'In'
          h4←']',Cmd,' -???? ⍝ for changes made when transferring from APLX'
          :Select lev
          :Case 0
              r,←h2 h3 h4
          :Case 1
              i←'Bring in objects defined in a transfer file.' ''
              i,←'-outdir=     uses Link.Export to write objects directly to plain text files under <dir>, rather than establishing them in the workspace.' ''
              ix←'The source APL can be specified through the -apl modifier or the file extension can tell the program how to handle the input file.'
              ix,←' An extension of .atf will use the ATF format (APL Transfer Format).'
              i,←⊂ix,' With ATF the acceptable APLs (-apl values) are:'
              i,←⊂⍕¯1↓APLs
              i,←⊂''
              ix←'-alphabets=  selects what lowercase, uppercase and underscored characters should translate to. '
              ix,←'E.g. to just change underscored characters into lowercase letters, make the third character a lowercase "a":'
              i,←ix('    ]',Cmd,' \tmp\infile.atf -alphabets=aAa')''
              ix←'Other formats include NARS2000 the APL Extended Format. '
              ix,←'Several modifiers allow fine tuning the process. The file extensions associated with each APL are:'
              i,←⊂ix
              i,←↓⍕APLs⍪Xext
              i,←⊂'The x?w extensions relate to workspaces, the x?f extensions relate to files.'
              ix←'ATF files are files used historically to transfer APL code. '
              ix,←'They were introduced in the 80s and are sometimes used to recover code from other '
              ix,←'APL vendors. They don''t always follow the same format and can be difficult to deal with.'
              i,←''ix'' 'Example: bring in an ATF file generated by another vendor'('    ]',Cmd,' \qa\xfr\aplx\ttt3d -atf')
              i,←'' 'Transfer files can also be generated in those APLs in a different serialized format.'
              i,←'' 'Example: retrieve all objects from an APL/PC transfer file and translate code:'
              i,←⊂'    ]',Cmd,' \qa\xfr\aplpc\starmap.xsw -tr'
              i,←'' 'Retrieve a ws from a Sharp APL (Unix) transfer file and define translate code:'
              i,←⊂'    ]',Cmd,' \qa\xfr\Sharp\utils.xuw -tr=2'
              i,←'' 'Retrieve some character and numeric data from a Dyalog transfer file:'
              i,←⊂'    ]',Cmd,' \qa\xfr\dyw\misc.xdw -obj=CN'
              i,←'' 'Retrieve all objects in a NARS workspace:'('    ]',Cmd,' \qa\xfr\nars\x1.ws.nars')
              i,←⊂'Note that you cannot retrieve individual objects from a NARS ws nor perform translation.'
              i,←''h3 h4
              r,←i
          :Case 2
              'xfr.∆describe'⎕CY'xfrcode.dws'
              r←'to/from'⎕R'from'⊢¯11↓∆describe
              r,←(⎕UCS 13),h4
          :Else
              'xfr.∆equivalence'⎕CY'xfrcode.dws' ⋄ CR←⎕UCS 13
              ix←1⍳⍨':APX'⍷∆equivalence ⍝ find APLX section
              r←ix↓∆equivalence
              r←(1+1⍳⍨CR CR⍷r)↓r ⍝ remove header
              r←(¯1+1⍳⍨CR CR':'⍷r)↑r ⍝ drop next sections
              r←'%'⎕R' → '⊢'"\d+"'⎕R{92 3::'?' ⋄ ⎕UCS 9031 9032 9047 9040[11 12 9 7⍳2⊃⎕VFI ⍵.Match~'"']}r
              r←↑1↓¨(r=CR)⊂r ⍝ turn into a matrix
              i←↓3 ⎕SE.Dyalog.Utils.showCol r
              r←'Here is the list of all the changes made for APLX:' '',i
              r,←''h2 h3
          :EndSelect
     
      :ElseIf Cmd≡'Out'
          :Select lev
          :Case 0
              r,←h2 h3
          :Case 1
              o←⊂'Write objects to an ATF or serialized file.'
              o,←⊂'If the format is ATF only the variables and programs in the current namespace are exported.'
              o,←⊂'For the serialized format everything but forms (instances) and program references is exported.'
              o,←⊂'You can specify which objects to be written out with the -obj modifier'
              o,←⊂''
              o,←'Example:' 'Write current workspace contents to file \tmp\aplp in ATF format:'
              o,←('      ]',Cmd,' \tmp\aplp  -atf')''
              o,←'Serialize 3 objects (not ATF):'('      ]',Cmd,' \tmp\myws -obj=A Bc def')
              o,←'' 'To retrieve the objects in another APL, )LOAD the xfrpc ws on that APL and do' '      ∆xfrto ''\tmp\myws''   ⍝ extension .xdw will be added'
              o,←'' 'To retrieve the objects in (possibly another version of) Dyalog APL do' '      ]in  \tmp\myws.xdw   ⍝ for example'
              r,←o,''h3
          :Else
              'xfr.∆describe'⎕CY'xfrcode.dws'
              r←'to/from'⎕R'to'⊢¯11↓∆describe   ⍝ M11146
          :EndSelect
      :EndIf
    ∇

:Endnamespace ⍝ inout  $Revision: 1791 $
