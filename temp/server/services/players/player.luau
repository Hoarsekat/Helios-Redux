local classpp = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('classpp'))
local class = classpp.class

local player = class("Player")({
	constructor = function(self, instance, character, humanoid, services)
		self.Name = instance.Name :: string
		self.Character = character :: Model ~= nil and character
		self.Humanoid = humanoid :: Humanoid ~= nil and humanoid
		self.Instance = instance :: Player
		self.Services = services :: table?
	end,
	Public = {
		Name = "",
		Character = "",
		Humanoid = "",
		Instance = "",
		setupCharacter = function(self)
			local description = self.Humanoid:GetAppliedDescription()

			description.Head = 0
			description.LeftArm = 0
			description.RightArm = 0
			description.LeftLeg = 0
			description.RightLeg = 0
			description.Torso = 0

			self.Humanoid:ApplyDescription(description)
		end,
		hasPermission = function(self, data)
			return self.Services.PermissionService:HasPermission(self.Instance, data)
		end,
	},
	Private = {
		Services = {},
	},
})

return player
