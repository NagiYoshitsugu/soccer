## -*- Mode: ruby -*-

######################################################################
=begin
= Player.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'Field.rb' ;
require 'FieldWindow.rb' ;
require 'Vector.rb' ;
require 'MovingObject.rb' ;

##======================================================================
=begin
--- class Player < MovingObject
=end
##======================================================================
class Player < MovingObject
  attr :team, true ;	
  attr :side, true ;	
  attr :unum, true ;
  attr :dir, true ;	

##------------------------------
=begin
--- SideLeftTag, SideRightTag, SideUnknownTag
=end
##------------------------------
  SideLeftTag = "Left" ;
  SideRightTag = "Right" ;
  SideUnknownTag = "unknown" ;

##------------------------------
=begin
=== limit parameters
=end
##------------------------------
  MaxDashPower = 100.0 ;	
  MinDashPower = -30.0 ;		
  MaxKickPower = 100.0 ;	
  MinKickPower = -30.0 ;		

  DashFactor = 0.01 ;			
  KickFactor = 0.02 ;		
  KickableMargin = 0.5 ;	
  KickNoise = 0.3 ;		
  TurnNoise = 0.3 ;		    
  DashNoise = 10.0 ;		

##------------------------------
=begin
--- initialize(team)
  * initialize
=end
##------------------------------
  def initialize(team)
    super() ;
    @team = team ;
    @size = 0.5 ;
    @dir = 0.0 ;
    @side = SideUnknownTag ;
    @unum = 0 ;
    @actable = true ;
  end

##------------------------------
=begin
--- setLeftSideUnum(unum)
=end
##------------------------------
  def setLeftSideUnum(unum)
    @side = SideLeftTag ;
    @unum = unum ;
  end

##------------------------------
=begin
--- setRightSideUnum(unum)
=end
##------------------------------
  def setRightSideUnum(unum)
    @side = SideRightTag ;
    @unum = unum ;
  end

##------------------------------
=begin
--- cycleThink(field) 
=end
##------------------------------
  def cycleThink(field) 
    kick(field, fltRand(10.0,100.0), fltRand(-1.0, +1.0)) ;
    if(rand(10) == 0)		# random action 1/10
      turn(field, fltRand(-1.0, +1.0)) ;
      dash(field, fltRand(10.0, 100.0)) ;
    end
  end

##------------------------------
=begin
--- turn(field, angle)
=end
##------------------------------
  def turn(field, angle)
    noise = fltRand(-TurnNoise,TurnNoise) ;
    @dir = normalizeAngle(@dir + angle + noise) ;
  end

##------------------------------
=begin
--- dash(field, power)
=end
##------------------------------
  def dash(field, power)
    power = normalizePower(power, MinDashPower, MaxDashPower) ; 

    noise = fltRand(-DashNoise, DashNoise) ;
    power += noise ;

    @vel.x += power * DashFactor * Math::cos(@dir) ;
    @vel.y += power * DashFactor * Math::sin(@dir) ;
  end

##------------------------------
=begin
--- kick(field, power, angle)
=end
##------------------------------
  def kickable?(field)
    ball = field.ball ;			
    dist = @pos.distanceTo(ball.pos) ;
    
    return (dist < @size + ball.size + KickableMargin) ;
  end

##------------------------------
=begin
--- kick(field, power, angle)
=end
##------------------------------
  def kick(field, power, angle)
    if(kickable?(field))
      dirNoise = fltRand(-KickNoise, KickNoise) ;  
      kickDir = @dir + angle + dirNoise ;

      field.ball.vel.x += power * KickFactor * Math::cos(kickDir) ; 
      field.ball.vel.y += power * KickFactor * Math::sin(kickDir) ;
      return true ;
    else
      return false ;
    end
  end

##------------------------------
=begin
--- ballPos(field)
=end
##------------------------------
  def ballPos(field)
    return field.ball.pos ;
  end

##------------------------------
=begin
--- ownGoalPos()
=end
##------------------------------
  def ownGoalPos()
    if(@side == SideLeftTag)
      return Field::GoalLeftPos ;
    else 
      return Field::GoalRightPos ;
    end
  end

##------------------------------
=begin
--- opponentGoalPos()
=end
##------------------------------
  def opponentGoalPos()
    if(@side == SideLeftTag)
      return Field::GoalRightPos ;
    else 
      return Field::GoalLeftPos ;
    end
  end

##------------------------------
=begin
--- to_s
  * literize
=end
##------------------------------
  def to_s
    return "#Player[" + @side + @unum.to_s + "|pos=" + @pos.to_s + "/vel=" + @vel.to_s + "]" ;
  end

##------------------------------
=begin
--- display(window)
=end
##------------------------------
  def display(window)
    if(@side == SideLeftTag)	  
      window.setPlayerLeftPos(@unum, @pos.x, @pos.y) ;  
      window.setPlayerLeftDir(@unum, @dir) ;      
    elsif(@side == SideRightTag)  
      window.setPlayerRightPos(@unum, @pos.x, @pos.y) ; 
      window.setPlayerRightDir(@unum, @dir) ;           
    else                       
      raise "illegal side value: " + @side.to_s ;
    end
  end

end

