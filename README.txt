                                        BETROTHED                                        
                                        ----*----
                           uncertainly turing complete esolang
                                      Conor O'Brien
                                        ----*----

TABLE OF CONTENTS

   I.   INTRODUCTION
   II.  PROGRAM REQUIREMENTS
   III. DEFINITIONS
   IV.  PROGRAM EXECUTION
   V.   PROOF OF TURING COMPLETENESS

I. INTRODUCTION
Betrothed is an esoteric language intended to be "unprovably Turing Complete", assuming
infinite memory. I have attempted to make the language not terribly convoluted by
limiting the uncertain parts of the language to the lengths of the line pairs. To make
the esolang more interesting, I have also restricted the source of the program. Further,
it is also interesting to note that the mode of execution is, as far as I know, is a new
thing.

    Just as a warning, this document provides a more rigorous specification of the
language. If you do not like symbols, well, shucks.

                                        ----*----

II. PROGRAM REQUIREMENTS
Any Betrothed program must consist of only the following characters, to include the space:

    {} [] () <> + = ;
    
    All semicolons (;) are replaced with newlines before parsing.

    The program must have an even number of lines. A line is defined to be a sequence of 
characters terminated by the a newline, optionally preceeded by a carriage return. If the
program does not end with such a sequence, the EOF is treated as a newline.

    The program is parsed in pairs of lines. For each pair of lines  (M, N) , the 
lengths  m  and  n  of  the respective lines must satisfy one of the following conditions:

  - both are pairs of betrothed numbers ( σ(m) = σ(n) = m + n + 1 , where
    σ(k) = sum of the divisors of k )
  - both are twin primes  ( m  is prime,  n  is prime, and  m = n + 2 )

and must satisfy:

  - no other two lines in a pair  (M', N')  with lengths  m'  and  n'  exist in the 
    program such that  (m, n) = (m', n')  or  (m, n) = (n', m') .

                                        ----*----

III. DEFINITIONS

Before detailing the execution of the program, I will go into some preliminary definitions.

    Let  '...'  denote a string of characters. For example,  'Hello'  is a string of the
characters "H", "e", "l", "l", and "o".

    Let  undef  represent an undefined value; when a program encounters this value, it
may either error or have undefined behaviour. 

    Let  #S  denote the length of a string  S . For example,  #'Hello' = 5.

    Let  S . T  denote the concatenation of two strings  S  and  T . For example,
 'He' . 'llo' = 'Hello' .

    Let  k { S  denote the zero-indexed  k th character in S. For example,
 0 { 'Hello' = 'H' .

    Let  k } S  denote all but the  k th character in S. For example,
 0 } 'Hello' = 'ello' .

    Let  sub(T, j, k)  be the slice of a string  T  from index  j  to index  j + k . For
example,  sub('Hello', 2, 2) = 'll' .

    (Conventional operations on strings remain evident:  S = T  for equality,  S /= T
for inequality, etc.)

    Let  S <= T  be true for strings  S  and  T  when there exists at least one index  i
