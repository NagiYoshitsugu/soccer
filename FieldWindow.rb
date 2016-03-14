## -*- Mode: ruby -*-

######################################################################
=begin
= FieldWindow.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'myCanvas.rb' ;
require 'Vector.rb' ;
require 'utility.rb' ;
require 'Field.rb' ;

##====================================================================
=begin
--- class DrawableObject
=end
##======================================================================
class DrawableObject
  attr :field,    true ;	
  attr :position, true ;	
  attr :size,     true ;	

  Size = 0.1 ;			## default size of moving object
  DrawParam = {:color => 'black'} ;  

##------------------------------
=begin
--- initialize(field = nil, pos = [0,0], size = Size)
  * initialize

  * ((| field |)) specifies field being the object
  * ((| pos |)) specify initial value of position of the object
        default value is [0,0]
  * ((| size |)) specify size of the object
=end
##------------------------------
  def initialize(field = nil, pos = [0,0], size = Size)
    @field = field ;
    @position = Vector::vector(pos) ;
    @size = size ;
  end

##------------------------------
=begin
--- canvas()
  * return canvas for display
  * when no canvas, return nil
=end
##------------------------------
  def canvas()
    if(@field.is_a?(FieldWindow))
      return @field.canvas() ;
    else
      return nil
    end
  end

##------------------------------
=begin
--- draw()
  * draw object
  * draw circle(center: position, radius: size)
=end
##------------------------------
  def draw()
    color = lookupParam(:color) ;
    canvas().drawCircle(@position.x,@position.y,@size,true,color) ;
  end

##------------------------------
=begin
--- lookupParam(key)
  * return parameters for display
=end
##------------------------------
  def lookupParam(key)
    return DrawParam[key] ;
  end

##------------------------------
=begin
--- to_s()
=end
##------------------------------
  def to_s()
    return ('#DrawableObject[' + @position.to_s + ']') ;
  end

end

##====================================================================
=begin
--- class DrawableBall < DrawableObject


=end
##======================================================================
class DrawableBall < DrawableObject

  Size = 0.5 ;			## size of ball for display 
  DrawParam = {:color => 'grey80'} ;  

##------------------------------
=begin
--- initialize(field = nil, pos = [0,0], size = Size)
  * initialize
=end
##------------------------------
  def initialize(field = nil, pos = [0,0], size = Size)
    super ;
  end

##------------------------------
=begin
--- draw()
=end
##------------------------------
  def draw()
    super() ;
  end

##------------------------------
=begin
--- lookupParam(key)
  * get parameter for display
##------------------------------
  def lookupParam(key)
    val = DrawParam[key] ;
    return val || super(key) ;
  end

##------------------------------
=begin
--- to_s()
=end
##------------------------------
  def to_s()
    return ('#DrawableBall[' + @position.to_s + ']') ;
  end

  
end

##====================================================================
=begin
--- DrawablePlayer < DrawableObject


=end
##======================================================================
class DrawablePlayer < DrawableObject
  attr :side,     true ;  
  attr :unum,     true ;  
  attr :dir,	  true ;  
  Size = 1.0 ;		## size of player for display
  DrawParamList = { 	
    :left  => { :color => 'red'},	## right team red
    :right => { :color => 'gold'},	## left team yellow
    :none  => { :color => 'black'}} ;	## no specify black
    
##------------------------------
=begin
--- initialize(field = nil, side = :left, unum = 0, pos = [0,0]) 
  * initialize
  * ((| field |)) specifies field being player, when display
  * ((| side |)) species plyer sides
  * ((| unum |)) species back number of plyer
  * ((| pos |)) species initial value of moving object
    default value is [0,0]。
=end
##------------------------------
  def initialize(field = nil, side = :left, unum = 0, pos = [0,0]) 
    super(field,pos,Size) ;     
    @side = side ;		
    @unum = unum ;		
    if(side == :left) 		
      @dir = 0.0 ;
    else 			
      @dir = Math::PI ;
    end
  end

