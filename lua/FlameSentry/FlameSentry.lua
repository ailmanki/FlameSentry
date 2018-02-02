Script.Load "lua/Sentry.lua"
Script.Load "lua/Weapons/Marine/Flamethrower.lua"

class 'FlameSentry' (Sentry)

FlameSentry.kMapName        = "flamesentry"
FlameSentry.kModelName      = PrecacheAsset("models/marine/flame_sentry/flame_sentry.model")
FlameSentry.kAnimationGraph = PrecacheAsset("models/marine/flame_sentry/flame_sentry.animation_graph")

-- Properties to inherit from Flamethrower
for _, v in ipairs {
	"kConeWidth",
	"kDamageRadius",
	"GetRange",
	"BurnSporesAndUmbra",
	"CreateFlame",
	"ApplyConeDamage",
	"ShootFlame",
} do
	FlameSentry[v] = assert(Flamethrower[v])
end

local kMuzzleNode         = "fxnode_flamesentrymuzzle"
local kMuzzleNodeOriginal = Sentry.kMuzzleNode
FlameSentry.kMuzzleNode   = kMuzzleNode
-- Unused?
--FlameSentry.kEyeNode	  = "fxnode_eye2"
--FlameSentry.kLaserNode  = "fxnode_eye2"

local networkVars = {}

if Server then
	local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/flamethrower/attack_loop")
	function FlameSentry:OnCreate()
		Sentry.OnCreate(self)

		self.attackSound:SetAsset(kFireLoopingSound)
	end
end

local function GetAttachPointOrigin(self, node)
	if node == kMuzzleNodeOriginal or node == "fxnode_flamethrowermuzzle" then
		return self:flamesentry_GetAttachPointOrigin(kMuzzleNode)
	else
		return self:flamesentry_GetAttachPointOrigin(node)
	end
end

local function DoDamage(self, damage, ...)
	self:flamesentry_DoDamage(damage * 2, ...)
end

function FlameSentry:OnInitialized()
	Sentry.OnInitialized(self)

	self:SetModel(self.kModelName, self.kAnimationGraph) -- How constants should **really** be used

	if not self.flamesentry_GetAttachPointOrigin then
		self.flamesentry_GetAttachPointOrigin = self.GetAttachPointOrigin
		self.GetAttachPointOrigin = GetAttachPointOrigin
	end

	if Server then
		local attacker = self
		local maxPitchDegree =  self.kMaxPitch
		local minPitchDegree = -self.kMaxPitch
		self.targetSelector.filters[1] = function(target, targetPoint) -- modification of PitchTargetFilter
			local origin     = attacker:GetEyePos()
			local viewCoords = attacker:GetCoords()
			local v          = targetPoint - origin
			local distY      = Math.DotProduct(viewCoords.yAxis, v)
			local distZ      = Math.DotProduct(viewCoords.zAxis, v)
			local pitch      = 180 * math.atan2(distY,distZ) / math.pi
			local result     = pitch >= minPitchDegree and pitch <= maxPitchDegree
			return result
		end
	end

	--[[ Uncomment to enable damage buff
	if not self.flamesentry_DoDamage then
		self.flamesentry_DoDamage = self.DoDamage
		self.DoDamage = DoDamage
	end
	--]]
end

function FlameSentry:OnGetMapBlipInfo()
	return true, kMinimapBlipType.Sentry, self:GetTeamNumber(), self:GetIsInCombat(), self:GetIsParasited()
end

function FlameSentry:GetEyePos()
	return assert(self:GetAttachPointOrigin(FlameSentry.kMuzzleNode))
end

function FlameSentry:OverrideLaserLength()
	return kFlamethrowerRange
end

function FlameSentry:GetViewAngles()
	if self.attacking then
		local angles = Angles()
		angles:BuildFromCoords(Coords.GetLookIn(Vector(), self.targetDirection))
		return angles
	else
		return self:GetAngles()
	end
end

function FlameSentry:GetMeleeOffset()
	return 0
end

if Server then
	local OnDeploy = debug.getupvalue(FlameSentry.OnConstructionComplete, "OnDeploy")
	function FlameSentry:OnConstructionComplete()
		self:AddTimedCallback(OnDeploy, 1.4)
	end

	function FlameSentry:FireBullets()
		---[[
		if not self.last_attack_effect or Shared.GetTime() - self.last_attack_effect > 1 then
			self:TriggerEffects "flamethrower_attack_start"
			self.last_attack_effect = Shared.GetTime()
		elseif Shared.GetTime() - self.last_attack_effect > 0.5 then
			self:TriggerEffects "flamesentry_attack"
			self.last_attack_effect = Shared.GetTime()
		end
		--]]
		--self:TriggerEffects "flamethrower_attack_start"
		return self:ShootFlame(self)
	end
end

GetEffectManager:AddEffectData(nil, {
	flamesentry_attack = {{{
		parented_cinematic = (function()
			for _, v in ipairs(kMarineWeaponEffects.flamethrower_attack.flamethrowerAttackCinematics) do
				if v.weapon_cinematic and not v.empty then
					Log("Found weapon cinematic %s", v.weapon_cinematic)
					return v.weapon_cinematic
				end
			end
			error "Could not find the flamethrower_attack weapon_cinematic for flamesentry_attack!"
		end)(),
		attach_point = kMuzzleNode,
	}}}
})

Shared.LinkClassToMap("FlameSentry", FlameSentry.kMapName, networkVars)
