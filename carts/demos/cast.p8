pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- raycasting demo
-- by zep

-- field of view
fov = 0.15 -- 0.2 = 72 degrees

-- true: to get wall patterns
-- based on distance
if (false) then
patterns={
	[0]=♥,▤,∧,✽,♥,◆,
	░,░,░,░,
	…,…,…,…
}
end

function _init()
	-- create player
	pl={}
	pl.x = 12 pl.y = 12
	pl.dx = 0 pl.dy = 0
	pl.z = 12
	pl.d = 0.25
	pl.dz = 0
	pl.jetpack=false
	
	-- map
	for y=0,31 do
		for x=0,31 do
			mset(x,y,mget(x,y)*3)
		end
	end
	
end

-- map z
function mz(x,y)
	return 16-mget(x,y)*0.125
end

function _update()
	
	-- moving walls
	
	for x=10,18 do
		for y=26,28 do
			mset(x,y,34+cos(t()/4+x/14)*19)
		end
	end
	
	-- control player
	
	local dx=0
	local dy=0

	if (btn(❎)) then
		-- strafe
		if (btn(⬅️)) dx-=1
		if (btn(➡️)) dx+=1
	else
		-- turn
		if (btn(⬅️)) pl.d+=0.02
		if (btn(➡️)) pl.d-=0.02
	end
	
	-- forwards / backwards
	if (btn(⬆️)) dy+= 1
	if (btn(⬇️)) dy-= 1
	
	spd = sqrt(dx*dx+dy*dy)
	if (spd) then
	
		spd = 0.1 / spd
		dx *= spd
		dy *= spd
		
		pl.dx += cos(pl.d-0.25) * dx
		pl.dy += sin(pl.d-0.25) * dx
		pl.dx += cos(pl.d+0.00) * dy
		pl.dy += sin(pl.d+0.00) * dy
	
	end
	
	local q = pl.z - 0.6
	if (mz(pl.x+pl.dx,pl.y) > q)
	then pl.x += pl.dx end
	if (mz(pl.x,pl.y+pl.dy) > q)
	then pl.y += pl.dy end
	
	-- friction
	pl.dx *= 0.6
	pl.dy *= 0.6
	
	-- z means player feet
	if (pl.z >= mz(pl.x,pl.y) and pl.dz >=0) then
		pl.z = mz(pl.x,pl.y)
		pl.dz = 0
	else
		pl.dz=pl.dz+0.01
		pl.z =pl.z + pl.dz
	end

	-- jetpack / jump when standing
	if (btn(4)) then 
		if (pl.jetpack or 
					 mz(pl.x,pl.y) < pl.z+0.1)
		then
			pl.dz=-0.15
		end
	end

end

function draw_3d()
	local celz0
	local col
	
	-- calculate view plane
	
	local v={}
	v.x0 = cos(pl.d+fov/2) 
	v.y0 = sin(pl.d+fov/2)
	v.x1 = cos(pl.d-fov/2)
	v.y1 = sin(pl.d-fov/2)
	
	
	for sx=0,127 do
	
		-- make all of these local
		-- for speed
		local sy=127
	
		-- camera based on player pos
		local x=pl.x
		local y=pl.y
		-- (player eye 1.5 units high)
		local z=pl.z-1.5

		local ix=flr(x)
		local iy=flr(y)
		local tdist=0
		local col=mget(ix,iy)
		local celz=16-col*0.125
		
		-- calc cast vector
		local dist_x, dist_y,vx,vy
		local last_dir
		local t=sx/127
		
		vx = v.x0 * (1-t) + v.x1 * t
		vy = v.y0 * (1-t) + v.y1 * t
		local dir_x = sgn(vx)
		local dir_y = sgn(vy)
		local skip_x = 1/abs(vx)
		local skip_y = 1/abs(vy)
		
		if (vx > 0) then
			dist_x = 1-(x%1) else
			dist_x =   (x%1)
		end
		if (vy > 0) then
			dist_y = 1-(y%1) else
			dist_y =   (y%1)
		end
		
		dist_x = dist_x * skip_x
		dist_y = dist_y * skip_y
		
		-- start skipping
		local skip=true
		
		while (skip) do
			
			if (dist_x < dist_y) then
				ix=ix+dir_x
				last_dir = 0
				dist_y = dist_y - dist_x
				tdist = tdist + dist_x
				dist_x = skip_x
			else
				iy=iy+dir_y
				last_dir = 1
				dist_x = dist_x - dist_y
				tdist = tdist + dist_y
				dist_y = skip_y
			end
			
			-- prev cel properties
			col0=col
			celz0=celz
			
			-- new cel properties
			col=mget(ix,iy)
			
			--celz=mz(ix,iy) 
			celz=16-col*0.125 -- inlined for speed
			
