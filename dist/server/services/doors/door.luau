-- TODO: Add classpp support (figure out a method to have SettingsFile as a metatable)

local janitor = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('janitor'))
local doorFunctions = require(script.Parent.doors)

local door = {}
door.__index = door

function door.new(object, services)
	local settingsFile = object:FindFirstChild("Settings")
	local self = setmetatable((settingsFile and require(settingsFile) or {}), door) -- Door will import settings

	assert(self.Function, "You must specify a door within a settings file to run door.new")

	self.Janitor = janitor.new()
	self.Object = object
	self:setNetworkOwnership()

	self.Services = services

	local permissionsFile = object:FindFirstChild("Permissions")
	self.Permissions = {
		Regular = (permissionsFile or {}),
		Lockdown = object:FindFirstChild("LockdownPermissions"), -- Lockdown permissions file seperate from regular permissions file
	}

	self.IsOpen = self.StartOpen or false
	self.WasOpen = false -- If lockdown enables, check if door was open, so door can reopen upon lockdown ending
	self.Lockdown = false
	self.Cooldown = false

	self.DoorFunction = self:findFunction(self.Function)
	assert(
		self.DoorFunction,
		'Door function with the name"' .. self.Function .. '" could not be found for ' .. self.Object:GetFullName()
	)

	if self.DoorFunction.setup then
		self.DoorFunction.setup(self)
	end

	if not self.AutoCloseTime then
		self.AutoCloseTime = 3 -- Default time for doors to close after being opened
	end

	if self.IsOpen then
		task.spawn(self.open, self)
	end

	self:setupReaders()

	--[[
        -- TODO: (if self.ConnectedLockdowns) add lockdown support through function self:handleLockdownChange() via a signal
    ]]

	self:handleLockdownChange()

	if self.StartLockdown then
		self:setLockdown(true)
	end

	return self
end

function door:findFunction()
	for _, module in ipairs(doorFunctions:GetChildren()) do
		if module:IsA("ModuleScript") then
			local success, result = pcall(require, module)

			if not success then
				warn("An error occured while loading door function module", module:GetFullName() .. ":", result)
			elseif not result.Name then
				warn("Configuration fault in door function module", module:GetFullName())
			elseif result.Name == self.Function then
				return result
			end
		end
	end
end

function door:setNetworkOwnership()
	for _, descendant in ipairs(self.Object:GetDescendants()) do
		if descendant:IsA("BasePart") then
			pcall(descendant.SetNetworkOwner, descendant, nil)
		end
	end
end

function door:setObjectCollisionGroup(groupName)
	for _, part in ipairs(self.Object:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end
end

function door:open()
	self.Cooldown = true
	self.IsOpen = true
	self:updatePrompts()

	if self.DoorFunction.actuate then
		self.DoorFunction.actuate(self, true)
	end

	if self.AutoClose or self.Lockdown then
		task.delay(self.AutoCloseTime, function()
			if self.IsOpen then
				self:close()
			end
		end)
	end

	self.Cooldown = false
end

function door:close()
	self.Cooldown = true
	self.IsOpen = false
	self:updatePrompts()

	if self.DoorFunction.actuate then
		self.DoorFunction.actuate(self, false)
	end

	self.Cooldown = false
end

function door:toggle()
	if self.IsOpen then
		self:close()
	else
		self:open()
	end
end

function door:updatePrompts()
	for _, prompt in ipairs(self.ProximityPrompts or {}) do
		if prompt:IsA("ProximityPrompt") then
			prompt.ActionText = (self.IsOpen and "Close" or "Open")
		end
	end
end

function door:setLockdown(enabled: boolean)
	self.Lockdown = not not enabled

	for _, led in ipairs(self.LEDs.LEDG) do
		led.Color = (enabled and BrickColor.new("Gold").Color or Color3.fromRGB(75, 151, 75))
		led.Material = (enabled and Enum.Material.Neon or Enum.Material.Metal)
	end

	for _, led in ipairs(self.LEDs.LEDGLOBAL) do
		led.Color = (enabled and BrickColor.new("Gold").Color or Color3.fromRGB(163, 162, 165))
	end

	if enabled then
		self.WasOpen = self.IsOpen
	end
end

function door:canPlayerAccess(player)
	local plr = self.Services.PlayerService:GetPlayer(player)

	if player.Team.Name == "Anomaly Actors" and not (self.DoorFunction and self.DoorFunction.NoActor) then
		return true
	end

	if not self.NoSCP005 and player.Character and player.Character:FindFirstChild("SCP-005") then -- Key SCP support
		return true
	end

	local hasBasePermissions = plr:hasPermission(self.Permissions.Regular)
	local hasLockdownPermissions = not self.Lockdown
		or not self.Permissions.Lockdown
		or plr:hasPermission(self.Permissions.Lockdown)

	return hasBasePermissions and hasLockdownPermissions
end
