## -*- Mode: ruby -*-

######################################################################
=begin
= Game.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'FieldWindow.rb' ;
require 'Vector.rb' ;
require 'Ball.rb' ;
require 'Team.rb' ;

##======================================================================
=begin
--- class Game
  * ball, teamLeft, teamRight
=end
##======================================================================
class Game
  attr :ball, true ;		
  attr :teamLeft, true ;		
  attr :teamRight, true ;		

  attr :cycleCount, true ;		# cycle count

  attr :window, true ;			# window　for display

##------------------------------
=begin
--- const
=end
##------------------------------
  KickInMargin = 1.0 ; 		# when kick-in, start at inside
  CycleInterval = 0.05 ;	# time in one cycle
  EventPause = 5 ;		# pause time when event

##------------------------------
=begin
--- initialize(teamL, teamR, makeWindowP = true)
  * init
=end
##------------------------------
  def initialize(teamL, teamR, makeWindowP = true)
    # initialize ball object
    @ball = Ball.new ;

    # left player
    teamL.side = Player::SideLeftTag ;
    assignPlayerLeft(teamL) ;
    @teamLeft = teamL ;
    
    # right player
    teamR.side = Player::SideRightTag ;
    assignPlayerRight(teamR) ;
    @teamRight = teamR ;

    @cycleCount = 0 ;

    # display window
    if(makeWindowP)
      @window = FieldWindow::new(:runDraw) ;
    end
  end

##------------------------------
=begin
--- assignPlayerLeft(team)
=end
##------------------------------
  def assignPlayerLeft(team)
    (0...11).each{|unum|
      team.newPlayer(self, Player::SideLeftTag, unum) ;
    }
  end

##------------------------------
=begin
--- assignPlayerRight(team)
=end
##------------------------------
  def assignPlayerRight(team)
    (0...11).each{|unum|
      team.newPlayer(self, Player::SideRightTag, unum) ;
    }
  end

##------------------------------
=begin
--- run()
  * main routine
  * call cycle at regular time intervals
=end
##------------------------------
  def run()
    while(true)
      cycle() ;
      sleep(CycleInterval) ;
    end
  end

##------------------------------
=begin
--- cycle()
  * processing of one cycle
=end
##------------------------------
  def cycle()
    cycleThink() ;		
    cycleMove() ;		
    event = cycleRuleCheck() ;	
    @cycleCount += 1 ;		# add cucle count
    draw() ;			# display
    if(!event.nil?)
      @window.setPlayMode(event) ; # display play mode
      sleep(EventPause) ;	# temporary halt when event
    end
  end

##------------------------------
=begin
--- cycleThink()
  * thinking of each player
=end
##------------------------------
  def cycleThink()
    (0...11).each{|unum|
      @teamLeft.playerList[unum].cycleThink(self) ;
      @teamRight.playerList[unum].cycleThink(self) ;
    }
  end

##------------------------------
=begin
--- cycleMove()
  * call moving cycle of ball & player
=end
##------------------------------
  def cycleMove()
    cycleMoveOne(@ball) ;
    (0...11).each{|unum|
      cycleMoveOne(@teamLeft.playerList[unum]) ;
      cycleMoveOne(@teamRight.playerList[unum]) ;
    }
  end

##------------------------------
=begin
--- cycleMoveOne(obj)
  * call moving cycle for one object
=end
##------------------------------
  def cycleMoveOne(obj)
    obj.cycleMove(self) ;
    checkCollision(obj) ;
  end

##------------------------------
=begin
--- checkCollision(obj)
  * check collision of the object each other
=end
##------------------------------
  def checkCollision(obj)
    obj.checkCollision(@ball) ;
    (0...11).each{|unum|
      obj.checkCollision(@teamLeft.playerList[unum]) ;
      obj.checkCollision(@teamRight.playerList[unum]) ;
    }
  end

##------------------------------
=begin
--- cycleRuleCheck()
  * check event on rules
=end
##------------------------------
  def cycleRuleCheck()
    event = nil ;
    # when fall below lower limit of field
    if(@ball.pos.y > FieldWindow::Width/2.0)
      event = "kick_in" ;
      @ball.pos.y = FieldWindow::Width/2.0 - KickInMargin ;
      @ball.vel.set(0,0) ;
    end
    # whem more than upper limit of field
    if(@ball.pos.y < -FieldWindow::Width/2.0)
      event = "kick_in" ;
      @ball.pos.y = - FieldWindow::Width/2.0 + KickInMargin ;
      @ball.vel.set(0,0) ;
    end

    # when protrude on the right side
    if(@ball.pos.x > FieldWindow::Length/2.0)
      if(abs(@ball.pos.y) < FieldWindow::GoalWidth / 2.0) 
        # when in gaol 
        event = "goal_left" ;
        @teamLeft.score += 1 ;
        @ball.pos.set(0,0) ;
        @ball.vel.set(0,0) ;
      else
        # when not gaol corner kick
        event = "corner_kick" ;
        @ball.pos.x = FieldWindow::Length/2.0 - KickInMargin ;
        if(@ball.pos.y > 0) 
          @ball.pos.y = FieldWindow::Width/2.0 - KickInMargin ;
        else
          @ball.pos.y = - (FieldWindow::Width/2.0 - KickInMargin) ;
        end
        @ball.vel.set(0,0) ;
      end
    end
    # protrude on left side
    if(@ball.pos.x < -FieldWindow::Length/2.0)
      if(abs(@ball.pos.y) < FieldWindow::GoalWidth / 2.0) 
        # when in gaol
        event = "goal_right" ;
        @teamRight.score += 1 ;
        @ball.pos.set(0,0) ;
        @ball.vel.set(0,0) ;
      else
        # when not gaol corner kick
        event = "corner_kick" ;
        @ball.pos.x = - FieldWindow::Length/2.0 + KickInMargin ;
        if(@ball.pos.y > 0) 
          @ball.pos.y = FieldWindow::Width/2.0 - KickInMargin ;
        else
          @ball.pos.y = - (FieldWindow::Width/2.0 - KickInMargin) ;
        end
        @ball.vel.set(0,0) ;
      end
    end

    return event ;
  end

##------------------------------
=begin
--- draw()
  * display
=end
##------------------------------
  def draw()
    ## specify location of ball
    @ball.display(@window) ;

    ## specify location of plyer
    @teamLeft.display(@window) ;
    @teamRight.display(@window) ;

    ## display game cycle
    @window.setPlayMode(@cycleCount) ;
  end

end
