                WADE - Wagners Debugger
.he WADE - Wagners Debugger - User Manual - V. 1.5 -  Page #

                      User Manual
                 Version 1.5 - 85-04-27


WADŠ i� a� interactiv� symboli� Z8� debugge� wit� ful� �
assembl� an� disassembl� usin� standar� ZILO� mnemonics� �
U� t� eigh� conditiona� and/o� unconditiona� breakpoint� �
plu� � temporar� breakpoin� ma� b� defined� Ful� tracin� �
wit� o� withou� lis� an� wit� real-tim� executio� o� �
subroutine� o� comman� o� automati� (usin� protecte� �
areas�� i� provided�� Tracin� ma� b� controlle� b� inst�
ructio� coun� o� � conditiona� expression� � ful� se� o� �
operator� provide� fo� arithmetic�� logical�� shift� an� �
relationa� operation� o� hex�� decimal� binary� an� cha�
racte� data�� an� o� registers�� variables� an� symbols� �
includin� embedde� assignment� t� register� an� varia�
bles�� Extende� addressin� ca� b� provide� fo� system� �
wit� bankin� o� memor� managemen� capabilities.

WAD� support� parameterise� comman� macro� an� conditio�
na� comman� execution.

WADŠ i� supplie� wit� complet� sourc� cod� fo� th� �
Digita� Researc� RMA� assembler�� Syste� dependen�� rou�
tine� lik� consol� i/o��  fil� i/o�� an� bankin� ar� �
collecte� i� � singl� modul� t� allo� eas� adaptatio� t� �
othe� operatin� system� o� stand-alon� ROM-base� appli�
cations.


                      No Copyright

Wade was written 1984-1985 by

     Thomas Wagner
     Patschkauer Weg 31
     D-1000 Berlin 33
     West Germany

     BIX mail: twagner

It has been released to the public domain in 1987.

Yo� ma� us� an� modif� thi� program� it� sources� o� an� �
part� o� it�� i� an� wa� yo� choose�� N� par�� o� thi� �
progra� i� copyrighte� an� longer�� eve� i� copyrigh� �
notice� stil� appea� i� som� o� th� files.

N� contributio� i� an� wa� i� requeste� o� expecte� �
(althoug� � wouldn'� rejec� i� :-))�� I'v� give� u� CP/� �
an� Z8�� programming�� s� thi� softwar� i� n� longe� �
supported� 

I'l� tr�� t� hel� an� answe� question� abou�� thi� �
software� bu� � haven'� touche� i� fo� quit� � while� s� �
don't expect too much.
.pa�                    Command Summary

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
T  {N}{J} U mexpr     ..Until�
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
.pa�                       Using WADE

Syntax:  WADE  { filename { symbol-filename }}

WAD� i� calle� lik� an� othe� CP/� command� I� relocate� �
itsel� belo� th� BDO� an� set� th� addres� a� � corres�
pondingl� (fo� CP/� 3�� thi� i� don� b� th� syste� usin� �
th� RS� mechanism).

I� � filnam� i� specifie� i� th� comman� line� thi� fil� �
i� the� rea� int� memory�� a� i� a� R-comman� ha� bee� �
entered� Pleas� not� tha� yo� hav� t� issu� a� F-comman� �
t� clea� th� filenam� fro� th� defaul� FC� i� th� pro�
gra� unde� tes� expect� parameters.

I� � secon� (symbol-� filenam� i� give� i� th� comman� �
line�� thi� fil� i� rea� a� � Symbo� File�� a� i� a� N� �
comman� ha� bee� entered�� Not� fo� CP/� 3�� tha�� th� �
progra� fil� i� rea� first� s� i� � progra� wit� attach�
e� RS� i� loaded�� ther� ma� b� no� enoug� spac� t� rea� �
al� symbols�� I� thi� case�� th� symbol� shoul� b� rea� �
before the program (see NF, NR and R commands).

Example:    WADE myprog.com myprog.sym


T� exi�� WAD� unde� CP/M�� issu� � � comman� wit� th� �
paramete� 0� Thi� wil� rese� th� BDOS-pointer� an� warm�
boo� th� operatin� system.

Example:    g0
.pa�                     Command input

Command� an� parameter� ma� b� entere� i� upper- o� �
lowercase�� Space� ma� b� use� freel� a� separato� be�
twee� operands�� comma� ma� b� use� t� separat� parame�
ters�� Th� maximu� accepte� inpu� lin� lengt� i� 7� �
characters.

Th� lin� i� interprete� onl� afte� � C� ha� bee� en�
tered�� s� yo� ca� edi� th� inpu� usin� th� DE̠ o� B� �
key�� � TA� i� interprete� a� � space�� � L� i� ignored� �
Al� othe� contro� character� ar� refused.


                  Auto Command Repeat

Al� entere� command� excep� 'G� ar� save� an� re-exe�
cute� i� � carriag� retur� onl� i� entered�� Parameters� �
however�� ar� no� saved�� s� th� defaul� value� wil� b� �
use� i� applicable� I� parameter� mus� b� specifie� wit� �
a command, auto repeat is not possible.


                    Display Control

Displa� outpu� ca� b� stoppe� a� eac� lin� en� b�� ente�
rin� ^� (contro� � S)�� an� continue� b� ^� (contro� � �
Q)�� Hittin� th� spac� ke� onc� wil� als� sto� th� dis�
play�� hittin� i� agai� (o� enterin� ^Q� wil� le� outpu� �
continue.


                     Command abort

Ever�� comman� whic� produce� outpu� ca� b� aborte� a� �
th� en� o� eac� outpu� lin� b� enterin� an�� characte� �
othe� tha� space�� ^S�� o� ^Q� Also� � trac� wit� Nolis� �
ca� b� aborte� a� an� tim� th� progra� doe� no� execut� �
i� real-time�� Abortin� � comman� wil� als� kil� � cur�
rentl� activ� comman� macro.
.pa�                      Expressions

Al� number� i� command� an� assembl� line� ma�� b� a� �
expression�� excep�� fo� "� regname"�� wher� � registe� �
name� no� � registe� designatio� (Rx� mus� b� used.

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
           wher� th� facto� whic� i� assigne� t� ma� b� �
�����������a� unsigne� registe� o� variabl� specifica�
�����������tion� o� a� addres� value� Th� resul� o� thi� �
�����������operato� i� th� valu� o� th� right-han� sid� �
�����������o� th� assignmen� operator�� whic� i� a�� th� �
�����������sam� tim� assigne� t� th� register�� variabl� �
�����������o� addres� specifie� o� th� left-han� side.
�����������Siz� adjustmen�� i� automati� fo� variable� �
�����������an� registers�� I� a� addres� i� use� a� th� �
�����������destination�� � wor� i� stored�� T� stor� � �
�����������byt� only�� us� th� operato� '=='�� Not� tha� �
�����������t� assig� t� � registe� o� variable�� n� sig� �
�����������o� expressio� ma� b� use� wit� th� registe� �
�����������or variable name, i.e. the expression
�����������RHL := 1234  will assign 1234 to register HL,
           wherea� +RH� :� 123� wil� assig� 123� t� th� �
�����������address contained in register HL.
.pa�   :       extended memory specification
           th� valu� o� thi� operato� i� th� valu� o� �
�����������th� right-han� sid� o� th� operator�� Th� �
�����������valu� o� th� left-han� sid� specifie� � (sys�
�����������te� dependent� extende� address�� whic� i� �
�����������use� i� memor� reference� an� wit� command� �
�����������whic� expec� a� address�� I� al� othe� cases� �
�����������thi� valu� i� ignored� A� erro� occur� i� th� �
�����������extende� addres� i� undefine� i� th� targe� �
�����������system��� o� i� extende䠠 addressin砠 i� �
�����������disabled.

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

���Th� variabl� � contain� th� standar� loa� addres� �
���(100� fo� CP/M� an� i� no� change� b� th� debugger� �
���bu� ma� b� use� assigne� t� � differen� value.

���Th� variabl� � contain� th� highes� addres� rea� o� �
���th� las� file�� I� i� update� eac� tim� a� R-comman� �
���i� executed.

���Th� variabl� � contain� th� highes� addres� rea� o� �
���al� previou� R-commands.

���Th� variabl� � contain� th� to� addres� o� th� use� �
���TPA� I� i� update� i� symbo� tabl� spac� i� expanded.

�   Th� variabl� ؠ contain� th� defaul� ban� fo� al� �
���operation� i� extende� addressin� i� enabled�� I� ma� �
���b� change� b� assignmen� o� b� changin� th� Pà wit� �
���an extended address.

���Th� short-for� '$� fo� P� ma� onl� b� use� i� expres�
���sions� no� i� a� X-comman�.

���Th� characte� '_� (underline� ma� b� use� i� number� �
���t� enhanc� readability� I� i� completel� ignored.

String:

   Any number of characters delimited by quotes (').
   Us� � tw� quote� (''� t� represen� � singl� quot� 
���within a string: 'It''s a quote'.

Register names:

   primary:    A, F, AF, B, C, BC, D, E, DE,
               H, L, HL, IX, IY, SP, PC

   alternate:  A', F', AF', B', C', BC', D', E', DE',
               H', L', HL'

   control:    IFF  (interrupt enable flip flop)
               I    (interrupt register)
               R    (refresh register, read only)

Symbols:

   An�� numbe� o� characters�� o� whic� onl� th� firs� �
���eigh�� character� ar� significan�� (th� significan� �
���lengt� o� symbol� ca� b� change� b�� reassembling)� �
���Th� firs� characte� mus� b� non-numeric�� Symbol� ma� �
���consis� o� letters�� digits�� an� th� specia� charac�
���ter� @� ?� _� an� $� Lowercas� letter� ar� translate� �
���to uppercase. Any underlines (_) are stripped.



                  Multiple Expressions

Al� command� expectin� � conditio� wil� accep� multipl� �
expression� i� sequence�� Onl� th� valu� o� th� las� �
expressio� i� use� a� th� conditio� result�� Th� genera� �
form for this "mexpr" is

   expression  { {,} expression ... }



                      Byte-Strings

Th� command� Q(ery)�� S(ubstitute)�� an� Z(ap� expec�� � �
byte-strin� a� operand�� I� � byte-string�� characte� �
string� ar� significan� ove� thei� ful� length�� Th� �
genera� for� is

   expression-or-string { {,} expression-or-string ... }
�onl�� th� lowe� byt� i� significan� fo� expression� i� �
byt� strings�� Not� tha� � strin� i� evaluate� first� s� �
t� ente� th� expressio� 'N'-4� i� � byte-string�� yo� �
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

Operator� o� equa� precedenc� ar� evaluate� lef�� t� �
right�� an� mus� b� brackete� i� � differen�� orde� o� �
evaluatio� i� desired�� Assignment� ar� evaluate� righ� �
to left.

Examples:

   1 + 2 * -3       => -5
   5 - 2 : 2 * 3    => Bank 3, Address 6
   ��5+2 =� (��6�   =� Assig� content� o� 3:� t� 3:7
   rhl := +rde := 1 => Assign 1 to register HL and the 
                       address contained in DE
   rhl := (rde). := 1 => same as above


Th� nestin� dept� o� expression� i� limite� b�� th� �
availabl� debugge� stac� space�� I� th� curren� release� �
25�� byte� ar� availabl� fo� th� stack�� s� tha�� an� �
reasonabl� expressio� shoul� caus� n� problems.

                        Booleans

Fo� command� expectin� � conditiona� expression� an� fo� �
th� boolea� AND/O� operators�� th� valu� �� represent� �
FALSE� whil� an� valu� othe� tha� � represent� TRUE.

Th� resul� o� th� relationa� an� boolea� operator� i� � �
fo� TRU� an� FFF� fo� FALSE.

A� exampl� t� sho� th� differenc� betwee� bitwise� an� �
boolean operators:

   1 &  2  is 0
   1 && 2  is FFFF.

   1 |  2  is 3
   1 || 2  is FFFF.
.pa�                        Commands

                      A - Assemble

Syntax:    A  { start-address }

I� � star� addres� i� no� specified�� th� las�� addres� �
displaye� i� a� � o� � comman� i� used.

Th� curren�� content� o� th� locatio� ar� displaye� i� �
he�� an� i� disassemble� form�� an� � lin� o� assembl� �
cod� i� expected� Th� cod� mus� b� specifie� i� standar� �
ZILO� mnemonics�� wit� operand� separate� b� � comma� N� �
abbreviation� ar� allowed�� Th� entere� instructio� re�
place� th� curren� one�� an� th� comman� wil� advanc� t� �
th� nex� instruction.
I� yo� ente� a� empt� line�� th� comman� wil� advanc� t� �
th� nex� instruction�� T� terminat� th� command� ente� � �
do� (.� a� firs� characte� i� � line.

I� a� inpu� ca� b� interprete� a� bot� � registe� an� � �
numbe� (a� i�   L�  A,� )�� th� registe� interpretatio� �
take� precedence�� Us� L� A,0� t� specif� a� immediat� �
value.

Th� displacemen�� fo� relativ� jump� i� entere� a� a� �
absolut� address�� Th� debugge� wil� calculat� th� dis�
placemen� fo� you.

�� symbo� ma�� b� define� a� th� curren�� addres� b� �
entering the symbol with a terminating colon (':').

�� synta� erro� wil� exi� assembl� mod� withou� changin� �
th� addres� pointer�� Simpl� enterin� � carriag� retur� �
will continue assembling at the same location.


Example:

   :a 220
   220  START:  LD    DE,2345          ld a,b
   221          LD    B,L              here: ld d,'a'
   223          JR    NZ,0227   .
   :
.pa�           B - Breakpoint Set/Delete/Display

Syntax:    a)  B
           b)  B   address { address.. }
           c)  BI  multexpr ; address { address.. }
           d)  BX
           e)  BX  address { address.. }
           f)  BXI

a) Al� breakpoint� an� th� conditiona� brea� expressio� �
���(if present) are displayed.

b)�Th� addresse� ar� entere� a� unconditiona� break�
���points� I� a� addres� i� alread� define� a� conditio�
���na� breakpoint�� th� conditio� i� delete� fo� thi� �
���address.

c) Th� expressio� i� store� a� brea� condition�� an� th� �
���addresse� ar� define� a� conditiona� breakpoints� An� �
���previousl� define� conditiona� breakpoint� ar� se� t� �
���unconditional.

d) Delete all breakpoints and the condition expression.

e) Delete the specified breakpoints.

f) Delet堠 th堠 brea렠 condition��� Al젠 conditiona� �
���breakpoint� ar� se� t� unconditional.


