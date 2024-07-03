                WADE - Wagners Debugger
.he WADE - Wagners Debugger - User Manual - V. 1.5 -  Page #

                      User Manual
                 Version 1.5 - 85-04-27


WADÅ  ió aî interactivå symboliã Z8° debuggeò witè  fulì 
assemblù anä disassemblù usinç standarä ZILOÇ mnemonics® 
Uğ tï eighô conditionaì and/oò unconditionaì breakpointó 
pluó á temporarù breakpoinô maù bå defined® Fulì tracinç 
witè  oò  withouô lisô anä witè real-timå  executioî  oæ 
subroutineó  oî  commanä oò automatiã  (usinç  protecteä 
areas©  ió provided®  Tracinç maù bå controlleä bù inst
ructioî counô oò á conditionaì expression® Á fulì seô oæ 
operatoró provideó foò arithmetic¬  logical¬  shift¬ anä 
relationaì operationó oî hex¬  decimal¬ binary¬ anä cha
racteò data¬  anä oî registers¬  variables¬ anä symbols¬ 
includinç  embeddeä assignmentó tï registeró anä  varia
bles®  Extendeä  addressinç caî bå provideä foò  systemó 
witè bankinç oò memorù managemenô capabilities.

WADÅ supportó parameteriseä commanä macroó anä conditio
naì commanä execution.

WADÅ  ió  supplieä  witè completå sourcå  codå  foò  thå 
Digitaì Researcè RMAÃ assembler®  Systeí dependenô  rou
tineó  likå  consolå i/o¬   filå i/o¬  anä  bankinç  arå 
collecteä iî á singlå modulå tï allo÷ easù adaptatioî tï 
otheò  operatinç systemó oò stand-alonå ROM-baseä appli
cations.


                      No Copyright

Wade was written 1984-1985 by

     Thomas Wagner
     Patschkauer Weg 31
     D-1000 Berlin 33
     West Germany

     BIX mail: twagner

It has been released to the public domain in 1987.

Yoõ maù uså anä modifù thió program¬ itó sources¬ oò anù 
partó  oæ it¬  iî anù waù yoõ choose®  Nï parô  oæ  thió 
prograí  ió  copyrighteä anù longer¬  eveî iæ  copyrighô 
noticeó stilì appeaò iî somå oæ thå files.

Nï  contributioî  iî anù waù ió  requesteä  oò  expecteä 
(althougè É wouldn'ô rejecô iô :-))®  I'vå giveî uğ CP/Í 
anä  Z8°  programming¬  sï  thió softwarå ió  nï  longeò 
supported® 

I'lì  trù  tï  helğ  anä  answeò  questionó  abouô  thió 
software¬ buô É haven'ô toucheä iô foò quitå á while¬ sï 
don't expect too much.
.paŠ                    Command Summary

A  {addr}             Assemble

B                     Display Breakpoints
B  adr {adr..}        Set Breakpoints
BI mexpr ;adr {adr..} Set Conditional Breakpoints
BX                    Clear all Breakpoints
BX adr {adr..}        Clear specified Breakpoints
BXI                   Clear Break Condition

C  {N}{J} {count}     Trace over calls {Nolist}{Jumps}
C  {N}{J} W mexpr     ..While
C  {N}{J} U mexpr     ..Until

D  {from {to}}        Dump memory

E  mexpr ;command     Execute command conditionally

F  {command line}     Specify Filename & command line

G  {to} {; breakadr}  Go {with temp breakpoint}

H                     Display Low and High addr of file
H  expr {expr..}      Display result of expression(s)

I  {port}             Input from port

J  file {params}      Jump to macro file

K                     Kill macro file

L  {from {to}}        List disassembled code

M  begin end dest     Move memory

N                     Name (Symbol) list
N  expr symname ...   Define Names
NF filename           Define Symbol File Name
NS num                Reserve Space for symbols
NX                    Delete all Names
NX symname ...        Delete specified Names
NR {offset}           Read Symbol File
NW                    Write Symbol File

O  {byte {port}}      Output a byte to port

P                     Display protect condition
P  mexpr              Define protect condition
PX                    Delete protect condition

Q  {J} begin end str  Query {justified} for bytes

R  {offset}           Read a File

.cp2
S  {addr}             Substitute memory
S  addr bytestring    Substitute immediate

T  {N}{J} {count}     Trace {Nolist} {Jumps only}
T  {N}{J} W mexpr     ..While
T  {N}{J} U mexpr     ..UntilŠ
U                     User input trap

V  begin end begin2   Verify (compare) memory

W  start end {offset} Write a file to disk

X                     Examine CPU state
X'                    Display alternate Registers
X  regname            Display & Change Register
X  regname expr       Change Register

Y                     Display Y-Variables
Y  n                  Display & Change Y-Variable n
Y  n  expr            Change Y-Variable n

Z  begin end bytestr  Zap (fill) memory with a string
.paŠ                       Using WADE

Syntax:  WADE  { filename { symbol-filename }}

WADÅ ió calleä likå anù otheò CP/Í command® Iô relocateó 
itselæ  belo÷ thå BDOÓ anä setó thå addresó aô ¶ corres
pondinglù (foò CP/Í 3¬  thió ió donå bù thå systeí usinç 
thå RSØ mechanism).

Iæ á filnamå ió specifieä iî thå commanä line¬ thió filå 
ió  theî reaä intï memory¬  aó iæ aî R-commanä haä  beeî 
entered® Pleaså notå thaô yoõ havå tï issuå aî F-commanä 
tï  cleaò thå filenamå froí thå defaulô FCÂ iæ thå  pro
graí undeò tesô expectó parameters.

Iæ  á seconä (symbol-© filenamå ió giveî iî thå  commanä 
line¬  thió filå ió reaä aó á Symboì File¬  aó iæ aî  NÒ 
commanä  haä  beeî entered®  Notå foò CP/Í 3¬  thaô  thå 
prograí filå ió reaä first¬ sï iæ á prograí witè attach
eä RSØ ió loaded¬  therå maù bå noô enougè spacå tï reaä 
alì  symbols®  Iî thió case¬  thå symboló shoulä bå reaä 
before the program (see NF, NR and R commands).

Example:    WADE myprog.com myprog.sym


Tï  exiô  WADÅ undeò CP/M¬  issuå á Ç commanä  witè  thå 
parameteò 0® Thió wilì reseô thå BDOS-pointeró anä warm
booô thå operatinç system.

Example:    g0
.paŠ                     Command input

Commandó  anä  parameteró  maù bå entereä  iî  upper- oò 
lowercase®  Spaceó  maù bå useä freelù aó separatoò  be
tweeî operands¬  commaó maù bå useä tï separatå  parame
ters®  Thå  maximuí  accepteä  inpuô linå lengtè  ió  7¹ 
characters.

Thå  linå  ió interpreteä onlù afteò á CÒ haó  beeî  en
tered¬  sï  yoõ caî ediô thå inpuô usinç thå DEÌ  oò  BÓ 
key®  Á TAÂ ió interpreteä aó á space¬  á LÆ ió ignored® 
Alì otheò controì characteró arå refused.


                  Auto Command Repeat

Alì  entereä  commandó excepô 'G§ arå saveä anä  re-exe
cuteä iæ á carriagå returî onlù ió entered®  Parameters¬ 
however¬  arå noô saved¬  sï thå defaulô valueó wilì  bå 
useä iæ applicable® Iæ parameteró musô bå specifieä witè 
a command, auto repeat is not possible.


                    Display Control

Displaù outpuô caî bå stoppeä aô eacè linå enä bù  ente
rinç  ^Ó (controì « S)¬  anä continueä bù ^Ñ (controì  « 
Q)®  Hittinç  thå spacå keù oncå wilì alsï stoğ thå dis
play¬  hittinç iô agaiî (oò enterinç ^Q© wilì leô outpuô 
continue.


                     Command abort

Everù  commanä  whicè produceó outpuô caî bå aborteä  aô 
thå  enä oæ eacè outpuô linå bù enterinç  anù  characteò 
otheò thaî space¬  ^S¬  oò ^Q® Also¬ á tracå witè Nolisô 
caî  bå aborteä aô anù timå thå prograí doeó noô executå 
iî real-time®  Abortinç á commanä wilì alsï kilì á  cur
rentlù activå commanä macro.
.paŠ                      Expressions

Alì  numberó  iî commandó anä assemblù lineó maù  bå  aî 
expression¬  excepô  foò "Ø regname"¬  wherå á  registeò 
name¬ noô á registeò designatioî (Rx© musô bå used.

An expression has the general form

   factor { operator factor ...}

where operator is one of the following:

   +       addition
   -       subtraction
   *       multiplication
   /       integer division
   %       remainder of integer division (modulus)

   &       bitwise AND
   !       bitwise OR
   |       bitwise OR  (alternate representation)
   #       bitwise XOR
   ^       bitwise XOR (alternate representation)

   <<      circular 16-bit left shift
   >>      circular 16-bit right shift

   <       less than
   <=      less than or equal to
   >       greater than
   >=      greater than or equal to
   =       equal
   <>      not equal

   &&      boolean AND
   ||      boolean OR
   !!      boolean OR (alternate representation)

   :=      assignment (word)
   ==      assignment (byte)
           wherå  thå factoò whicè ió assigneä tï maù bå 
           aî  unsigneä registeò oò variablå  specifica
           tion¬ oò aî addresó value® Thå resulô oæ thió 
           operatoò  ió thå valuå oî thå right-hanä sidå 
           oæ thå assignmenô operator¬  whicè ió aô  thå 
           samå timå assigneä tï thå register¬  variablå 
           oò addresó specifieä oî thå left-hanä side.
           Sizå  adjustmenô  ió automatiã foò  variableó 
           anä  registers®  Iæ aî addresó ió useä aó thå 
           destination¬  á  worä ió stored®  Tï storå  á 
           bytå only¬  uså thå operatoò '=='®  Notå thaô 
           tï assigî tï á registeò oò variable¬  nï sigî 
           oò  expressioî maù bå useä witè thå  registeò 
           or variable name, i.e. the expression
           RHL := 1234  will assign 1234 to register HL,
           whereaó  +RHÌ :½ 123´ wilì assigî 123´ tï thå 
           address contained in register HL.
.paŠ   :       extended memory specification
           thå  valuå  oæ thió operatoò ió thå valuå  oî 
           thå  right-hanä  sidå oæ  thå  operator®  Thå 
           valuå oî thå left-hanä sidå specifieó á (sys
           teí  dependent© extendeä  address¬  whicè  ió 
           useä  iî memorù referenceó anä witè  commandó 
           whicè expecô aî address®  Iî alì otheò cases¬ 
           thió valuå ió ignored® Aî erroò occuró iæ thå 
           extendeä  addresó ió undefineä iî thå  targeô 
           system¬   oò   iæ  extendeä   addressinç   ió 
           disabled.

A factor has the form

   { sign } number

where sign is

   + (plus), - (minus), or ~ (not)

and number is

   (expression)    the byte at the memory location 
                   addressed by "expression"

   (expression).   the word at the memory location
                   addressed by "expression"

   [expression]    the value of the expression

   hhhh    hex number
   dddd.   decimal number
   bbbb"   binary number
   'c'     character
   string  character string (only the last 2 characters
           are significant)
   Rx      contents of CPU-Register x
   Yn      contents of Variable Y0..Y9
   H       special variable H(igh)
   L       special variable L(ow)
   M       special variable M(ax)
   T       special variable T(op)
   X       special variable eXtended address default
   $       CPU-register PC
   .symbol Value of the symbol

   Thå  variablå  Ì containó thå standarä  loaä  addresó 
   (100è  foò CP/M© anä ió noô changeä bù thå  debugger¬ 
   buô maù bå useò assigneä tï á differenô value.

   Thå  variablå È containó thå highesô addresó reaä  oî 
   thå  lasô file®  Iô ió updateä eacè timå aî R-commanä 
   ió executed.

   Thå  variablå Í containó thå highesô addresó reaä  oî 
   alì previouó R-commands.

   Thå  variablå Ô containó thå toğ addresó oæ thå  useò 
   TPA® Iô ió updateä iæ symboì tablå spacå ió expanded.

Š   Thå  variablå  Ø  containó thå defaulô banë  foò  alì 
   operationó iæ extendeä addressinç ió enabled®  Iô maù 
   bå  changeä bù assignmenô oò bù changinç thå PÃ  witè 
   an extended address.

   Thå short-forí '$§ foò PÃ maù onlù bå useä iî expres
   sions¬ noô iî aî X-commanä.

   Thå characteò '_§ (underline© maù bå useä iî  numberó 
   tï enhancå readability® Iô ió completelù ignored.

String:

   Any number of characters delimited by quotes (').
   Uså  á  twï quoteó (''© tï represenô á  singlå  quotå 
   within a string: 'It''s a quote'.

Register names:

   primary:    A, F, AF, B, C, BC, D, E, DE,
               H, L, HL, IX, IY, SP, PC

   alternate:  A', F', AF', B', C', BC', D', E', DE',
               H', L', HL'

   control:    IFF  (interrupt enable flip flop)
               I    (interrupt register)
               R    (refresh register, read only)

Symbols:

   Anù  numbeò  oæ characters¬  oæ whicè onlù thå  firsô 
   eighô  characteró  arå significanô  (thå  significanô 
   lengtè  oæ symboló caî bå changeä  bù  reassembling)® 
   Thå firsô characteò musô bå non-numeric®  Symboló maù 
   consisô oæ letters¬  digits¬  anä thå speciaì charac
   teró @¬ ?¬ _¬ anä $® Lowercaså letteró arå translateä 
   to uppercase. Any underlines (_) are stripped.



                  Multiple Expressions

Alì  commandó expectinç á conditioî wilì accepô multiplå 
expressionó  iî  sequence®  Onlù thå valuå oæ  thå  lasô 
expressioî ió useä aó thå conditioî result®  Thå generaì 
form for this "mexpr" is

   expression  { {,} expression ... }



                      Byte-Strings

Thå commandó Q(ery)¬  S(ubstitute)¬  anä Z(ap© expecô  á 
byte-strinç  aó  operand®  Iî á  byte-string¬  characteò 
stringó  arå  significanô oveò theiò  fulì  length®  Thå 
generaì forí is

   expression-or-string { {,} expression-or-string ... }
Šonlù  thå loweò bytå ió significanô foò  expressionó  iî 
bytå strings®  Notå thaô á strinç ió evaluateä first¬ sï 
tï  enteò  thå expressioî 'N'-4° iî á  byte-string¬  yoõ 
have to use brackets:

   'N'-40  1+2*3  'A'+2      => 'N', -40, 7, 'A', 2
   ['N'-40] [1+2]*3 ['A'+2]  => '^N', 9, 'C'


                  Order of Evaluation

The precedence of operators is as follows (high to low):

   expression delimiters       (), ()., []
   signs                       +, -, ~
   bitwise operators           &, !, |, #, ^
   multiplication operators    *, /, %, <<, >>
   addition operators          +, -
   relational operators        =, <>, <, >, <=, >=
   boolean operators           &&, ||, !!
   extended address            :
   assignment                  :=, ==

Operatoró  oæ  equaì  precedencå arå evaluateä  lefô  tï 
right¬  anä  musô bå bracketeä iæ á differenô  ordeò  oæ 
evaluatioî  ió desired®  Assignmentó arå evaluateä righô 
to left.

Examples:

   1 + 2 * -3       => -5
   5 - 2 : 2 * 3    => Bank 3, Address 6
   ³º5+2 =½ (³º6©   =¾ Assigî contentó oæ 3:¶ tï 3:7
   rhl := +rde := 1 => Assign 1 to register HL and the 
                       address contained in DE
   rhl := (rde). := 1 => same as above


Thå  nestinç  deptè  oæ expressionó ió  limiteä  bù  thå 
availablå debuggeò stacë space®  Iî thå currenô release¬ 
25¶  byteó  arå availablå foò thå  stack¬  sï  thaô  anù 
reasonablå expressioî shoulä causå nï problems.

                        Booleans

Foò commandó expectinç á conditionaì expression¬ anä foò 
thå  booleaî AND/OÒ operators¬  thå valuå  °  representó 
FALSE¬ whilå anù valuå otheò thaî ° representó TRUE.

Thå resulô oæ thå relationaì anä booleaî operatoró ió  ° 
foò TRUÅ anä FFFÆ foò FALSE.

Aî  examplå  tï sho÷ thå differencå betweeî bitwise  anä 
boolean operators:

   1 &  2  is 0
   1 && 2  is FFFF.

   1 |  2  is 3
   1 || 2  is FFFF.
.paŠ                        Commands

                      A - Assemble

Syntax:    A  { start-address }

Iæ  á starô addresó ió noô specified¬  thå lasô  addresó 
displayeä iî aî Á oò Ó commanä ió used.

Thå  currenô  contentó oæ thå locatioî arå displayeä  iî 
heø  anä iî disassembleä form¬  anä á linå  oæ  assemblù 
codå ió expected® Thå codå musô bå specifieä iî standarä 
ZILOÇ mnemonics¬  witè operandó separateä bù á comma® Nï 
abbreviationó  arå allowed®  Thå entereä instructioî re
placeó thå currenô one¬  anä thå commanä wilì advancå tï 
thå nexô instruction.
Iæ yoõ enteò aî emptù line¬  thå commanä wilì advancå tï 
thå nexô instruction®  Tï terminatå thå command¬ enteò á 
doô (.© aó firsô characteò iî á line.

Iæ aî inpuô caî bå interpreteä aó botè á registeò anä  á 
numbeò  (aó iî   LÄ  A,Ã )¬  thå registeò interpretatioî 
takeó  precedence®  Uså LÄ A,0Ã tï specifù aî  immediatå 
value.

Thå  displacemenô  foò relativå jumpó ió entereä  aó  aî 
absolutå address®  Thå debuggeò wilì calculatå thå  dis
placemenô foò you.

Á  symboì  maù  bå  defineä aô thå  currenô  addresó  bù 
entering the symbol with a terminating colon (':').

Á  syntaø erroò wilì exiô assemblù modå withouô changinç 
thå addresó pointer®  Simplù enterinç á carriagå  returî 
will continue assembling at the same location.


Example:

   :a 220
   220  START:  LD    DE,2345          ld a,b
   221          LD    B,L              here: ld d,'a'
   223          JR    NZ,0227   .
   :
.paŠ           B - Breakpoint Set/Delete/Display

Syntax:    a)  B
           b)  B   address { address.. }
           c)  BI  multexpr ; address { address.. }
           d)  BX
           e)  BX  address { address.. }
           f)  BXI

a) Alì  breakpointó anä thå conditionaì breaë expressioî 
   (if present) are displayed.

b) Thå  addresseó  arå entereä aó  unconditionaì  break
   points® Iæ aî addresó ió alreadù defineä aó conditio
   naì  breakpoint¬  thå  conditioî ió deleteä foò  thió 
   address.

c) Thå expressioî ió storeä aó breaë condition¬  anä thå 
   addresseó arå defineä aó conditionaì breakpoints® Anù 
   previouslù defineä conditionaì breakpointó arå seô tï 
   unconditional.

d) Delete all breakpoints and the condition expression.

e) Delete the specified breakpoints.

f) Deletå   thå   breaë   condition®   Alì   conditionaì 
   breakpointó arå seô tï unconditional.


