## -*- Mode:Ruby -*-

######################################################################
=begin
= myCanvasGtk.rb
=end
######################################################################

$isGtk2 = false ;
$LOAD_PATH.each{|dir|
  if(FileTest::exists?(File::join(dir,"gtk2.rb"))) then
    $isGtk2 = true ;
    break ;
  end
}

if($isGtk2)
  require 'gtk2' ;
else
  require 'gtk' ;
end

require 'thread' ;
require 'myCanvasDevBase.rb' ;

## for compatibility between Gtk and Gtk2
if($isGtk2)
  Gtk::Widget::SIGNAL_EXPOSE_EVENT = "expose_event" ;
  Gtk::Widget::SIGNAL_CONFIGURE_EVENT = "configure_event" ;
end

## for compatibility of Gtk::Label
if(! Gtk::Label.method_defined?("set_label")) then
  class Gtk::Label
    def set_label(label)
      set_text(label)
    end
  end
end

## for compatibility X11's path
RGBFILE_CANDIDATES = ["./rgb.txt", 
                      "/usr/lib/X11/rgb.txt", 
                      "/usr/share/X11/rgb.txt"] ; 
RGBFILE_CANDIDATES.each{|path|
  if(FileTest::exist?(path)) then
    RGBFILE = path ;
    break ;
  end
}
p [:usingRGBfile, RGBFILE] ;


class MyCanvasGtk < MyCanvasDevBase

  attr :topwindow,	TRUE ;

  attr :hbox,		TRUE ;
  attr :vbox,		TRUE ;
  attr :topbar,		TRUE ;
  attr :bottombar,	TRUE ;
  attr :leftbar,	TRUE ;
  attr :rightbar,	TRUE ;
  attr :centerbox,	TRUE ;

  attr :quitbutton,	TRUE ;
  attr :statusbar,	TRUE ;
  attr :statusTable,	TRUE ;
  attr :statusbarPos,	TRUE ;

  attr :canvas,		TRUE ;
  attr :drawable,	TRUE ;
  attr :buffer,		TRUE ;
  attr :currentbuffer,	TRUE ;

  attr :geometry,	TRUE ;
  attr :gc,		TRUE ;
  attr :color,		TRUE ; # color table
  attr :colormap,	TRUE ;
  attr :font,		TRUE ;
  attr :fontmap,	TRUE ;

  attr :thread,		TRUE ;

  ##----------------------------------------------------------------------
  ## setup

  ##----------------------------------------
  ## initialize
  ##

  def initialize(param = {})
    setSizeByParam(param) ;
    setupWindow(param) ;
  end

  ##--------------------
  ## default size

  def dfltSizeX()
    return 512 ;
  end

  def dfltSizeY()
    return 512 ;
  end

  ##----------------------------------------
  ## setup window
  ##

  def setupWindow(param)
    if($isGtk2)
      Gtk.init ;
      @topwindow = Gtk::Window::new() ;
    else
      @topwindow = Gtk::Window::new(Gtk::WINDOW_TOPLEVEL) ;
    end
    @topwindow.set_title(param.fetch('title',"myGtkCanvas")) ;
    
    @topwindow.realize ;

    setupWindowTopMiddleBottom(param) ;
    setupWindowLeftCenterRight(param) ;

    setupWindowCanvas(param) ;

    setupWindowStatusbar(param) ;

    setupWindowQuit(param) ;

    @topwindow.show_all ;
  end

  ##--------------------
  ## setup top/middle/bottom

  def setupWindowTopMiddleBottom(param) 

    # vertical box
    @vbox = Gtk::VBox::new(false) ; 
    @topwindow.add(@vbox) ; 
    @vbox.show() ;

    #top bar
    @topbar = Gtk::HBox::new(false) ; 
    @vbox.add(@topbar) ; 
    @topbar.show() ;

    #middle bar
    @hbox = Gtk::HBox::new(false) ; 
    @vbox.add(@hbox) ; 
    @hbox.show() ;

    #bottom bar
    @bottombar = Gtk::HBox::new(false) ; 
    @vbox.add(@bottombar) ; 
    @bottombar.show() ;
  end

  ##--------------------
  ## setup left/center/right

  def setupWindowLeftCenterRight(param)
    @leftbar = Gtk::VBox::new(false) ; 
    @hbox.add(@leftbar) ;
    @leftbar.show() ;

    @centerbox = Gtk::VBox::new(false) ;
    @hbox.add(@centerbox) ;
    @centerbox.show() ;
    
    @rightbar = Gtk::VBox::new(false) ;
    @hbox.add(@rightbar) ;
    @rightbar.show() ;
  end

  ##--------------------
  ## setup canvas

  def setupWindowCanvas(param)
    @canvas = Gtk::DrawingArea::new() ;

    if($isGtk2)
      @canvas.set_size_request(@sizeX,@sizeY) ;
    else
      @canvas.set_usize(@sizeX,@sizeY) ;
    end
    				# set_app_paintable is for v.1.2.9 or greater
    if(1.0208 < (Gtk::MAJOR_VERSION + 
		 Gtk::MINOR_VERSION * 0.01 + 
		 Gtk::MICRO_VERSION * 0.0001)) then
      @canvas.set_app_paintable(true) ;
    end

    @centerbox.add(@canvas) ;
    @canvas.show() ;

    @canvas.signal_connect(Gtk::Widget::SIGNAL_EXPOSE_EVENT) do |win,evt|
      expose_event(win,evt) ;
    end

    @canvas.signal_connect(Gtk::Widget::SIGNAL_CONFIGURE_EVENT){|w, e| 
      if(@drawable.nil?) 
	@drawable = @canvas.window ;

        if($isGtk2)
          @geometry = @drawable.geometry ;
        else
          @geometry = @drawable.get_geometry ;
        end
	@sizeX = @geometry[2] ;
	@sizeY = @geometry[3] ;

	assignNewBuffer(false) ;

	prepareGC(true) ;
	assignBaseColors() ;
	assignBaseFonts() ;
      end
    }
  end

  ##--------------------
  ## setup status bar

  class StatusInfoEntry
    attr :name, true ;
    attr :value, true ;
    attr :dest,	true ;

    def initialize(name, value = nil, dest = nil) 
      @name = name ;
      @value = value ;
      @dest = dest ;
    end
  end

  def setupWindowStatusbar(param)
    statusList = param.fetch('status',nil) ;
    return if (statusList.nil?) ;

    @statusTable = Hash::new ;

    @statusbarPos = param.fetch('statusPos','right') ;

    case @statusbarPos
    when 'left'
      @statusbar = @leftbar ;
    when 'right'
      @statusbar = @rightbar ;
    when 'top'
      @statusbar = @topbar ;
    when 'bottom'
      @statusbar = @bottombar ;
    else
      $stderr << "Error: unknown statusbar position: " << @statusbarPos << "\n" ;
      fail ;
    end

    addStatusInfoEntry("_slot_","_value_") ;

    statusList.each{|entry|
      addStatusInfoEntry(entry[0],entry[1]) ;
    }

  end

  ##--------------------
  ## add status info entry

  def addStatusInfoEntry(name, value = "")

    case @statusbarPos
    when 'left', 'right'
      slot = Gtk::HBox::new(false) ;
      entrySep = Gtk::HSeparator.new ;
      slotValueSep = Gtk::VSeparator.new ;
      padding = 10 ;
    when 'top', 'bottom'
      slot = Gtk::VBox::new(false) ;
      entrySep = Gtk::VSeparator.new ;
      slotValueSep = Gtk::HSeparator.new ;
      padding = 0 ;
    end