-- print(ix.." "..iy.." "..col)
			
			if (col==72) then skip=false end
			
			--discard close hits
			if (tdist > 0.05) then
			-- screen space
			
			local sy1 = celz0-z
			sy1 = (sy1 * 64)/tdist
			sy1 = sy1 + 64 -- horizon 
			
			-- draw ground to new point
			
			if (sy1 < sy) then
				
				line(sx,sy1-1,sx,sy,
					sget((celz0*2)%16,8))
					
				sy=sy1
			end
			
			-- draw wall if higher
			
			if (celz < celz0) then
				local sy1 = celz-z
				
				
				sy1 = (sy1 * 64)/tdist
				sy1 = sy1 + 64 -- horizon 
				if (sy1 < sy) then
					
					local wcol = last_dir*-6+13
					if (not skip) then
						wcol = last_dir+5
					end
					if (patterns) then
						fillp(patterns[flr(tdist/3)%8]-0.5)
						wcol=103+last_dir*102
					end

					line(sx,sy1-1,sx,sy,
					 wcol)
					 sy=sy1
					
					fillp()
				end
			end
		end   
		end -- skipping
	end -- sx

	cursor(0,0) color(7)
	print("cpu:"..flr(stat(1)*100).."%",1,1)
end


function _draw()
	cls()
	
	-- to do: sky? stars?
	rectfill(0,0,127,127,12)
	draw_3d()
	-- draw map
	if (false) then
		mapdraw(0,0,0,0,32,32)
		pset(pl.x*8,pl.y*8,12)
		pset(pl.x*8+cos(pl.d)*2,pl.y*8+sin(pl.d)*2,13)
	end
end




