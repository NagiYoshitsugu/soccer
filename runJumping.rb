## -*- Mode: ruby -*-

######################################################################
=begin
= runJumping.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'FieldWindow.rb' ;
require 'Ball.rb' ;
require 'Player.rb' ;

##======================================================================
## main routine
##======================================================================

## initialize
ball = Ball.new ;                     
ball.pos.x = 0.0 ; ball.pos.y = 0.0 ; 
playerLeft = Array.new(11) ;	   
(0...11).each{|unum| 
  playerLeft[unum] = Player.new() ;             
  playerLeft[unum].setLeftSideUnum(unum) ;     
  playerLeft[unum].pos.set(fltRand(-50,50), fltRand(-30,30)) ; 
  playerLeft[unum].dir = fltRand(-3.14,3.14) ;  
}

playerRight = Array.new(11) ;	     
(0...11).each{|unum|   
  playerRight[unum] = Player.new() ;           
  playerRight[unum].setRightSideUnum(unum) ;   
  playerRight[unum].pos.set(fltRand(-50,50), fltRand(-30,30)) ;
  playerRight[unum].dir = fltRand(-3.14,3.14) ; 
}


puts ball ;


(0...11).each{|unum|
  puts playerLeft[unum] ;
}


(0...11).each{|unum|
  puts playerRight[unum] ;
}

fieldWindow = FieldWindow::new(:runDraw) ; 

ball.display(fieldWindow) ;

(0...11).each{|unum|
  playerL = playerLeft[unum] ;
  playerL.display(fieldWindow) ;

  playerR = playerRight[unum] ;
  playerR.display(fieldWindow) ;
}


sleep(5) ;


while(true)
  ball.pos.set(fltRand(-50,50), fltRand(-30,30)) ;  
  ball.display(fieldWindow) ;                     
  sleep(1) ;                                      
end