Example:
       :b 4711 .start
       :bi rc = 15; 5
       :b
       4711  0400  0005(If)
       If: rc = 15
       :
.pa�                  C - Trace over calls

Syntax:    a)  C {N} {J} {count}
           b)  C {N} {J} W multexpr
           c)  C {N} {J} U multexpr

Thi� comman� work� th� sam� a� th� T(race�� command� �
excep�� tha� routine� CALLe� ar� execute� i� real-time� �
i.e� the� ar� no� traced.

Th� calle� routin� MUS� retur� t� th� instructio� afte� �
th� Call-instruction� o� tracin� wil� fail� Tha� is� yo� �
ca� no�� us� thi� comman� fo� routine� whic� expec�� � �
paramete� lis� afte� th� cal� instructio� an� modif� th� �
retur� address�� o� fo� routine� whic� migh�� po� th� �
retur� addres� an� retur� t� somewher� else.

See definition of T for more details on the parameters.

Example:   cnw rbc <> 0 && rde = 0


                        D - Dump

Syntax:    D   {from-address {to-address}}

Memor� i� displaye� i� hexadecima� an� ASCI� forma� fro� �
th� from-addres� u� to�� an� including�� th� to-address� �
I� th� to-addres� i� no�� specified�� th� from-addres� �
plu� 7� i� used�� resultin� i� a� 8-lin� display� I� th� �
from-addres� i� no� given�� dumpin� continue� fro� th� �
las�� addres� dumped�� I� th� to-addres� i� smalle� tha� �
th� from-address� on� lin� i� dumped.

Example:   d 110 140
           d 110 1         (this will dump 110 to 11f)
.pa�           E - Execute Command Conditionally

Syntax:    E   { multexpr } ; command

Th� debugge� comman� i� execute� onl� i� th� resul�� o� �
th� expressio� i� TRUE�� I� n� expressio� i� specified� �
o� i� th� inpu� i� no� a� expression�� th� comman� wil� �
no�� b� executed�� Thi� comman� i� mainl� fo� us� i� �
comman� macros.

Example:   e rhl > 1000;j mac2, rhl



                F - Specify Command Line

Syntax:    F   { command-line }

Execution of this command is system dependent.

Fo� CP/M�� th� comman� lin� i� inserte� a� th� standar� �
locatio� 80�� an� th� defaul� FCB'� a� 5� an� 6à ar� �
filled� Fo� CP/� Plus� th� passwor� field� a� 51..5� ar� �
als� defined.

Example:   f test.com;pass -f -x


             G - Start Real-Time Execution

Syntax��   �   {to-address� �� temporary-break-addres� }

Th� use� progra� i� entere� a� th� specifie� to-address� �
I� th� to-addres� i� no� specified�� executio� begin� a� �
th� curren� PC.

� temporar� breakpoin� ma� b� set� whic� i� automatical�
l� delete� o� an� break.

Example:   g;111
.pa�                 H - Display Expression

Syntax:    a)  H
           b)  H   expression  { {,} expression ... }

