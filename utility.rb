## -*- Mode: ruby -*-

######################################################################
=begin
= utility.rb
=end
######################################################################

##--------------------------------------------------------------------
=begin
== include Math 
=end
##--------------------------------------------------------------------
include Math ;		

##--------------------------------------------------------------------
=begin
== other function

--- fltRand(min,max)
=end
##--------------------------------------------------------------------
def fltRand(min,max) 
  w = max - min ;
  r = min + w * rand() ;
  return r ;
end

##--------------------------------------------------------------------
=begin
--- abs(x)
=end
##--------------------------------------------------------------------
def abs(x)
  if(x >= 0) then
    return x ;
  else
    return -x ;
  end
end

##--------------------------------------------------------------------
=begin
--- sq(x)
=end
##--------------------------------------------------------------------
def sq(x)
  return x * x ;
end

##--------------------------------------------------------------------
=begin
--- normalizeAngle(angle)
=end
##--------------------------------------------------------------------
def normalizeAngle(angle)
  while(angle > Math::PI)
    angle -= 2.0 * Math::PI ;
  end
  while(angle < -Math::PI)
    angle += 2.0 * Math::PI ;
  end
  return angle ;
end

##--------------------------------------------------------------------
=begin
--- normalizePower(power, min, max)
=end
##--------------------------------------------------------------------
def normalizePower(power, min, max)
  if(power < min)
    power = min ;
  end
  if(power > max)
    power = max ;
  end
  return power ;
end


