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
	name = "FireDoorUp",
	actuate = function(self, shouldOpen)
		local timeToComplete
		local soundName = shouldOpen and "OpenSound" or "CloseSound"

		if not shouldOpen then
			if self.Object.Alarms then
				for _, alarm in ipairs(self.Object.Alarms:GetChildren()) do
					if alarm:IsA("Model") and alarm:FindFirstChild("Bulb") then
						local bulb = alarm.Bulb
						local hinge = bulb:FindFirstChild("HingeConstraint")
						local neon = bulb:FindFirstChild("Neon")
						if hinge and neon then
							hinge.AngularVelocity = 5
							neon.Material = Enum.Material.Neon
							for _, v in pairs(neon:GetChildren()) do
								if v.ClassName == "SpotLight" then
									v.Enabled = true
								end
							end
						end
					end
				end
			end

			if self.AlarmSound then
				self.AlarmSound:Play()
			end

			task.wait(2)

			if self[soundName] and self[soundName]:IsA("Sound") then
				self[soundName]:Play()
			end

			for _, object in ipairs(self.Object.Doors:GetChildren()) do
				timeToComplete = self.Object.Doors.Door.Main:WaitForChild("Close").TimeLength * 2

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
			if self.Object.Alarms then
				for _, alarm in ipairs(self.Object.Alarms:GetChildren()) do
					if alarm:IsA("Model") and alarm:FindFirstChild("Bulb") then
						local bulb = alarm.Bulb
						local hinge = bulb:FindFirstChild("HingeConstraint")
						local neon = bulb:FindFirstChild("Neon")
						if hinge and neon then
							hinge.AngularVelocity = 0
							neon.Material = Enum.Material.Plastic
							for _, v in pairs(neon:GetChildren()) do
								if v.ClassName == "SpotLight" then
									v.Enabled = false
								end
							end
						end
					end
				end
			end

			if self.AlarmSound then
				self.AlarmSound:Stop()
			end

			if self[soundName] and self[soundName]:IsA("Sound") then
				self[soundName]:Play()
			end

			for _, object in ipairs(self.Object.Doors:GetChildren()) do
				timeToComplete = self.Object.Doors.Door.Main:WaitForChild("Open").TimeLength * 2

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
			openSound.PlaybackSpeed = 0.5
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
			closeSound.PlaybackSpeed = 0.5
			closeSound.Parent = self.Object.Doors.Door.Main

			self.CloseSound = closeSound
		end

		if tonumber(self.AlarmSound) then
			local alarmSound = Instance.new("Sound")
			alarmSound.SoundId = "rbxassetid://" .. tostring(self.AlarmSound)
			alarmSound.Name = "Alarm"
			alarmSound.Looped = true
			alarmSound.RollOffMinDistance = 20
			alarmSound.Parent = self.Object.Doors.Door.Main
			self.AlarmSound = alarmSound
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