Example:
       :b 4711 .start
       :bi rc = 15; 5
       :b
       4711  0400  0005(If)
       If: rc = 15
       :
.paŠ                  C - Trace over calls

Syntax:    a)  C {N} {J} {count}
           b)  C {N} {J} W multexpr
           c)  C {N} {J} U multexpr

Thió  commanä  workó  thå samå aó thå  T(race©  command¬ 
excepô  thaô routineó CALLeä arå executeä iî  real-time¬ 
i.e® theù arå noô traced.

Thå calleä routinå MUSÔ returî tï thå instructioî  afteò 
thå Call-instruction¬ oò tracinç wilì fail® Thaô is¬ yoõ 
caî  noô  uså thió commanä foò routineó whicè  expecô  á 
parameteò lisô afteò thå calì instructioî anä modifù thå 
returî  address¬  oò  foò routineó whicè mighô  poğ  thå 
returî addresó anä returî tï somewherå else.

See definition of T for more details on the parameters.

Example:   cnw rbc <> 0 && rde = 0


                        D - Dump

Syntax:    D   {from-address {to-address}}

Memorù ió displayeä iî hexadecimaì anä ASCIÉ formaô froí 
thå from-addresó uğ to¬  anä including¬  thå to-address® 
Iæ  thå to-addresó ió noô  specified¬  thå  from-addresó 
pluó 7Æ ió used¬  resultinç iî aî 8-linå display® Iæ thå 
from-addresó  ió noô given¬  dumpinç continueó froí  thå 
lasô  addresó dumped®  Iæ thå to-addresó ió smalleò thaî 
thå from-address¬ onå linå ió dumped.

Example:   d 110 140
           d 110 1         (this will dump 110 to 11f)
.paŠ           E - Execute Command Conditionally

Syntax:    E   { multexpr } ; command

Thå  debuggeò commanä ió executeä onlù iæ thå resulô  oæ 
thå  expressioî ió TRUE®  Iæ nï expressioî ió specified¬ 
oò iæ thå inpuô ió noô aî expression¬  thå commanä  wilì 
noô  bå  executed®  Thió  commanä ió mainlù foò  uså  iî 
commanä macros.

Example:   e rhl > 1000;j mac2, rhl



                F - Specify Command Line

Syntax:    F   { command-line }

Execution of this command is system dependent.

Foò CP/M¬  thå commanä linå ió inserteä aô thå  standarä 
locatioî  80¬  anä  thå defaulô FCB'ó aô 5Ã anä  6Ã  arå 
filled® Foò CP/Í Plus¬ thå passworä fieldó aô 51..5¶ arå 
alsï defined.

Example:   f test.com;pass -f -x


             G - Start Real-Time Execution

Syntaxº    Ç   {to-addressı û» temporary-break-addresó }

Thå useò prograí ió entereä aô thå specifieä to-address® 
Iæ thå to-addresó ió noô specified¬  executioî beginó aô 
thå currenô PC.

Á temporarù breakpoinô maù bå set¬ whicè ió automatical
lù deleteä oî anù break.

Example:   g;111
.paŠ                 H - Display Expression

Syntax:    a)  H
           b)  H   expression  { {,} expression ... }

