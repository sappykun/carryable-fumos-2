AddCSLuaFile()

if engine.ActiveGamemode() == "terrortown" then
	SWEP.Base = "weapon_tttbase"
	SWEP.Slot = 8
else
	SWEP.Base = "weapon_base"
	SWEP.Slot = 4
end

SWEP.AutoSpawnable = false
SWEP.InLoadoutFor = nil
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = true

SWEP.Spawnable	= false
SWEP.AdminOnly	= false
SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.DrawCrosshair        = false
SWEP.BounceWeaponIcon   = false

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "None" 

SWEP.Secondary.ClipSize        = -1 
SWEP.Secondary.DefaultClip    = -1 
SWEP.Secondary.Automatic    = false 
SWEP.Secondary.Ammo            = "none"

if SERVER then
	cvarMinSqueezes = CreateConVar("fumo_carryable_min_squeezes", 3, FCVAR_REPLICATED, "Minimum times you can right-click with a fumo before it explodes.")
	cvarExpChance = CreateConVar("fumo_carryable_explosion_chance", 0.1, FCVAR_REPLICATED, "Chance for fumo to explode after min_squeezes. Default is 0.1 (10% chance). 0 disables exploding.")
	cvarForceKill = CreateConVar("fumo_carryable_force_kill", 0, FCVAR_REPLICATED, "Should exploding fumo bypass armor/godmode and kill player directly", 0, 1)
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.ClickCount = 0
	self.Idle = 0
	self.IdleTimer = CurTime() + 1
end

-- Seems to be a fix for the weapon's staying static after playing the deploy animation.
function SWEP:Think()
	if self.Idle == 0 and self.IdleTimer <= CurTime() then
		if SERVER then
			local vm = self.Owner:GetViewModel()
			vm:SendViewModelMatchingSequence( vm:LookupSequence( "idle" ) )
		end
		self.Idle = 1
	end
end

function SWEP:Holster()
	if CLIENT and IsValid(self.WorldModelEnt) then
		self.WorldModelEnt:Remove()
	end
	return true
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "deploy" ) )
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()

	if SERVER then self.Owner:EmitSound("fumosays.wav") end
end


function SWEP:PrimaryAttack()
    self.Owner:EmitSound("fumosquee.wav")
    if self:GetNextPrimaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + 1)

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

-- Blank method prevents sounds when right-clicking
function SWEP:SecondaryAttack()
end

-- Spawning a fumo from the spawn menu does not call Deploy.
-- Therefore, the safest place to deal with making the worldmodel
-- is in this method.
function SWEP:DrawWorldModel()
	local _Owner = self:GetOwner()
	local ownervalid = IsValid(_Owner)
	
	if not IsValid(self.WorldModelEnt) then
		self.WorldModelEnt = ClientsideModel(self.WorldModel)
		self.WorldModelEnt:SetNoDraw(true) -- fix to prevent fumo's rendering twice when in front of mirrors
	end

	self.WorldModelEnt:SetModel(self.WorldModel)

	if ownervalid then
		local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if !boneid then return end

		local matrix = _Owner:GetBoneMatrix(boneid)
		if !matrix then return end

		local newPos, newAng = LocalToWorld(self.OffsetVec or Vector(-5, -2, -5), self.OffsetAng or Angle(-50, 50, 80), matrix:GetTranslation(), matrix:GetAngles())

		self.WorldModelEnt:SetPos(newPos)
		self.WorldModelEnt:SetAngles(newAng)

		self.WorldModelEnt:SetupBones()
	else
		self.WorldModelEnt:SetPos(self:GetPos())
		self.WorldModelEnt:SetAngles(self:GetAngles())
	end

	self.WorldModelEnt:DrawModel()
end
