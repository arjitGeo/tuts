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

: 10power  
  10  
  swap  
  begin  
  dup  
  1 > while  
    swap  
    10 *  
    swap  
    1 -  
  repeat   
  drop ;
    
: r
  dup
  0 > if 10power then 
  rot
  10 *
  rot
  + 
  swap
  dup 
  0 > if 
    *
    swap drop
  else 
     drop 
  then ;