a) Thå  valueó oæ thå speciaì variableó  L(ow)¬  H(igh)¬ 
   M(ax)¬  anä T(op© (seå "expressions"¬ above© arå dis
   played.

b) Thå  expressioî  ió evaluateä anä displayeä  iî  hex¬ 
   decimal¬ binarù anä charateò form¬ witè two'ó comple
   menô  foò heø anä decimal®  Thió ió repeateä foò  alì 
   given expressions.
   Thió  commanä maù alsï bå useä tï assigî tï variableó 
   anä registeró anä tï displaù theiò values.

Example:   h y0 + $ << 2 & fffe


                  I - Input from port

Syntax:    I   { port }

Onå  bytå ió reaä anä displayeä froí thå specifieä port® 
Iæ nï porô ió given¬  thå lasô porô numbeò specifieä foò 
thió commanä ió used.

Foò systemó whicè evaluatå thå uppeò halæ oæ thå addresó 
buó  oî I/O¬  thå porô maù bå specifieä aó á 16-biô num
ber® Thå uppeò bytå wilì bå outpuô oî A8..A15.

Example:

   :i 2210
   I(Port=10, B=22): ...
   :
.paŠ               J - Jump to Command Macro

Syntax:    J   filename { , parameter ... }

Executioî  anä  formaô oæ thió commanä ió systeí  depen
dent.

Commanä inpuô wilì bå reaä froí thå specifieä file®  Thå 
commandó  wilì  bå  reaä untiì aî erroò  oò  end-of-filå 
occurs®  Nï nestinç oæ commanä macroó ió possible¬ usinç 
thió  commanä  froí withiî á macrï  wilì  terminatå  thå 
calling macro.

Macrï   executioî  maù  bå  prematurelù  terminateä   bù 
enterinç  á characteò aô thå consolå oò bù usinç thå  K-
command from within the macro.

Macroó maù bå parameterized® Thå parameteró specifieä iî 
thå  macrï  calì wilì bå substituteä foò  thå  parameteò 
identifieò @î iî thå macrï body¬ wherå î ió thå positioî 
oæ  thå  parameter¬  countinç froí ° tï  9®  Spaceó  arå 
significanô  iî  á parameteò excepô afteò  á  comma¬  sï 
commaó  musô  bå useä tï separatå parameters®  Aî  emptù 
parameteò  ió generateä bù twï commaó iî  sequence®  Thå 
parameteò identifieò wilì bå substituteä anywhere¬  eveî 
iî strings®  Tï generatå á @-characteò iî á  macro¬  uså 
twï @'s.

Example:

Contents of file TESTMAC:

   g;123
   e rhl > @0; k
   e ; *** HL is less than @0 ! ***      (Note 1)
   e @1; j testmac, @1,@2,@3,@4,@5,@6    (Note 2)
.paŠInvocation:

   j testmac, 100, 50

Notes:

   1)  Thå  commanä iî thió linå wilì neveò bå executed¬ 
       buô  thå linå wilì bå displayeä oî thå  terminal® 
       Iô thuó maù bå useä tï displaù á message.

   2)  Thió commanä wilì onlù bå executeä iæ thå  seconä 
       parameteò (numbeò 1© ió non-empty.


                K - Kill Macro Execution

Syntax:    K

Á currentlù activå macrï wilì bå terminated® Iæ nï macrï 
is active, this command has no effect.


               L - List Disassembled Code

Syntax:    L   { from-address { to-address }}

Thå  codå  beginninç  aô thå  from-addresó  uğ  to¬  anä 
including¬  thå  to-address¬  ió listeä iî  disassembleä 
form® Iæ nï to-addresó ió given¬ eighô lineó arå listed® 
Iæ nï from-addresó ió specified¬  listinç continueó froí 
thå lasô listeä instruction¬ oò froí thå currenô PÃ iæ á 
breaë haó occurred.

Iæ thå to-addresó ió smalleò thaî thå from-address¬  onå 
linå ió listed.

Example:   l rpc rpc + 5

.paŠ                    M - Move Memory

Syntaxº    Í   begin-addresó end-addresó destination

Thå   memorù  startinç  aô  begin-addresó  uğ  to¬   anä 
including¬  thå end-address¬ ió moveä tï thå destinatioî 
address.

Overlappinç  moveó  arå  alloweä anä dï  noô  resulô  iî 
propagatinç valueó througè memory.

Aî erroò wilì resulô iæ thå end-addresó ió smalleò  thaî 
thå begin-address.

Example:   m rpc rpc+10 3000
.paŠ              N - Name (Symbol) Definition

Syntax:    a)  N
           b)  N   address symbol ...
           c)  NF  filename
           d)  NX
           e)  NX  symbol ...
           f)  NS  number
           g)  NR  { offset }
           h)  NW

