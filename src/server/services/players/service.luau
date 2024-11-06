local knit = require("@packages/knit")
local janitor = require("@packages/janitor")

local player = require("./player")

local players = game:GetService("Players")

local service = knit.CreateService({
	Name = "PlayerService",
	Client = {},

	_Players = {},
})

function service:GetPlayer(plr)
	assert(self._Players[plr], "Player with name " .. plr.Name .. "not found using PlayerService:GetPlayer")

	return self._Players[plr]
end

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
