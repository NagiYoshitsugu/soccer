## -*- Mode: ruby -*-

######################################################################
=begin
= Dango.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'Game.rb' ;

##======================================================================
=begin
--- class DangoPlayer
=end
##======================================================================
class DangoPlayer < Player
##------------------------------
=begin
--- cycleThink(field) 
=end
##------------------------------
  def cycleThink(field) 
    if(kickable?(field)) 
      goalPos = opponentGoalPos() ;                
      goalDirection = @pos.directionTo(goalPos) ;  
      kickAngle = goalDirection - @dir ;          
      kick(field, fltRand(10.0,100.0), kickAngle) ; 
    else		 
      if(rand(3) == 0) then 
	ballDirection = @pos.directionTo(ballPos(field)) ;
	turnAngle = ballDirection - @dir ;
	turn(field, turnAngle) ;
      else
	dash(field, fltRand(10.0, 50.0)) ;
      end
    end
  end

end

##======================================================================
=begin
--- class DangoTeam
=end
##======================================================================
class DangoTeam < Team
##------------------------------
=begin
--- initialize(teamname)
=end
##------------------------------
  def initialize(teamname)
    super ;			
    @playerClass = DangoPlayer ;
  end
  
end
