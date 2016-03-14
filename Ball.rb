## -*- Mode: ruby -*-

######################################################################
=begin
= Ball.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'FieldWindow.rb' ;
require 'Vector.rb' ;
require 'MovingObject.rb' ;

##======================================================================
=begin
--- class Ball < MovingObject
=end
##======================================================================
class Ball < MovingObject

##------------------------------
=begin
--- initialize()
  * initialize
=end
##------------------------------
  def initialize()
    super() ;
    @size = 0.1 ;
  end

##------------------------------
=begin
--- to_s
  * literize
=end
##------------------------------
  def to_s
    return "#Ball[pos=" + @pos.to_s + "/vel=" + @vel.to_s + "]" ;
  end

##------------------------------
=begin
--- display(window)
  * display window
=end
##------------------------------
  def display(window)
    window.setBallPos(@pos.x, @pos.y) ;   
  end
end
