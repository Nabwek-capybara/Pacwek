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

function Pacwek:SlashCommand(msg)
    msg = string.lower(msg or "")

    if msg == "show" then
        PacwekUI:Toggle()
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

SLASH_PWTEST1 = "/pwtest"

SlashCmdList["PWTEST"] = function(msg)

    msg = msg or ""

    if msg == "" then
        msg = "Deathbringer's Will"
    end

    PacwekRolls:Start(msg)
end