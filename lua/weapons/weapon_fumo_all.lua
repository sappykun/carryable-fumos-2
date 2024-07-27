AddCSLuaFile()

SWEP.Base = "weapon_fumo_base"
SWEP.Category = "Fumos"
SWEP.Spawnable	= true

SWEP.InLoadoutFor = {ROLE_INNOCENT, ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.EquipMenuData = {
  type = "fumo!!!!!!!!!!!!",
  desc = "left click: dont press that\nright click: change fumo\nreload: squeeze fumo (dont)"
};

SWEP.Kind = 9
SWEP.PrintName		= "All Fumos"			
SWEP.Purpose        = "fumo!!!!!!!!!!!!"
SWEP.Instructions   = "left click: dont press that\nright click: change fumo\nreload: squeeze fumo (dont)"
SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.OffsetVec = Vector(-5, -2, -5)
SWEP.OffsetAng = Angle(-50, 50, 80)

local fumo_options = {
	"weapon_fumo_reimu",
	"weapon_fumo_marisa",
	"weapon_fumo_cirno",
	"weapon_fumo_youmu",
	"weapon_fumo_remi",
	"weapon_fumo_flandre",
	"weapon_fumo_suwako",
	"weapon_fumo_yuuka",
	"weapon_fumo_mokou",
	"weapon_fumo_sakuya",
	"weapon_fumo_yuyuko",
	"weapon_fumo_sanae",
	"weapon_fumo_tsukasa",
	"weapon_fumo_shion",
	"weapon_fumo_keiki",
	"weapon_fumo_junko",
	"weapon_fumo_momiji",
}

-- TODO: Save the selected fumo somehow. Could use ClientConVar,
-- but a whole bunch of error/exploit checking would need to be done
function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "SelectedFumo" )
	self:NetworkVarNotify( "SelectedFumo", self.FumoChanged )
	self:SetSelectedFumo(1)
end

function SWEP:SecondaryAttack()
	fumo = self:GetSelectedFumo() + 1
	if fumo > #fumo_options then
		fumo = 1
	end

	if CLIENT and IsFirstTimePredicted() then
		surface.PlaySound("carryable_fumos/fumosays.wav") 
	elseif game.SinglePlayer() then
		self.Owner:EmitSound("carryable_fumos/fumosays.wav")
	end

	self:SetSelectedFumo(fumo)
	self.Owner.LastSelectedFumo = fumo
end


function SWEP:FumoChanged( name, old, new )
	-- Some weird fuckery with network values that default to nil.
	if new == 0 then return end

	selected_swep = weapons.Get(fumo_options[new])
	-- Why does this become nil and why
	-- does nothing bad happen if we ignore it?
	if selected_swep == nil then return end

	--Msg("FumoChanged   ", new, "\n")

	self.ViewModel = selected_swep.ViewModel
	self.WorldModel = selected_swep.WorldModel
	self.OffsetVec = selected_swep.OffsetVec
	self.OffsetAng = selected_swep.OffsetAng
end


function SWEP:PreDrawViewModel(vm, weapon, ply)
	vm:SetModel(self.ViewModel)
end

function SWEP:Reload()
    self.Owner:EmitSound("carryable_fumos/fumosquee.wav", 100, 100)
    if self:GetNextPrimaryFire() > CurTime() then return end
    self:SetNextSecondaryFire(CurTime() + 1)

    if SERVER and self.ClickCount >= cvarMinSqueezes:GetInt() and math.random() < cvarExpChance:GetFloat() then 
        local explosion = ents.Create("env_explosion") 
        explosion:SetPos(self.Owner:GetPos()) 
        explosion:SetOwner(self.Owner)
        explosion:Spawn()
        explosion:SetKeyValue("iMagnitude", "200")
        explosion:Fire("Explode", 0, 0)

		if cvarForceKill:GetBool() then
			self.Owner:Kill()
		end
    end
	
	self.ClickCount = self.ClickCount + 1
end