a) Thå  numbeò  oæ defineä symboló anä thå currenô  freå 
   symboì  spacå ió displayeä iî decimal¬  theî alì  de
   fineä symboló arå listeä iî ascendinç addresó order.

b) Thå symboì ió defineä aó havinç thå valuå  "address"® 
   Iæ thå symboì ió alreadù defined¬ iô wilì bå assigneä 
   thå ne÷ value.

c) Defineó thå namå foò thå symboì file® Thå symboì filå 
   namå ió noô changeä bù thå normaì 'F'-command® Thå NÆ 
   commanä  ió implieä iæ á seconä filenamå ió specifieä 
   on the initial command line.

d) Alì symboló arå deleted® Thió wilì noô releaså symboì 
   tablå memorù space®

e© Thå specifieä symboì nameó arå deleted.

f) Thå  symboì  tablå  ió  expandeä  tï  makå  rooí  foò 
   "number¢ additional symbols® 

g) Thå  filå  specifieä bù thå lasô NF-commanä  wilì  bå 
   reaä  aó  symbol-file®  Iæ aî offseô ió  given¬  thió 
   offseô  wilì bå addeä tï alì symboì values®  Thå  re
   quireä  formaô isº  Firsô value¬  theî  symboì  name¬ 
   separateä bù spaceó oò tabs® Valuå anä symboì musô bå 
   oî  thå  samå  line®  Onå linå maù  contaiî  multiplå 
   symboì  definitions®  Nï linå maù bå longeò  thaî  8° 
   characters.

