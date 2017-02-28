DEBUG_LEVEL =: 0
STRICT_CHECK =: 0

NB. lev. distance modified from 
NB. http://code.jsoftware.com/wiki/Essays/Levenshtein_Distance ,
NB. under heading "A Non-Looping Solution" .

lmy =: 4 : 'y,(0{x){(1+(1{x)<.{:y),2{x'

lmx =: 4 : 0
  b =. (_1+#y){x
  d =. {:y
  m =. (}.<.}:) d
  y , > lmy&.>/ (|.<"1 b,.m,.}:d),<#y
)

LM =: =/~ lmx^:(#@[) ,:@i.@>:@#@[

LD =: _1&{^:2@LM

divisors =: /:~@,@>@(*/&.>/)@((^ i.@>:)&.>/)@(__&q:)
sum =: +/
sigma =: sum@divisors"0

betrothed =: [: <./ >:@+ = sigma@,
twin_primex =: [: *./ 1&p:@:, *. ] = 2 + [
twin_prime =: twin_primex +. twin_primex~
correct =: betrothed +. twin_prime

NB. some parsing commands
barr =: (;/@, [: , _2 |."1@]\ ]) '<>(){}[]'
mirror =: barr rplc~ |.
shiftx =: [ *./@:="1 #@[ ]\ ]
NB. yields indices that start a shift
shifts_of =: 0 ,~ shiftx +. (mirror@[ shiftx ])
pint =: 0 = [: # -.&'0123456789je._'
peval =: (3 : 'die ''invalid input `'' , (quote y) , ''`''')`".@.pint
nullary =: "_

unbox =: >^:_
enbox =: <@unbox
read_file =: 1!:1@enbox
nores =: 0 0&$@
errm =: warn =: ([: stderr 'Fatal error: ' , ,&LF) nores
errd =: exit@[ [ errm@]
error =: errm : errd
die =: 1&error
DIE =: [`die@.STRICT_CHECK

STACK =: i.0
PUSH =: 3 : 'STACK =: STACK , y'
POP =: 3 : 0 : [
  if. #STACK do.
    v =. {: STACK
    STACK =: }: STACK
    v
  else.
    0
  end.
)
GET =: 3 : 0
  arr =. i.0
  while. y > #arr do.
    arr =. arr ,~ POP ''
  end.
  arr
)

debugd =: 4 : 0
  if. x <: DEBUG_LEVEL do. echo y end.
)
debug =: 2&$: : debugd
DEBUG =: 1&debug

betr_op =: 1 : 'PUSH u/ y , POP '''''


outc =: 3 : 0
  v =. POP ''
  stdout u: v
)

jump =: 4 : 0
  prog_index =: y
)

diagnostic_list =: <;._1 LF, 0 : 0
  #STACK
  prog_index
  0 { 6!:0 ''
  1 { 6!:0 ''
  2 { 6!:0 ''
  3 { 6!:0 ''
  4 { 6!:0 ''
  <. 5 { 6!:0 ''
  1000 * (- <.) 5 { 6!:0 ''
)

diagnostic =: 4 : 0
  ". y pick diagnostic_list
)

duplicate =: 4 : 0
  top =. POP ''
  while. y >: 0 do.
    PUSH top
    y =. <: y
  end.
)

cmds  =: ]  ` (echo@POP nullary)` PUSH      ` outc
names =: '' ; 'outnum'          ; 'pushnum' ; 'outchr'
cmds  =: cmds  `  jump  ` (0 jump POP) ` (4 : 'y { STACK')
names =: names , 'jump' ; 'popjump'    ; 'pick'
cmds  =: cmds  ` (* betr_op)  ` (+ betr_op) ` (- betr_op) ` (% betr_op)
names =: names , 'multiply'   ; 'add'       ; 'subtract'  ; 'divide'
cmds  =: cmds  ` duplicate   ` (4 : 'echo STACK') ` (exit@0:)
names =: names , 'duplicate' ; 'outstack'         ; 'exit'
cmds  =: cmds  ` (exit@])   ` POP    ` (3 : 'exec_op/ GET 2 [ y')
names =: names , 'exitcode' ; 'drop' ; 'exec'
cmds  =: cmds  `  diagnostic
names =: names ,<'diagnostic'

exec_op =: 4 : 0
  c =. x { cmds
  x (c`:6) y
)
argvget =: 3 : 0
  NB.echo y;STACK
  if. y >: #ARGV do. die 'invalid argument index ' , (":y) end.
  y { ARGV
)

main =: 3 : 0
  if. 0 = #y do. die 'insufficient arguments' end.
  file_name =. 0 { y
  prog =. CR -.~ (';';LF) rplc~ read_file file_name
  lines =. (<;._1) LF , prog
  if. 2 | #lines do. die 'number of lines must be even' end.
  pairs =. _2 ]\ lines
  NB. initial checking (gathering pairs)
  ps =. ''
  for_pair. pairs do.
    'M N' =. pair
    'm n' =. # each pair
    if.     >./ 0 = n , m   do. DIE 'forbidden line lengths' 
    elseif. -. n correct m  do. DIE 'forbidden line lengths'
    end.
    ps =. ps ;~ m, n
  end.
  ps =. }. ps
  ps =. ps , |.each ps
  if. -. ps -: ~. ps do. DIE 'lines with matching lengths' end.
  prog_index =: 0
  while. prog_index < #pairs do.
    pair =. prog_index { pairs
    
    NB.echo 'ind/stack: ',":prog_index;STACK
    NB.echo 'pair: ',":pair
    NB.6!:3]1
    NB.echo 20#LF
    'M N' =. pair
    'm n' =. # each pair
    shifts =. a:
    shift_inds =. M shifts_of N
    
    if. 0 = >./ shift_inds do.
      NB. input
      PUSH peval unbox argvget 3 + POP ''
    else.
      debug shift_inds ; m ; n
      c_i =. 0
      mask =. i.0
      for_ind. shift_inds do.
        if. ind do.
          s_inds =. c_i + i.m
          mask =. mask , s_inds
          shifts =. shifts ;~ s_inds { N
        end.
        c_i =. >: c_i
      end.
      shifts =. }: shifts
      q =. #shifts
      mask =. ~. mask
      mask =. -. mask e.~ i.n
      NP =. mask # N
      debug 'M: ' , quote M
      debug 'N: ' , quote N
      debug 'N'': ' , quote NP
      ld =. N LD NP
      DEBUG 'lev dist: ' , ": ld
      DEBUG 'q: ' , ": q
      DEBUG 'executing: ' , > q { names
      q exec_op ld - q
      prog_index =: >: prog_index
    end.
    DEBUG '---stack'
    DEBUG STACK
    DEBUG '---/stack'
  end.
)

main 2 }. ARGV
exit 0