##------------------------------
=begin
--- draw()
  * draw player
  * draw direction plyers face
=end
##------------------------------
  def draw()
    super();
    color = lookupParam(:color) ;
    len = @size * 2.0 ;
    dx = @position.x + len * Math::cos(@dir) ;
    dy = @position.y + len * Math::sin(@dir) ;
    canvas().drawSolidLine(@position.x,@position.y,dx,dy,1,color) ;
  end

##------------------------------
=begin
--- lookupParam(key)
  * get draw parameter
=end
##------------------------------
  def lookupParam(key)
    val = DrawParamList[@side][key] ;
    return val || super(key) ;
  end

##------------------------------
=begin
--- to_s()
  * literize
=end
##------------------------------
  def to_s()
    return ('#DrawablePlayer[' + @side.to_s + '-' + @unum.to_s + 
	    '|' + @position.to_s + '/' + ']') ;
  end

end

##======================================================================
=begin
--- class FieldWindow
=end
##======================================================================
class FieldWindow
  include Field ;  

  ##--------------------------------------------------
  ## instance value

  attr :canvas,	true ;		
  attr :teamLeft, true ;	
  attr :teamRight, true ;	
  attr :playMode, true ;	

  attr :ball, true ;	
  attr :playerLeft, true ;	
  attr :playerRight, true ;

  attr :drawThread, true ;	

  ##--------------------------------------------------
  ## constant value

  Scale = 5 ;			

##------------------------------
=begin
--- initialize(runMode = false)
  * initialize
  * initialize (({ @canvas }))
  * initialize display object for ball & player
=end
##------------------------------
  def initialize(runMode = false)
    assignCanvas() ;	
    assignBall() ;	
    assignPlayers() ;	
    case(runMode)	
    when :runDraw; 
      forkDraw()        
    end
  end

##------------------------------
=begin
--- assignCanvas()
  initialize display window*
=end
##------------------------------
  def assignCanvas()
    @canvas = MyCanvas.new('gtk',
			   { 'width'	=> (Length + Margin) * Scale,
			     'height'	=> (Width + Margin) * Scale,
			     'scale'	=> Scale,
			     'centerp'	=> true,
			     ''		=> nil}) ;

    @teamLeft = Gtk::Label.new("(left team)") ;
    @canvas.device.topbar.add(@teamLeft) ;  
    @teamLeft.show() ;

    
    @playMode = Gtk::Label.new("(playmode)") ;
    @canvas.device.topbar.add(@playMode) ;
    @playMode.show() ;

    
    @teamRight = Gtk::Label.new("(right team)") ;
    @canvas.device.topbar.add(@teamRight) ;
    @teamRight.show() ;
  end

##------------------------------
=begin
--- assignBall()
  *initialize ball object for display
=end
##------------------------------
  def assignBall()
    @ball = DrawableBall::new(self,[0,0]) ;
  end

##------------------------------
=begin
--- assignPlayers()
  *initialize player object for display
=end
##------------------------------
  def assignPlayers()
    @playerLeft = [] ;
    @playerRight = [] ;

    y = - Width / 2.0 - 5.0 ;
    ox = 10.0 ; 
    sx = 3.0 ;
    (0...11).each{ |i| 
      x = ox + sx * i ;  
      @playerLeft.push(DrawablePlayer::new(self,:left,i,[-x,y])) ;
      @playerRight.push(DrawablePlayer::new(self,:right,i,[x,y])) ;
    }
  end

##------------------------------
=begin
--- forkDraw()
=end
##------------------------------
  def forkDraw()
    @drawThread = Thread.start do	
      Thread::current.abort_on_exception = true ;  
      runDraw() ;		
    end
    return @drawThread ;
  end

##------------------------------
=begin
--- runDraw()
  * main routine for display
=end
##------------------------------
  def runDraw()
    @canvas.animation(true,0.1,'white'){|i|  
      cycleDraw() ;                          
    }
  end

