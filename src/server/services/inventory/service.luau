local datastoreService = game:GetService("DataStoreService")
local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

local indium = require("@packages/indium")

local loadoutStore = datastoreService:GetDataStore("LoadoutStore")
local serverAge = tick()

local service = indium.CreateService({
	Name = "InventoryService",
	Client = {},

	_Cache = {},
})

function service:GetLoadout(player)
	local key = (player.UserId .. "_" .. player.Team.Name):sub(1, 50)

	if tick() - serverAge < 120 and #players:GetPlayers() >= 40 then
		return {}
	end

	if not self._Cache[key] or tick() - self._Cache[key].Time >= 600 then
		self._Cache[key] = { Time = tick(), Value = nil }
		self._Cache[key] = { Time = tick(), Value = loadoutStore:GetAsync(key) }
	else
		return self._Cache[key].Value
	end

	if not self._Cache[key].Value then
		self._Cache[key].Value = {}
	else
		self._Cache[key].Value = httpService:JSONDecode(self._Cache[key].Value)
	end

	return self._Cache[key].Value
end

function service:UpdateLoadout(player, data)
	local key = (player.UserId .. "_" .. player.Team.Name):sub(1, 50)
	local allowed = true

	for i, v in pairs(data) do
		if typeof(i) == "string" or i:len() > 30 then
			allowed = false
		elseif typeof(v) ~= "number" or v < 30 or v >= 1000000 then
			-- selene:allow(if_same_then_else)
			allowed = false
		end
	end

	if not allowed then
		return
	end

	if not self._Cache[key] then
		self._Cache[key] = { Time = tick() - 30, Value = data }
	end

	self._Cache[key].Value = data

	if tick() - self._Cache[key].Time >= 30 then
		loadoutStore:UpdateAsync(key, function()
			return httpService:JSONEncode(self._Cache[key].Value)
		end)
		self._Cache[key].Time = tick()
	end
end

function service.Client:GetLoadout(player)
	return self.Server:GetLoadout(player)
end

function service.Client:UpdateLoadout(player, data)
	return self.Server:UpdateLoadout(player, data)
end

return service
