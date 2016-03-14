## -*- Mode: ruby -*-

######################################################################
=begin
= Vector.rb
=end
######################################################################

require 'utility.rb' ;

##======================================================================
=begin
--- class Vector
  * 2 dimension vector
=end
##======================================================================
class Vector
  # instance value
  attr :x, true ;	
  attr :y, true ;

##------------------------------
=begin
--- initialize(x = nil, y = nil)
  * initialize
=end
##------------------------------
  def initialize(x = nil, y = nil)
    set(x,y) ;
  end

##------------------------------
=begin
--- set(x,y)
=end
##------------------------------
  def set(x=nil,y=nil)
    if(x.nil?())	       
      @x = 0.0 ;
      @y = 0.0 ;

    elsif(y.nil?())
      if(x.is_a?(Vector)) 
        @x = x.x ;
        @y = x.y ;
      elsif(x.is_a?(Array)) 
        @x = x[0] ;
        @y = x[1] ;
      end
    else		
      @x = x ;
      @y = y ;
    end
  end

##------------------------------
=begin
--- add(v)
=end
##------------------------------
  def add(v)
    return Vector.new(@x + v.x, @y + v.y) ;
  end

##------------------------------
=begin
--- +(v)
=end
##------------------------------
  def +(v) ; return add(v) ; end

##------------------------------
=begin
--- add(v)
=end
##------------------------------
  def del(v)
    return Vector.new(@x - v.x, @y - v.y) ;
  end

##------------------------------
=begin
--- -(v)
=end
##------------------------------
  def -(v) ; return del(v) ; end

##------------------------------
=begin
--- mul(a)
=end
##------------------------------
  def mul(a)
    return Vector.new(@x * a, @y * a) ;
  end

##------------------------------
=begin
--- *(a)
=end
##------------------------------
  def *(a) ; return mul(a) ; end

##------------------------------
=begin
--- addToSelf(v)
=end
##------------------------------
  def addToSelf(v)
    @x += v.x ;
    @y += v.y ;
    return self ;
  end

##------------------------------
=begin
--- delFromSelf(v)
=end
##------------------------------
  def delFromSelf(v)
    @x -= v.x ;
    @y -= v.y ;
    return self
  end

##------------------------------
=begin
--- mulSelf(a)
=end
##------------------------------
  def mulSelf(a)
    @x *= a ;
    @y *= a ;
    return self ;
  end

##------------------------------
=begin
--- abs()
=end
##------------------------------
  def abs()
    return sqrt(sq(@x) + sq(@y)) ;
  end

##------------------------------
=begin
--- distanceTo(v)
=end
##------------------------------
  def distanceTo(v)
    dx = @x - v.x ;
    dy = @y - v.y ;
    return Math::sqrt(dx * dx + dy * dy) ;
  end

##------------------------------
=begin
--- directionTo(v)
=end
##------------------------------
  def directionTo(v)
    dx = v.x - @x ;
    dy = v.y - @y ;
    return Math::atan2(dy,dx) ;
  end

##------------------------------
=begin
--- to_s()
  * literize
##------------------------------
  def to_s
    return "(" + @x.to_s + "," + @y.to_s + ")" ;
  end
end

##======================================================================
=begin
--- class << Vector
=end
##======================================================================
class << Vector

##------------------------------
=begin
--- vector(v)
=end
##------------------------------

  def vector(v)
    return v if(v.is_a?(Vector)) ;
    return Vector::new(v[0],v[1]) if (v.is_a?(Array)) ;
    raise "Error: unsupported initializer for Vector:" + v.to_s ;
  end

end




