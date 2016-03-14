## -*- Mode: ruby -*-

######################################################################
=begin
= DangoAround.rb
=end
######################################################################

$LOAD_PATH.push(File::dirname($0)) ;

require 'Game.rb' ;

##======================================================================
=begin
--- class DangoAroundPlayer
=end
##======================================================================
class DangoAroundPlayer < Player
##------------------------------
=begin
--- cycleThink(field) 
  * 思考サイクル
  * アルゴリズム
    * ボールが蹴れるなら、ボールをゴールに向かって蹴る。
    * ボールを蹴れないなら、
      * 2回に1回は方向修正
      * それ以外はそのままダッシュ
=end
##------------------------------
  def cycleThink(field) 
    if(kickable?(field)) # ボールを蹴れるならゴールの方向に蹴る。
      goalPos = opponentGoalPos() ;                # ゴールの位置
      goalDirection = @pos.directionTo(goalPos) ;  # ゴールの方向
      kickAngle = goalDirection - @dir ;           # 蹴るべき方向
      kick(field, fltRand(10.0,100.0), kickAngle) ; # 蹴る動作
    else		 # ボールが蹴れないなら、走る。
      # ダッシュしてみる
      if(rand(3) == 0) then # 3回に1回は向きを修正
	if(rand(5) == 0) then # たまにそっぽを向く。
	  turn(field, fltRand(-Math::PI,Math::PI)) ;
	else
	  ballDirection = @pos.directionTo(ballPos(field)) ;
	  turnAngle = ballDirection - @dir ;
	  turn(field, turnAngle) ;
	end
      else
	# 現在向いている方向へダッシュ。ダッシュの力は [10,50] の間でランダム
	dash(field, fltRand(10.0, 50.0)) ;
      end
    end
  end

end

##======================================================================
=begin
--- class DangoAroundTeam
  * 団子サッカーをするチーム
=end
##======================================================================
class DangoAroundTeam < Team
##------------------------------
=begin
--- initialize(teamname)
   * 初期化。
   * ((| teamname |)) はチーム名の文字列を指定
=end
##------------------------------
  def initialize(teamname)
    super ;			## 基本的な初期化は class Player のものを利用
    @playerClass = DangoAroundPlayer ;## プレーヤは class DangoAroundPlayer
  end
  
end
