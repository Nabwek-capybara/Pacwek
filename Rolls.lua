PacwekRolls = {}

PacwekRolls.active = false

PacwekRolls.current = {
    item = nil,
    reservers = {},
    rolls = {},
    reroll = false,
    rerollPlayers = {},
}

local frame = CreateFrame("Frame")

frame:RegisterEvent("CHAT_MSG_SYSTEM")

frame:SetScript("OnEvent", function(self, event, message)

    if not PacwekRolls.active then
        return
    end

    local player, roll, low, high = string.match(
        message,
        "(.+) rolls (%d+) %((%d+)%-(%d+)%)"
    )

    if not player then
        return
    end

    roll = tonumber(roll)
    low = tonumber(low)
    high = tonumber(high)

    if low ~= 1 then
        return
    end

    local rollType = nil
	
	local hasSR =
		PacwekRolls:HasSR()

    if high == 100 then
	
		if hasSR then
			rollType = "SR"
		else
			rollType = "MS"
		end
    elseif high == 99 then
        rollType = "OS"
    elseif high == 98 then
        rollType = "TMOG"
    else
        return
    end

    local current = PacwekRolls.current

    -- reroll mode
    if current.reroll then

        local allowed = false

        for _, name in ipairs(current.rerollPlayers) do
            if name == player then
                allowed = true
                break
            end
        end

        if not allowed then
            return
        end
    end

    local reserveCount =
        current.reservers[player] or 0

    local hasSR =
        PacwekRolls:HasSR()

    -- item has SR -> only reservers may MS roll
    if hasSR then

    if rollType ~= "SR" then

        PacwekCompat:Print(
            "Ignored non-SR roll from " ..
            player
        )

        return
    end

    if reserveCount <= 0 then

        PacwekCompat:Print(
            "Ignored non-reserver " ..
            player
        )

        return
    end
end

    current.rolls[player] =
        current.rolls[player] or {}



    local existing =
        current.rolls[player][rollType]

    local maxAllowed = 1

    if rollType == "SR" and reserveCount > 1 then
        maxAllowed = reserveCount
    end

    local totalRolls = 0

    if existing then
        totalRolls = #existing
    end

    if totalRolls >= maxAllowed then

        PacwekCompat:Print(
            player ..
            " exceeded allowed rolls"
        )

        return
    end

    current.rolls[player][rollType] =
        current.rolls[player][rollType] or {}

    table.insert(
        current.rolls[player][rollType],
        roll
    )

    PacwekCompat:Print(
        player ..
        " rolled " ..
        roll ..
        " (" ..
        rollType ..
        ")"
    )
	
	PacwekRolls:CheckAutoFinish()
	
end)


-- ===================================
-- Start roll sesji
--
-- Item:
--     	item name lub item link
-- ===================================


function PacwekRolls:Start(item, count)

	count = count or 1

	local itemLink = item
	
	local itemName =
    GetItemInfo(item)
	
	if itemName then
		
		local realItemLink = 
			select(2, GetItemInfo(item))
			
		if realItemLink then
			itemLink = realItemLink
		end
	
	item = itemName
	
	end


    self.active = true

    self.current = {
        item = item,
		itemLink = itemLink,
		count = count,
        reservers = {},
        rolls = {},
        reroll = false,
        rerollPlayers = {},
		winners = {},
		resolvedCount = 0,
    }

    local reservers =
        PacwekSoftRes:GetItemReservers(item)

    for _, player in ipairs(reservers) do

        self.current.reservers[player] =
            (self.current.reservers[player] or 0) + 1
    end

    local announceItem =
		itemLink or item
		
	if count > 1 then
		announceItem = 
			announceItem ..
			" x" ..
			count
	end
	
	SendChatMessage(
		"Rolling for " ..
		announceItem ..
		" MS/SR: /roll - OS: /roll 99 - TMOG: /roll 98",
		"RAID_WARNING"
	)

    if #reservers > 0 then

        SendChatMessage(
            "Reserved by: " ..
            table.concat(reservers, ", "),
            "RAID"
        )
    end
	

	C_Timer.After(10, function()

    if PacwekRolls.active then

        SendChatMessage(
            "Rolling ends in 5 seconds",
            "RAID_WARNING"
        )
    end
end)

