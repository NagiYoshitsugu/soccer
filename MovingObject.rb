## -*- Mode: ruby -*-

######################################################################
=begin
= MovingObject.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'Vector.rb' ;

##======================================================================
=begin
--- class MovingObject
=end
##======================================================================
class MovingObject
  attr :pos, true ;	
  attr :vel, true ;	
  attr :decay, true ;   
  attr :size, true ;	

##------------------------------
=begin
--- initialize()
=end
##------------------------------
  def initialize()
    @pos = Vector.new() ;    
    @vel = Vector.new() ;   
    @decay = 0.8 ;	   
    @size = 0.5 ;	   
  end

##------------------------------
=begin
--- cycleMove(field)
=end
##------------------------------
  def cycleMove(field)
    @pos.addToSelf(@vel) ;		
    @vel.mulSelf(@decay) ;		
  end

##------------------------------
=begin
--- checkCollision(obj)
=end
##------------------------------
  def checkCollision(obj)
    if(isCollidedWith(obj))
      @pos = @pos - @vel ;		
      @vel.set(0,0) ;			
    end
  end

##------------------------------
=begin
--- isCollidedWith(obj)
  * check collision
=end
##------------------------------
  def isCollidedWith(obj)
    if(self == obj)
      return false  ;			
    end

    r = @pos.distanceTo(obj.pos) ;	
    l = @size + obj.size ;		

    return (r < l) ;		
  end

##------------------------------
=begin
--- to_s
=end
##------------------------------
  def to_s
    return "#MovingObject[pos=" + @pos.to_s + "/vel=" + @vel.to_s + "]" ;
  end

end
