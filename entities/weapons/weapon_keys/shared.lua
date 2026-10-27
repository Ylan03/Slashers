-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-07-26T13:54:42+02:00
-- @Last Modified by:   Hyltaria
-- @Last Modified time: 2026-10-27
--
-- Roland's keys: left click = lock a door (uses a key), right click = unlock a
-- door locked by a survivor (gives the key back).
-- The number of keys is now a networked variable of the weapon (before, the HUD
-- used a client side counter that was never reset between rounds).

if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Keys"
	SWEP.Slot = 1
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "DarylWinters"
SWEP.Instructions = "Left click to lock / Right click to unlock"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.WorldModel = ""

SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Slashers"
SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.MaxKeys = 3
SWEP.CloseTime = 1
SWEP.MaxDistance = 100

local LOCKABLE_MODELS = {
	["models/props_doors/doormain_rural01_small.mdl"] = true,
	["models/props_doors/doormainmetal01.mdl"] = true,
}

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "KeysLeft")
	self:NetworkVar("Float", 0, "LockStart")
	self:NetworkVar("Float", 1, "LockEnd")
end

function SWEP:Initialize()
	self:SetHoldType("normal")
	if SERVER then
		self:SetKeysLeft(self.MaxKeys)
	end
end

-- Returns the door the owner is looking at, if it can be locked / unlocked
function SWEP:GetTargetDoor()
	local owner = self:GetOwner()
	if !IsValid(owner) then return end

	local trace = owner:GetEyeTrace()
	local door = trace.Entity
	if !IsValid(door) or door:GetClass() != "prop_door_rotating" then return end
	if !LOCKABLE_MODELS[door:GetModel()] then return end
	if trace.HitPos:Distance(owner:GetShootPos()) > self.MaxDistance then return end

	return door
end

function SWEP:IsLocking()
	return self:GetLockEnd() > 0
end

function SWEP:TimerName()
	return "sls_keys_sounds_" .. self:EntIndex()
end

function SWEP:StartAction(door, lock)
	self.LockAction = lock
	self.LockDoor = door
	self:SetLockStart(CurTime())
	self:SetLockEnd(CurTime() + self.CloseTime)
	self:SetHoldType("pistol")

	timer.Create(self:TimerName(), 0.1, self.CloseTime * 10, function()
		if !IsValid(self) then return end
		local snd = {1, 3, 4}
		self:EmitSound("weapons/357/357_reload" .. snd[math.random(1, #snd)] .. ".wav", 50, 100)
	end)
end

function SWEP:StopAction()
	self:SetLockStart(0)
	self:SetLockEnd(0)
	self.LockDoor = nil
	self:SetHoldType("normal")
	timer.Remove(self:TimerName())
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 2)
	self:SetNextSecondaryFire(CurTime() + 2)
	if CLIENT or self:IsLocking() then return end
	if self:GetKeysLeft() <= 0 then return end

	local door = self:GetTargetDoor()
	if !door or door:GetNWBool("LockedByUser", false) then return end

	self:StartAction(door, true)
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + 2)
	self:SetNextSecondaryFire(CurTime() + 2)
	if CLIENT or self:IsLocking() then return end
	if self:GetKeysLeft() >= self.MaxKeys then return end

	local door = self:GetTargetDoor()
	if !door or !door:GetNWBool("LockedByUser", false) then return end

	self:StartAction(door, false)
end

function SWEP:Succeed()
	local door = self.LockDoor
	local lock = self.LockAction
	self:StopAction()
	if !IsValid(door) then return end

	if lock then
		if self:GetKeysLeft() <= 0 then return end
		door:Fire("Close", "", 0)
		door:Fire("Lock", "", 0.1)
		door:Fire("setanimation", "Lock", 0.1)
		door:SetNWBool("LockedByUser", true)
		self:SetKeysLeft(self:GetKeysLeft() - 1)
	else
		door:Fire("Unlock", "", 0)
		door:Fire("setanimation", "Unlock", 0)
		door:SetNWBool("LockedByUser", false)
		self:SetKeysLeft(math.min(self:GetKeysLeft() + 1, self.MaxKeys))
	end
end

function SWEP:Think()
	if CLIENT or !self:IsLocking() then return end

	-- Cancel if the player looks away from the door
	if self:GetTargetDoor() != self.LockDoor then
		self:StopAction()
		return
	end

	if self:GetLockEnd() <= CurTime() then
		self:Succeed()
	end
end

function SWEP:Holster()
	if SERVER then self:StopAction() end
	return true
end

function SWEP:OnRemove()
	timer.Remove(self:TimerName())
end

function SWEP:DrawHUD()
	if !self:IsLocking() then return end

	local w = ScrW()
	local h = ScrH()
	local x, y, width, height = w / 2 - w / 10, h / 1.15, w / 5, h / 35
	draw.RoundedBox(8, x, y, width, height, Color(10, 10, 10, 120))
	local time = math.max(self:GetLockEnd() - self:GetLockStart(), 0.01)
	local status = math.Clamp((CurTime() - self:GetLockStart()) / time, 0, 1)
	local BarWidth = status * (width - 16)
	local cornerRadius = math.Min(8, BarWidth / 3 * 2 - BarWidth / 3 * 2 % 2)
	draw.RoundedBox(cornerRadius, x + 8, y + 8, BarWidth, height - 16, Color(255 - (status * 255), 0 + (status * 255), 0, 255))
end

function SWEP:PreDrawViewModel()
	return true
end
