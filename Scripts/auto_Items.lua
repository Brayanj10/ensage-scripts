--<<Automatic: Midas, Phase boots, bottle in fountain, Magic stick and Bloodstone if low hp>>
require("libs.ScriptConfig")
require("libs.Utils")

config = ScriptConfig.new()
config:SetParameter("Quickbuy", true)
config:SetParameter("Bloodstone", true)
config:SetParameter("Bottle", true)
config:SetParameter("PhaseBoots", true)
config:SetParameter("MagicStick", true)
config:SetParameter("Midas", true)
config:Load()

enableQuickbuy = config.Quickbuy
enableBloodstone = config.Bloodstone
enableBottle = config.Bottle
enablePhaseBoots = config.PhaseBoots
enableMagicStick = config.MagicStick
enableMidas = config.Midas

local play = false

function Tick(tick)
    if not PlayingGame() or not SleepCheck() or not play then return end
    local me = entityList:GetMyHero()
	local bloodstone = me:FindItem("item_bloodstone")
	local bottle = me:FindItem("item_bottle")
	local phaseboots = me:FindItem("item_phase_boots")
	local midas = me:FindItem("item_hand_of_midas")
	local stick = me:FindItem("item_magic_stick") or me:FindItem("item_magic_wand")

	local creeps = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Neutral,controllable=false,alive=true,illusion=false})

	if me.alive and not me:IsInvisible() and not me:IsChanneling() then

		if enableQuickbuy and me.health/me.maxHealth < 0.09 then
			client:ExecuteCmd("dota_purchase_quickbuy")
		end

		if enableBloodstone and bloodstone and bloodstone:CanBeCasted() and me.health/me.maxHealth < 0.04 then
			me:CastAbility(bloodstone,me.position)
			Sleep(1000)
		end

		if enableBottle and bottle and bottle:CanBeCasted() and me:DoesHaveModifier("modifier_fountain_aura_buff") and not me:DoesHaveModifier("modifier_bottle_regeneration") and (me.health < me.maxHealth or me.mana < me.maxMana) then
			me:CastAbility(bottle)
			Sleep(1000)
		end

		if enablePhaseBoots and phaseboots and phaseboots:CanBeCasted() then
			me:CastAbility(phaseboots)
			Sleep(1000)
		end

		if enableMagicStick and stick and stick:CanBeCasted() and stick.charges > 0 and me.health/me.maxHealth < 0.3 then
			me:CastAbility(stick)
			Sleep(1000)
		end

		if enableMidas and midas and midas:CanBeCasted() then
			for _,v in ipairs(creeps) do
				if GetDistance2D(me,v) < 700 and v:CanDie() and v.maxHealth >= 950 and v.ancient == false and v.level >= 5 then
					me:CastAbility(midas,v)
					Sleep(1000)
				end
			end
		end
	end
end

function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
	end
end

function Close()
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
