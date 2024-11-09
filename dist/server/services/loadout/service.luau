local knit = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('knit'))
local janitor = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('janitor'))
local promise = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('promise'))

local loadout = script.Parent:WaitForChild("loadout")
local loadoutAssets = loadout:WaitForChild("assets")

local playerService

local players = game:GetService("Players")

local service = knit.CreateService({
	Name = "LoadoutService",
	Client = {},
})

local DEBUG = false -- SET TO TRUE IF TESTING MORPHS

function service:AddAccessory(character, accessory: Accessory | (table & Instance))
	assert(character :: Model, "You must specify a valid character for LoadoutService:AddAccessory")
	assert(accessory, "You must specify a valid accessory(s) for LoadoutService:AddAccessory")

	local function weld(acc)
		acc.Parent = character
		local toAttach

		if acc:FindFirstChild("Middle") then
			toAttach = acc.Middle
		elseif acc:FindFirstChild("Handle") then
			toAttach = acc.Handle
		else
			return
		end

		for _, v in pairs(acc:GetDescendants()) do
			if
				v.className == "Part"
				or v.className == "UnionOperation"
				or v.className == "WedgePart"
				or v.className == "MeshPart"
			then
				local W = Instance.new("Weld")
				W.Part0 = toAttach
				W.Part1 = v

				local CJ = CFrame.new(toAttach.Position)
				local C0 = toAttach.CFrame:inverse() * CJ
				local C1 = v.CFrame:inverse() * CJ

				W.C0 = C0
				W.C1 = C1
				W.Parent = toAttach
			end

			if toAttach.Name == "Middle" then
				local Y = Instance.new("Weld")
				Y.Part0 = character[acc:GetAttribute("BodyPart")]
				Y.Part1 = toAttach
				Y.C0 = CFrame.new(0, 0, 0)
				Y.Parent = Y.Part0
			end
		end

		for _, v in pairs(acc:GetDescendants()) do
			if
				v.className == "Part"
				or v.className == "UnionOperation"
				or v.className == "WedgePart"
				or v.className == "MeshPart"
			then
				v.Anchored = false
				v.CanCollide = false
			end
		end
	end

	return promise.new(function(resolve)
		if typeof(accessory) == "table" then
			for _, v in pairs(accessory) do
				weld(v)
			end
		else
			weld(accessory)
		end

		resolve()
	end)
end

function service:RemoveAccessories(character)
	return promise.new(function(resolve)
		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("Accessory") then
				descendant:Destroy()
			end
		end

		resolve()
	end)
end

function service:RestoreAccessories(player)
	return promise.new(function(resolve)
		local humanoidModel = players:CreateHumanoidModelFromUserId(player.Instance.UserId)

		for _, child in ipairs(humanoidModel:GetChildren()) do
			if child:IsA("Accessory") then
				self:AddAccessory(player.Character, child)
			end
		end

		humanoidModel:Destroy()

		resolve()
	end)
end

function service:RemoveClothing(character)
	return promise.new(function(resolve)
		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("Clothing") or descendant:IsA("ShirtGraphic") then
				descendant:Destroy()
			end
		end

		resolve()
	end)
end

function service:RestoreClothing(player)
	return promise.new(function(resolve)
		local humanoidModel = players:CreateHumanoidModelFromUserId(player.Instance.UserId)

		for _, child in ipairs(humanoidModel:GetChildren()) do
			if child:IsA("Clothing") or child:IsA("ShirtGraphic") then
				child.Parent = player.Character
			end
		end

		humanoidModel:Destroy()

		resolve()
	end)
end

function service:KnitStart()
	playerService = knit.GetService("PlayerService")

	local playerAddedConnection = players.PlayerAdded:Connect(function(plr)
		local player = playerService:GetPlayer(plr)

		task.wait(5)

		if DEBUG then
			-- Removes players clothing > Removes players accessories > Adds morph accessories > After 10 seconds restores player to their original look
			self:RemoveClothing(player.Character):andThen(function()
				self:RemoveAccessories(player.Character):andThen(function()
					self:AddAccessory(player.Character, loadoutAssets.test:GetChildren()):catch(warn)
				end)
			end)

			task.wait(10)

			self:RestoreClothing(player):andThen(function()
				self:RemoveAccessories(player.Character):andThen(function()
					self:RestoreAccessories(player):catch(warn)
				end)
			end)
		end
	end)

	self._janitor = janitor.new()
	self._janitor:Add(playerAddedConnection)
end

return service
