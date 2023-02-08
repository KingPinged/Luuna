local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local UpdateService = Knit.CreateService({
	Name = "UpdateService",
	Client = {},
})

local needToCloseServerAt

--TODO warning: watch messagingservice limits. should we make a messaging knit service to middleware all messaginservices?

--TODO: open cloud will notify that there is an update and thus the server should now close
--TODO: use memory store instead of messagingservice if possible in the future for open cloud
function UpdateService:KnitStart()
	--TODO: if you can not use open cloud on memory store, then I have to use httpservice instead for servers that start after announced

	MessagingService:SubscribeAsync("globalData", function(data)
		if data.updateTime > os.time() then
			needToCloseServer = true
		end
	end)
end

function UpdateService:KnitInit() end

return UpdateService
