
require ("Inspired")
require ("DeftLib")
if myHeroName ~= "MonkeyKing" then return end

local version = "0.2"

function AutoUpdate(data)
	if tonumber(data) > tonumber(version) then
		PrintChat("[Safari Wukong] New version found!")
		PrintChat("[Safari Wukong] Downloading update, please wait ...")
		DownloadFileAsync("https://raw.githubusercontent.com/NentoR/GoS/master/SafariWukong.lua", SCRIPT_PATH .. "SafariWukong.lua", function() PrintChat("[Safari Wukong] Update completed. Please 2xF6") return end)
	else
		PrintChat("[Safari Wukong] No Updates Found !")
	end
end
GetWebResultAsync("https://raw.githubusercontent.com/NentoR/GoS/master/SafariWukong.version", AutoUpdate)


local WuMenu = MenuConfig("Wukong", "Wukong")


WuMenu:SubMenu("C", "Combo")

WuMenu.C:Boolean("CQ", "Use Q in Combo", true)
WuMenu.C:Boolean("CW", "Use W in Combo", true)
WuMenu.C:Boolean("CE", "Use E in Combo", true)
WuMenu.C:Boolean("CR", "Use R in Combo", true)

WuMenu:SubMenu("LC", "LaneClear")

WuMenu.LC:Boolean("LCQ", "Use Q to lasthit minion", true)
WuMenu.LC:Boolean("LCE", "Use E", false)

WuMenu:SubMenu("Draws", "Drawings")
WuMenu.Draws:Boolean("DRE", "Draw E Range", true)


Range_Table = {

      AR =  { Range = 175 },
      Q = { Range = 175 }, 
      W = { Range = 175 },
      E = { Range = 625 },
      R = { Range = 160 }

};

--[[function CalcDmg(spell, unit)

	local dmg = {

	[_Q] = 30 + 30 * GetCastLevel(myHero, _Q) + GetBonusDmg(myHero) * 0.1,
	[_E] = 60 + 45 * GetCastLevel(myHero, _E) + GetBonusDmg(myHero) * 0.8
};

return dmg[spell]
end ]]

DMG_Table = {
	
	QDMG = 30 + 30 * GetCastLevel(myHero, _Q) + GetBonusDmg(myHero) * 0.1 ,
	EDMG = 60 + 45 * GetCastLevel(myHero, _E) + GetBonusDmg(myHero) * 0.8 
};


local Spin = false

OnLoad(function()


	if _G.AutoCarry_Loaded == true then 
		PrintChat("[Safari Wukong] Deftsu's AutoCarry Reborn loaded successfully")
	end
	if _G.DAC_Loaded == true then
		PrintChat("[Safari Wukong] Deftsu's AutoCarry loaded successfully")
	end
	if _G.GoSWalkLoaded == true then
		PrintChat("[Safari Wukong] GoSWalk loaded successfully")
	end

	PrintChat("[Safari Wukong] Loaded successfully")

end)

OnDraw(function(myHero)
		if not IsDead(myHero) or IsRecalling(myHero) then
			if WuMenu.Draws.DRE:Value() then
				if Ready(_E) then
				DrawCircle(GetOrigin(myHero), Range_Table.E.Range, 1, 25, GoS.Blue)
			end
		end
	end
end)


OnTick(function(myHero)

    if not IsDead(myHero) or IsRecalling(myHero) then
    
    local target = GetCurrentTarget()

    OrbMode()
    --CalcDmg(spell, unit)
    LaneClear()
    Harass(target)

   -- local QDMG = 30 + 30 * GetCastLevel(myHero, _Q) + GetBonusDmg(myHero) * 0.1

   if Spin == false then
   	Combo(target) 
   end

   if Spin == true then
   	Combo(target) return end

   	--print(CalcDmg(0, target))

   	if GetCurrentHP(target) <= 75 then
   		CastR(target) return end

   		if GetCurrentHP(myHero) <= 100 and GetCurrentHP(target) <= 75 or 100 then
   			CastR(target)
   		end

   		CastR(target)

   		--[[ if Spin == true then BlockAttack(true) end
   		if Spin == false then BlockAttack(false) end ]] -- Broken ATM (Not Needed Anyway)
   	end
end)

function OrbMode()
	if _G.AutoCarry_Loaded == true then
            return DACR:Mode()
            
    elseif _G.DAC_Loaded == true then
            return DACR:Mode()          
            
    elseif _G.GoSWalkLoaded == true and GoSWalk.CurrentMode then
            return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1] -- Thanks Shulepin :)
        end
    end

function BlockAttack(bool)
	if _G.AutoCarry_Loaded then
		return DACR.attacksEnables == (bool)
		elseif _G.DAC_Loaded then 
			return DAC.attacksEnable == (bool)
		end
	end

function Combo(target)

		if OrbMode() == "Combo" then

				if WuMenu.C.CE:Value() and Ready(_E) and ValidTarget(target, Range_Table.E.Range) then
					CastTargetSpell(target, _E)
			end
			    if WuMenu.C.CQ:Value() and Ready(_Q) and ValidTarget(target, Range_Table.Q.Range) then
			    	CastSpell(_Q)
			end
			    if WuMenu.C.CW:Value() and Ready(_W) and ValidTarget(target, Range_Table.W.Range) then
			    	CastSpell(_W)
			end
		end
	end

function CastR(target)
	if KeyIsDown(32) then
		if WuMenu.C.CR:Value() and Ready(_R) and ValidTarget(target, Range_Table.R.Range) then
			CastSpell(_R)
			end
		end
	end

OnUpdateBuff(function(unit, buff)
			if unit.isMe and buff.Name:lower("monkeykingspintowin") then
				Spin = true
				--PrintChat("Ult is ON")
			end
		end)

OnRemoveBuff(function(unit, buff)
			if unit.isMe and buff.Name:lower("monkeykingspintowin") then
				Spin = false
				--PrintChat("Ult Is OFF")
			end
		end) 

function LaneClear()
	if OrbMode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if WuMenu.LC.LCQ:Value() and Ready(_Q) and ValidTarget(minion, Range_Table.Q.Range) then
				if GetCurrentHP(minion) < DMG_Table.QDMG then
					CastSpell(_Q)
				end
			end
			if WuMenu.LC.LCE:Value() and Ready(_E) and ValidTarget(minion, Range_Table.E.Range) then
				CastTargetSpell(minion, _E)
			end
		end
	end
end

function Harass(target)
	if OrbMode() == "Harass" then
		if WuMenu.C.CE:Value() and Ready(_E) and ValidTarget(target, Range_Table.E.Range) then
			CastTargetSpell(target, _E)
		end
		if WuMenu.C.CW:Value() and Ready(_W) and ValidTarget(target, Range_Table.W.Range) then
			CastSpell(_W)
		end
		if WuMenu.C.CQ:Value() and Ready(_Q) and ValidTarget(target, Range_Table.Q.Range) then
			CastSpell(_Q)
		end
	end
end