__gfx__
00000000111111112222222233333333444444445555555566666666777777776666666699999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777776666666699999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00700700111111112222222233333333444444445555555566666666777777776666666699999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00077000111111112222222233333333444444445555555566666666777777776666666699999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00077000111111112222222233333333444444445555555566666666777777776666666699999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00700700111111112222222233333333444444445555555566666666777777776666666699999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777776666666699999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777776666666699999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
32222228a9e49aeb00000000000000004444444400000000000000000000000088888888000000000000000000000000000000000000000000000000ffffffff
000000000000000000000000000000004444444400000000000000000000000088888888000000000000000000000000000000000000000000000000f888888f
0000000000000000000000000000000044ffff4400000000000000000000000088ffff88000000000000000000000000000000000000000000000000f8ffff8f
0000000000000000000000000000000044ffff4400000000000000000000000088ffff88000000000000000000000000000000000000000000000000f8ffff8f
0000000000000000000000000000000044ffff4400000000000000000000000088ffff88000000000000000000000000000000000000000000000000f8ffff8f
0000000000000000000000000000000044ffff4400000000000000000000000088ffff88000000000000000000000000000000000000000000000000f8ffff8f
000000000000000000000000000000004444444400000000000000000000000088888888000000000000000000000000000000000000000000000000f888888f
000000000000000000000000000000004444444400000000000000000000000088888888000000000000000000000000000000000000000000000000ffffffff
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666
cc77c777c7c7ccccc777c7c7c7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666
c7ccc7c7c7c7cc7cc7ccc7c7ccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666
c7ccc777c7c7ccccc777c777cc7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666
c7ccc7ccc7c7cc7cccc7ccc7c7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666
cc77c7cccc77ccccc777ccc7c7c7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666666666666
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666
555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666666666666666
55555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666666666666
5555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666666666666666666
55555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666666666666666
5555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666666666666
555555555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666666666666666666
55555555555555555555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666666666666666
555555555555555555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666666666666666666666
55555555555555555555555555555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666666666666666666
5555555555555555555555555555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccc6666666667d666666666666666666666666
555555555555555555555555555555555555555555555555555ccccccccccccccccccccccccccccccccccccccccc66666666777ddddd66666666666666666666
5555555555555555555555555555555555555555555555555555555ccccccccccccccccccccccccccccccccccc6666666677777dddddddd66666666666666666
555555555555555555555555555555555555555555555555555555555555cccccccccccccccccccccccccccc666666666777777ddddddddddd66666666666666
55555555555555555555555555555555555555555555555555555555555555555cccccccccccccccccccccc6666666677777777dddddddddddddd66666666666
5555555555555555555555555555555555555555555555555555555555555555555555ccccccccccccccc666666667777777777dddddddddddddddddd6666666
55555555555555555555555555555555555555555555555555555555555555555555555555ccccccccc66666666777777777777ddddddddddddddddddddd6666
5555555555555555555555555555555555555555555555555555555555555555555555555555555ccc666666667777777777777dddddddddddddddddddddddd6
5555555555555555555555555555555555555555555555555555555555555555555555555555555556666666777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555556666677777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555556667777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555556677777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555557777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555577777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555577777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555557777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555557777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555557777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555557777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555dddddddddd55555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777dddddddddddddddddddddd77777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777dddddddddddddddddddddd77777777777777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777ddddddddddddddddddddddddd777777777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777ddddddddddddddddddddddddd777777777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777ddddddddddddddddddddddddd777777777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777777ddddddddddddddddddddddddddd7777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777777ddddddddddddddddddddddddddd7777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777777ddddddddddddddddddddddddddd7777777777777777777777777777777777ddddddddddddddddddddddddd
55555555555555555555555555555555557777777777aaaaaaaaaaaaaaaaaaaaddddddddddddd77777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777ddddddddddddddddddddddddddddddd77777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777ddddddddddddddddddddddddddddddd77777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777ddddddddddddddddddddddddddddddd77777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777ddddddddddddddddddeeeeeeeeeeeeeeeee7777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddd7777777777777777ddddddddddddddddddddddddd
5555555555555555555333333333333333377777777777777eeeeeeeeeeeeeddddddddddddddddddddddddd7777777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333377777777777777dddddddddddddddddddddddddddddddddddd7777777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333337777777777777dddddddddddddddddddddddddddddddddddd7777777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333333777777777777dddddddddddddddddddddddddddddddddddd7777777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333333337777777777ddddddddddddddddddddddddddbbbbbbbbbbbbbb777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333333333777777777dddddddddddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777ddddddddddddddddddddddddd
333333333333333333333333333333333333333333337777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7ddddddddddddddddddddddddd
33333333333333333333333333333333333333333333377777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddddddddddddddddddddddddddddddd
3333333333333333333333333333333333333333333333777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddddddddddddddddddddddddddddddddddddddddd
333333333333333333333333333333333333333333333333777777777bbbbbbbbbbbbbbbbbbbdddddddddddddddddddddddddddddddddddddddddddddd333333
33333333333333333333333333333333333333333333333337777777777bbbbbbbddddddddddddddddddddddddddddddddddddddddddddddddd3333333333333
333333333333333333333333333333333333333333333333337777777777dddddddddddddddddddddddddddddddddddddddddddddddd33333333333333333333
333333333333333333333333333333333333333333333333333377777777ddddddddddddddddddddddddddddddddddddddddd333333333333333333333333333
333333333333333333333333333333333333333333333333333337777777dddddddddddddddddddddddddddddddddd3333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333377777dddddddddddddddddddddddddd333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333337777ddddddddddddddddddd3333333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333333777dddddddddddd33333333333333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333333337ddddd333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333

__map__
1818181818181818181818181818181818181818181818181818181818181818000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060708090a0b000000000000000001000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060708090a0b000100000000000101010000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060c0c0c0c0c000000000404000001000005000000000c030303030c0018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060c0c0c0c0c000000000404000000000505050000000303030303030018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060504030201000000000000000000000005000000000303030303030018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060504030201000000000000000000000000000000000303030303030018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000303030303030018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000c030303030c0018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000001000001000000000000000000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000010000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000001000001000000000001000100000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000010000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800140d0d01010d0d1400000000000000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d02020d0d0d00000000000000000000000001000102040402010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d03030d0d0d00000000000000000000000000000102050502010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d04040d0d0d00000000000000000000000000000102060602010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d05050d0d0d00000000000000000000000000000102070702010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0606060606060d00000000000000000000000000000102080802010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0606060606060d00000000000000000000000000000102090902010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0606060606060d000000000000000000000000000001020a0a02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0606060606060d000000000000000000000000000001020b0b02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18001406060606060614000000000000000000000000000001020c0c02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d07070d0d0d0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d08080d0d0d0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d09090a0b0c0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d09090a0b0c0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d0d0d0d0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1818181818181818181818181818181818181818181818181818181818181818000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144

