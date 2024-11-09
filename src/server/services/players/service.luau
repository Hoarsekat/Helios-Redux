local knit = require("@packages/knit")
local janitor = require("@packages/janitor")

local playerClass = require("./player")

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
end

function service:KnitStart()
	local playerAddedConnection = players.PlayerAdded:Connect(function(plr)
		self:SetupPlayer(plr)
	end)

	self._janitor = janitor.new()
	self._janitor:Add(playerAddedConnection)
end

return service
