local SyringesPlus = RegisterMod("syringesPlus", 1)
local game = Game()
local MIN_FIRE_DELAY = 5

local SyringeId = {
    USED_NEEDLE = Isaac.GetItemIdByName("Used Needle"),
    MORPHINE = Isaac.GetItemIdByName("Morphine"),
    BOOSTER_SHOT = Isaac.GetItemIdByName("Booster Shot")
}

local HasSyringe = {
    Used_Needle = false,
    Morphine = false,
    Booster_Shot = false
}

local SyringeBonus = {
    USED_NEEDLE = 2,
    MORPHINE = 0.08,
    BOOSTER_SHOT_SP = 0.04,
    BOOSTER_SHOT_DMG = 0.28
}

-- Validate inventory
local function UpdateSyringe(player)
   HasSyringe.Used_Needle = player:HasCollectible(SyringeId.USED_NEEDLE)
   HasSyringe.Morphine = player:HasCollectible(SyringeId.MORPHINE) 
   HasSyringe.Booster_Shot = player:HasCollectible(SyringeId.BOOSTER_SHOT) 
end

--When the run starts or is continued
function SyringesPlus:onPlayerInit(player)
    UpdateSyringes(player)
end

SyringesPlus:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SyringesPlus.onPlayerInit)

-- Update passive effects
function SyringesPlus:onUpdate(player)
    if game:GetFrameCount() == 1 then
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.USED_NEEDLE, Vector(320, 300), Vector (0, 0), nil)
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.MORPHINE, Vector(270, 300), Vector (0, 0), nil)
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.BOOSTER_SHOT, Vector(370, 300), Vector (0, 0), nil)
    end
end

SyringesPlus:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SyringesPlus.onUpdate)

-- Update cache
function SyringesPlus:onCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
       if player:HasCollectible(SyringeId.USED_NEEDLE) then
           if player.MaxFireDelay >= MIN_FIRE_DELAY + SyringeBonus.USED_NEEDLE then
                player.MaxFireDelay = player.MaxFireDelay - SyringeBonus.USED_NEEDLE 
            elseif player.MaxFireDelay >= MIN_FIRE_DELAY then
                player.MaxFireDelay = MIN_FIRE_DELAY
            end
        end
        if player:HasCollectible(SyringeId.BOOSTER_SHOT) then
           player.Damage = player.Damage + SyringeBonus.BOOSTER_SHOT_DMG
        end
    end
    if cacheFlag == CacheFlag.CACHE_SPEED then
       if player:HasCollectible(SyringeId.BOOSTER_SHOT) then
           player.MoveSpeed = player.MoveSpeed + SyringeBonus.BOOSTER_SHOT_SP 
        end
        if player:HasCollectible(SyringeId.MORPHINE) then
           player.MoveSpeed = player.MoveSpeed - SyringeBonus.MORPHINE 
        end
    end
end

SyringesPlus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SyringesPlus.onCache)