##------------------------------
=begin
--- cycleDraw()
=end
##------------------------------
  def cycleDraw()
    draw() 		
  end

##------------------------------
=begin
--- draw()
  * gross eachroutine for display 
##------------------------------
  def draw()
    drawField() ;	
    drawPlayers() ;	
    drawBall() ;	
  end

##------------------------------
=begin
--- drawField()
  * routine displaying field
=end
##------------------------------
  def drawField()
    l = Length ;             
    w = Width ;    
    m = Margin ;             
    s = PitchMargin ;
    pl = PenaltyAreaLength ; 
    pw = PenaltyAreaWidth ;
    gl = GoalAreaLength ;    
    gw = GoalAreaWidth ;
    gd = GoalDepth ;         
    gg = GoalWidth ;

    @canvas.drawRectangle(-((l+m)/2),-((w+m)/2),(l+m),(w+m),true,'maroon') ;
    @canvas.drawRectangle(-((l+s)/2),-((w+s)/2),(l+s),(w+s),true,'DarkGreen') ;
    @canvas.drawRectangle(-((l+0)/2),-((w+0)/2),(l+0),(w+0),false,'white') ;
    @canvas.drawSolidLine(0,-w/2,0,w/2,1,'white') ;
    @canvas.drawCircle(0,0,CircleR,false,'white') ;
    @canvas.drawRectangle(-l/2,     -pw/2, pl,pw,false,'white') ;
    @canvas.drawRectangle( l/2 - pl,-pw/2, pl,pw,false,'white') ;
    @canvas.drawRectangle(-l/2,     -gw/2, gl,gw,false,'white') ;
    @canvas.drawRectangle( l/2 - gl,-gw/2, gl,gw,false,'white') ;
    @canvas.drawRectangle(-l/2 - gd,-gg/2, gd,gg,true,'grey50') ;
    @canvas.drawRectangle( l/2     ,-gg/2, gd,gg,true,'grey50') ;
  end

##------------------------------
=begin
--- drawPlayers()
  * display player
=end
##------------------------------
  def drawPlayers()
    @playerLeft.each{|player|   
      player.draw() ;
    }
    @playerRight.each{|player|
      player.draw() ;
    }
  end

##------------------------------
=begin
--- drawBall()
  * display ball
=end
##------------------------------
  def drawBall()
    ball.draw() ;
  end

##------------------------------
=begin
--- setBallPos(x,y)
  * correct position of ball
=end
##------------------------------
  def setBallPos(x,y)
    @ball.position.set(x,y)
  end

##------------------------------
=begin
--- setPlayerLeftPos(unum, x, y)
=end
##------------------------------
  def setPlayerLeftPos(unum, x, y)
    @playerLeft[unum].position.set(x,y) ;
  end

##------------------------------
=begin
--- setPlayerRightPos(unum, x, y)
=end
##------------------------------
  def setPlayerRightPos(unum, x, y)
    @playerRight[unum].position.set(x,y) ;
  end

##------------------------------
=begin
--- setPlayerLeftDir(unum, dir)
=end
##------------------------------
  def setPlayerLeftDir(unum, dir)
    @playerLeft[unum].dir = dir ;
  end

##------------------------------
=begin
--- setPlayerRightDir(unum, dir)
=end
##------------------------------
  def setPlayerRightDir(unum, dir)
    @playerRight[unum].dir = dir ;
  end

##------------------------------
=begin
--- setTeamLeft(teamname,score)
=end
##------------------------------
  def setTeamLeft(teamname,score)
    @teamLeft.set_label("%s : %d" % [teamname, score]) ;
  end

##------------------------------
=begin
--- setTeamRight(teamname,score)
=end
##------------------------------
  def setTeamRight(teamname,score)
    @teamRight.set_label("%s : %d" % [teamname, score]) ;
  end

##------------------------------
=begin
--- setPlayMode(info)
=end
##------------------------------
  def setPlayMode(info)
    @playMode.set_label(info.to_s) ;
  end

end










