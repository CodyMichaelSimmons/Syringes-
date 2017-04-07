local SyringesPlus = RegisterMod("syringesPlus", 1)
local game = Game()
local MIN_FIRE_DELAY = 5

local SyringeId = {
    USED_NEEDLE = Isaac.GetItemIdByName("Used Needle"),
    MORPHINE = Isaac.GetItemIdByName("Morphine"),
    BOOSTER_SHOT = Isaac.GetItemIdByName("Booster Shot"),
    ALLERGY_SHOT = Isaac.GetItemIdByName("Allergy Shot"),
    LUCKY_JUICE = Isaac.GetItemIdByName("Lucky Juice"),
    LETHAL_INJECTION = Isaac.GetItemIdByName("Lethal Injection")
}

SyringesPlus.COLLECTIBLE_LITTLE_HELPER = Isaac.GetItemIdByName("Little Helper")
SyringesPlus.COSTUME_BOOSTER_SHOT = Isaac.GetCostumeIdByPath("gfx/characters/boostershot.anm2")
SyringesPlus.COSTUME_LETHAL_INJECTION = Isaac.GetCostumeIdByPath("gfx/characters/lethalinjection.anm2")
SyringesPlus.COSTUME_MORPHINE = Isaac.GetCostumeIdByPath("gfx/characters/morphine_SP.anm2")

-- Little Helper
local LH = {
    Active = false,
    Direction = Direction.NO_DIRECTION,
    DirectionStart = 1,
    EntityVariant = Isaac.GetEntityVariantByName("Little Helper"),
    Entity = nil
}

local HasSyringe = {
    Used_Needle = false,
    Morphine = false,
    Booster_Shot = false,
    Allergy_Shot = false,
    Lucky_Juice = false,
    Lethal_Injection = false,
}

local UseCostume = {
    BSC = false,
    LIC = false,
    MoC = false
}

local SyringeBonus = {
    USED_NEEDLE = 2,
    MORPHINE = 0.08,
    BOOSTER_SHOT_SP = 0.04,
    BOOSTER_SHOT_DMG = 0.28,
    ALLERGY_SHOT_SS = 0.3,
    ALLERGY_SHOT_FD = 0.5,
    LUCKY_JUICE = 3,
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
   HasSyringe.Lucky_Juice = player:HasCollectible(SyringeId.LUCKY_JUICE) 
   HasSyringe.Lethal_Injection = player:HasCollectible(SyringeId.LETHAL_INJECTION) 
end

--When the run starts or is continued
function SyringesPlus:onPlayerInit(player)
    UpdateSyringe(player) 
end

SyringesPlus:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SyringesPlus.onPlayerInit)

-- Update passive effects, comments used for testing
function SyringesPlus:onUpdate(player)
    
    local player = game:GetPlayer(0)
    
    if game:GetFrameCount() == 1 then
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.USED_NEEDLE, Vector(320, 300), Vector (0, 0), nil)
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.MORPHINE, Vector(270, 300), Vector (0, 0), nil)
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.BOOSTER_SHOT, Vector(370, 300), Vector (0, 0), nil)
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.ALLERGY_SHOT, Vector(320, 250), Vector (0, 0), nil)
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.LETHAL_INJECTION, Vector(270, 250), Vector (0, 0), nil)
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringeId.LUCKY_JUICE, Vector(370, 250), Vector (0, 0), nil)
        --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, SyringesPlus.COLLECTIBLE_LITTLE_HELPER, Vector(320, 200), Vector(0,0), nil)
    end
    
    UpdateSyringe(player)
    -- Used Needle Poison Effect
    if player:HasCollectible(SyringeId.USED_NEEDLE) then
       for i, entity in pairs(Isaac.GetRoomEntities()) do 
           if entity:IsVulnerableEnemy() and math.random(1000) == 2 then
                entity:AddPoison(EntityRef(player), 75, 0.1)
            end
        end
    end
    
    -- Update Little Helper
    if LH.Room ~= nil and game:GetLevel():GetCurrentRoomIndex() ~= LH.Room then
        player:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0), 0,0, false, false)
       LH.Active = false 
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:AddCacheFlags(CacheFlag.CACHE_RANGE)
        player:EvaluateItems()
        LH.Room = nil
    end 
    
    if HasSyringe.Booster_Shot and BSC ~= true then
        player:AddNullCostume(SyringesPlus.COSTUME_BOOSTER_SHOT)
        BSC = true
    end
    if HasSyringe.Lethal_Injection and LIC ~= true then
        player:AddNullCostume(SyringesPlus.COSTUME_LETHAL_INJECTION)
        LIC = true
    end
    if HasSyringe.Morphine and MoC ~= true then
        player:AddNullCostume(SyringesPlus.COSTUME_MORPHINE)
        MoC = true
    end
    
