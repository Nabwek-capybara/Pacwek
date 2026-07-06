Pacwek = LibStub("AceAddon-3.0"):NewAddon(
    "Pacwek",
    "AceEvent-3.0",
    "AceConsole-3.0"
)

Pacwek.softres = {}
Pacwek.activeLoot = {}

function Pacwek:OnInitialize()

    PacwekDB = PacwekDB or {}

    PacwekDB.softres =
        PacwekDB.softres or {}

    self.softres =
        PacwekDB.softres
print(Pacwek.SlashCommand)
    self:RegisterChatCommand(
        "pacwek",
		"SlashCommand"
    )
	 self:RegisterChatCommand(
        "pw",
		"SlashCommand"
    )

    PacwekCompat:Print(
        "Loaded for WoW 3.3.5a"
    )
end


function Pacwek:LOOT_OPENED()

		PacwekLoot:LOOT_OPENED()

end

function Pacwek:OnEnable()

end

-- =========================
-- Dostępne komendy:
-- 		/pacwek
-- 		/pw
-- 		/pwroll
--		/pwtest - do testowania SR
-- =========================

function Pacwek:SlashCommand(msg)
    msg = string.lower(msg or "")

    if msg == "show" then
        PacwekUI:Toggle()
        return
    end
	
	if msg == "clear" then
		PacwekSoftRes:Clear()
		return
	end

    if string.find(msg, "sr ") then
        local data = string.sub(msg, 4)
        PacwekSoftRes:Import(data)
        return
    end

    PacwekCompat:Print("Commands:")
	PacwekCompat:Print("/pwsr")
    PacwekCompat:Print("/Pacwek show or /pw show")
    PacwekCompat:Print("/Pacwek sr <data> or /pw sr <data>")
	PacwekCompat:Print("/pwroll <item>")
end

SLASH_PACWEKSR1 = "/pwsr"

SlashCmdList["PACWEKSR"] = function(msg)

    if not Pacwek.softres then
        PacwekCompat:Print("No SoftRes data loaded")
        return
    end

    local found = false

    for item, players in pairs(Pacwek.softres) do

        found = true

        PacwekCompat:Print(
            item .. " -> " ..
            table.concat(players, ", ")
        )
    end

    if not found then
        PacwekCompat:Print("No reserves found")
    end
end



SLASH_PWROLL1 = "/pwroll"

SlashCmdList["PWROLL"] = function(msg)

    msg = msg or ""

    if msg == "" then

        PacwekCompat:Print(
            "Usage: /pwroll [count] <item link>"
        )

        return
    end

    local count = 1
    local item = msg

    -- Czy pierwszy argument jest liczbą?
    local firstArg, rest = string.match(
        msg,
        "^(%d+)%s+(.+)$"
    )
	
	if count < 1 then

		PacwekCompat:Print(
			"Item count must be at least 1."
		)

		return
	end
	
    if firstArg then

        count = tonumber(firstArg)
        item = rest
    end

    PacwekRolls:Start(
        item,
        count
    )
end


-- =======================
-- Dev commands
-- =======================

SLASH_PWTIE1 = "/pwtie"


SlashCmdList["PWTIE"] = function()

    PacwekRolls.active = true

    PacwekRolls.current = {

        item = "Tie Test",

        itemLink = "Tie Test",

        count = 3,
		
		reservers = {
			Bowek = 1,
			Mossa = 1,
			Bonre = 1,
			Plebster = 1,
		},

        winners = {},

        resolvedCount = 0,

        rolls = {

            Bowek = {
                SR = {99},
            },

            Mossa = {
                SR = {95},
            },

            Bonre = {
                SR = {95},
            },
			
			Plebster = {
				SR = {95},
			},

        },
    }

    PacwekRolls:Finish()
end


SLASH_PWREROLL1 = "/pwreroll"


SlashCmdList["PWREROLL"] = function()

    PacwekRolls.current.rolls = {

        Mossa = {
            SR = {81},
        },

        Bonre = {
            SR = {97},
        },

        Plebster = {
            SR = {55},
        },
    }
end


SLASH_PWTEST1 = "/pwtest"

SlashCmdList["PWTEST"] = function(msg)

    msg = msg or ""

    if msg == "" then
        msg = "Returning Footalls"
    end

    PacwekRolls:Start(msg, 2)
end





-- =================
-- Koniec dev testu
-- ================