if GetObjectName(GetMyHero()) ~= "Fiora" then return end

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat("New version found! " .. data)
        PrintChat("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/NentoR/GoS/master/SafariFiora.lua", SCRIPT_PATH .. "SafariFiora.lua", function() PrintChat("Update Complete, please 2x F6!") return end)
    else
        PrintChat("No updates found!")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/NentoR/GoS/master/SafariFiora.version", AutoUpdate)

FioraMenu = MenuConfig("Fiora", "Fiora")



FioraMenu:SubMenu("Combo", "Combo")

FioraMenu.Combo:Boolean("CQ", "Use Q", true)
FioraMenu.Combo:Boolean("CE1", "Cast E1", true)
FioraMenu.Combo:Boolean("CE2", "Cast E2", true)
FioraMenu.Combo:Boolean("CR", "Use R", true)
FioraMenu.Combo:Boolean("CastTiamat", "Cast Tiamat", true)
FioraMenu.Combo:Boolean("EA", "If >= 2 or more enemies around cast R", true)


FioraMenu:SubMenu("Harass", "Harass")


FioraMenu.Harass:Boolean("HQ", "Use Q", true)
FioraMenu.Harass:Boolean("HW", "Use W", false)
FioraMenu.Harass:Boolean("HE", "Use E", true)


FioraMenu:SubMenu("LC", "LaneClear")

FioraMenu.LC:Boolean("LCQ", "Use Q to lasthit minion", true)
FioraMenu.LC:Boolean("LCE", "Use E", true)


FioraMenu:SubMenu("Draws", "Drawings")

FioraMenu.Draws:Boolean("DRQ", "Draw Q Range", true)
FioraMenu.Draws:Boolean("DRR", "Draw R Range", true)


local Range = 150
local QRange = 400
local WRange = 750
local ERange = 150
local RRange = 500

DMG_Table = {
	
	Q = 65 + 10 * GetCastLevel(myHero, _Q) + ((90 + 5 * GetCastLevel(myHero, _Q)) / 100) * GetBonusDmg(myHero)
};

OnDraw(function(myHero)
	if not IsDead(myHero) then
		if FioraMenu.Draws.DRQ:Value() and Ready(_Q) then
			DrawCircle(GetOrigin(myHero), QRange, 1, 25, GoS.Blue)
		end
		if FioraMenu.Draws.DRR:Value() and Ready(_R) then
			DrawCircle(GetOrigin(myHero), RRange, 1, 25, GoS.Blue)
		end
	end
end)

local target = GetCurrentTarget()
DACR.attacksEnabled = true

OnLoad(function()
	PrintChat("[Safari Fiora] Loaded")
end)

OnTick(function()
	QCast(target)
    E1Cast(target)
    CastTiamat(target)
	E2Cast(target)

	LaneClear()
	RCast(target)

end)

function LaneClear()
	if DACR:Mode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if FioraMenu.LC.LCQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) then
				if GetCurrentHP(minion) < DMG_Table.Q then
					CastSkillShot(_Q, minion)
				end
			end
			if FioraMenu.LC.LCE:Value() and Ready(_E) and ValidTarget(minion, Range) then
				CastSpell(_E)
			end
		end
	end
end



function QCast(target)
	if KeyIsDown(32) then
		if FioraMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastSkillShot(_Q, GetMousePos())
			AttackUnit(target)
		end
	end
end

function E1Cast(target)
	if KeyIsDown(32) then
		if FioraMenu.Combo.CE1:Value() and Ready(_E) and ValidTarget(target, Range) then
			CastSpell(_E)
			AttackUnit(target)
			DACR.attacksEnabled = false
		end
	end
end

function CastTiamat(target)
	if KeyIsDown(32) then
		if FioraMenu.Combo.CastTiamat:Value() and Ready(GetItemSlot(myHero, 3077)) and ValidTarget(target, Range) then
			CastSpell(GetItemSlot(myHero, 3077))
		end
		if FioraMenu.Combo.CastTiamat:Value() and Ready(GetItemSlot(myHero, 3074)) and ValidTarget(target, Range) then
			CastSpell(GetItemSlot(myHero, 3074))
		end
	end
end

function E2Cast(target)
	if KeyIsDown(32) then
		if FioraMenu.Combo.CE2:Value() and Ready(_E) and ValidTarget(target, Range) then
			DACR.attacksEnabled = true
			AttackUnit(target)
		end
	end
end

function Harass(target)
	if DACR:Mode() == "Harass" then
		if FioraMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastSkillShot(_Q, GetMousePos())
		end
		if FioraMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, Range) then
			CastSpell(_E)
			AttackUnit(target)
		end
		if FioraMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, WRange) then
			CastSkillShot(_W, target)
		end
	end
end

function RCast(target)
	if KeyIsDown(32) then
		if FioraMenu.Combo.EA:Value() and Ready(_R) and ValidTarget(target, 500) and EnemiesAround(myHero.pos, 500) >= 2 then
			CastTargetSpell(_R, target)
		end
	end
end

