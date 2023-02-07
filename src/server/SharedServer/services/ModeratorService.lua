local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ModeratorService = Knit.CreateService {
    Name = "ModeratorService",
    Client = {

    },
}

local config = require(ReplicatedStorage.config)


local banList = {

}

local Promise = require(ReplicatedStorage.Packages.Promise)


--do not make direct method of service to prevent potential abuse / all banning must be handled HERE
function BanPlayer(player)

end

function KickPlayer(player)
    --todo: add a delay between each try
	Promise.retry(
		Promise.new(function(resolve, reject)

			local success, result = pcall(function()
				return player:Kick()
			end)

			if not success then
				warn(`Failed to kick {player.Name} : {result} `)
				reject(result)
			else
				resolve(result)
			end
		end),
		config.maxModerationTries
	)
end

function ModeratorService:CheckPlayerModerated(player)

    --this may not be as performant as just checking a dictionary key if banList becomes too big
    for _, v in banList do 
        if v == player.UserId then
            player:Kick()
        end
    end

    --todo check database entry
end


function ModeratorService.Client:CheckPlayerModerated(player)
    return self.Server:CheckPlayerModerated(player)
end


return ModeratorService