h) Thå  symboì  tablå  wilì  bå  writteî  tï  thå   filå 
   specified by the last NF-command.
.paŠCautions:

   Symboì  tablå  spacå ió allocateä  downwardó  (towarä 
   addresó  0© iî memory¬  directlù belo÷ thå  debugger® 
   Expansioî oæ thió spacå ió automatiã iæ morå  symboló 
   arå  defineä  thaî caî bå containeä iî thå  availablå 
   space®  Iæ  thå prograí stacë ió withiî 51² byteó  oæ 
   thå toğ oæ thå TPA¬ thå stacë wilì bå moveä down¬ anä 
   thå  SĞ wilì bå changeä accordingly®

   Iæ  thå prograí undeò tesô useó spacå aô thå  toğ  oæ 
   thå  TPÁ foò datá oò prograí storage¬  thió spacå maù 
   bå  overwritteî wheî symboì tablå spacå ió  expanded¬ 
   oò  thå  prograí mighô overwritå  thå  symboì  table¬ 
   causinç thå debuggeò tï crash® Tï avoiä this¬ reservå 
   enougè  symboì  tablå spacå beforå startinç thå  pro
   gram® Tï bå safå froí symboì tablå expansion¬ yoõ maù 
   seô thå M-variablå tï thå toğ oæ thå TPA¬  sincå WADÅ 
   wilì  neveò expanä thå symboì tablå belo÷ Maø  (Exam
   pleº  è m := t).

   Foò  CP/Í ³ only¬  programó witè aî attacheä RSØ wilì 
   causå thå M-variablå tï bå seô tï thå Toğ oæ thå TPA¬ 
   sincå  alì  RSXeó wilì bå  relocateä  there®  Reservå 
   symboì  spacå beforå loadinç thå program¬  sincå  thå 
   symboì  tablå  cannoô  bå expandeä oncå  thå  RSØ  ió 
   loaded.

Example:

       :n 100 start, 5 bdos, 4711 stinks
       :ns 40.
       :nf test.sym
       :nr 2000
       :nx bdos
       :nf new.sym
       :nw

.paŠ                   O - Output to Port

Syntax:    O   { data-byte { port-address }}

Outpuô thå data-bytå tï thå specifieä port-address®  Thå 
data-bytå wilì alsï bå displayed.

Iæ thå port-addresó ió noô given¬  thå lasô port-addresó 
specifieä witè aî O-commanä ió used® Iæ thå data-bytå ió 
noô entered¬ thå datá oæ thå lasô O-commanä ió used.

Foò systemó whicè evaluatå thå uppeò halæ oæ thå addresó 
buó  oî I/O¬  thå porô maù bå specifieä aó á 16-biô num
ber® Thå higè bytå wilì bå outpuô oî A8..A15.

Example:

   :o 'x' 2210
   O(Port=10, B=22): ...
   :
.paŠ                  P - Trace Protection

Syntax:    a)  P
           b)  PX
           c)  P   multexpr