#    @statusbar.add(slot)
    @statusbar.pack_start(slot,false,false,0) ;
    @statusbar.pack_start(entrySep,false,false,1) ;

    nameWin = Gtk::Label::new(name.to_s) ;
#    nameWin.set_pattern("_" * 80) ;
    slot.pack_start(nameWin,false,false,padding) ;

    slot.pack_start(slotValueSep) ;

    useEntryP = false ;
    if(useEntryP) then		# using Entry widget
      valueWin = Gtk::Entry::new() ;
      valueWin.set_text(value.to_s) ;
      valueWin.set_editable(false) ;
    else			# using label widget
      valueWin = Gtk::Label::new() ;
      valueWin.set_text(value.to_s) ;
      valueWin.set_justify(Gtk::JUSTIFY_RIGHT)
    end
    slot.pack_start(valueWin,false,false,padding) ;
    
    slot.show_all ;
    entrySep.show ;
    
    entry = StatusInfoEntry.new(name,value,valueWin) ;
    @statusTable[name] = entry ;
  end

  ##--------------------
  ## set status value

  def setStatusInfo(name, value)
    entry = @statusTable[name] ;
    if(entry.nil?)
      raise "unknown status :" + name ;
    end

    entry.dest.set_text(value.to_s) ;
  end

  ##--------------------
  ## setup quit button

  def setupWindowQuit(param)
    pos = param.fetch('quitbutton','bottom') ;
    
    if(!pos.nil?) then
      @quitbutton = Gtk::Button::new("quit") ;

      case pos
      when 'left'
	@leftbar.add(@quitbutton) ;
      when 'right'
	@rightbar.add(@quitbutton) ;
      when 'top'
	@topbar.add(@quitbutton) ;
      when 'bottom'
	@bottombar.add(@quitbutton) ;
      else
	$stderr << "Error: unknown quit-button position: " << pos << "\n" ;
	fail ;
      end

      @quitbutton.signal_connect("clicked") {
	exit(0) ;
      }
    end
  end


  ##----------------------------------------------------------------------
  ## top facility
  ##

  ##----------------------------------------
  ## run

  def run()
    @thread = Thread::new{
      Thread::current.abort_on_exception = true ;
      Gtk.main ;
    }
    @thread.run() ; 
    beginPage() ;
  end

  ##----------------------------------------
  ## finish

  def finish()
    endPage() ;
    @thread.run() ;  
    sleep ;
  end

  ##----------------------------------------
  ## flush

  def flush()
    if(! @buffer.nil?) 
      if($isGtk2)
        @drawable.draw_drawable(@gc,@buffer,0,0,0,0,width(),height()) ;

      else
        @drawable.draw_pixmap(@gc,@buffer,0,0,0,0,width(),height()) ;
      end
      @currentbuffer = @buffer ;
    end

    if(Thread.current != @thread && !@thread.nil?)
      @thread.run() ;
    end
  end

  ##----------------------------------------
  ## begin/end page

  def beginPage(color="white") # if color=nil, copy from old buffer
    assignNewBuffer(color.nil?) ;
    clearPage(color) if(!color.nil?) ;
  end

  def endPage()
    flush() ;
  end

  ##----------------------------------------
  ## clear page

  def clearPage(color="white")
    @gc.set_foreground(getColor(color)) ;
    @buffer.draw_rectangle(@gc,true,0,0,width(),height()) ;
  end

  ##----------------------------------------------------------------------
  ## draw primitive

  ##----------------------------------------
  ## set line style
  ##

  def setGCLineAttributes(gc,thickness,style)
    if($isGtk2)
      if(style == :dashed)
        gc.set_line_attributes(thickness, Gdk::GC::LINE_ON_OFF_DASH,
                               Gdk::GC::CAP_NOT_LAST, Gdk::GC::JOIN_MITER) ;
      else
        gc.set_line_attributes(thickness, Gdk::GC::LINE_SOLID,
                               Gdk::GC::CAP_NOT_LAST, Gdk::GC::JOIN_MITER) ;
      end
    else
      if(style == :dashed)
        gc.set_line_attributes(thickness, Gdk::LINE_ON_OFF_DASH,
                               Gdk::CAP_NOT_LAST, Gdk::JOIN_MITER) ;
      else
        gc.set_line_attributes(thickness, Gdk::LINE_SOLID,
                               Gdk::CAP_NOT_LAST, Gdk::JOIN_MITER) ;
      end
    end
                             
  end

  ##----------------------------------------
  ## draw dashed line
  ##

  def drawDashedLine(x0,y0,x1,y1,thickness=1,color="grey")
    @gc.set_foreground(getColor(color)) ;
    setGCLineAttributes(@gc,thickness, :dashed)

    @buffer.draw_line(@gc,valX(x0),valY(y0),valX(x1),valY(y1)) ;
  end

  ##----------------------------------------
  ## draw solid line
  ##

  def drawSolidLine(x0,y0,x1,y1,thickness=1,color="black")
    @gc.set_foreground(getColor(color)) ;
    setGCLineAttributes(@gc,thickness, :solid)

    @buffer.draw_line(@gc,valX(x0),valY(y0),valX(x1),valY(y1)) ;
  end

  ##----------------------------------------
  ## draw ellipse (circle)
  ##

  def drawEllipse(x,y,rx,ry,fillp,color="black")
    @gc.set_foreground(getColor(color)) ;
    setGCLineAttributes(@gc,1, :solid)

    @buffer.draw_arc(@gc,fillp,valX(x-rx),valY(y-ry),scaleX(2*rx),scaleY(2*ry),
		       360 * 0, 360 * 64) ;
  end

  ##----------------------------------------
  ## draw rectangle
  ##
  
  def drawRectangle(x,y,w,h,fillp,color="black")
    @gc.set_foreground(getColor(color)) ;
    setGCLineAttributes(@gc,1,:solid)

    @buffer.draw_rectangle(@gc,fillp,valX(x),valY(y),scaleX(w),scaleY(h)) ;
  end

  ##----------------------------------------
  ## draw text
  ##
  
  def drawText(x ,y ,text, fontSize = 14, fontFamily = :times, color="black")
    @font = getFont(fontFamily, fontSize) ;
    @gc.set_foreground(getColor(color)) ;
    if($isGtk2)
      ## see http://homepage1.nifty.com/markey/memo/200502.html
      layout = @topwindow.create_pango_layout() ;
      layout.set_text(text) ;
      layout.font_description = @font ;
      @buffer.draw_layout(@gc,valX(x),valY(y),layout) ;
    else
      @buffer.draw_string(@font,@gc,valX(x),valY(y)+fontSize,text) ;
    end
  end

  ##----------------------------------------------------------------------
  ## utility

  ##----------------------------------------
  ## assignNewBuffer

  def assignNewBuffer(copyp = false) # if initp=true, copy from old buffer
    # create new buffer
    oldbuf = @buffer ;
    newbuf = Gdk::Pixmap::new(@drawable, width(), height(),-1) ;

    #copy from old buffer
    if(!oldbuf.nil? && copyp)
      if($isGtk2)
        newbuf.draw_drawable(@gc,oldbuf,0,0,0,0,width(),height()) ;
      else
        newbuf.draw_pixmap(@gc, oldbuf, 0,0, 0,0,width(),height());
      end
    end

    @buffer = newbuf ;
    @currentbuffer = oldbuf ;
  end

  ##----------------------------------------
  ## expose_event
  ##

  def expose_event(w,e)
    if($isGtk2)
      @drawable.draw_drawable(@gc,@currentbuffer,0,0,0,0,width(),height()) ;
    else
      @drawable.draw_pixmap(@gc,@currentbuffer,0,0,0,0,width(),height()) ;
    end
