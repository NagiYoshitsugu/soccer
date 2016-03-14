## -*- Mode:Ruby -*-

######################################################################
=begin
= myCanvas.rb
=end
######################################################################
require "myCanvasDevBase.rb" ;
require "myCanvasGtk.rb" ;


class MyCanvas < MyCanvasDevBase
  attr :device, true ;

  ##----------------------------------------
  ## setSize by param table

  def initialize(devtype,param)
    setupDevice(devtype,param) ;
  end

  ##----------------------------------------
  ## setSize by param table

  def setupDevice(devtype,param) 
    case devtype
    when 'gtk'
      @device = MyCanvasGtk.new(param) ;
    when 'tgif'
      @device = MyCanvasTgif.new(param) ;
    when 'tk'
      @device = MyCanvasTk.new(param) ;
    else
      @stderr.printf("Error:unknown device type : %s\n",devtype.to_s) ;
      fail ;
    end
  end

  ##----------------------------------------
  ## setSize by param table

  def setSizeByParam(param) 
    @device.setSizeByParam(param) ;
  end

  ##----------------------------------------
  ## setSize

  def setSize(szX,szY,scale,centerp=FALSE)
    @device.setSize(szX,szY,scale,centerp) ;
  end

  ##----------------------------------------
  ## setShift

  def setShift(sx,sy) 
    @device.setShift(sx,sy) 
  end

  ##----------------------------------------
  ## setScale

  def setScale(scale)
    @device.setScale(scale)
  end

  ##----------------------------------------
  ## setScaleShift by boundary box

  def setScaleShiftByBoundaryBox(x0,y0,x1,y1)
    @device.setScaleShiftByBoundaryBox(x0,y0,x1,y1) ;
  end

  ##----------------------------------------------------------------------
  ## access
  ##

  def sizeX()
    return @device.sizeX() ;
  end

  def sizeY()
    return @device.sizeY() ;
  end

  ##--------------------
  ## getScaleX

  def getScaleX()
    return @device.getScaleX() ;
  end

  ##--------------------
  ## getScaleY

  def getScaleY()
    return @device.getScaleY() ;
  end

  ##----------------------------------------------------------------------
  ## toplevel
  ##

  ##----------------------------------------
  ## run [!!! should be defined in subclass!!!] 

  def run()
    @device.run() ;
  end

  ##----------------------------------------
  ## finish

  def finish()
    @device.finish() ;
  end

  ##----------------------------------------
  ## flush

  def flush()
    @device.flush() ;
  end

  ##----------------------------------------
  ## begin/end Page [!!! should be defined in subclass!!!] 

  def beginPage(color="white") 
    @device.beginPage(color) ;
  end

  def endPage()
    @device.endPage() ;
  end

  ##----------------------------------------------------------------------
  ## draw facility
  ##

  ##----------------------------------------
  ## draw line

  ##--------------------
  ## dashed line [!!! should be defined in subclass!!!] 

  def drawDashedLine(x0,y0,x1,y1,thickness=1,color="grey") ;
    @device.drawDashedLine(x0,y0,x1,y1,thickness,color) ;
  end

  ##--------------------
  ## solid line [!!! should be defined in subclass!!!] 

  def drawSolidLine(x0,y0,x1,y1,thickness=1,color="black") ;
    @device.drawSolidLine(x0,y0,x1,y1,thickness,color) ;
  end

  ##----------------------------------------
  ## draw circle

  ##--------------------
  ## draw circle body [!!! should be defined in subclass!!!] 

  def drawCircle(x,y,r,fillp=false,color="black")
    @device.drawCircle(x,y,r,fillp,color) ;
  end

  ##--------------------
  ## draw circle body [!!! should be defined in subclass!!!] 

  def drawEllipse(x,y,rx,ry,fillp=false,color="black")
    @device.drawEllipse(x,y,rx,ry,fillp,color) ;
  end

  ##----------------------------------------
  ## draw rectangle
  ##
  
  ##--------------------
  ## draw rectangle body [!!! should be defined in subclass!!!] 

  def drawRectangle(x,y,w,h,fillp=false,color="black")
    @device.drawRectangle(x,y,w,h,fillp,color) ;
  end

  def drawText(x ,y ,text, fontSize = 14, fontFamily = :times, color="black")
    @device.drawText(x,y,text,fontSize,fontFamily,color) ;
  end

end
