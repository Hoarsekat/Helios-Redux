local groupAbbreviations = require(game:GetService('ReplicatedStorage'):WaitForChild('common'):WaitForChild('abbreviations'):WaitForChild('group'))

return function(player, _, group, rank)
	local groupId = groupAbbreviations[group] or tonumber(group)

	if not groupId then
		return false
	end

	local playerRank = player:GetRankInGroup(groupId)

	if playerRank then
		local splitRank = string.split(rank, ",")

		for _, rankSegment in pairs(splitRank) do
			if rankSegment:find("-") then
				local splitSegment = string.split(rankSegment, "-")

				if (playerRank >= tonumber(splitSegment[1])) and (playerRank <= tonumber(splitSegment[2])) then
					return true
				end
			else
				if playerRank == tonumber(rankSegment) then
					return true
				end
			end
		end
	else
		return playerRank > 0
	end

	return false
end
