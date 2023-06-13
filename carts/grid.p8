pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- default functions
function _init()

	-- initialise grid
	gridsize=5
	grid={}
	for i=1,gridsize do
		add(grid, {})
		for j=1, gridsize do
			add(grid[i],{})
		end
	end
	
	-- players
	player={{},{}}
	for i in all(player) do
		i.life=20
		i.hand={}
	end
	
	-- cards
	card_list={
		{sprt={x1=0,y1=0,x2=8,y2=10},name="runt",atk=1,def=1},
		{sprt={x1=8,y1=0,x2=8,y2=10},name="minion",atk=2,def=1},
		{sprt={x1=16,y1=0,x2=8,y2=10},name="brute",atk=1,def=2},
		{sprt={x1=24,y1=0,x2=8,y2=10},name="mage",atk=1,def=1},
	}
	
	-- turn indicators
	turn=1
	drawcard=true
	usedcard=false
	
	choice=1
	
end

function _update()
	-- show player cards
	if drawcard and turn%2!=0 then
		card_draw(player[1])
		drawcard=false
	end
	
	if turn%2!=0 then
		if btnp(⬅️) then
			if player[1].hand[choice-1] then
				choice-=1
			end
		end
		
		if btnp(➡️) then
			if player[1].hand[choice+1] then
				choice+=1
			end
		end
		
	end
end
	
function _draw()
	cls(1)
	drawgrid()
	drawcreatures()
	if player[1].hand then
		cardhelp(player[1].hand[choice])
	end
end

-->8
-- draw functions
function drawgrid()
	-- visual padding
	xpad=8
	ypad=8
	for x=1,gridsize do
		for y=1,gridsize do
			if y==1 then
				pal(6,8)
			elseif y==gridsize then
				pal(6,12)
			end
			rect(xpad+(16*x),ypad+(16*y),xpad+(16*x)+16,ypad+(16*y)+16,6)
			pal()
		end
	end
	line(xpad+16,ypad+(16*gridsize),xpad+(16*gridsize)+16,ypad+(16*gridsize),6)
end

function drawcreatures()
	for x=1,gridsize do
		for y=1,gridsize do
			if	grid[x][y].sprt then
				sspr(
					grid[x][y].sprt.x1,
					grid[x][y].sprt.y1,
					grid[x][y].sprt.x2,
					grid[x][y].sprt.y2,
					x*16-3,
					y*16-4
				)
			end
		end
	end
end

function cardhelp(card)
	if card then
		text = card.name		
	 print(text, centred(text),5,7)
	 text = "⬅️ atk:"..card.atk.."|def:"..card.def.." ➡️  "		
	 print(text, centred(text),15,7)
	 print(choice.."/"..#player[1].hand,0,0,7)
	end
end

function centred(text)
	return 64-#text*2
end
-->8
-- logic stuff

-- card draw
function card_draw(p)
	add(p.hand,rnd(card_list))
end




__gfx__
06666000066660070000000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f66f0000f66f007006666000f66f00c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f5f50000f5f500700f66f000f5f5004000000000000000000700700000000000000000000000000000000000000000000000000000000000000000000000000
0ffff0000ffff04400f5f5000ffff004000000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000
646666006466666f00ffff006a66966f000000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000
644666006446600464466666649a6000000000000000000000700700000000000000000000000000000000000000000000000000000000000000000000000000
f6446f00f644600066446666f6446000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0664400006644000f664466f06644000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06664000066640000666446006664000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06006000060060000666644006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06006000060060000060060006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
