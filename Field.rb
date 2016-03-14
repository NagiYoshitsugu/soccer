## -*- Mode: ruby -*-

######################################################################
=begin
= Field.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;
require 'Vector.rb' ;

##======================================================================
=begin
--- module Field
=end
##======================================================================
module Field

##------------------------------
=begin
=== 長さ関係の定数
=end
##------------------------------
  Length = 105.0 ;		
  Width = 68.0 ;		
  Margin = 20 ;			
  CircleR = 9.15 ;		
  PitchMargin = 5.0 ;		
  PenaltyAreaLength = 16.5 ;
  PenaltyAreaWidth = 40.32 ;	
  GoalAreaLength = 5.5 ;	
  GoalAreaWidth = 18.32 ;	
  GoalDepth = 2.0 ;		
  GoalWidth = 7.32 ;	

  HalfLength = Length/2.0 ;	
  HalfWidth = Width/2.0 ;	

  #penalty
  PenaltyCornerX = HalfLength - PenaltyAreaLength ; 
  PenaltyCornerY = PenaltyAreaWidth/2.0 ;

  #goal  
  GoalAreaCornerX = HalfLength - GoalAreaLength ; 
  GoalAreaCornerY = GoalAreaWidth/2.0 ;

##------------------------------
=begin
=== define position
=end
##------------------------------
  CenterSpotPos = Vector.new(0.0,0.0) ;		
  GoalLeftPos = Vector.new(-HalfLength, 0.0) ;	
  GoalRightPos = Vector.new(HalfLength, 0.0) ;  
  CornerLeftTopPos = 	 Vector.new(-HalfLength, -HalfWidth); 
  CornerLeftBottomPos =  Vector.new(-HalfLength,  HalfWidth); 
  CornerRightTopPos = 	 Vector.new( HalfLength, -HalfWidth); 
  CornerRightBottomPos = Vector.new( HalfLength,  HalfWidth); 

end
