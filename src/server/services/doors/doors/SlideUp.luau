local tweenService = game:GetService("TweenService")

function weld(o1, o2)
	if o1:IsA("BasePart") and o2:IsA("BasePart") then
		local w = Instance.new("Weld")
		w.Parent = o1
		w.C0 = o1.CFrame:Inverse() * CFrame.new(o1.CFrame.p)
		w.C1 = o2.CFrame:Inverse() * CFrame.new(o1.CFrame.p)
		w.Part0 = o1

		w.Part1 = o2

		o2.Anchored = false
	end
end

return {
	name = "SlideUp",
	actuate = function(self, shouldOpen)
		local timeToComplete
		local soundName = shouldOpen and "OpenSound" or "CloseSound"

		if self[soundName] and self[soundName]:IsA("Sound") then
			self[soundName]:Play()
		end

		if not shouldOpen then
			for _, object in ipairs(self.Object.Doors:GetChildren()) do
				timeToComplete = self.Object.Doors.Door.Main:WaitForChild("Close").TimeLength

				tweenService
					:Create(object.Main, TweenInfo.new(timeToComplete), { CFrame = object.Main.OrigPos.Value })
					:Play()
			end

			task.wait(timeToComplete)

			if self.Object.Frame:FindFirstChild("Dust") then
				self.Object.Frame.Dust.ParticleEmitter:Emit(70)
			end

			return true
		else
			for _, object in ipairs(self.Object.Doors:GetChildren()) do
				timeToComplete = self.Object.Doors.Door.Main:WaitForChild("Open").TimeLength

				tweenService
					:Create(
						object.Main,
						TweenInfo.new(timeToComplete),
						{ CFrame = object.Main.OrigPos.Value * CFrame.new(0, 0, -object.Main.Size.Z) }
					)
					:Play()
			end

			task.wait(timeToComplete)

			return true
		end
	end,
	setup = function(self)
		if
			self.OpenSound
			and tonumber(self.OpenSound)
			and self.Object.Doors
			and self.Object.Doors.Door
			and self.Object.Doors.Door.Main
		then
			local openSound = Instance.new("Sound")
			openSound.SoundId = "rbxassetid://" .. tostring(self.OpenSound)
			openSound.Name = "Open"
			openSound.Parent = self.Object.Doors.Door.Main

			self.OpenSound = openSound
		end

		if
			self.CloseSound
			and tonumber(self.CloseSound)
			and self.Object.Doors
			and self.Object.Doors.Door
			and self.Object.Doors.Door.Main
		then
			local closeSound = Instance.new("Sound")
			closeSound.SoundId = "rbxassetid://" .. tostring(self.CloseSound)
			closeSound.Name = "Close"
			closeSound.Parent = self.Object.Doors.Door.Main

			self.CloseSound = closeSound
		end

		for _, door in pairs(self.Object.Doors:GetChildren()) do
			local originalPosition = Instance.new("CFrameValue")
			originalPosition.Name = "OrigPos"
			originalPosition.Value = door.Main.CFrame
			originalPosition.Parent = door.Main

			for _, child in pairs(door:GetChildren()) do
				if child ~= door.Main and child:IsA("BasePart") then
					weld(door.Main, child)
				end
			end
		end

		self:setObjectCollisionGroup("Doors")
	end,
}
