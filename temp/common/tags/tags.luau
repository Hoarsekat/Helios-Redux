local collectionService = game:GetService("CollectionService")

local tags = {}

function tags.bindToTag(tag, callback)
	task.spawn(function()
		for _, item in ipairs(collectionService:GetTagged(tag)) do
			task.spawn(function()
				callback(item)
			end)
		end
	end)

	return collectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

function tags.bindToTagRemoved(tag, callback)
	return collectionService:GetInstanceRemovedSignal(tag):Connect(callback)
end

return tags