#    p(e.area) ;
    false ;
  end

  ##----------------------------------------
  ## color utility
  ##

  def assignBaseColors()
    @color = Hash::new() ;

    if($isGtk2)
      @colormap = Gdk::Colormap.system ;
    else
      @colormap = Gdk::Colormap.get_system ;
    end

  end

  def getColor(colorname)
    col = @color[colorname] ;
    if(col.nil?) then
      f = File::new(RGBFILE) ;
      rval = -1 ; gval = -1 ; bval = -1 ;
      while(entry = f.gets)
	entry.strip! ;
	rstr,gstr,bstr,name = entry.split ;
	if(name == colorname) then
	  rval = rstr.to_i * 256 ;
	  gval = gstr.to_i * 256 ;
	  bval = bstr.to_i * 256 ;
	  break ;
	end
      end
      if(rval < 0) then
	if(colorname =~ /^\#([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])$/) then
	  rstr = $1 ; gstr = $2 ; bstr = $3 ;
	  rval = rstr.hex * 256 ; 
	  gval = gstr.hex * 256 ; 
	  bval = bstr.hex * 256 ; 
	else
	  $stderr << "unknown color name:" << colorname << "\n" ;
	end
      end
      col = assignColor(colorname,rval,gval,bval) ;
    end
    return col ;
  end

  def assignColor(color,rval,gval,bval) 
    c = Gdk::Color.new(rval,gval,bval) ;
    @color[color] = c ;
    @colormap.alloc_color(c,false,true) ;
    return c ;
  end
    
  ##----------------------------------------
  ## prepareGC
  ##

  def prepareGC(forcep)
    if(forcep || @gc.nil?) then
      @gc = Gdk::GC.new(@drawable) ;
    end
  end

  ##----------------------------------------
  ## font utility
  ##

  def assignBaseFonts()
    defaultFamily = :times ;
    defaultSize = 14 ;

    @fontmap = Hash::new() ;
    @font = getFont(defaultFamily,defaultSize) ;
  end

  def fontAlias(aliasname)
    if($isGtk2)
      table = { 
        :times => "Times %d",
        :helvetica => "Helvetica %d",
        nil => nil } ;
    else
      table = {
        :times => 
          "-adobe-times-medium-r-normal--%d-*-*-*-*-*-iso8859-1",
        :helvetica => 
          "-adobe-helvetica-medium-r-normal--%d-*-*-*-*-*-iso8859-1",
        nil => nil } ;
    end
      
    return table[aliasname] ;
  end

  def getFont(family,size)
    fontlist = @fontmap[family] ;
    fontlist = @fontmap[family] = Hash.new if(fontlist.nil?) ;
    font = fontlist[size] ;
    if(font.nil?) then
      fontname = fontAlias(family) ;
      if($isGtk2) 
        font = Pango::FontDescription.new(fontname % [size]) ;
      else
        font = Gdk::Font.fontset_load(fontname % [size]) ;
      end
      fontlist[size] = font ;
    end
    return font ;
  end

end


  