a) Display current protect condition

b) Delete protect condition

c) Define protect condition

Thå  protecô conditioî ió evaluateä oî eacè  trace®  Thå 
instructioî wilì bå executeä iî real-time¬  witè á breaë 
seô tï thå currenô returî address¬  iæ thå protecô  exp
ressioî evaluateó tï á TRUÅ (nonzero) value.

CAUTIONº Iæ thå valuå aô thå currenô stackpointeò ió NOÔ 
á  returî  addresó wheî thå protecô expressioî ió  true¬ 
thå  breakpoinô wilì bå seô aô aî invaliä  address¬  anä 
thå prograí maù fail¬ oò iô maù noô returî tï thå debug
ger.

Thå  defaulô valuå oæ thå protecô expressioî ió 'RPÃ  >½ 
xxxx'¬  wherå  xxxø  ió  thå  startinç  addresó  oæ  thå 
debugger®  Thió  resultó iî BDOS-calló beinç executeä iî 
reaì  time®   Bå  carefuì  wheî  changinç  thå   protecô 
expression¬ sincå tracinç intï thå BDOÓ wilì mosô likelù 
noô  worë  (thå debuggeò alsï useó BDOS-calls¬  anä  thå 
BDOS is not re-entrant).


Example:   p rpc >= (6).


          Q - Query (search) for a byte string

Syntax:    Q   {J} begin-addr end-addr byte-string

Memorù wilì bå searcheä foò thå byte-strinç startinç  aô 
thå begin-addò uğ to¬ anä including¬ thå end-addr® Everù 
matcè  wilì bå displayeä aó onå linå oæ dump¬  witè  thå 
dumğ beginninç aô thå firsô matchinç byte¬  or¬  iæ Ê ió 
specified¬ aô ¸ byteó beforå thå firsô matchinç byte.

Example:   qj l h 'Hello' 0d 0a
.paŠ              R - Read a File into Memory

Syntax:    R   { offset }

Execution of this command is system dependent.

Thå  filå  specifieä bù thå lasô F-commanä wilì bå  reaä 
intï memory®  Aî offset¬  iæ specified¬ wilì bå addeä tï 
thå standarä loaä address®  Iæ á filå haó thå  extensioî 
HEX¬  iô ió assumeä tï contaiî standarä INTEL-Heø formaô 
records®  Alì  otheò  filetypeó arå reaä intï memorù  aó 
theù arå withouô anù editing.

Aî erroò occuró iæ thå filå cannoô bå found¬ iæ thå loaä 
addresó ió belo÷ 80è (CP/M)¬  oò iæ thå filå woulä over
writå thå debugger.

Foò  CP/Í 3¬  fileó witè aî attacheä RSØ wilì bå  loadeä 
viá thå system'ó "loaä overlay¢ function¬  whicè handleó 
thå relocatioî oæ thå RSX®  Á filå ió assumeä tï havå aî 
attacheä  RSØ iæ thå firsô bytå containó á REÔ  instruc
tioî (C9)¬  anä iæ thå filetypå ió .COM®  Notå thaô  foò 
fileó  witè attacheä RSX¬  thå Higè addresó wilì noô  bå 
seô  tï  thå  enä oæ thå file¬  sincå  thió  addresó  ió 
unknown.

Example:   r h-100


                 S - Substitute Memory

Syntax:    a)  S   address byte-string
           b)  S   { address }

a) The byte-string replaces the memory at address.

b) Thå  bytå aô thå specifieä addresó ió displayed¬  anä 
   inpuô oæ á byte-strinç ió expected®  Thå  byte-strinç 
   replaceó  thå  contentó  oæ  memory¬   anä  thå  nexô 
   locatioî ió displayed® Aî emptù inpuô advanceó tï thå 
   nexô location® Uså á doô (.© aó firsô inpuô characteò 
   tï terminatå thå command.
   Iæ nï addresó ió specified¬ substitutioî continueó aô 
   thå  lasô  addresó  displayeä bù á previouó  Ó  oò  Á 
   command.

Example:

   :s rhl 'Hi, there' 0d 0a



                       T - Trace

Syntax:    a)  T   {N}{J}  {count}
           b)  T   {N}{J}  W multexpr
           c)  T   {N}{J}  U multexpr

