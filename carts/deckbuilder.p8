pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- game variables
p1_life=20
p2_life=20
gridsize=5
gridpad=8
grid={}

-- card data
cards = {
 {name="runt",str=1},
 {name="minion",str=2},
 -- add more cards as needed
}

-- player turn variables
p_turn=1
playedcard=false

-- initialize grid
for x=1,gridsize do
 grid[x]={}
 for y=1,gridsize do
  grid[x][y]=nil
 end
end


function _init()
 -- set up game window
 cls()
 -- load any assets if needed
end


function _update()
 -- game logic goes here
 
 -- player input handling
 if p_turn == 1 and not playedcard then
  if btnp(❎) then
   -- play card when ❎ is pressed
   playcard(1)
   playedcard=true
  end
 end
 
 -- game logic
 if p_turn==1 then
  -- move creatures towards the opponent's side
  for x=1, gridsize do
   for y=1, gridsize do
    local creature = grid[x][y]
    if creature != nil then
     -- move creature
     if x < gridsize then
      grid[x+1][y] = creature
      grid[x][y] = nil
     else
      -- creature reached opponent's side, attack
      p2_life=p2_life-creature.str
      grid[x][y] = nil
     end 
    end
   end
  end
  p_turn=2 -- switch to opponent's turn
  playedcard=false
 else
  -- opponent's turn (ai logic)
  -- implement opponent's card playing and creature movement here
  p_turn=1 -- switch to player's turn
 end

 
end

function _draw()
 cls(1)
 -- drawing code goes here
 -- draw grid
 for i=0,1 do
 	if i==0 then
 		pal(7,12)
 	else
 		pal(7,8)
 	end
	 rectfill(40,8+(i*95),87,24+(i*95))
	 pal()
 end
 for x=1,gridsize do
  for y=1,gridsize do
   rect(x*16+gridpad,y*16+gridpad,x*16+15+gridpad,y*16+15+gridpad,10)
  end
 end
 
 -- draw player and opponent life
 print("p1: ".. p1_life, 2, 2, 7)
 print("p2: "..p2_life, 2, 120, 7)
 
 -- draw creatures
 for x=1,5 do
 string = ""
 	for y=1,5 do
 		if grid[x][y] == nil then
 			string=string.."[]"
 		else
 			string=string..grid[x][y].name
 		end
 	end
 	print(string)
 end
end

function playcard(c_id)
	if c_id >= 1 and c_id <= #cards then
		-- spawn a creature on a random free space in the top row
		local free={}
		for x = 1, gridsize do
  for y = 1, gridsize do
   if grid[x][y] == nil then
    grid[x][y] = {name=cards[c_id].name, str = cards[c_id].str }     return -- exit the function once a creature is spawned
    end
	  end
		end
	end
end

function test()
	print("line reached")
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000cccc000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000cccc000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000cccc000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000cccc000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
