RLCore = nil

TriggerEvent('RLCore:GetObject', function(obj) RLCore = obj end)

RegisterServerEvent('pw_character:server:exitCharCreator')
AddEventHandler('pw_character:server:exitCharCreator', function(data)
    if data ~= nil then
        local _src = source
        local _char = RLCore.Functions.GetPlayer(_src)
        _char.toggleNewCharacter()
        TriggerEvent('pw_character:server:initialCharSave', _src, data, 'Default')
        TriggerClientEvent('pw_character:client:completedCharCreation', _src)
    end
end)

RegisterServerEvent('pw_character:server:initialCharSave')
AddEventHandler('pw_character:server:initialCharSave', function(source, data, name)
    local _char = RLCore.Functions.GetPlayer(source)
    local _cid = _char.PlayerData.citizenid()
    local _steam = _char.PlayerData.steam()
    if data ~= nil and name ~= nil then
        local skin = {
            ['hair1'] = data.drawables[2],
            ['hair2'] = data.drawtextures[3],
            ['hairColor'] = data.hairColor,
            ['headOverlay'] = data.headOverlay,
            ['headStructure'] = data.headStructure,
            ['headBlend'] = data.headBlend,
        }

        local updatedSkin = json.encode(skin)

        exports.ghmattimysql.execute("UPDATE `characters` SET `skin` = @skin WHERE `steam` = @steam AND `cid` = @cid", {['@skin'] = updatedSkin, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
            if updated > 0 then
                print('Set Initial Character Skin')
            end
        end)

        local outfit = {
            ['model'] = data.model,
            ['drawables'] = data.drawables,
            ['drawtextures'] = data.drawtextures,
            ['props'] = data.props,
            ['proptextures'] = data.proptextures,
        }

        local newOutfit = json.encode(outfit)

        exports.ghmattimysql:execute("INSERT INTO `character_outfits` (`cid`,`name`,`data`) VALUES (@cid, @name, @data)", {['@cid'] = _cid, ['@name'] = name, ['@data'] = newOutfit}, function(outfitId)
            if outfitId > 0 then
                exports.ghmattimysql:execute("UPDATE `characters` SET `cur_outfit` = @cur_outfit WHERE `steam` = @steam AND `cid` = @cid", {['@cur_outfit'] = outfitId, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
                    if updated > 0 then
                        _char.setLastOutfit(outfitId)
                    end
                end)
            end
        end)
    end
end)

RLCore.Functions.CreateCallback('pw_character:server:updateSkinData', function(source, cb, data)
    local _src = source
    local _char = RLCore.Functions.GetPlayer(_src)
    local _cid = _char.PlayerData.citizenid
    local _steam = _char.PlayerData.steam
    skin = {
        ['hair1'] = data.drawables[2],
        ['hair2'] = data.drawtextures[3],
        ['hairColor'] = data.hairColor,
        ['headOverlay'] = data.headOverlay,
        ['headStructure'] = data.headStructure,
        ['headBlend'] = data.headBlend,
    }

    local updatedSkin = json.encode(skin)

    exports.ghmattimysql:execute("UPDATE `characters` SET `skin` = @skin WHERE `steam` = @steam AND `cid` = @cid", {['@skin'] = updatedSkin, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
        if updated > 0 then
            cb(true)
        else
            cb(false)
        end
    end)
end)

RLCore.Functions.CreateCallback('pw_character:server:saveNewOutfit', function(source, cb, data, name)
    local _src = source
    local _char = RLCore.Functions.GetPlayer(_src)
    local _cid = _char.PlayerData.citizenid
    local _steam = _char.PlayerData.steam
    local outfit = {
        ['model'] = data.model,
        ['drawables'] = data.drawables,
        ['drawtextures'] = data.drawtextures,
        ['props'] = data.props,
        ['proptextures'] = data.proptextures,
    }

    local newOutfit = json.encode(outfit)

    exports.ghmattimysql:execute("SELECT * FROM `character_outfits` WHERE `cid` = @cid", {['@cid'] = _cid}, function(outfitAmount)
        local total = #outfitAmount
        if total < 10 then
            exports.ghmattimysql:execute("INSERT INTO `character_outfits` (`cid`,`name`,`data`) VALUES (@cid, @name, @data)", {['@cid'] = _cid, ['@name'] = name, ['@data'] = newOutfit}, function(outfitId)
                if outfitId > 0 then
                    exports.ghmattimysql:execute("UPDATE `characters` SET `cur_outfit` = @cur_outfit WHERE `steam` = @steam AND `cid` = @cid", {['@cur_outfit'] = outfitId, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
                        if updated > 0 then
                            _char.setLastOutfit(outfitId)
                            cb(true, total)
                        else
                            cb(false, total)
                        end
                    end)
                else
                    cb(false, total)
                end
            end)
        else
            cb(false, total)
        end
    end)
end)

RLCore.Functions.CreateCallback('pw_character:server:replaceCurrentOutfit', function(source, cb, data)
    local _src = source
    local _char = RLCore.Functions.GetPlayer(_src)
    local _cid = _char.PlayerData.citizenid
    local _currentOutfit = _char.getLastOutfit()
    local outfit = {
        ['model'] = data.model,
        ['drawables'] = data.drawables,
        ['drawtextures'] = data.drawtextures,
        ['props'] = data.props,
        ['proptextures'] = data.proptextures,
    }

    local newOutfit = json.encode(outfit)

    exports.ghmattimysql:execute("UPDATE `character_outfits` SET `data` = @data WHERE `outfit_id` = @outfit_id AND `cid` = @cid", {['@outfit_id'] = _currentOutfit, ['@cid'] = _cid, ['@data'] = newOutfit}, function(updated)
        if updated > 0 then
            cb(true)
        else
            cb(false)
        end
    end)
end)

RLCore.Functions.CreateCallback('pw_character:server:updateTattoos', function(source, cb, tattoos)
    local _src = source
    local _char = RLCore.Functions.GetPlayer(_src)
    local _cid = _char.PlayerData.citizenid
    if tattoos ~= nil then

        local newTattoos = json.encode(tattoos)

        exports.ghmattimysql:execute("UPDATE `characters` SET `tattoos` = @tattoos WHERE `cid` = @cid", {['@tattoos'] = newTattoos, ['@cid'] = _cid}, function(updated)
            if updated > 0 then
                cb(true)
            else
                cb(false)
            end
        end)
    else
        cb(false)
    end
end)

RLCore.Functions.CreateCallback('pw_character:server:getTattooData', function(source, cb)
    local _char = RLCore.Functions.GetPlayer(source)
    local _cid = _char.PlayerData.citizenid
    local TattooData = exports.ghmattimysql:executeSync("SELECT `tattoos` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
    local charTattoos = nil
    if TattooData ~= nil then
        charTattoos = json.decode(TattooData)
    end
    cb(charTattoos)
end)


RLCore.Functions.CreateCallback('pw_character:server:getCharSkin', function(source, cb)
    local _char = RLCore.Functions.GetPlayer(source)
    local _cid = _char.PlayerData.citizenid
    local _steam = _char.PlayerData.steam
    local _lastout = _char.getLastOutfit()
    local outfitData = exports.ghmattimysql:executeSync("SELECT `data` FROM `character_outfits` WHERE `outfit_id` = @id", {['@id'] = _lastout})
    local SkinData = exports.ghmattimysql:executeSync("SELECT `skin` FROM `characters` WHERE `steam` = @steam AND `cid` = @cid", {['@steam'] = _steam, ['@cid'] = _cid})
    local TattooData =exports.ghmattimysql:executeSync("SELECT `tattoos` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
    if outfitData ~= nil and SkinData ~= nil then
        local newOutfitData = json.decode(outfitData)
        local newSkinData = json.decode(SkinData)
        local charTattoos = nil
        if TattooData ~= nil then
            charTattoos = json.decode(TattooData)
        end

        local actualSkin = {
            ['model'] = tonumber(newOutfitData.model),
            ['drawables'] = newOutfitData.drawables,
            ['drawtextures'] = newOutfitData.drawtextures,
            ['props'] = newOutfitData.props,
            ['proptextures'] = newOutfitData.proptextures,
            ['hairColor'] = newSkinData.hairColor,
            ['headOverlay'] = newSkinData.headOverlay,
            ['headStructure'] = newSkinData.headStructure,
            ['headBlend'] = newSkinData.headBlend,
        }
        actualSkin.drawables["2"] = newSkinData.hair1
        actualSkin.drawtextures[3] = newSkinData.hair2

        cb(actualSkin, charTattoos)
    else
        cb(false)
    end
end)

RLCore.Functions.CreateCallback('pw_character:server:getOutfitData', function(source, cb, outfitId)
    local outfit = tonumber(outfitId)
    if outfit ~= nil then
        local _char = RLCore.Functions.GetPlayer(source)
        local _cid = _char.PlayerData.citizenid
        local _steam = _char.PlayerData.steam
        local outfitData = exports.ghmattimysql:executeSync("SELECT `data` FROM `character_outfits` WHERE `outfit_id` = @outfit_id AND `cid` = @cid", {['@outfit_id'] = outfit, ['@cid'] = _cid})
        local SkinData = exports.ghmattimysql:executeSync("SELECT `skin` FROM `characters` WHERE `steam` = @steam AND `cid` = @cid", {['@steam'] = _steam, ['@cid'] = _cid})
        local TattooData = exports.ghmattimysql:executeSync("SELECT `tattoos` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
        if outfitData ~= nil and SkinData ~= nil then
            exports.ghmattimysql:execute("UPDATE `characters` SET `cur_outfit` = @cur_outfit WHERE `steam` = @steam AND `cid` = @cid", {['@cur_outfit'] = outfitId, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
                if updated > 0 then
                    _char.setLastOutfit(outfitId)
                end
            end)
            local charTattoos = nil
            if TattooData ~= nil then
                charTattoos = json.decode(TattooData)
            end
            local newOutfitData = json.decode(outfitData)
            local newSkinData = json.decode(SkinData)

            local actualSkin = {
                ['model'] = tonumber(newOutfitData.model),
                ['drawables'] = newOutfitData.drawables,
                ['drawtextures'] = newOutfitData.drawtextures,
                ['props'] = newOutfitData.props,
                ['proptextures'] = newOutfitData.proptextures,
                ['hairColor'] = newSkinData.hairColor,
                ['headOverlay'] = newSkinData.headOverlay,
                ['headStructure'] = newSkinData.headStructure,
                ['headBlend'] = newSkinData.headBlend,
            }
            actualSkin.drawables["2"] = newSkinData.hair1
            actualSkin.drawtextures[3] = newSkinData.hair2

            cb(actualSkin, charTattoos)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

RLCore.Functions.CreateCallback('pw_character:server:getCharactersOutfits', function(source, cb)
    local _char = RLCore.Functions.GetPlayer(source)
    local _cid = _char.PlayerData.citizenid
    local characterOutfits = exports.ghmattimysql:executeSync("SELECT * FROM `character_outfits` WHERE `cid` = @cid", { ['@cid'] = _cid})
    cb(characterOutfits)
end)

RegisterServerEvent('pw_character:server:deleteCharacterOutfit')
AddEventHandler('pw_character:server:deleteCharacterOutfit', function(outfitData)
    local _src = source
    local _char = RLCore.Functions.GetPlayer(source)
    local _cid = _char.PlayerData.citizenid
    local _steam = _char.PlayerData.steam
    local _curout = _char.getLastOutfit()
    if (outfitData.outfit ~= nil) and (outfitData.outfit ~= _curout) then
        exports.ghmattimysql:execute("SELECT COUNT(*) FROM `character_outfits` WHERE `cid` = @cid", {['@cid'] = _cid}, function(tot)
            if tot > 1 then
                exports.ghmattimysql:execute("DELETE FROM `character_outfits` WHERE `cid` = @cid AND `outfit_id` = @oid", {['@cid'] = _cid, ['@oid'] = outfitData.outfit}, function()
                    TriggerClientEvent("RLCore:Notify", source, 'Deleted Outfit: ' .. outfitData.outfitName)
                end)
            end
        end)
    else
        TriggerClientEvent('RLCore:Notify', _src, 'You can\'t delete the outfit you are currently wearing!')
    end
end)


RLCore.Functions.CreateCallback('pw_character:server:doesCharHaveEnoughMoney', function(source, cb)
    local _src = source
    local _char = RLCore.Functions.GetPlayer(source)
    cb(_char.Functions.GetMoney("cash"))
end)

RegisterServerEvent('pw_character:server:payForMenu')
AddEventHandler('pw_character:server:payForMenu', function(menutype, purchaseInfo)
    local _src = source
    if menutype ~= nil and purchaseName ~= nil then
        local _char = RLCore.Functions.GetPlayer(_src)
        local amount = Config.Costs[menutype]
        if amount ~= nil then
            _char.Functions.RemoveMoney("cash", amount)
            TriggerClientEvent('RLCore:Notify', _src,'Paid $' .. amount .. ' ' .. purchaseInfo .. '.')
        end
    end
end)


RegisterCommand('toggleclothes', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_character:client:characterAccessoryMenu', _src)
end)


RegşsterCommand('forceped', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil then
        TriggerClientEvent('pw_character:client:forceSetPed', _src, args[1])
    end
end)