## -*- Mode: ruby -*-

######################################################################
=begin
= Team.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'FieldWindow.rb' ;
require 'Player.rb' ;

##======================================================================
=begin
--- class Team
=end
##======================================================================
class Team
  attr :name, 	true ;		
  attr :score,  true ;	
  attr :side,   true ;         
  attr :playerList, true ;	
  attr :playerClass, true ;	

##------------------------------
=begin
--- initialize(teamname)
=end
##------------------------------
  def initialize(teamname)
    @name = teamname ;       
    @score = 0 ;             
    @playerList = [] ;	     
    @playerClass = Player ;  
    @side = Player::SideUnknownTag
  end

##------------------------------
=begin
--- newPlayer(field, side, unum) 
=end
##------------------------------
  def newPlayer(field, side, unum) 
    player = playerClass.new(self) ;

    setupPlayer(player, field, side, unum) ;
    playerList.push(player) ;

    return player ;
  end

##------------------------------
=begin
--- setupPlayer(player, field, side, unum)
=end
##------------------------------
  def setupPlayer(player, field, side, unum)
    if(side == Player::SideLeftTag)
      player.setLeftSideUnum(unum) ;
      player.pos.set(-30.0 , 3*(unum-5)) ;
      player.dir = 0.0 ;
    else		
      player.setRightSideUnum(unum) ;
      player.pos.set(30.0, 3*(unum-5)) ;
      player.dir = 3.14 ;
    end
    
    return player ;
  end

##------------------------------
=begin
--- display(window)
=end
##------------------------------
  def display(window)
    @playerList.each{ |player|
      player.display(window) ;
    }
    if(@side == Player::SideLeftTag) then
      window.setTeamLeft(@name, @score) ;
    else
      window.setTeamRight(@name, @score) ;
    end
  end

end
