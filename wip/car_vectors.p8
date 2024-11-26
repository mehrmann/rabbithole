pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
raw="415,341,350,342,334,314,306,305,304,248,307,230,324,225,366,225,377,247,392,255,406,246,418,226,460,224,480,234,480,273,499,280,541,281,552,301,552,328,536,343,486,343,402,343,"
pd=split(raw)
local pw=32

function _init()
	local i=1
	while i<#pd do
		add(path,{x=pd[i],y=pd[i+1]})
		i+=2
	end
	dbg={}
end

function _update60()
	if (btn(⬅️)) car.angle-=0.01
	if (btn(➡️)) car.angle+=0.01
	if (btn(⬆️)) then 
		car.pos.x+=sin(car.angle)*0.5
		car.pos.y+=cos(car.angle)*0.5
	elseif (btn(⬇️)) then 
		car.pos.x-=sin(car.angle)*0.5
		car.pos.y-=cos(car.angle)*0.5
	end
	
	
end

function _draw()
	cls(3)
	camera(car.pos.x-63,car.pos.y-63)
	map()
		
	if #path>1 then
		for i = 1, #path - 1 do
	  local a, b = path[i], path[i + 1]
	  drawsegment(a,b,pw,12)
	 end
	end
	
	drawsegment(path[#path],path[1],pw,12)
	
	car:draw()
	
	local dir={
		x=sin(car.angle) * 8,
		y=cos(car.angle) * 8
	}
	
	local future=vadd(car.pos, dir)
	
	vline(car.pos, future, 14)
	
	local mindist,minindex=3000,1
	for i = 1, #path-1 do
	 local q, w = path[i], path[i + 1]
	 
	 local a=vsub(w,q)
	 local b=vsub(future,q)
	 if vmag(b)>0 and vmag(b)<64 then
		 local t=vdot(a,b)/vdot(a,a)
		 if t>=-0.2 and t<=1.2 then
		 	local proj=vproj(b,a)
		 	local c=vsub(future, vadd(q,proj))
		 	local dist=vmag(c)
		 	vline(vadd(q,proj), future, 6)

		 	if mindist>0 and dist<mindist then
		 		mindist=dist
		 		minindex=i
		 	end	
		 end
		end
	end
	
	if (minindex>0) then
		local q,w=path[minindex],path[minindex+1]
		local a=vsub(w,q)
		local b=vsub(future,q)
		local proj=vproj(b,a)
		local target=vadd(q,proj)
		vline(target, future, 11)
		local aim=vsub(proj, car.pos)
		local cross=dir.x/8*target.y - dir.y/8*target.x
		dbg[1]=car.pos.x
		dbg[2]=car.pos.y
		dbg[3]=car.angle
		dbg[4]=cross
	end

	camera()
	for d in all(dbg) do
		print(d)
	end
end

function drawsegment(a,b,w,col)
 local vx=b.x-a.x
	local vy=b.y-a.y
 local l=sqrt(vx*vx+vy*vy)
 local ox=vy/l * w/2
 local oy=vx/l * w/2
 
 line(a.x, a.y, b.x, b.y, col)
	line(a.x-ox,a.y+oy,a.x+ox,a.y-oy,col)
	line(b.x-ox,b.y+oy,b.x+ox,b.y-oy,col)
	line(a.x-ox,a.y+oy,b.x-ox,b.y+oy,col)
	line(a.x+ox,a.y-oy,b.x+ox,b.y-oy,col)
	circ(b.x,b.y,w/2)
end 

-->8
-- car physics
global=_ENV

class=setmetatable({
	new=function(self, tbl)
		tbl=tbl or {}
		setmetatable(tbl,{
			__index=self
		})
		return tbl
	end,
},{__index=_ENV})

car = class:new({
	pos={x=340,y=340},
	vel={x=0,y=0},
	drag=0.9,
	angle=0.5,
	angvel=0.0,
	angdrag=0.8,
	power=0.1,
	turnspeed=0.003,
	
	update=function(_ENV)
		pos.x+=vel.x
		pos.y+=vel.y
		vel.x*=drag
		vel.y*=drag
		angle+=angvel
		angvel*=angdrag
		
		drift=btn(🅾️)
		
		if btn(❎) then
			vel.x+=sin(angle) * power
			vel.y+=cos(angle) * power
		end
		
		if btn(⬅️) then
			angvel-=turnspeed
		elseif btn(➡️) then
			angvel+=turnspeed
		end
	end,
	
	draw=function(_ENV)
		pd_rotate(flr(pos.x),flr(pos.y),flr(angle*32)/32,.5,.5,1.4,false,1.0)
	end,
})
	
-->8
-- util

function vadd(a,b) 
	return {
		x=a.x+b.x,
		y=a.y+b.y
	}
end

function vsub(a,b) 
	return {
		x=a.x-b.x,
		y=a.y-b.y
	}
end

function vmag(a)
	return sqrt((a.x*a.x) + (a.y*a.y))
end

function vmul(a,s)
	return {x=a.x*s,y=a.y*s}
end

function vdot(a,b)
	return (a.x * b.x) + (a.y * b.y)
end

function vproj(a,b)
	a=vmul(a, 0.01)
	b=vmul(b, 0.01)
	local dp=vdot(a,b)
	local mag2_sq=vdot(b,b)
	local scalar=dp/mag2_sq
	printh("a:"..a.x.."/"..a.y.." vdot(a, b):"..dp.." vdot(b, b):"..mag2_sq)
	return {
		x=scalar*b.x*100,
		y=scalar*b.y*100
	}
end

function vline(a,b,col)
	line(a.x,a.y, b.x,b.y, col)
end

function pd_rotate(x,y,rot,mx,my,w,flip,scale)
  scale=scale or 1
  w*=scale*4
  local cs, ss = cos(rot)*.125/scale,sin(rot)*.125/scale
  local sx, sy = mx+cs*-w, my+ss*-w
  local hx,halfw = flip and -w or w,-w
  for py=y-w, y+w do
    if (not(o and (rot<.25 or rot >.75) and py>y+4)) tline(x-hx, py, x+hx, py, sx-ss*halfw, sy+cs*halfw, cs, ss)
    halfw+=1
  end
end
-->8
path={}
__gfx__
00000000012cc21033333333433333330000000000000000000000000088888888888800000000000000000000000000000a0000555555550000000000000000
000000000167761033333333333333340000000000000000000000888888888888888888880000000000000000000000000a0000555555550000000000000000
0070070001cccc1033333333333333330000000000000000000888888855555555555588888880000000000000000000000a0000555555550000000000000000
0007700000cccc0033333333333333330000000000000000088888555555555555555555558888800000000000000000aaa0aaa0555555550000000000000000
0007700000cccc0033333333333433330000000000000008888855555555555555555555555588888000000000000000000a0000555555550000000000000000
007007000177771033333333333333330000000000000088855555555555555555555555555555588800000000000000000a0000555555550000000000000000
0000000001cccc1033333333433333430000000000000888555555555555555555555555555555558880000000000000000a0000555555880000000000000000
0000000001fccf103333333333333333000000000008885555555555555555555555555555555555558880000000000000000000555555880000000000000000
00000000018cc8105555555500000000000000000088855500000000000000000000000000000000555888000000000000000000555555880000000000000000
00000000056776505555555500000000000000000888555500000000000000000000000000000000555588800000000000000000555555880000000000000000
0000000001cccc105555555500000000000000008885555500000000000000000000000000000000555558880000000000000000555555880000000000000000
0000000000cccc005555555500000000000000088855555500000000000000000000000000000000555555888000000000000000555555880000000000000000
0000000000cccc005555555500000000000000088555555500000000000000000000000000000000555555588000000000000000555555880000000000000000
00000000017777105555555500000000000000885555555500000000000000000000000000000000555555558800000000000000555555880000000000000000
0000000005cccc505555555500000000000008855555555500000000000000000000000000000000555555555880000000000000555555880000000000000000
0000000001fccf105555555500000000000088855555555500000000000000000000000000000000555555555888000000000000555555880000000000000000
88888888885555555555555555555555000088550000000000000000000000000000000000000000000000005588000000000000000000000000000000000000
88888888885555555555555555555555000885550000000000000000000000000000000000000000000000005558800000000000000000000000000000000000
55555555885555555555555555555555000885550000000000000000000000000000000000000000000000005558800000000000000000000000000000000000
55555555885555555555555555555555008885550000000000000000000000000000000000000000000000005558880000000000000000000000000000000000
55555555885555555555555555555555008855550000000000000000000000000000000000000000000000005555880000000000000000000000000000000000
55555555885555555555555555555555008855550000000000000000000000000000000000000000000000005555880000000000000000000000000000000000
55555555885555555555555885555555088555550000000000000000000000000000000000000000000000005555588000000000000000000000000000000000
55555555885555555555558888555555088555550000000000000000000000000000000000000000000000005555588000000000000000000000000000000000
55555555555555885555558888555555088555550000000000000000000000000000000000000000000000005555588000000000000000000000000000000000
55555555555555885555555885555555088555550000000000000000000000000000000000000000000000005555588000000000000000000000000000000000
55555555555555885555555555555555885555550000000000000000000000000000000000000000000000005555558800000000000000000000000000000000
55555555555555885555555555555555885555550000000000000000000000000000000000000000000000005555558800000000000000000000000000000000
55555555555555885555555555555555885555550000000000000000000000000000000000000000000000005555558800000000000000000000000000000000
55555555555555885555555555555555885555550000000000000000000000000000000000000000000000005555558800000000000000000000000000000000
88888888555555885555555555555555885555550000000000000000000000000000000000000000000000005555558800000000000000000000000000000000
88888888555555885555555555555555885555550000000000000000000000000000000000000000000000005555558800000000000000000000000000000000
88555555000000000000000000000000000000000000000000000000555555880000000000000000000000000000000000000000000000000000000000000000
88555555000000000000000000000000000000000000000000000000555555880000000000000000000000000000000000000000000000000000000000000000
88555555000000000000000000000000000000000000000000000000555555880000000000000000000000000000000000000000000000000000000000000000
88555555000000000000000000000000000000000000000000000000555555880000000000000000000000000000000000000000000000000000000000000000
88555555000000000000000000000000000000000000000000000000555555880000000000000000000000000000000000000000000000000000000000000000
88555555000000000000000000000000000000000000000000000000555555880000000000000000000000000000000000000000000000000000000000000000
08855555000000000000000000000000000000000000000000000000555558800000000000000000000000000000000000000000000000000000000000000000
08855555000000000000000000000000000000000000000000000000555558800000000000000000000000000000000000000000000000000000000000000000
08855555000000000000000000000000000000000000000000000000555558800000000000000000000000000000000000000000000000000000000000000000
08855555000000000000000000000000000000000000000000000000555558800000000000000000000000000000000000000000000000000000000000000000
00885555000000000000000000000000000000000000000000000000555588000000000000000000000000000000000000000000000000000000000000000000
00885555000000000000000000000000000000000000000000000000555588000000000000000000000000000000000000000000000000000000000000000000
00888555000000000000000000000000000000000000000000000000555888000000000000000000000000000000000000000000000000000000000000000000
00088555000000000000000000000000000000000000000000000000555880000000000000000000000000000000000000000000000000000000000000000000
00088555000000000000000000000000000000000000000000000000555880000000000000000000000000000000000000000000000000000000000000000000
00008855000000000000000000000000000000000000000000000000558800000000000000000000000000000000000000000000000000000000000000000000
00008885555555550000000000000000000000000000000055555555588800000000000000000000000000000000000000000000000000000000000000000000
00000885555555550000000000000000000000000000000055555555588000000000000000000000000000000000000000000000000000000000000000000000
00000088555555550000000000000000000000000000000055555555880000000000000000000000000000000000000000000000000000000000000000000000
00000008855555550000000000000000000000000000000055555558800000000000000000000000000000000000000000000000000000000000000000000000
00000008885555550000000000000000000000000000000055555588800000000000000000000000000000000000000000000000000000000000000000000000
00000000888555550000000000000000000000000000000055555888000000000000000000000000000000000000000000000000000000000000000000000000
00000000088855550000000000000000000000000000000055558880000000000000000000000000000000000000000000000000000000000000000000000000
00000000008885550000000000000000000000000000000055588800000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888555555555555555555555555555555555555888000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008885555555555555555555555555555555588800000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000888555555555555555555555555555555888000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000088888555555555555555555555555888880000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888885555555555555555555588888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008888888555555555555888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000008888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000202020202020202020202020202012212113202020202006162121212166762020202020122121132020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000202020202020202020202020202012212113202020202000172737475767002030203020042121230202
0202028090a0b0202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000202020202020202020202020202012212113202020202020202020202030302020202020052121212121
2121212121a1b1202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000202020202020202020202020202012212113202020302020202020202020202020202020061621212121
212121212121b2202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020302020202012212113202020202020202020202020202020202020201727370303
030303322121b3202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202004212123028090a00020202020202020202020202020202020202020
20202012212113202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202005212121212121a1b120202020202020202020202020202020202020
20202012212113202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000002020202020202020202020202020200616212121212121b220202020202020202020202020202020202020
20202012212113202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000002020202020302020202020202020200717273703322121b320302020203020202030202020302020202020
30202012212113202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020200421212302020202020202020202020202020202020202
02020233212174202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020203020202020202020202020200521212121212121212121212121212121212121212121
21212121212175202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020200616212121212121212121212121212121212121212121
21212121216676202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020200017273703030303030303030303030303030303030303
03030347576700202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202030202020202020202020202020202020202020202020202020202020
20202020203020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020302020202020202020202020203020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202030202020202020202020
20302020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020302020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202030202020202020202020202020202020202020202020202020202020202020202030
20202020302020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202030202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020302020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202030202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202030202020202020202020202020202020302020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
30202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0405060708090a0b002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1415121212121a1b001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
241212121212122b001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
341212222312123b003000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4012123233121247000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5012121212121257002112123100000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061121212126667000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202030202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071727374757677000000000000000000000000000002020202020202020202020202020202020202020202020302020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020203020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202030202020202020202020202030202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020203020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202030202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202030202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020302020202020202020302020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202030202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020203020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202030202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202030202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020302020202020202020202020202020202020202020202020202020302020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000020202020202020202020202020204050607202020202008090a0b04050607202020202008090a00020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000020202020202020202020202020214151212121212121212121a1b14151212121212121212121a1b020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202022412121212121212121212122b2412121212121212121212122b020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202023412122230303030302312123b3412122230303030302312123b020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020202020202022112123102020202024012121212121247020202020221121231020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002020202020202020203030202022112123102020202025012121212121257030203020221121231020202020202030202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
