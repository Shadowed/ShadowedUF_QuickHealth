--[[ 
	Shadow Unit Frames (Quick Health), Mayen of US-Mal'Ganis PvP
]]

local L = {
	["Quick Health"] = "Quick Health",
	["Enable Quick Health"] = "Enable Quick Health",
	["Enables LibQuickHealth-2.0 support, this will watch the combat log and make your health update slightly faster."] = "Enables LibQuickHealth-2.0 support, this will watch the combat log and make your health update slightly faster.",
}

local QuickHealth = {}
local frames = {}
local LibQuickHealth = LibStub("LibQuickHealth-2.0")
ShadowUF:RegisterModule(QuickHealth, "quickHealth", L["Quick Health"])

function QuickHealth:OnDefaultsSet()
	for _, unit in pairs(ShadowUF.units) do
		ShadowUF.defaults.profile.units[unit].quickHealth = {enabled = true}
	end
end

function QuickHealth:Setup()
	local enabled
	for frame in pairs(frames) do
		enabled = true
		break
	end
	
	if( not enabled ) then
		LibQuickHealth:UnregisterAllCallbacks(self)
		return
	end
	
	LibQuickHealth.RegisterCallback(self, "HealthUpdated", "HealthUpdated")
end

function QuickHealth:OnEnable(frame)
	frame.quickHealth = frame.quickHealth or CreateFrame("Frame")
	
	frame:RegisterUpdateFunc(self, "UpdateGUID")
	frames[frame] = true
	
	self:Setup()
end

function QuickHealth:OnDisable(frame)
	frame:UnregisterAll(self)
	frames[frame] = true
	self:Setup()
end

function QuickHealth:UpdateGUID(frame)
	frame.quickHealth.guid = UnitGUID(frame.unit)
end

-- Stole the fenv method from clad
-- We have to set the env to access the global env if we can't find the function to make it actually continue to work
local proxyEnv = {UnitHealth = LibQuickHealth.UnitHealth}
setmetatable(proxyEnv, { 
	__index    = _G,
	__newindex = function (t, k, v) _G[k] = v end,
})

local Update = ShadowUF.modules.healthBar.Update
local IncUpdate = ShadowUF.modules.incHeal.UpdateFrame
local oldHealthEnv = getfenv(ShadowUF.modules.healthBar.Update)
local oldIncEnv = getfenv(ShadowUF.modules.healthBar.IncUpdate)
function QuickHealth:HealthUpdated(event, guid, health, maxHealth)
	setfenv(Update, proxyEnv)
	setfenv(IncUpdate, proxyEnv)
	
	for frame in pairs(frames) do
		if( frame.quickHealth.guid == guid ) then
			Update(ShadowUF.modules.healthBar, frame)
			
			if( frame.incHeal and frame.incHeal.enabled ) then
				IncUpdate(ShadowUf.modules.incHeal, frame, "UNIT_HEALTH")
			end
		end
	end

	setfenv(Update, oldHealthEnv)
	setfenv(IncUpdate, oldIncEnv)
end

function QuickHealth:OnConfigurationLoad()
	ShadowUF.Config.unitTable.args.bars.args.healthBar.args.quickHealth = {
		order = 2.10,
		type = "toggle",
		name = L["Enable Quick Health"],
		desc = L["Enables LibQuickHealth-2.0 support, this will watch the combat log and make your health update slightly faster."],
		arg = "quickHealth.enabled",
	}
end













