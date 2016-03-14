## -*- mode: ruby -*-

######################################################################
=begin
= testSoccerGame.rb
= test for Game（at random）
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'Game.rb' ;

teamL = Team.new("myTeamFoo") ;
teamR = Team.new("myTeamBar") ;

game = Game.new(teamL, teamR) ;

game.run() ;
