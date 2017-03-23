local SyringesPlus = RegisterMod("syringesPlus", 1)
local game = Game()
local MIN_FIRE_DELAY = 5

local SyringeId = {
    USED_NEEDLE = Isaac.GetItemIdByName("Used Needle"),
    MORPHINE = Isaac.GetItemIdByName("Morphine"),
    BOOSTER_SHOT = Isaac.GetItemIdByName("Booster Shot"),
    ALLERGY_SHOT = Isaac.GetItemIdByName("Allergy Shot"),
    LETHAL_INJECTION = Isaac.GetItemIdByName("Lethal Injection")
}

local HasSyringe = {
    Used_Needle = false,
    Morphine = false,
    Booster_Shot = false,
    Allergy_Shot = false,
    Lethal_Injection = false
}

local SyringeBonus = {
    USED_NEEDLE = 2,
    MORPHINE = 0.08,
    BOOSTER_SHOT_SP = 0.04,
    BOOSTER_SHOT_DMG = 0.28,
    ALLERGY_SHOT_SS = 0.3,
    ALLERGY_SHOT_FD = 0.5,
    LETHAL_INJECTION_DMG = 1.5,
    LETHAL_INJECTION_FD = 0.2,
}

-- Pills
local SleepingPill = {
    ID = Isaac.GetPillEffectByName("Sleeping Pill"),
    BONUS_SP = 0.08,
    IsSleepy = false
}
local IveBeenBad = {
    ID = Isaac.GetPillEffectByName("I've Been Bad"),
    BONUS_SP = 0.08,
    IsBad = false
}

SleepingPill.Color = Isaac.AddPillEffectToPool(SleepingPill.ID)
SleepingPill.Color = Isaac.AddPillEffectToPool(IveBeenBad.ID)

-- Validate inventory
local function UpdateSyringe(player)
   HasSyringe.Used_Needle = player:HasCollectible(SyringeId.USED_NEEDLE)
   HasSyringe.Morphine = player:HasCollectible(SyringeId.MORPHINE) 
   HasSyringe.Booster_Shot = player:HasCollectible(SyringeId.BOOSTER_SHOT) 
   HasSyringe.Allergy_Shot = player:HasCollectible(SyringeId.ALLERGY_SHOT) 
   HasSyringe.Lethal_Injection = player:HasCollectible(SyringeId.LETHAL_INJECTION) 

end

--When the run starts or is continued
function SyringesPlus:onPlayerInit(player)
    UpdateSyringe(player) 
end

SyringesPlus:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SyringesPlus.onPlayerInit)

-- Update passive effects, used for testing
function SyringesPlus:onUpdate(player)
    if game:GetFrameCount() == 1 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.USED_NEEDLE, Vector(320, 300), Vector (0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.MORPHINE, Vector(270, 300), Vector (0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.BOOSTER_SHOT, Vector(370, 300), Vector (0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.ALLERGY_SHOT, Vector(420, 300), Vector (0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.LETHAL_INJECTION, Vector(220, 300), Vector (0, 0), nil)
    end
    
    UpdateSyringe(player)
    
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
        if player:HasCollectible(SyringeId.LETHAL_INJECTION) then
           player.Damage = player.Damage + SyringeBonus.LETHAL_INJECTION_DMG
        end
    end
    if cacheFlag == CacheFlag.CACHE_SPEED then
       if player:HasCollectible(SyringeId.BOOSTER_SHOT) then
           player.MoveSpeed = player.MoveSpeed + SyringeBonus.BOOSTER_SHOT_SP 
        end
        if player:HasCollectible(SyringeId.MORPHINE) then
           player.MoveSpeed = player.MoveSpeed - SyringeBonus.MORPHINE 
        end
        if SleepingPill.IsSleepy then
           --player.MoveSpeed = player.MoveSpeed - SleepingPill.BONUS_SP 
           player:AddSoulHearts(2)
           SleepingPill.IsSleepy = false
        end
        if IveBeenBad.IsBad then
           --player.MoveSpeed = player.MoveSpeed - SleepingPill.BONUS_SP 
           player:AddBlackHearts(2)
           IveBeenBad.IsBad = false
        end
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
       if player:HasCollectible(SyringeId.ALLERGY_SHOT) then
           player.ShotSpeed = player.ShotSpeed + SyringeBonus.ALLERGY_SHOT_SS 
        end
    end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
       if player:HasCollectible(SyringeId.ALLERGY_SHOT) then
           player.FireDelay = player.FireDelay - SyringeBonus.ALLERGY_SHOT_FD
        end
       if player:HasCollectible(SyringeId.LETHAL_INJECTION) then
           player.FireDelay = player.FireDelay - SyringeBonus.LETHAL_INJECTION_FD
        end
    end
    if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
       if player:HasCollectible(SyringeId.LETHAL_INJECTION) then
           player.TearColor = Color(0.909, 0.172, 0.172, 1.0, 0.0, 0.0, 0.0)
        end
    end
end

SyringesPlus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SyringesPlus.onCache)

-- Pills Proc
function SleepingPill:Proc(_PillEffect)
    local player = game:GetPlayer(0)
    SleepingPill.Room = game:GetLevel():GetCurrentRoomIndex()
    SleepingPill.IsSleepy = true
    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
end

SyringesPlus:AddCallback(ModCallbacks.MC_USE_PILL, SleepingPill.Proc, SleepingPill.ID)

function IveBeenBad:Proc(_PillEffect)
    local player = game:GetPlayer(0)
    IveBeenBad.Room = game:GetLevel():GetCurrentRoomIndex()
    IveBeenBad.IsBad = true
    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
end

SyringesPlus:AddCallback(ModCallbacks.MC_USE_PILL, IveBeenBad.Proc, IveBeenBad.ID)