a) "count¢  instructionó  arå  traced®  Iæ nï  counô  ió 
   given¬ onå instructioî ió traced.
Šb) tracinç continueó whilå thå expressioî evaluateó tï á 
   TRUE value.

c) tracinç continueó untiì thå expressioî evaluateó tï á 
   TRUE value.

Iæ  Î  ió given¬  thå traceä instructionó  wilì  noô  bå 
displayed.

Iæ  Ê ió given¬  onlù instructionó whicè modifù thå pro
graí counteò (Jump¬  Calì anä Returî instructions©  wilì 
bå  displayeä anä counteä oò causå thå expressioî tï  bå 
evaluated.

Iæ NÊ ió specified¬ instructionó wilì noô bå listed¬ anä 
onlù  instructionó whicè modifù thå PÃ wilì decreaså thå 
counô oò tesô thå condition.

Tracinç  wilì terminatå independenô oæ counô oò  expres
sioî iæ á breakpoinô ió encountered¬  oò iæ á  characteò 
(otheò thaî ^Ó oò ^Q© ió entereä aô thå console.

Iæ  thå  protecô conditioî (seå P¬  above© becomeó  TRUÅ 
durinç trace¬  tracinç wilì bå inhibiteä anä thå protec
teä parô wilì bå executeä iî real-time.

CAUTIONº  Sincå iô ió noô possiblå tï breaë aô thå  cur
renô  PC¬  instructionó causinç á looğ tï itselæ caî  bå 
traceä onlù wheî thå looğ ió exited®  Instructionó otheò 
thaî DJNÚ wilì causå thå debuggeò tï issuå aî error.
That is,

   100       LD    B,10
   102       DJNZ  102

wilì  executå  thå DJNÚ iî real-timå anä theî tracå  thå 
nexô instruction¬ whereas

   100       JP    NZ,100

wilì causå thå debuggeò tï refuså tï trace¬  eveî iæ thå 
conditioî ió false® Yoõ havå tï changå thå PÃ bù hanä tï 
allo÷ thå prograí tï continue.

Self-modifyinç  codå caî causå thå tracå tï faiì iæ  thå 
impliciô   breaë   afteò  thå  traceä   instructioî   ió 
overwritteî bù thå instructioî itself® Foò example,

       100     LD (103),A
       103     NOP

wilì causå thå breaë aô 10³ tï bå missed¬  anä executioî 
oæ thå prograí wilì continuå iî real-time.


Example:   tj u y0:=y0+1, rpc > 2000

.paŠ                  U - User Input Trap

Syntax:    U

Thió commanä ió user-defineable®  Executioî anä  parame
teró arå systeí dependent.

Thå  debuggeò wilì prompô foò á character®  Enterinç  CÒ 
wilì deletå anù trağ character¬  enterinç anù otheò cha
racteò wilì definå thió chaò aó inpuô trağ character® Iæ 
á trağ chaò ió defined¬ alì consolå inpuô bù thå prograí 
undeò test¬  excepô foò thå "reaä consolå buffer¢  func
tioî oæ CP/M¬ wilì bå checkeä foò equalitù witè thå trağ 
character¬ anä á breaë wilì bå entereä oî á match® 

Thå  breaë wilì bå seô uğ sucè thaô thå prograí     wilì 
agaiî  reaä á characteò iæ á Gï ió issued®  Thió  seconä 
characteò  reaä  wilì  theî noô agaiî bå checkeä  foò  á 
matcè witè thå trağ character.

Example:

       :u
       Ch: ~
       :


                   V - Verify Memory

Syntax:    V   begin-addr end-addr compare-addr

Memorù startinç aô thå begin-addò uğ to¬  anä including¬ 
thå  end-addr¬  ió compareä witè memorù startinç aô  thå 
compare-addr®  Non-matchinç  byteó  arå  displayeä  witè 
theiò address.

Example:   v 100 1ff 200
.paŠ                W - Write memory to File

Syntax:    W   start-address end-address { offset }

Execution of this command is system dependent.

Memorù  beginninç  aô  thå  start-addresó  uğ  to¬   anä 
including¬  thå  end-addresó  ió  writteî  tï  thå  filå 
specifieä  bù  thå lasô F-command®  Iæ thå filå typå  ió 
.HEX, Intel Hex format will be generated.

Aî  offseô ió onlù accepteä foò fileó oæ typå  HEX¬  anä 
theî  specifieó  thå offseô tï bå addeä tï  thå  currenô 
writå addresó wheî generatinç thå Hex-filå address.

Example:   w l h


            X - Examine CPU State/Registers

Syntax:    a)  X
           b)  X'
           c)  X   register-name
           d)  X   register-name expression {...}

a) Thå primarù registers¬  thå currenô instruction¬  anä 
   the bottom stack words are displayed.

b) The alternate register set is displayed.

c) Thå  contentó oæ thå registeò arå displayed¬  anä  aî 
   expressioî ió expected®  Thå valuå oæ thå  expressioî 
   ió assigneä tï thå register.

d) Thå  registeò  ió seô tï thå  specifieä  value®  Thió 
   specification may be repeated.


Example:

       :x pc
       0100  1ac
       :x a 0a b 0c de 1234
.paŠ                Y - Display Y-Variables

Syntax:    a)  Y
           b)  Y   n
           c)  Y   n  expression {...}

a) Display the contents of all 10 Y-Variables

b) Thå  contentó oæ thå variablå î (î ½ 0..9©  arå  dis
   played¬  anä aî expressioî ió expected®  Thå valuå oæ 
   thå expressioî ió assigneä tï thå variable.

c) Thå  variablå î ió seô tï thå specifieä  value®  Thió 
   specification may be repeated.