end

function SyringesPlus:ActivateLittleHelper(_Type, RNG)
    LH.Active = true
    local player = Isaac.GetPlayer(0)
    LH.Room = game:GetLevel():GetCurrentRoomIndex()
    player:SetColor(Color(0.8, 0.8, 1.0, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)
     if LH.Active then
        local rng = math.random(1,4)
        if rng == 1 then
            player.Damage = player.Damage + math.random(5)
        end
        if rng == 2 then
            player.MoveSpeed = player.MoveSpeed +  0.5 * math.random()
        end
        if rng == 3 then
            player.ShotSpeed = player.ShotSpeed + math.random()
        end
        if rng == 4 then
            player.TearHeight = player.TearHeight - math.random(2,5)
            player.TearFallingSpeed = player.TearFallingSpeed + math.random(1,3)
        end
        LH.Active = false
    end
    return true;
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
        if LH.Active then
           player.Damage = player.Damage + 2.0 * math.random() 
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
           player:AddBlackHearts(2)
           IveBeenBad.IsBad = false
        end
        if LH.Active then
           player.MoveSpeed = player.MoveSpeed + 0.5 * math.random() 
        end
    end
    if cacheFlag == CacheFlag.CACHE_LUCK then
       if player:HasCollectible(SyringeId.LUCKY_JUICE) then
           player.Luck = player.Luck + SyringeBonus.LUCKY_JUICE 
        end
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
       if player:HasCollectible(SyringeId.ALLERGY_SHOT) then
           player.ShotSpeed = player.ShotSpeed + SyringeBonus.ALLERGY_SHOT_SS 
        end
        if LH.Active then
           player.ShotSpeed = player.ShotSpeed - math.random(5) 
        end
    end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
       if player:HasCollectible(SyringeId.ALLERGY_SHOT) then
           player.FireDelay = player.FireDelay - SyringeBonus.ALLERGY_SHOT_FD
        end
       if player:HasCollectible(SyringeId.LETHAL_INJECTION) then
           player.FireDelay = player.FireDelay - SyringeBonus.LETHAL_INJECTION_FD
        end
        if LH.Active then
           player.FireDelay = player.FireDelay - math.random(5) 
        end
    end
    if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
       if player:HasCollectible(SyringeId.LETHAL_INJECTION) then
           player.TearColor = Color(0.909, 0.172, 0.172, 1.0, 0.0, 0.0, 0.0)
            player:SetColor(Color(1.0, 0.560, 0.560, 1.0, 0.0, 0.0 ,0.0), 0, 0, false, false)
        end
    end
    if cacheFlag == CacheFlag.CACHE_RANGE then
       if LH.Active then
           player.TearHeight = player.TearHeight + math.random(2,5)
            player.TearFallingSpeed = player.TearFallingSpeed + math.random(1,3)
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
SyringesPlus:AddCallback(ModCallbacks.MC_USE_ITEM, SyringesPlus.ActivateLittleHelper, SyringesPlus.COLLECTIBLE_LITTLE_HELPER)