a)�Th� value� o� th� specia� variable� L(ow)�� H(igh)� �
���M(ax)�� an� T(op� (se� "expressions"� above� ar� dis�
���played.

b) Th� expressio� i� evaluate� an� displaye� i� hex� �
���decimal� binar� an� charate� form� wit� two'� comple�
���men�� fo� he� an� decimal�� Thi� i� repeate� fo� al� �
���given expressions.
���Thi� comman� ma� als� b� use� t� assig� t� variable� �
���an� register� an� t� displa� thei� values.

Example:   h y0 + $ << 2 & fffe


                  I - Input from port

Syntax:    I   { port }

On� byt� i� rea� an� displaye� fro� th� specifie� port� �
I� n� por� i� given�� th� las� por� numbe� specifie� fo� �
thi� comman� i� used.

Fo� system� whic� evaluat� th� uppe� hal� o� th� addres� �
bu� o� I/O�� th� por� ma� b� specifie� a� � 16-bi� num�
ber� Th� uppe� byt� wil� b� outpu� o� A8..A15.

Example:

   :i 2210
   I(Port=10, B=22): ...
   :
.pa�               J - Jump to Command Macro

Syntax:    J   filename { , parameter ... }

Executio� an� forma� o� thi� comman� i� syste� depen�
dent.

Comman� inpu� wil� b� rea� fro� th� specifie� file�� Th� �
command� wil� b� rea� unti� a� erro� o� end-of-fil� �
occurs�� N� nestin� o� comman� macro� i� possible� usin� �
thi� comman� fro� withi� � macr� wil� terminat� th� �
calling macro.

Macr executio� ma�� b� prematurel�� terminate䠠 b� �
enterin� � characte� a� th� consol� o� b� usin� th� K-�
command from within the macro.

Macro� ma� b� parameterized� Th� parameter� specifie� i� �
th� macr� cal� wil� b� substitute� fo� th� paramete� �
identifie� @� i� th� macr� body� wher� � i� th� positio� �
o� th� parameter�� countin� fro� � t� 9�� Space� ar� �
significan�� i� � paramete� excep� afte� � comma�� s� �
comma� mus�� b� use� t� separat� parameters�� A� empt� �
paramete� i� generate� b� tw� comma� i� sequence�� Th� �
paramete� identifie� wil� b� substitute� anywhere�� eve� �
i� strings�� T� generat� � @-characte� i� � macro�� us� �
tw� @'s.

Example:

Contents of file TESTMAC:

   g;123
   e rhl > @0; k
   e ; *** HL is less than @0 ! ***      (Note 1)
   e @1; j testmac, @1,@2,@3,@4,@5,@6    (Note 2)
.pa�Invocation:

   j testmac, 100, 50

Notes:

   1)  Th� comman� i� thi� lin� wil� neve� b� executed� 
