require("libs.DrawManager3D")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Hotkey", "M", config.TYPE_HOTKEY)
config:Load()

toggleKey = config.Hotkey

local Play = false

local rec1 = drawMgr3D:CreateRect(Vector(-2272,1792,0), Vector(0,0,0), Vector2D(0,0), Vector2D(30,30), 0x000000ff, drawMgr:GetTextureId("NyanUI/other/fav_heart"))
local rec2 = drawMgr3D:CreateRect(Vector(3000,-2450,0), Vector(0,0,0), Vector2D(0,0), Vector2D(30,30), 0x000000ff, drawMgr:GetTextureId("NyanUI/other/fav_heart"))

function Key(msg,code)
	if msg ~= KEY_UP and code == toggleKey and not client.chat then
		if not play then
			play = true
			rec1.visible = true
			rec2.visible = true
			return true
		else
			play = false
			rec1.visible = false
			rec2.visible = false
			return true
		end
	end
end

function Tick(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero() if not me then return end
	
	local runes = entityList:GetEntities(function (ent) return ent.classId==CDOTA_Item_Rune and GetDistance2D(ent,me) < 200 end)[1]	

	if play and runes then 
		entityList:GetMyPlayer():Select(me)
		entityList:GetMyPlayer():TakeRune(runes)	
	end
end


function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			play = true
			script:RegisterEvent(EVENT_KEY,Key)
			script:RegisterEvent(EVENT_TICK,Tick)
			script:UnregisterEvent(Load)
		end
	end
end

function Close()
	collectgarbage("collect")
	if play then
		play = false
		rec1.visible = false
		rec2.visible = false
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,Close)