Thå Y-Variableó arå noô modifieä bù thå debuggeò anä arå 
thuó  availablå  aó counteró oò evenô markeró  foò  useò 
expressions and command macros.

Example:

       :y 0
       0000  123
       :y 0 123  1 0c  2 0d


                 Z - Zap (fill) memory

Syntax:    Z   begin-addr end-addr byte-string

Memorù startinç aô begin-addò uğ to¬ anä including¬ end-
addò ió filleä witè thå byte-string.

Example:   z 2000 2fff 0d 0a
.paŠ                        Appendix
             Extended Memory Considerations

Thå  distributioî disë containó á versioî oæ WADÅ  whicè 
supportó  extendeä addressinç undeò CP/Í 3®  Iæ yoõ  arå 
runninç á bankeä versioî oæ CP/Í 3¬  thió versioî shoulä 
ruî  oî youò systeí withouô modificationó if¬  anä  onlù 
if, the following is true:

-  therå  ió  aô leasô ² ë spacå iî commoî memorù  belo÷ 
   thå BDOÓ entry®  Thió spacå ió requireä tï allo÷ WADÅ 
   tï  switcè  bacë intï thå defaulô banë  (banë  1©  oî 
   returî froí á breakpoinô iî á differenô bank®

-  thå MOVE¬  XMOVÅ anä SELMEÍ entrieó oæ youò BIOÓ  arå 
   in common memory.

Iæ  yoõ  dï  noô intenä tï uså  tracinç  oò  breakpointó 
outsidå oæ thå normaì banë 1¬  yoõ shoulä bå ablå tï uså 
thå extendeä versioî eveî iæ thå firsô conditioî ió  noô 
true. 

Pleaså  notå thaô thå extendeä versioî ió mucè sloweò iî 
alì  memorù accesó operationó duå tï thå neeä tï  accesó 
memorù  viá thå MOVÅ anä XMOVÅ BIOÓ routineó insteaä  oæ 
usinç direcô access®  Thå extendeä versioî shoulä there
forå onlù bå useä wherå accesó tï otheò bankó ió  neces
sary.

Tï verifù thaô yoõ caî ruî thå extendeä version¬ uså thå 
non-extended WADE and the command macro EXTEST:

   WADE
   J EXTEST

anä  notå wherå thå macrï stopó execution®  Iæ thå macrï 
exitó witè á g0¬  yoõ caî uså thå extendeä  version®  Iæ 
thå  messagå  'OË tï uså iî non-tracå mode§ appearó  buô 
thå macrï theî terminató witè 'Lesó thaî ² ë free'¬  yoõ 
may not trace any routine outside the default bank.


                        Cautions

WADÅ alwayó operateó oî á 'defaulô bank'¬  whicè ió  seô 
tï  ±  (thå CP/Í TPÁ bank© oî entry®  Sincå therå ió  nï 
systeí  independenô  waù tï obtaiî  thå  currenô  activå 
bank¬  yoõ havå tï changå thå activå banë bù hanä iæ yoõ 
intenä  tï tracå anù routinå outsidå oæ banë 1®  Extremå 
cautioî  musô  bå employeä wheî tracinç  routineó  whicè 
mighô changå thå currenô bank¬  sincå tracinç mighô faiì 
(mosô likelù completelù crashinç thå system© iæ WADÅ  ió 
noô informeä oî thå banë switch®  Pleaså note¬ too¬ thaô 
thå restarô locatioî iî alì bankó foò whicè á breakpoinô 
haó  beeî  defineä wilì bå changeä whilå tracinç  ió  iî 
progresó oò anù breakpoinô haó beeî seô anä thå  prograí 
ió  executinç iî reaì time®  Althougè WADÅ wilì  restorå 
thå  originaì contentó oæ thió location¬  yoõ shoulä noô 
attempô  tï tracå anù routinå whicè mighô depenä oî  thå 
informatioî  storeä aô thió locatioî (38è tï 3aè iî  thå 
currenô release).Š
                   Changing the Bank

Thå  currenô  activå banë ió containeä  iî  thå  speciaì 
registeò  'X§  anä  maù bå displayeä usinç thå È  oò  X§ 
command®  Iô maù bå changeä bù assignmenô:

   H X :½ 0

or by changing the program counter with the X-command:

   X PC 0:100

Yoõ  caî  alsï  uså alì memorù referencå  commandó  witè 
locationó  outsidå  thå currenô banë  bù  specifyinç  aî 
extendeä address:

   L 0:100         Lists Bank 0, Address 100
   S 5:e000        Substitutes Bank 5, Address E000
   M 0:0 ff 100    Moveó  froí Banë 0¬  Addresó ° tï FF¬ 
                   to Address 100 in the current Bank
   Ú 7:° ff 0      Setó Locationó ° tï FÆ iî Banë · tï 0

You may even assign to locations in other banks:

   H 0:100 := (7:100).


                     Customization

Iæ yoõ owî thå sourcå versioî oæ WADE¬  yoõ mighô possi
blù  changå  thå  entrù 'EBREAK§ iî  modulå  MONPEEË  tï 
obtaiî   thå  currentlù selecteä banë iî  somå  hardwarå 
dependenô  waù  anngå  thå  entrù 'EBREAK§ iî  modulå  MONPEEË  tï 
obtaiî   thå  currentlù selecteä banë iî  somå  hardwarå 
dependenô  waù  anä  storå iô iî  thå  variablå  'CBANK§ 
beforå switchinç tï thå defaulô bank®  Thió woulä  allo÷ 
tracinç  intï otheò bankó withouô settinç thå X-registeò 
bù  hand®  Iæ youò BIOÓ returnó thå previouslù  selecteä 
banë iî registeò Á oî exiô froí thå SELMEÍ routine¬  yoõ 
maù  simplù  seô thå equatå 'MEGA§ tï TRUÅ iî  thå  filå 
MONOPT.LIB and re-assemble the module MONPEEK.