�������bu�� th� lin� wil� b� displaye� o� th� terminal� 
�������I� thu� ma� b� use� t� displa� � message.

   2)  Thi� comman� wil� onl� b� execute� i� th� secon� �
�������paramete� (numbe� 1� i� non-empty.


                K - Kill Macro Execution

Syntax:    K

� currentl� activ� macr� wil� b� terminated� I� n� macr� �
is active, this command has no effect.


               L - List Disassembled Code

Syntax:    L   { from-address { to-address }}

Th� cod� beginnin� a� th� from-addres� u� to�� an� �
including�� th� to-address�� i� liste� i� disassemble� �
form� I� n� to-addres� i� given� eigh� line� ar� listed� �
I� n� from-addres� i� specified�� listin� continue� fro� �
th� las� liste� instruction� o� fro� th� curren� P� i� � �
brea� ha� occurred.

I� th� to-addres� i� smalle� tha� th� from-address�� on� �
lin� i� listed.

Example:   l rpc rpc + 5

.pa�                    M - Move Memory

Syntax��   ͠  begin-addres� end-addres� destination

Th堠 memor�� startin� a�� begin-addres� u� to��� an� �
including�� th� end-address� i� move� t� th� destinatio� �
address.

Overlappin� move� ar� allowe� an� d� no�� resul�� i� �
propagatin� value� throug� memory.

A� erro� wil� resul� i� th� end-addres� i� smalle� tha� �
th� begin-address.

Example:   m rpc rpc+10 3000
.pa�              N - Name (Symbol) Definition

Syntax:    a)  N
           b)  N   address symbol ...
           c)  NF  filename
           d)  NX
           e)  NX  symbol ...
           f)  NS  number
           g)  NR  { offset }
           h)  NW

