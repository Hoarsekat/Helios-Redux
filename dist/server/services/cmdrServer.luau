local cmdr = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('cmdr'))
cmdr:RegisterDefaultCommands()
cmdr:RegisterCommandsIn(script.Parent.Parent.commands)
return nil
