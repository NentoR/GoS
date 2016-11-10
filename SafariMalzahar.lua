if GetObjectName(GetMyHero()) ~= "Malzahar" then return end

local ver = "0.1"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat("New version found! " .. data)
        PrintChat("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/NentoR/GoS/master/SafariMalzahar.lua", SCRIPT_PATH .. "SafariMalzahar.lua", function() PrintChat("Update Complete, please 2x F6!") return end)
    else
        PrintChat("No updates found!")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/NentoR/GoS/master/SafariMalzahar.version", AutoUpdate)

--require("DeftLib")
require("ChallengerCommon")
require("DamageLib")

Config = MenuConfig("Malzahar", "Safari Malzahar")


Config:SubMenu("Combo", "Combo")

Config.Combo:Boolean("Q", "Use Q", true)
Config.Combo:Boolean("W", "Use W", true)
Config.Combo:Boolean("E", "Use E", true)
Config.Combo:Boolean("R", "Use R", true)
Config.Combo:Boolean("NoAA", "Don't AA while doing Combo", false)

Config:SubMenu("Harass", "Harass")

Config.Harass:Boolean("AutoHarass", "Auto Harass Enabled ?", true)
Config.Harass:Boolean("AutoHarassE", "Auto Harass with E", true)
Config.Harass:Boolean("AutoHarassQ", "Auto Harass with Q", false)
Config.Harass:Slider("MinimumMana", "Minimum Mana %", 30, 0, 100, 1)

Config:SubMenu("LaneClear", "LaneClear")

Config.LaneClear:Boolean("LCE", "Use E to LaneClear", true)
Config.LaneClear:Boolean("LCQ", "Use Q to LaneClear", false)
Config.LaneClear:Boolean("LCW", "Use W to LaneClear", true)
Config.LaneClear:Slider("LCMMFQ", "LaneClear Minimum Minions for Q", 2, 0, 6, 1)
Config.LaneClear:Slider("LCMMFE", "LaneClear Minimum Minions for E", 2, 0, 6, 1)
Config.LaneClear:Slider("MEMANA", "Minimum E Mana %", 30, 0, 100, 1)
Config.LaneClear:Slider("MQMANA", "Minimum Q Mana %", 30, 0, 100, 1)
Config.LaneClear:Slider("MWMANA", "Minimum W Mana %", 30, 0, 100, 1)

Config:SubMenu("KS", "KillSteal")

Config.KS:Boolean("KSQ", "Kill Steal with Q", true)
Config.KS:Boolean("KSE", "Kill Steal with E", true)

--[[Config:SubMenu("Skins", "SkinChanger")

Config.Skins:Boolean("SC", "Use Skin Changer", true)
Config.Skins:Slider("SCC", "Choose skin", 0, 0, 6, 1) ]]

--[[Config:SubMenu("Turret", "Target Under Turret")

Config.Turret:Boolean("TT", "If target under ally turret cast R", true) ]]

Config:SubMenu("Interrupter", "Interrupter")

Config.Interrupter:Boolean("IE", "Enable Interrupter for Q ?", true)

Config:SubMenu("Draws", "Drawings")

Config.Draws:Boolean("DRQ", "Draw Q range", true)
Config.Draws:Boolean("DRW", "Draw W range", true)
Config.Draws:Boolean("DRE", "Draw E range", true)
Config.Draws:Boolean("DRR", "Draw R range", true)


--local MalzaharQ = { delay = 750, range = 900, radius =  85,  speed = math.huge };
--local PredQ = GetLinearAOEPrediction(target, MalzaharQ)


Ranges = { Q = 900, W = 450, E = 650, R = 700 };

local QDMG = 70 + 40 * GetCastLevel(myHero, _Q) + GetBonusAP(myHero) * 0.7
local WDMG = 30 + 2 * GetCastLevel(myHero, _W) * GetBonusDmg(myHero) * 0.4

DACR.movementEnabled = true 
DACR.attacksEnabled = true

local OnUlti = false

OnLoad(function()
	PrintChat("[Safari Malzahar] Loaded successfully")

		Interrupter(target)
end)

OnTick(function()

	target = GetCurrentTarget()

	--print(IsUnderTower(myHero, MINION_ALLY))

	Combo(target)
	CastR(target)
	LaneClear()
	Harass(target)
	KillSteal(target)
	--UnderTurretUnit(target)

	if Config.Combo.NoAA:Value() then
		DACR.attacksEnabled = false
	end

end)