a) Th� numbe� o� define� symbol� an� th� curren�� fre� �
���symbo� spac� i� displaye� i� decimal�� the� al� de�
���fine� symbol� ar� liste� i� ascendin� addres� order.

b)�Th� symbo� i� define� a� havin� th� valu� "address"� �
���I� th� symbo� i� alread� defined� i� wil� b� assigne� �
���th� ne� value.

c) Define� th� nam� fo� th� symbo� file� Th� symbo� fil� �
���nam� i� no� change� b� th� norma� 'F'-command� Th� N� �
���comman� i� implie� i� � secon� filenam� i� specifie� �
���on the initial command line.

d) Al� symbol� ar� deleted� Thi� wil� no� releas� symbo� �
���tabl� memor� space�

e� Th� specifie� symbo� name� ar� deleted.

f) Th� symbo� tabl� i� expande� t� mak� roo� fo� �
���"number� additional symbols� 

g) Th� fil� specifie� b� th� las� NF-comman� wil� b� �
���rea� a� symbol-file�� I� a� offse� i� given�� thi� �
���offse�� wil� b� adde� t� al� symbo� values�� Th� re�
���quire� forma� is�� Firs� value�� the� symbo� name� �
���separate� b� space� o� tabs� Valu� an� symbo� mus� b� �
���o� th� sam� line�� On� lin� ma�� contai� multipl� �
���symbo� definitions�� N� lin� ma� b� longe� tha� 8� �
���characters.

h) Th� symbo� tabl� wil� b� writte� t� th堠 fil� �
���specified by the last NF-command.
.pa�Cautions:

   Symbo� tabl� spac� i� allocate� downward� (towar� �
���addres� 0� i� memory�� directl� belo� th� debugger� �
���Expansio� o� thi� spac� i� automati� i� mor� symbol� �
���ar� define� tha� ca� b� containe� i� th� availabl� �
���space�� I� th� progra� stac� i� withi� 51� byte� o� �
���th� to� o� th� TPA� th� stac� wil� b� move� down� an� �
���th� S� wil� b� change� accordingly�

���I� th� progra� unde� tes� use� spac� a� th� to� o� �
���th� TP� fo� dat� o� progra� storage�� thi� spac� ma� �
���b� overwritte� whe� symbo� tabl� spac� i� expanded� �
���o� th� progra� migh� overwrit� th� symbo� table� �
���causin� th� debugge� t� crash� T� avoi� this� reserv� �
���enoug� symbo� tabl� spac� befor� startin� th� pro�
���gram� T� b� saf� fro� symbo� tabl� expansion� yo� ma� �
���se� th� M-variabl� t� th� to� o� th� TPA�� sinc� WAD� �
���wil� neve� expan� th� symbo� tabl� belo� Ma�� (Exam�
���ple�  � m := t).

���Fo� CP/� � only�� program� wit� a� attache� RS� wil� �
���caus� th� M-variabl� t� b� se� t� th� To� o� th� TPA� �
���sinc� al� RSXe� wil� b� relocate� there�� Reserv� �
���symbo� spac� befor� loadin� th� program�� sinc� th� �
���symbo� tabl� canno�� b� expande� onc� th� RSؠ i� �
���loaded.

Example:

       :n 100 start, 5 bdos, 4711 stinks
       :ns 40.
       :nf test.sym
       :nr 2000
       :nx bdos
       :nf new.sym
       :nw

.pa�                   O - Output to Port

Syntax:    O   { data-byte { port-address }}

Outpu� th� data-byt� t� th� specifie� port-address�� Th� �
data-byt� wil� als� b� displayed.

I� th� port-addres� i� no� given�� th� las� port-addres� �
specifie� wit� a� O-comman� i� used� I� th� data-byt� i� �
no� entered� th� dat� o� th� las� O-comman� i� used.

Fo� system� whic� evaluat� th� uppe� hal� o� th� addres� �
bu� o� I/O�� th� por� ma� b� specifie� a� � 16-bi� num�
ber� Th� hig� byt� wil� b� outpu� o� A8..A15.

Example:

   :o 'x' 2210
   O(Port=10, B=22): ...
   :
.pa�                  P - Trace Protection

Syntax:    a)  P
           b)  PX
           c)  P   multexpr

