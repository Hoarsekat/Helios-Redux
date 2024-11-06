local knit = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('knit'))
local janitor = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('janitor'))

local player = require(script.Parent:WaitForChild('player'))

local players = game:GetService("Players")

local service = knit.CreateService({
	Name = "PlayerService",
	Client = {},

	_Players = {},
})

function service:KnitStart()
	local playerAddedConnection = players.PlayerAdded:Connect(function(plr)
		local character = plr.Character or plr.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")

		local playerClass = player.new(plr.Name, character, humanoid)

		self._Players[plr] = playerClass
		self._Players[plr]:setupCharacter()
	end)

	self._janitor = janitor.new()
	self._janitor:Add(playerAddedConnection)
end

return service