C_Timer.After(12, function()

    if PacwekRolls.active then

        SendChatMessage(
            "3...",
            "RAID"
        )
    end
end)

C_Timer.After(13, function()

    if PacwekRolls.active then

        SendChatMessage(
            "2...",
            "RAID"
        )
    end
end)

C_Timer.After(14, function()

    if PacwekRolls.active then

        SendChatMessage(
            "1...",
            "RAID"
        )
    end
end)

    C_Timer.After(15, function()
        PacwekRolls:Finish()
    end)
end

-- ======================================
-- Funkcja do sprawdzania czy na itemie jest SR, zwraca false w przypadku gdy go brak
-- ======================================

function PacwekRolls:HasSR()

    if not self.current
    or not self.current.reservers then
        return false
    end

    for _, count in pairs(
        self.current.reservers
    ) do

        if count > 0 then
            return true
        end
    end

    return false
end

-- ================================================
-- Zwraca:
-- Highest roll, listę winnerów
--
-- count = ilość kopii itema
-- 
-- Double SR daje dodatkowe szanse na roll,
-- Ale gracz może wygrać makmsymalnie
-- jedną kopię danego iteam per roll
--
-- winnerlist ogarnia gdy jest potrzebny reroll lub kilka osób wygrywa ten sam item jak np. w przypadku tokenów
-- =============================================================

function PacwekRolls:GetHighestRoll(tier)

    local highest = 0
    local winners = {}

    for player, data in pairs(self.current.rolls) do

        if data[tier] then

            for _, roll in ipairs(data[tier]) do

                if roll > highest then

                    highest = roll
                    winners = { player }

                elseif roll == highest then

                    table.insert(
                        winners,
                        player
                    )
                end
            end
        end
    end

    return highest, winners
end


-- ====================================
-- Sprawdza czy ostatnie miejsce
-- kwalifikujące się do wygranej
-- ma remis
--
-- Zwraca:
-- tiePlayers
-- tieRoll
-- ====================================

function PacwekRolls:GetTiePlayers(tier,count)


    local entries = {}

    local excluded = {}

    for _, winner in ipairs(
        self.current.winners
    ) do

        excluded[winner.player] = true
    end

    for player, rollsByType in pairs(
        self.current.rolls
    ) do

        if not excluded[player]
        and rollsByType[tier] then

            for _, roll in ipairs(
                rollsByType[tier]
            ) do

                table.insert(entries, {
                    player = player,
                    roll = roll,
                })
            end
        end
    end

    table.sort(entries, function(a, b)
        return a.roll > b.roll
    end)

    local unique = {}
    local usedPlayers = {}

    for _, entry in ipairs(entries) do

        if not usedPlayers[entry.player] then

            table.insert(unique, entry)

            usedPlayers[entry.player] = true
        end
    end

    local border =
        count - self.current.resolvedCount

    if border <= 0 then
        return nil
    end

    if #unique < border then
        return nil
    end

    local borderRoll =
        unique[border].roll

    local tiePlayers = {}

    for _, entry in ipairs(unique) do

        if entry.roll == borderRoll then

            table.insert(
                tiePlayers,
                entry.player
            )
        end
    end

    if #tiePlayers > 1 then
        return tiePlayers
    end

    return nil
end

-- ====================================
-- Zwraca najlepszych unikalnych graczy
-- dla danego tieru rolla
-- ====================================

function PacwekRolls:GetTopPlayers(tier, count)

    local entries = {}
	
	-- Gracze którzy już wygrali