a) Display current protect condition

b) Delete protect condition

c) Define protect condition

Th� protec� conditio� i� evaluate� o� eac� trace�� Th� �
instructio� wil� b� execute� i� real-time�� wit� � brea� �
se� t� th� curren� retur� address�� i� th� protec�� exp�
ressio� evaluate� t� � TRU� (nonzero) value.

CAUTION� I� th� valu� a� th� curren� stackpointe� i� NO� �
� retur� addres� whe� th� protec� expressio� i� true� �
th� breakpoin� wil� b� se� a� a� invali� address�� an� �
th� progra� ma� fail� o� i� ma� no� retur� t� th� debug�
ger.

Th� defaul� valu� o� th� protec� expressio� i� 'RPà >� �
xxxx'�� wher� xxx�� i� th� startin� addres� o� th� �
debugger�� Thi� result� i� BDOS-call� bein� execute� i� �
rea� time��� B� carefu� whe� changin� th堠 protec� �
expression� sinc� tracin� int� th� BDO� wil� mos� likel� �
no�� wor� (th� debugge� als� use� BDOS-calls�� an� th� �
BDOS is not re-entrant).


Example:   p rpc >= (6).


          Q - Query (search) for a byte string

Syntax:    Q   {J} begin-addr end-addr byte-string

Memor� wil� b� searche� fo� th� byte-strin� startin� a� �
th� begin-add� u� to� an� including� th� end-addr� Ever� �
matc� wil� b� displaye� a� on� lin� o� dump�� wit� th� �
dum� beginnin� a� th� firs� matchin� byte�� or�� i� � i� �
specified� a� � byte� befor� th� firs� matchin� byte.

Example:   qj l h 'Hello' 0d 0a
.pa�              R - Read a File into Memory

Syntax:    R   { offset }

Execution of this command is system dependent.

Th� fil� specifie� b� th� las� F-comman� wil� b� rea� �
int� memory�� A� offset�� i� specified� wil� b� adde� t� �
th� standar� loa� address�� I� � fil� ha� th� extensio� �
HEX�� i� i� assume� t� contai� standar� INTEL-He� forma� �
records�� Al� othe� filetype� ar� rea� int� memor�� a� �
the� ar� withou� an� editing.

A� erro� occur� i� th� fil� canno� b� found� i� th� loa� �
addres� i� belo� 80� (CP/M)�� o� i� th� fil� woul� over�
writ� th� debugger.

Fo� CP/� 3�� file� wit� a� attache� RS� wil� b� loade� �
vi� th� system'� "loa� overlay� function�� whic� handle� �
th� relocatio� o� th� RSX�� � fil� i� assume� t� hav� a� �
attache� RS� i� th� firs� byt� contain� � REԠ instruc�
tio� (C9)�� an� i� th� filetyp� i� .COM�� Not� tha�� fo� �
file� wit� attache� RSX�� th� Hig� addres� wil� no�� b� �
se�� t� th� en� o� th� file�� sinc� thi� addres� i� �
unknown.

Example:   r h-100


                 S - Substitute Memory

Syntax:    a)  S   address byte-string
           b)  S   { address }

a) The byte-string replaces the memory at address.

b) Th� byt� a� th� specifie� addres� i� displayed�� an� �
���inpu� o� � byte-strin� i� expected�� Th� byte-strin� �
���replace� th� content� o� memory��� an� th� nex� �
���locatio� i� displayed� A� empt� inpu� advance� t� th� �
���nex� location� Us� � do� (.� a� firs� inpu� characte� �
���t� terminat� th� command.
���I� n� addres� i� specified� substitutio� continue� a� �
���th� las�� addres� displaye� b� � previou� Ӡ o� � �
���command.

Example:

   :s rhl 'Hi, there' 0d 0a



                       T - Trace

Syntax:    a)  T   {N}{J}  {count}
           b)  T   {N}{J}  W multexpr
           c)  T   {N}{J}  U multexpr

a) "count�� instruction� ar� traced�� I� n� coun�� i� �
���given� on� instructio� i� traced.
�b) tracin� continue� whil� th� expressio� evaluate� t� � �
���TRUE value.

c) tracin� continue� unti� th� expressio� evaluate� t� � �
���TRUE value.

I� Π i� given�� th� trace� instruction� wil� no�� b� �
displayed.

