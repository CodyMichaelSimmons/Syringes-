local syringesPlus = RegisterMod("syringesPlus", 1)

syringesPlus.COLLECTIBLE_USED_NEEDLE = Isaac.GetItemIdByName("Used Needle")

function syringesPlus:onUpdate()
    -- Beginning of run initialization
    if Game():GetFrameCount() == 1 then
       syringesPlus.HasUsedNeedle = false
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, syringesPlus.COLLECTIBLE_USED_NEEDLE, Vector(320,300), Vector(0,0), nil)
    end
    
    -- Used Needle functionality
    for playerNum = 1, Game():GetNumPlayers() do
       local player = Game():GetPlayer(playerNum)
        if player:HasCollectible(syringesPlus.COLLECTIBLE_USED_NEEDLE) then
            if not syringesPlus.HasUsedNeedle then -- Inital pickup
               player:AddSoulHearts(2)
                syringesPlus.HasUsedNeedle = true
            end
           for i, entity in pairs(Isaac.GetRoomEntities()) do -- Ongoing
               if entity:IsVulnerableEnemy() and math.random(2500) == 1 then
                   entity:AddPoison(EntityRef(player), 100, 3.5) 
                end
            end
        end
    end    
end    

Isaac.DebugString("Debug!")
syringesPlus:AddCallback(ModCallbacks.MC_POST_UPDATE, syringesPlus.onUpdate)