0 constant black  
2 constant red  
1 constant brown  
3 constant orange  
4 constant yellow  
5 constant green  
6 constant blue  
7 constant violet  
8 constant grey  
9 constant white  

: exp ( u1 u2 -- u3 ) \ u3 = u1^u2
   dup
   0 = if 1 exit then
   over swap 1 ?do over * loop nip ;

: r ( n1 n2 n3 -- n4 )
  \ calculate the 3rd ring exponent
  rot rot >r >r       \ store the first 2 args on return stack
  10                  \ exponent of 10
  swap
  exp                 \ calcualte the 10 ^ 3rd_ring
  r> r> swap          \ pop the first 2 arguments form return stack

  \ calculate the 1st_ring * 10 + 2nd_ring
  10 * +               
  swap                

  \ if 3rd ring calcualted exponent is not 0 than multiply that with the 1_st*10+2_nd 
  dup                 
  0 > if                  
    *
  else
    nip
  then 
  ;