I� � i� given�� onl� instruction� whic� modif� th� pro�
gra� counte� (Jump�� Cal� an� Retur� instructions�� wil� �
b� displaye� an� counte� o� caus� th� expressio� t� b� �
evaluated.

I� N� i� specified� instruction� wil� no� b� listed� an� �
onl�� instruction� whic� modif� th� P� wil� decreas� th� �
coun� o� tes� th� condition.

Tracin� wil� terminat� independen� o� coun� o� expres�
sio� i� � breakpoin� i� encountered�� o� i� � characte� �
(othe� tha� ^� o� ^Q� i� entere� a� th� console.

I� th� protec� conditio� (se� P�� above� become� TRU� �
durin� trace�� tracin� wil� b� inhibite� an� th� protec�
te� par� wil� b� execute� i� real-time.

CAUTION�� Sinc� i� i� no� possibl� t� brea� a� th� cur�
ren�� PC�� instruction� causin� � loo� t� itsel� ca� b� �
trace� onl� whe� th� loo� i� exited�� Instruction� othe� �
tha� DJN� wil� caus� th� debugge� t� issu� a� error.
That is,

   100       LD    B,10
   102       DJNZ  102

wil� execut� th� DJN� i� real-tim� an� the� trac� th� �
nex� instruction� whereas

   100       JP    NZ,100

wil� caus� th� debugge� t� refus� t� trace�� eve� i� th� �
conditio� i� false� Yo� hav� t� chang� th� P� b� han� t� �
allo� th� progra� t� continue.

Self-modifyin� cod� ca� caus� th� trac� t� fai� i� th� �
implici��� brea렠 afte� th� trace䠠 instructio i� �
overwritte� b� th� instructio� itself� Fo� example,

       100     LD (103),A
       103     NOP

wil� caus� th� brea� a� 10� t� b� missed�� an� executio� �
o� th� progra� wil� continu� i� real-time.


Example:   tj u y0:=y0+1, rpc > 2000

.pa�                  U - User Input Trap

Syntax:    U

Thi� comman� i� user-defineable�� Executio� an� parame�
ter� ar� syste� dependent.

Th� debugge� wil� promp� fo� � character�� Enterin� C� �
wil� delet� an� tra� character�� enterin� an� othe� cha�
racte� wil� defin� thi� cha� a� inpu� tra� character� I� �
� tra� cha� i� defined� al� consol� inpu� b� th� progra� �
unde� test�� excep� fo� th� "rea� consol� buffer�� func�
tio� o� CP/M� wil� b� checke� fo� equalit� wit� th� tra� �
character� an� � brea� wil� b� entere� o� � match� 

Th� brea� wil� b� se� u� suc� tha� th� progra�    wil� �
agai� rea� � characte� i� � G� i� issued�� Thi� secon� �
characte� rea� wil� the� no� agai� b� checke� fo� � �
matc� wit� th� tra� character.

Example:

       :u
       Ch: ~
       :


                   V - Verify Memory

Syntax:    V   begin-addr end-addr compare-addr

Memor� startin� a� th� begin-add� u� to�� an� including� �
th� end-addr�� i� compare� wit� memor� startin� a�� th� �
compare-addr�� Non-matchin� byte� ar� displaye� wit� �
thei� address.

Example:   v 100 1ff 200
.pa�                W - Write memory to File

Syntax:    W   start-address end-address { offset }

Execution of this command is system dependent.

Memor�� beginnin� a�� th� start-addres� u� to��� an� �
including�� th� end-addres� i� writte� t� th� fil� �
specifie� b�� th� las� F-command�� I� th� fil� typ� i� �
.HEX, Intel Hex format will be generated.

A� offse� i� onl� accepte� fo� file� o� typ� HEX�� an� �
the� specifie� th� offse� t� b� adde� t� th� curren� �
writ� addres� whe� generatin� th� Hex-fil� address.

Example:   w l h


            X - Examine CPU State/Registers

Syntax:    a)  X
           b)  X'
           c)  X   register-name
           d)  X   register-name expression {...}

a) Th� primar� registers�� th� curren� instruction�� an� �
���the bottom stack words are displayed.

b) The alternate register set is displayed.

c) Th� content� o� th� registe� ar� displayed�� an� a� �
���expressio� i� expected�� Th� valu� o� th� expressio� �
���i� assigne� t� th� register.

d) Th� registe� i� se� t� th� specifie� value�� Thi� �
���specification may be repeated.


Example:

       :x pc
       0100  1ac
       :x a 0a b 0c de 1234
.pa�                Y - Display Y-Variables

Syntax:    a)  Y
           b)  Y   n
           c)  Y   n  expression {...}

a) Display the contents of all 10 Y-Variables

b) Th� content� o� th� variabl� � (� � 0..9�� ar� dis�
���played�� an� a� expressio� i� expected�� Th� valu� o� �
���th� expressio� i� assigne� t� th� variable.

c) Th� variabl� � i� se� t� th� specifie� value�� Thi� �
���specification may be repeated.


Th� Y-Variable� ar� no� modifie� b� th� debugge� an� ar� �
thu� availabl� a� counter� o� even� marker� fo� use� �
expressions and command macros.

Example:

       :y 0
       0000  123
       :y 0 123  1 0c  2 0d


                 Z - Zap (fill) memory

Syntax:    Z   begin-addr end-addr byte-string

