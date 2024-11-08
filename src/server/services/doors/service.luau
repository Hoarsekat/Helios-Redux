local knit = require("@packages/knit")
local tags = require("@common/tags/tags")

local doorClass = require("./door")

local service = knit.CreateService({
	Name = "DoorsService",
	Client = {},
})

function service:GetDoor(object)
	if self.doors[object] then
		return self.doors[object]
	else
		local newDoor = doorClass.new(object, { PlayerService = knit.GetService("PlayerService") })
		self.doors[object] = newDoor

		return newDoor
	end
end

function service:KnitStart()
	self.doors = {}
	tags.bindToTag("Door", function(object)
		local success, result = pcall(self.GetDoor, self, object)

		if not success then
			warn("Error while initialising door", object:GetFullName() .. ":", result)
		end
	end)
end

return service
