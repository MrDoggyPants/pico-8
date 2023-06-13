pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- player variables
players = {
  {x = 60, y = 60, speed = 2, team = 0, skill = "accurate", stealchance = 0.05},
  {x = 100, y = 60, speed = 2, team = 0, skill = "pass", passchance = 0.2},
  {x = 80, y = 80, speed = 2, team = 0, skill = "steal", stealchance = 0.1},
  {x = 60, y = 100, speed = 2, team = 1, skill = "accurate", stealchance = 0.05},
  {x = 100, y = 100, speed = 2, team = 1, skill = "pass", passchance = 0.2}
}

-- ball variables
ball = {
  x = 80,
  y = 80,
  x_speed = 0,
  y_speed = 0
}

-- goal variables
goalwidth = 20
goalheight = 10
leftgoal = {x = 0, y = 55, width = goalwidth, height = goalheight}
rightgoal = {x = 127 - goalwidth, y = 55, width = goalwidth, height = goalheight}

-- score variables
leftscore = 0
rightscore = 0

function _update()
  -- move the players and perform actions based on their skills
  for i, player in ipairs(players) do
    local opponentteam = (player.team + 1) % 2
    local opponent = players[get_opponent_player_index(opponentteam)]
    
    if btn(0) then
      player.x -= player.speed
    elseif btn(1) then
      player.x += player.speed
    end
    
    if btn(2) then
      player.y -= player.speed
    elseif btn(3) then
      player.y += player.speed
    end
  
  -- move the ball
  ball.x += ball.x_speed
  ball.y += ball.y_speed

  -- perform skill actions based on the player's skill level
    if player.skill == "accurate" and rnd() < 0.02 then
      ball.x_speed = (player.x - ball.x) * 0.1
      ball.y_speed = (player.y - ball.y) * 0.1
    elseif player.skill == "pass" and rnd() < player.passchance then
      pass_ball(player, opponent)
    elseif player.skill == "steal" and rnd() < player.stealchance then
      if check_collision(player, ball) then
        reset_ball()
      end
    end
  end

  -- ball collision with players
  for i, player in ipairs(players) do
    if check_collision(player, ball) then
      -- ball bounce logic
      ball.y_speed = -ball.y_speed
    end
  end
  
  -- ball collision with walls
  if ball.x < 0 or ball.x > 127 then
    -- ball bounce logic
    ball.x_speed = -ball.x_speed
  end
  
  if ball.y < 0 or ball.y > 127 then
    -- ball bounce logic
    ball.y_speed = -ball.y_speed
  end
  -- check for goals
  if check_collision(ball, leftgoal) then
    rightscore += 1
    reset_ball()
  end
  
  if check_collision(ball, rightgoal) then
    leftscore += 1
    reset_ball()
  end
end

function _draw()
  -- clear the screen
  cls()
  
  -- draw the players
  for _, player in ipairs(players) do
    rectfill(player.x, player.y, player.x + 8, player.y + 8, 9)
  end
  
  -- draw the ball
  circfill(ball.x, ball.y, 3, 6)

  -- draw the goals
  rectfill(leftgoal.x, leftgoal.y, leftgoal.x + leftgoal.width, leftgoal.y + leftgoal.height, 11)
  rectfill(rightgoal.x, rightgoal.y, rightgoal.x + rightgoal.width, rightgoal.y + rightgoal.height, 11)
  
  -- draw the scores
  print("score: " .. leftscore, 5, 5, 7)
  print("score: " .. rightscore, 110, 5, 7)
end

function check_collision(obj1, obj2)
  return obj1.x < obj2.x + 3 and
         obj1.x + 8 > obj2.x and
         obj1.y < obj2.y + 3 and
         obj1.y + 8 > obj2.y
end

function reset_ball()
  ball.x = 80
  ball.y = 80
  ball.x_speed = 0
  ball.y_speed = 0
end

function get_opponent_player_index(opponentteam)
  for i, player in ipairs(players) do
    if player.team == opponentteam then
      return i
    end
  end
end

function pass_ball(fromplayer, toplayer)
  if check_collision(fromplayer, toplayer) then
    ball.x_speed = (toplayer.x - ball.x) * 0.1
    ball.y_speed = (toplayer.y - ball.y) * 0.1
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
