local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

Knit.AddServices(script.Parent.SharedServer.services)
Knit.AddServices(script.Parent.Lobby.services)

Knit.Start():catch(warn)
