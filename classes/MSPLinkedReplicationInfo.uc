class MSPLinkedReplicationInfo extends LinkedReplicationInfo;

var PlayerReplicationInfo ownerPRI;
var KFPlayerController ownerController;
var array<class<KFVeterancyTypes> > veterancyTypes;
var class<KFVeterancyTypes> desiredPerk;
var MSPMut mut;
var bool initialized;
var int desiredPerkLevel, minPerkLevel, maxPerkLevel;

replication {
    reliable if (Role < ROLE_Authority)
       sendPerkToServer;
    reliable if (Role == ROLE_Authority)
        flushToClient, desiredPerkLevel, minPerkLevel, maxPerkLevel, 
        ownerPRI;
}

simulated function Tick(float DeltaTime) {
    super.Tick(DeltaTime);
    if (Role == ROLE_Authority) {
        mut.sendVeterancyTypes(self);
        PlayerController(Owner).SteamStatsAndAchievements= spawn(class'MinsP.MSPSteamStats', Owner);
        ownerPRI.SteamStatsAndAchievements= PlayerController(Owner).SteamStatsAndAchievements;
    }
        
    Disable('Tick');
}

simulated function flushToClient(string vetNames) {
    local int i;
    local array<string> parts;

    Split(vetNames, ";", parts);
    for(i= 0; i < parts.Length; i++) {
        veterancyTypes[veterancyTypes.Length]= class<KFVeterancyTypes>(DynamicLoadObject(parts[i], class'Class'));
    }
}

function addVeterancyTypes(array<class<KFVeterancyTypes> > types) {
    local int i, j;
    local array<string> classnames, parts;
    local PlayerController localController;

    localController= Level.GetLocalPlayerController();
    for(j= 0; j < types.Length; j++) {
        for(i= 0; i < veterancyTypes.Length && veterancyTypes[i] != types[j]; i++) {
        }
        if (i >= veterancyTypes.Length) {
            veterancyTypes[veterancyTypes.Length]= types[j];
            parts[parts.Length]= string(types[j]);
            if (parts.Length == 4) {
                classnames[classnames.Length]= join(parts, ";");
                parts.Length= 0;
            }
        }
    }
    if (parts.Length > 0) {
        classnames[classnames.Length]= join(parts, ";");
        parts.Length= 0;
    }
    if (localController == none) {
        for(i= 0; i < classnames.Length; i++) {
            flushToClient(classnames[i]);
        }
    }
}

function sendPerkToServer(class<KFVeterancyTypes> perk, int level) {
    local KFPlayerController kfPC;
    local KFPlayerReplicationInfo kfRepInfo;
    local bool selectedNewPerk, canChangePerk, isObjectiveMode;
    local KF_StoryObjective currentObj;

    kfPC= KFPlayerController(Owner);
    kfRepInfo= KFPlayerReplicationInfo(kfPC.PlayerReplicationInfo);
    if (kfPC != none && kfRepInfo != none) {
        desiredPerk= perk;
        desiredPerkLevel= level;

        selectedNewPerk= desiredPerk != kfRepInfo.ClientVeteranSkill || desiredPerkLevel != kfRepInfo.ClientVeteranSkillLevel;
        isObjectiveMode= kfPC.GameReplicationInfo.IsA('KF_StoryGRI');
        if (isObjectiveMode) {
            currentObj= KF_StoryGRI(kfPC.GameReplicationInfo).GetCurrentObjective();
        }
        canChangePerk= isObjectiveMode && (currentObj == None || currentObj.IsTraderObj() || 
                    KF_StoryGRI(kfPC.GameReplicationInfo).MaxMonsters == 0) || 
                !isObjectiveMode && !KFGameReplicationInfo(kfPC.GameReplicationInfo).bWaveInProgress;

        if (!canChangePerk && selectedNewPerk) {
            kfPC.ClientMessage(Repl(kfPC.YouWillBecomePerkString, "%Perk%", perk.default.VeterancyName));
        } else if (!ownerPRI.bReadyToPlay || !kfPC.bChangedVeterancyThisWave) {
            if (selectedNewPerk) {
                kfPC.ClientMessage(Repl(kfPC.YouAreNowPerkString, "%Perk%", desiredPerk.default.VeterancyName));
            }

            kfPC.bChangedVeterancyThisWave= selectedNewPerk && kfPC.GameReplicationInfo.bMatchHasBegun && ownerPRI.bReadyToPlay;

            kfPC.SelectedVeterancy= desiredPerk;
            kfRepInfo.ClientVeteranSkill= desiredPerk;
            kfRepInfo.ClientVeteranSkillLevel= level;

            if (KFHumanPawn(kfPC.Pawn) != none) {
                KFHumanPawn(kfPC.Pawn).VeterancyChanged();
            }    
        } else {
            kfPC.ClientMessage(kfPC.PerkChangeOncePerWaveString);
        }
    }
}

simulated function changePerk(int perkIndex) {
    desiredPerk= veterancyTypes[perkIndex];
    sendPerkToServer(desiredPerk, desiredPerkLevel);
}

simulated function changeRandomPerk() {
    changePerk(Rand(veterancyTypes.Length));
}

static function MSPLinkedReplicationInfo findLRI(PlayerReplicationInfo pri) {
    local LinkedReplicationInfo lriIt;
    local MSPLinkedReplicationInfo mspIt;

    if (pri == None) {
        return None;
    }
    for(lriIt= pri.CustomReplicationInfo; lriIt != None && lriIt.class != class'MSPLinkedReplicationInfo';
            lriIt= lriIt.NextReplicationInfo) {
    }
    if (lriIt == None) {
        foreach pri.DynamicActors(class'MSPLinkedReplicationInfo', mspIt)
            if (mspIt.ownerPRI == pri) 
                return mspIt;
        return None;
    }
    return MSPLinkedReplicationInfo(lriIt);
}

static function string join(array<string> parts, string separator) {
    local int i;
    local string whole;

    for(i= 0; i < parts.Length; i++) {
        if (i != 0) {
            whole$= separator;
        }
        whole$= parts[i];
    }
    return whole;
}
