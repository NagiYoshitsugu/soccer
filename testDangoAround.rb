## -*- mode: ruby -*-

######################################################################
=begin
= testDangoAround.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'Dango.rb' ;
require 'DangoAround.rb' ;

teamL = DangoAroundTeam.new("myDangoAround") ;
teamR = DangoTeam.new("myDango") ;

game = Game.new(teamL, teamR) ;

game.run() ;
