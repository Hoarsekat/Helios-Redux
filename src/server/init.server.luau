local indium = require("@packages/indium")
local promise = require("@packages/promise")

local runtime = os.clock()

promise
	.new(function(resolve)
		for _, v in ipairs(script.services:GetDescendants()) do
			if v:IsA("ModuleScript") and v.Name:find("service$") then
				require(v)
			end
		end

		resolve()
	end)
	:catch(warn)

promise
	.try(indium.Start)
	:andThen(function()
		print(string.format("[Server] Took %.4f seconds to initialize services.", os.clock() - runtime))
	end)
	:catch(warn)