for which  sub(T, i, #S) = S , and false otherwise.

    Let  P & Q  denote the conjunction of two predicates, and  P | Q  the disjunction of
two predicates.

    Let  rev(S)  denote the reversed order of characters of a string  S .

    Let  rep(S, t1, t2)  denote the replacement of all substrings  t1  in  S  with  t2 .
For example,  rep('3.141514', '14', '$') = '3.$15$' .

Let:

                    {  undef                                if #t1 /= #t2
    tr(S, t1, t2) = {  tr(rep(S, 0{t1, 0{t2), 0}t1, 0}t2)   if #t1 > 0
                    {  S                                    if #t1 = 0

Let the "mirror" operation be defined as:

    mir(S) = tr(rev(S), '<>{}()[]', '><}{)(][')

Let:

                 {  rot(sub(S, 1, #S - 1) . (0 { S), n - 1)  if n > 0
    rot(S, n) =  {  S                                        if n = 0
                 {  rev(rot(S, #S + n))                      if n < 0

Let  S  be a "shift" of  T  if and only if, for some  0 <= n < #S ,  rot(S, n) = T .

A string  S  a "pliable subset" of a string  T  if and only if, for any shift  S'  of  S :

    (S' <= T) | (mir(S') <= T)

 S'  here is called a "pliable factor" of  T  with respect to  S . For example,  'ABB'
is a pliable subset of  'BBAB' , since  'BBA'  is a shift of  'ABB'  and a subset of  
'BBAB' .

                                        ----*----

IV. PROGRAM EXECUTION

Now, for the program execution specification. Suppose Betrothed has a set of commands,
hereafter referred to as  CMDS . I will define the actual commands later, to be used in
this incarnation of the language.

    For each of the aforementioned pairs  (M, N) , the following algorithm is performed:

  1. Call  Q  the set of (possibly overlapping) pliable factors of  M  with respect to  N .
  2. Let  q = #Q .
  3. Remove all such pliable factors from  N  and call this new string N' .
  4. Call  d  the levenshtein distance between  N  and  N' .
  5. Let  F  be the  q th command in  CMDS . Then, call  F(d) .



                                        ----*----

Betrothed manipulates a stack. Popping from an empty stack gives a zero.

                                        ----*----

This is the list of commands used in this incarnation of betrothed. (Note that index = 
 q  from before.) Here,  z = d - q .

          +-------+------------+-----------------------------------------------+
          | index | name       | effect                                        |
          +=======+============+===============================================+
          | 0     | input      | pop x; push x'th data argument*               |
          | 1     | outnum     | pop x; output x                               |
          | 2     | pushnum    | push z                                        |
          | 3     | outchr     | pop x; output x as an ASCII character         |
          | 4     | jump       | jumps to line pair d                          |
          | 5     | popjump    | pop x; jumps to line pair x                   |
          | 6     | if         | peek x; if x != 0, execute next statement     |
          | 7     | pick       | pops x; pushes the x'th element in the stack  |
          | 8     | multiply   | pop x; push x * z                             |
          | 9     | add        | pop x; push x + z                             |
          | 10    | subtract   | pop x; push x - z                             |
          | 11    | divide     | pop x; push x / z                             |
          | 12    | duplicate  | pop x; "push x" z times                       |
          | 13    | outstack   | display the contents of the stack             |
          | 14    | exit       | terminates program                            |
          | 15    | exitcode   | exits with code z                             |
          | 16    | drop       | pop x                                         |
          | 17    | exec       | pop y; pop x; executes instruction x with y   |
          | 18    | diagnostic | pushes the z'th information diagnostic**      |
          +-------+------------+-----------------------------------------------+

* the first data argument being the first argument that is not the name of the file, and is
passed to the betrothed interpreter. The argument is parsed as a number (up to the
implementation as to how the number exactly is parsed), and if no number can be validly
parsed, the program should error. Below are marked the data arguments, valid or invalid:

    betrothed file.bet 3 5 asdf foo 9
                       ^ ^ ^^^^ ^^^ ^
    
** The information diagnostics are:

  0. size of stack
  1. current index in program
  2. current year (full)
  3. current month (1 is January)
  4. current day
  5. current hours
  6. current minutes
  7. current seconds
  8. current nanoseconds

                                        ----*----

V. PROOF OF TURING COMPLETENESS

Now, no language can be Turing Complete with bounded program size. Therefore, if Betrothed
is Turing Complete, it must have unbounded program size. Since the lengths of the lines of
a Betrothed program must be twin prime pairs or betrothed pairs, and since both sequences
are unproven to be infinite or finite, Betrothed has unbounded program size if and only if
there are infintie betrothed pairs, there are infinite twin prime pairs, or both.

    Next: to prove that if Betrothed has an unbounded program size, then it is Turing
Complete. I will use the op-codes from the above table to demonstrate key factors of a
Turing Complete language; they are of the form  [index]<[ld]> .

  1. Conditional goto: 6<> 5<>, or if-popjump. This can be used to form a loop.
  2. Inequality to a constant K: 10<K> 
  3. Arbitrarily large variable space: you can use some separator constant C.

    With this, I have sufficient reason to believe that Betrothed is Turing Complete.