function Combo(target)
	if DACR:Mode() == "Combo" and OnUlti == false then
		if (GetCurrentMana(myHero) > GetCastMana(myHero, _E, GetCastLevel(myHero, _E))) and (GetCurrentMana(myHero) > GetCastMana(myHero, _W, GetCastLevel(myHero, _W))) and (GetCurrentMana(myHero) > GetCastMana(myHero, _R, GetCastLevel(myHero, _R))) then
			if Config.Combo.Q:Value() and Ready(_Q) and (GetCurrentMana(myHero) > GetCastMana(myHero, _Q, GetCastLevel(myHero, _Q))) and ValidTarget(target, Ranges.Q) then
				CastSkillShot(_Q, target)
			end
			if Config.Combo.W:Value() and Ready(_W) and ValidTarget(target, Ranges.W) then
				CastSkillShot(_W, target)
			end
			if Config.Combo.E:Value() and Ready(_E) and ValidTarget(target, Ranges.E) then
				CastTargetSpell(target, _E)
			end
			--if Ready(_R) and not Ready(_W) and not Ready(_E) and target ~= nil and ValidTarget(target, Ranges.R) then
				--CastTargetSpell(target, _R)

			else 
				if Ready(_E) and ValidTarget(target, ERange) then
					CastTargetSpell(target, _E)
				end
				if Ready(_Q) and GetCurrentMana(myHero) > GetCastMana(myHero, _Q, levelall) and ValidTarget(target, Ranges.Q) then
					CastSkillShot(_Q, target)
				end
				if Ready(_W) and GetCurrentMana(myHero) > GetCastMana(myHero, _W, levelall) and ValidTarget(target, Ranges.W) then
					CastSkillShot(_W, target)
			end
		end
	end
end

function CastR(target)
		if DACR:Mode() == "Combo" then

		if Ready(_R) and not Ready(_W) and not Ready(_E) and target ~= nil and ValidTarget(target, Ranges.R) then
			CastTargetSpell(target, _R)
		end
	end
end

--[[OnProcessSpell(function(unit,spell)
	if unit.isMe and spell.Name == "MalzaharR" then
		OnUlti = true
		DACR.movementEnabled = false
		DACR.attacksEnabled = false 
		PrintChat("Ult is working")
	end
end)

OnProcessSpellComplete(function(unit,spell)
	if unit.isMe and spell.Name == "MalzaharR" then
		OnUlti = false 
		DACR.movementEnabled = true
		DACR.attacksEnabled = true 
		PrintChat("Ult finished")
	end
end) ]]


OnUpdateBuff(function(unit, buff)
    if not unit or not buff then return end
    if buff.Name == "MalzaharR" then
        OnUlti = true
        print("R on process")
        DACR.movementEnabled = false 
        DACR.attacksEnabled = false 
    end
end)

OnRemoveBuff(function(unit, buff)
    if not unit or not buff then return end
    if buff.Name == "MalzaharR" then
        OnUlti = false
        print("R not on process")
        DACR.movementEnabled = true 
        DACR.attacksEnabled = true 
    end
end)

function LaneClear()
		if DACR:Mode() == "LaneClear" then
			for _, minion in pairs(minionManager.objects) do
				if Config.LaneClear.LCW:Value() and Ready(_W) and ValidTarget(minion, Ranges.W) then
					if GetCurrentHP(minion) < WDMG and Config.LaneClear.MWMANA:Value() <= GetPercentMP(myHero) then
						CastSkillShot(_W, minion)
					end
				end
				if Config.LaneClear.LCQ:Value() and Ready(_Q) and ValidTarget(minion, Ranges.Q) then
					if GetCurrentHP(minion) < QDMG and GetTeam(minion) >= Config.LaneClear.LCMMFQ:Value() and GetPercentMP(myHero) >= Config.LaneClear.MQMANA:Value() then
						CastSkillShot(_Q, minion)
					end
				end
				if Config.LaneClear.LCE:Value() and Ready(_E) and ValidTarget(minion, Ranges.E) and GetPercentMP(myHero) >= Config.LaneClear.MEMANA:Value() then
					if GetTeam(minion) >= Config.LaneClear.LCMMFE:Value() then
					CastTargetSpell(minion, _E)
				end
			end
		end
	end
end

function Harass(target)
	if DACR:Mode() == "Harass" then
		if Config.Harass.AutoHarass:Value() then
			if Config.Harass.AutoHarassQ:Value() and Ready(_Q) and ValidTarget(target, Ranges.Q) then
				CastSkillShot(_Q, target)
			end
			if Config.Harass.AutoHarassE:Value() and Ready(_E) and ValidTarget(target, Ranges.E) then
				CastTargetSpell(_E, target)
			end
		end
	end
end

function KillSteal(target)
	for _, Killable in pairs(GetEnemyHeroes()) do
		if Config.KS.KSQ:Value() and Ready(_Q) and ValidTarget(target, Ranges.Q) then
			if GetCurrentHP(target) < getdmg("Q", target) then
				CastSkillShot(_Q, target)
			end
		end
		if Config.KS.KSE:Value() and Ready(_E) and ValidTarget(target, Ranges.E) then
			if GetCurrentHP(target) < getdmg("E", target) then
				CastTargetSpell(target, _E)
			end
		end
	end
end 

--[[function UnderTurretUnit(target)
	if Config.Turret.TT:Value() and Ready(_R) then
		if IsUnderTower(target, MINION_ALLY) then
			CastTargetSpell(target, _R)
		end
	end
end ]]

function Interrupter(target)
	ChallengerCommon.Interrupter(Config.Interrupter, function(unit, spell)
		if Config.Interrupter.IE:Value() and unit.team ~= myHero.team and ValidTarget(target, Ranges.Q) then
			CastTargetSpell(unit, _Q)
			PrintChat("Interrupter Wokring")
		end
	end)
end
