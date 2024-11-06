local knit = require("@packages/knit")
local promise = require("@packages/promise")

local runtime = os.clock()

promise
	.new(function(resolve)
		for _, v in ipairs(script.controllers:GetDescendants()) do
			if v:IsA("ModuleScript") and v.Name:find("controller$") then
				require(v)
			end
		end

		resolve()
	end)
	:catch(warn)

promise
	.try(knit.Start)
	:andThen(function()
		print(string.format("[Client] Took %.4f seconds to initialize controllers.", os.clock() - runtime))
	end)
	:catch(warn)
