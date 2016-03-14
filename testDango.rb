## -*- mode: ruby -*-

######################################################################
=begin
= testDango.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'Dango.rb' ;

teamL = DangoTeam.new("myDangoTeamFoo") ;
teamR = DangoTeam.new("myDangoTeamBar") ;

game = Game.new(teamL, teamR) ;

game.run() ;
