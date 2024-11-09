local knit = require("@packages/knit")
local permissions = script.Parent:WaitForChild("permissions")

local players = game:GetService("Players")

local service = knit.CreateService({
	Name = "PermissionService",
	Client = {},

	_Functions = {},
})

local VERBOSE_LOGS = false -- Use specifically for debugging, lots of clutter!

function service:HasPermission(player, data)
	if not self.hasInitialised then
		if self.initialising then
			repeat
				task.wait()
			until self.hasInitialised
		end
	end

	if data == nil and player ~= nil then
		data = player
	end

	if typeof(data) == "Instance" then
		if data:IsA("ObjectValue") then
			data = data.Value
		end
		if data:IsA("ModuleScript") then
			data = require(data)
		end
	elseif type(data) == "string" then
		data = { data }
	end

	if typeof(player) == "number" then
		for _, playerObj in ipairs(players:GetPlayers()) do
			if playerObj.UserId == player then
				player = playerObj
			end
		end

		if typeof(player) == "number" then
			return false
		end
	end

	local requireAll = not not (data and data.RequireAll) -- if RequireAll is an argument, it will require all conditions to be met

	for _, permissionSegment in pairs(data) do
		if type(permissionSegment) == "table" then
			if self:HasPermission(player, permissionSegment) then
				if not requireAll then
					return true
				end
			elseif requireAll then
				return false
			end
		elseif type(permissionSegment) == "string" then
			local returnOpposite = false

			if string.sub(permissionSegment, 0, 1) == "!" then
				returnOpposite = true
				permissionSegment = string.sub(permissionSegment, 2)
			end

			local split = string.split(permissionSegment, ":")
			local functionName = split[1]

			if self._Functions[functionName] then
				local hasPerm = self._Functions[functionName](player, self, table.unpack(split, 2))

				if returnOpposite then
					hasPerm = not hasPerm
				end

				if hasPerm then
					if not requireAll then
						return true
					end
				elseif requireAll then
					return false
				end
			elseif requireAll then
				warn(
					'Permission function with the name "' .. functionName .. '" was not found (ReqAll).',
					debug.traceback()
				)
				return false
			end
		elseif typeof(permissionSegment) == "function" then
			local success, result = pcall(permissionSegment, player)
			local passedCheck = success and (result == true)

			if passedCheck and not requireAll then
				return true
			elseif not passedCheck and requireAll then
				return false
			end
		end
	end

	return requireAll
end

function service.Client:HasPermission(player, data)
	return self.Server:HasPermission(player, data)
end

function service:RegisterFunction(name, _function)
	self._Functions[name] = _function
end

function service:RegisterFunctionsIn(folder: Folder)
	local children = folder:GetChildren()

	for i, module in pairs(children) do
		if module:IsA("ModuleScript") then
			local success, _ = pcall(function()
				return self:RegisterFunction(module.Name, require(module))
			end)

			if success and VERBOSE_LOGS then
				print("Registered permission function:", module.Name, tostring(i) .. "/" .. tostring(#children))
			elseif VERBOSE_LOGS then
				warn('Failed to register permission function "' .. module.Name .. '":')
			end
		end
	end

	print("Registered permissions functions in", folder)
end

function service:KnitStart()
	self.initialising = true
	self:RegisterFunctionsIn(permissions)
	self.hasInitialised = true
	self.initialising = false
end

return service
