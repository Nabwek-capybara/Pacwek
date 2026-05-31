PacwekSoftRes = {}

function PacwekSoftRes:Import(raw)

    if not raw or raw == "" then
        PacwekCompat:Print("No SoftRes data")
        return
    end

    PacwekDB.softres = {}
	Pacwek.softres = PacwekDB.softres

    local imported = 0

    for line in string.gmatch(raw, "[^\r\n]+") do

        -- pomijamy nagłówek
        if not string.find(line, "^Item,Name") then

            local item, player

            -- CSV z cudzysłowami
            if string.sub(line, 1, 1) == "\"" then

                local closingQuote = string.find(
                    line,
                    "\",",
                    2,
                    true
                )

                if closingQuote then

                    item = string.sub(
                        line,
                        2,
                        closingQuote - 1
                    )

                    player = string.sub(
                        line,
                        closingQuote + 2
                    )
                end

            else
                -- fallback dla prostego CSV
                item, player = string.match(
                    line,
                    "([^,]+),(.+)"
                )
            end

            if item and player then

                item = string.gsub(item, "^%s+", "")
                item = string.gsub(item, "%s+$", "")

                player = string.gsub(player, "^%s+", "")
                player = string.gsub(player, "%s+$", "")

                if item ~= "" and player ~= "" then

                    Pacwek.softres[item] =
                        Pacwek.softres[item] or {}

                    table.insert(
                        Pacwek.softres[item],
                        player
                    )

                    imported = imported + 1
                end
            end
        end
    end

    PacwekCompat:Print(
        "Imported " .. imported .. " SoftRes entries"
    )
end

function PacwekSoftRes:GetItemReservers(itemName)

    if not Pacwek.softres then
        return {}
    end

    return Pacwek.softres[itemName] or {}
end