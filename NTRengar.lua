
if GetObjectName(GetMyHero()) ~= "Rengar" then return end

require("DamageLib")
require("OpenPredict")

local ver = 0.1

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat("New version found! " .. data)
        PrintChat("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/NentoR/GoS/master/NTRengar.lua", SCRIPT_PATH .. "NTRengar.lua", function() PrintChat("Update Complete, please 2x F6!") return end)
    else
        PrintChat("No updates found!")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/NentoR/GoS/master/NTRengar.version", AutoUpdate)

if FileExist(COMMON_PATH.."MixLib.lua") then 
	require('MixLib') 
	else 
		PrintChat("MixLib not found. Please wait for download.") 

		DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/GoS/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!")

		end) 
	return end


Config = MenuConfig("Rengar", "NT SERIES: Rengar")

Config:SubMenu("Combo", "C.O.M.B.O")
--
Config.Combo:Boolean("E", "1. Use E", true)
Config.Combo:Boolean("Q", "2. Use Q", true)
Config.Combo:Boolean("W", "3. Use W", true)
Config.Combo:DropDown("PR", "Priority", 1, {"E", "W", "Q"})

Config:SubMenu("LC", "LaneClear")
--
Config.LC:Boolean("LCQ", "Use Q", true)
Config.LC:Boolean("LCE", "Use E", true)

Config:SubMenu("JC", "JungleClear")
--
Config.JC:Boolean("JCQ", "Use Q", true)
Config.JC:Boolean("JCW", "Use W", true)
Config.JC:Boolean("JCE", "Use E", true)

Config:SubMenu("Misc", "Misc")
--
Config.Misc:Boolean("HT", "Use Hydra/Tiamat", true)

local Melee = 125
local QRange = 450
local WRange = 500
local ERange = 1000

-- Rengar R buff name = RengarR
-- Rengar Q buff names = RengarQ and RengarQ2
-- Rengar W buff name = RengarW
-- Rengar E buff name = RengarE

local OnBuff = false 

local PredMyE = { delay = 0.250, speed = 1500, radius = 70, range = 1000 }

OnTick(function()

	local target = GetCurrentTarget()

	Combo(target)
	LaneClear()
	JungleClear()
end)

OnUpdateBuff(function(unit,buff)
	if unit.isMe and buff.Name:lower() == "rengarr" then
		OnBuff = true 
	end
end)

OnRemoveBuff(function(unit,buff)
	if unit.isMe and buff.Name:lower() == "rengarr" then
		OnBuff = false 
	end
end)

function Combo(target)
	if Mix:Mode() == "Combo" then
		if Config.Misc.HT:Value() then
			HydraPower(target)
		end
	    if Config.Combo.PR:Value() == 1 and OnBuff == false then
			CastE(target)
			CastQ(taget)
			CastW(target)
		elseif Config.Combo.PR:Value() == 2 and OnBuff == false then
			CastW(target)
			CastE(target)
			CastQ(target)
		elseif Config.Combo.PR:Value() == 3 and OnBuff == false then
			CastQ(target)
			CastE(target)
			CastW(target)
		end
	end
end

function HydraPower(target)
	if Ready(GetItemSlot(myHero, 3077)) and ValidTarget(target, Melee) then
		CastSpell(GetItemSlot(myHero, 3077))
	end
	if Ready(GetItemSlot(myHero, 3074)) and ValidTarget(target, Melee) then
		CastSpell(GetItemSlot(myHero, 3074))
	end
end

function CastQ(target)
		if Config.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastSkillShot(_Q, target)
		end
	end

function CastW(target)
		if Config.Combo.W:Value() and Ready(_W) and ValidTarget(target, WRange) then
			CastSpell(_W)
		end
	end

function CastE(target)
	local PredEEE = GetPrediction(target, PredMyE)
	if Config.Combo.E:Value() and Ready(_E) and ValidTarget(target, ERange) and PredEEE.hitChance >= 0.4 and not PredEEE:mCollision(1) then
		CastSkillShot(_E, PredEEE.castPos)
	end
end

function LaneClear()
		if Mix:Mode() == "LaneClear" then
			for _, minion in pairs(minionManager.objects) do
			if Config.LC.LCQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) then
				CastSkillShot(_Q, minion)
			end
			if Config.LC.LCE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
				if GetCurrentHP(minion) < getdmg("E", minion, myHero, GetCastLevel(myHero, _E)) then
					CastSkillShot(_E, minion)
				end
			end
		end
	end
end

function JungleClear()
		if Mix:Mode() == "LaneClear" then
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then

			    if Config.JC.JCE:Value() and Ready(_E) and ValidTarget(mob, ERange) then
					CastSkillShot(_E, mob)
				end
				if Config.JC.JCW:Value() and Ready(_W) and ValidTarget(mob, WRange) then
					CastSpell(_W)
				end
				if Config.JC.JCQ:Value() and Ready(_Q) and ValidTarget(mob, QRange) then
			        CastSkillShot(_Q, mob)
			    end
			end
		end
	end
end
