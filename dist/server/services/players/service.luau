local knit = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('knit'))
local janitor = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('janitor'))

local playerClass = require(script.Parent:WaitForChild('player'))

local players = game:GetService("Players")

local service = knit.CreateService({
	Name = "PlayerService",
	Client = {},

	_Players = {},
})

function service:GetPlayer(plr)
	if self._Players[plr] then
		return self._Players[plr]
	else
		local character = plr.Character or plr.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")

		local player =
			playerClass.new(plr, character, humanoid, { PermissionService = knit.GetService("PermissionService") })

		self._Players[plr] = player

		return self._Players[plr]
	end
end

function service.Client:GetPlayer(plr)
	return self.Server:GetPlayer(plr)
end

function service:SetupPlayer(plr: Player)
	local player = self:GetPlayer(plr)

	player:setupCharacter()
	if player:hasPermission("All") then -- Test
		print(plr.Name, [[has permission type "All"]])
	end
end

function service:KnitStart()
	local playerAddedConnection = players.PlayerAdded:Connect(function(plr)
		self:SetupPlayer(plr)
	end)

	self._janitor = janitor.new()
	self._janitor:Add(playerAddedConnection)
end

return service
