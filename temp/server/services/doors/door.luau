-- No classpp support

local janitor = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('janitor'))
local doorFunctions = script.Parent:WaitForChild("doors")

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

	--self:handleLockdownChange()

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
			elseif not result.name then
				warn("Configuration fault in door function module", module:GetFullName())
			elseif result.name == self.Function then
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

function door:playerInteracted(player, reader)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local backpack = player.Backpack

	local currentlyEquippedTool = character:FindFirstChildOfClass("Tool")

	if backpack:FindFirstChild("Keycard") then
		humanoid:EquipTool(backpack.Keycard)
	end

	if self.Cooldown then
		return false
	end

	local readerSounds = self.ReaderSounds[reader]

	if self:canPlayerAccess(player) then
		readerSounds.GrantedSound:Play()
		self:flashLEDs("LEDG")
		task.wait(0.25)
		self:toggle()
		if character:FindFirstChild("Keycard") then -- if player has keycard equipped still, unequip it/change it back to previous tool
			if currentlyEquippedTool then
				humanoid:EquipTool(currentlyEquippedTool)
			else
				humanoid:UnequipTools()
			end
		end
	else
		readerSounds.DeniedSound:Play()
		self:flashLEDs("LEDR")
		return false
	end
end

function door:flashLEDs(ledGroup)
	local leds = self.LEDs[ledGroup]
	local checkLockdown = (ledGroup == "LEDG")

	if ledGroup ~= "LEDGLOBAL" then
		for _, ledObject in ipairs(leds) do
			ledObject.Material = Enum.Material.Neon
			ledObject.Color = (ledGroup == "LEDG" and Color3.fromRGB(75, 151, 75) or Color3.fromRGB(117, 0, 0))

			task.delay(1.5, function()
				if checkLockdown and self.Lockdown then
					ledObject.BrickColor = BrickColor.new("Gold")
				else
					ledObject.Material = Enum.Material.Metal
				end
			end)
		end
	end

	for _, ledObject in ipairs(self.LEDs["LEDGLOBAL"]) do
		ledObject.Material = Enum.Material.Neon
		ledObject.Color = (ledGroup == "LEDG" and Color3.fromRGB(75, 151, 75) or Color3.fromRGB(117, 0, 0))

		task.delay(1.5, function()
			if self.Lockdown then
				ledObject.BrickColor = BrickColor.new("Gold")
			else
				ledObject.Color = Color3.fromRGB(163, 162, 165)
			end
		end)
	end
end

function door:setupReaders()
	local readerNames = {
		["Reader"] = {
			holdDuration = 0, -- default 0, 1 for testing prompts
			requiresKeycard = true, -- true
		},
	}

	self.LEDs = { -- LEDG = LED Green, etc | LEDGLOBAL = all types of lights
		LEDG = {},
		LEDR = {},
		LEDGLOBAL = {},
	}
	self.ProximityPrompts = {}
	self.ReaderSounds = {}

	for _, descendant in ipairs(self.Object:GetDescendants()) do
		if descendant:IsA("BasePart") then
			for lightName, array in pairs(self.LEDs) do
				if lightName == descendant.Name then
					table.insert(array, descendant)
				end
			end

			for readerName, data in pairs(readerNames) do
				if readerName == descendant.Name then
					local readerSounds = {}

					local grantedSound = Instance.new("Sound")
					grantedSound.Name = "AccessGranted"
					grantedSound.SoundId = "rbxassetid://200888468"
					grantedSound.Parent = descendant
					readerSounds.GrantedSound = grantedSound

					local deniedSound = Instance.new("Sound")
					deniedSound.Name = "AccessDenied"
					deniedSound.SoundId = "rbxassetid://200888510"
					deniedSound.Parent = descendant
					readerSounds.DeniedSound = deniedSound

					self.ReaderSounds[descendant] = readerSounds

					local prompt = Instance.new("ProximityPrompt")
					prompt.ObjectText = self.CustomName or "Door"
					prompt.ActionText = (self.IsOpen and "Close" or "Open")
					prompt.KeyboardKeyCode = Enum.KeyCode.E
					prompt.RequiresLineOfSight = true
					prompt.MaxActivationDistance = self.ReaderMaxActivationDistance or 10
					prompt.Style = Enum.ProximityPromptStyle.Custom -- Custom, default for debugging
					prompt.HoldDuration = data.holdDuration or 0
					prompt.Parent = descendant
					prompt.Enabled = true -- false by default due to keycard handling

					table.insert(self.ProximityPrompts, prompt)

					local triggeredConnection = prompt.Triggered:Connect(function(player)
						-- TODO: Add support for hacking
						if self.OnlyOpen and self.IsOpen then
							return
						end
						self:playerInteracted(player, descendant)
					end)

					self.Janitor:Add(triggeredConnection)
					self.Janitor:Add(prompt)

					break
				end
			end
		end
	end
end

function door:destroy()
	self.Janitor:Cleanup()
	self.Object = nil
	self.Permissions = nil
	self.LEDs = nil
	self.ProximityPrompts = nil
end

return door