Memor� startin� a� begin-add� u� to� an� including� end-�
add� i� fille� wit� th� byte-string.

Example:   z 2000 2fff 0d 0a
.pa�                        Appendix
             Extended Memory Considerations

Th� distributio� dis� contain� � versio� o� WADŠ whic� �
support� extende� addressin� unde� CP/� 3�� I� yo�� ar� �
runnin� � banke� versio� o� CP/� 3�� thi� versio� shoul� �
ru� o� you� syste� withou� modification� if�� an� onl� �
if, the following is true:

- �ther� i� a� leas� � � spac� i� commo� memor�� belo� �
���th� BDO� entry�� Thi� spac� i� require� t� allo� WAD� �
���t� switc� bac� int� th� defaul� ban� (ban� 1�� o� �
���retur� fro� � breakpoin� i� � differen� bank�

-��th� MOVE�� XMOV� an� SELME� entrie� o� you� BIOӠ ar� �
���in common memory.

I� yo�� d� no� inten� t� us� tracin� o� breakpoint� �
outsid� o� th� norma� ban� 1�� yo� shoul� b� abl� t� us� �
th� extende� versio� eve� i� th� firs� conditio� i� no� �
true. 

Pleas� not� tha� th� extende� versio� i� muc� slowe� i� �
al� memor� acces� operation� du� t� th� nee� t� acces� �
memor�� vi� th� MOV� an� XMOV� BIO� routine� instea� o� �
usin� direc� access�� Th� extende� versio� shoul� there�
for� onl� b� use� wher� acces� t� othe� bank� i� neces�
sary.

T� verif� tha� yo� ca� ru� th� extende� version� us� th� �
non-extended WADE and the command macro EXTEST:

   WADE
   J EXTEST

an� not� wher� th� macr� stop� execution�� I� th� macr� �
exit� wit� � g0�� yo� ca� us� th� extende� version�� I� �
th� messag� 'O� t� us� i� non-trac� mode� appear� bu� �
th� macr� the� terminat� wit� 'Les� tha� � � free'�� yo� �
may not trace any routine outside the default bank.


                        Cautions

WAD� alway� operate� o� � 'defaul� bank'�� whic� i� se� �
t� �� (th� CP/� TP� bank� o� entry�� Sinc� ther� i� n� �
syste� independen�� wa� t� obtai� th� curren�� activ� �
bank�� yo� hav� t� chang� th� activ� ban� b� han� i� yo� �
inten� t� trac� an� routin� outsid� o� ban� 1�� Extrem� �
cautio� mus�� b� employe� whe� tracin� routine� whic� �
migh� chang� th� curren� bank�� sinc� tracin� migh� fai� �
(mos� likel� completel� crashin� th� system� i� WADŠ i� �
no� informe� o� th� ban� switch�� Pleas� note� too� tha� �
th� restar� locatio� i� al� bank� fo� whic� � breakpoin� �
ha� bee� define� wil� b� change� whil� tracin� i� i� �
progres� o� an� breakpoin� ha� bee� se� an� th� progra� �
i� executin� i� rea� time�� Althoug� WAD� wil� restor� �
th� origina� content� o� thi� location�� yo� shoul� no� �
attemp�� t� trac� an� routin� whic� migh� depen� o� th� �
informatio� store� a� thi� locatio� (38� t� 3a� i� th� �
curren� release).�
                   Changing the Bank

Th� curren�� activ� ban� i� containe� i� th� specia� �
registe� 'X�� an� ma� b� displaye� usin� th� Ƞ o� X� �
command�� I� ma� b� change� b� assignmen�:

   H X :� 0

or by changing the program counter with the X-command:

   X PC 0:100

Yo�� ca� als� us� al� memor� referenc� command� wit� �
location� outsid� th� curren� ban� b�� specifyin� a� �
extende� address:

   L 0:100         Lists Bank 0, Address 100
   S 5:e000        Substitutes Bank 5, Address E000
   M 0:0 ff 100    Move� fro� Ban� 0�� Addres� � t� FF� �
�������������������to Address 100 in the current Bank
   � 7:� ff 0      Set� Location� � t� F� i� Ban� � t� 0

You may even assign to locations in other banks:

   H 0:100 := (7:100).


                     Customization

I� yo� ow� th� sourc� versio� o� WADE�� yo� migh� possi�
bl�� chang� th� entr� 'EBREAK� i� modul� MONPEEˠ t� �
obtai�  th� currentl� selecte� ban� i� som� hardwar� �
dependen�� wa�� anng� th� entr� 'EBREAK� i� modul� MONPEEˠ t� �
obtai�  th� currentl� selecte� ban� i� som� hardwar� �
dependen�� wa�� an� stor� i� i� th� variabl� 'CBANK� �
befor� switchin� t� th� defaul� bank�� Thi� woul� allo� �
tracin� int� othe� bank� withou� settin� th� X-registe� �
b�� hand�� I� you� BIO� return� th� previousl�� selecte� �
ban� i� registe� � o� exi� fro� th� SELME� routine�� yo� �
ma�� simpl�� se� th� equat� 'MEGA� t� TRU� i� th� fil� �
MONOPT.LIB and re-assemble the module MONPEEK.