-- ====================================

	local excluded = {}

	for _, winner in ipairs(
		self.current.winners
	) do

		excluded[winner.player] = true
	end

    for player, rollsByType in pairs(
        self.current.rolls
    ) do

        if rollsByType[tier] then

            for _, roll in ipairs(
                rollsByType[tier]
            ) do

                table.insert(entries, {
                    player = player,
                    roll = roll,
                })
            end
        end
    end

    table.sort(entries, function(a, b)
        return a.roll > b.roll
    end)

    local winners = {}
    local usedPlayers = {}

    for _, entry in ipairs(entries) do

        if not usedPlayers[entry.player]
		and not excluded[entry.player] then

            table.insert(
                winners,
                entry
            )

            usedPlayers[entry.player] = true

            if #winners >= count then
                break
            end
        end
    end
	
    return winners
end


-- =======================================
-- Finish sesji rollowania
-- 
-- Priorytet: SR > MS > OS >Tmog
--
-- Funkcja ogarnia:
-- - Winner detection
-- - Rerolle
-- - Remisy
-- =======================================

function PacwekRolls:Finish()

    if not self.active then
        return
    end

    local hasSR = self:HasSR()

    local priority

    local itemCount =
        self.current.count or 1

    if hasSR then

        priority = {
            "SR",
        }

    else

        priority = {
            "MS",
            "OS",
            "TMOG",
        }
    end

    for _, tier in ipairs(priority) do

        local winners =
            self:GetTopPlayers(
                tier,
                itemCount
            )
			
		local tiePlayers =
			self:GetTiePlayers(
				tier,
				itemCount
			)
			
	if tiePlayers then
	
		local border =
			itemCount -
			self.current.resolvedCount

		local safeWinners = border - 1

		for i = 1, safeWinners do

			local winner =
				winners[i]

			table.insert(
				self.current.winners,
				{
					player = winner.player,
					roll = winner.roll,
					tier = tier,
				}
			)

			self.current.resolvedCount =
            self.current.resolvedCount + 1
		end

		self.current.reroll = true
		self.current.rerollPlayers = tiePlayers
		self.current.rolls = {}

		SendChatMessage(
			"Tie for remaining positions:  " ..
				table.concat(
				tiePlayers,
				", "
			),
			"RAID_WARNING"
		)

		SendChatMessage(
			"Reroll now",
			"RAID_WARNING"
		)

		C_Timer.After(
			15,
			function()
            PacwekRolls:Finish()
			end
		)

		return
	end

        if #winners > 0 then

            -- ====================================
            -- Jeden item
            -- ====================================

            if itemCount == 1 then

                local winner =
                    winners[1]

                SendChatMessage(
                    winner.player ..
                    " wins " ..
                    (self.current.itemLink or self.current.item) ..
                    " with " ..
                    winner.roll ..
                    " (" ..
                    tier ..
                    ")",
                    "RAID"
                )

                self.active = false

                return
            end

            -- ====================================
            -- Wiele kopii itema
            -- ====================================

            SendChatMessage(
    "Winners for " ..
    (self.current.itemLink or self.current.item) ..
    ":",
    "RAID_WARNING"
)

		local finalWinners = {}

		-- zwycięzcy zapisani przed rerollem

		for _, winner in ipairs(
					self.current.winners
					) do

						table.insert(
						finalWinners,
						winner
					)
		end

	-- zwycięzcy z ostatniej rundy

		for _, winner in ipairs(winners) do

			table.insert(
				finalWinners,
				winner
			)
		end

		for index, winner in ipairs(
			finalWinners
		) do

			SendChatMessage(
				index ..
				". " ..
				winner.player ..
				" (" ..
				winner.roll ..
				")",
				"RAID"
			)
		end

            self.active = false

            return
        end
    end

    SendChatMessage(
        "No valid rolls for " ..
        self.current.item,
        "RAID"
    )

    self.active = false
end


-- ====================================================
-- Automatyczny end SR rolla gdy
-- wszyscy gracze z SR na itemie zrobią roll
-- ====================================================

function PacwekRolls:CheckAutoFinish()

    if not self:HasSR() then
        return
    end

    for player, count in pairs(
        self.current.reservers
    ) do
		
        local data =
            self.current.rolls[player]

        local rolls = 0

        if data and data["SR"] then
            rolls = #data["SR"]
        end

        if rolls < count then
            return
        end
    end

    SendChatMessage(
        "All SR rolls received",
        "RAID"
    )

    self:Finish()
end