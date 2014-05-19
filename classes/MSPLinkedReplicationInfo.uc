class MSPLinkedReplicationInfo extends LinkedReplicationInfo;

var string interactionClass;
var KFPlayerController ownerController;
var array<class<KFVeterancyTypes> > veterancyTypes;
var MSPMut mut;
var bool initialized;
var int desiredPerkLevel, minPerkLevel, maxPerkLevel;

replication {
    reliable if (Role < ROLE_Authority)
       sendPerkToServer;
    reliable if (Role == ROLE_Authority)
        flushToClient, desiredPerkLevel, minPerkLevel, maxPerkLevel;
}

simulated function Tick(float DeltaTime) {
    local PlayerController localController;

    super.Tick(DeltaTime);

    if (!initialized) {
        if (Role == ROLE_Authority) {
            mut.sendVeterancyTypes(self);
            PlayerController(Owner).SteamStatsAndAchievements.Destroy();
            PlayerController(Owner).SteamStatsAndAchievements= spawn(class'MinsP.MSPSteamStats', Owner);
        }
        localController= Level.GetLocalPlayerController();
        if (localController != none) {
            localController.Player.InteractionMaster.AddInteraction(interactionClass, localController.Player);
        }
        initialized= true;
    }
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

    kfPC= KFPlayerController(Owner);
    kfRepInfo= KFPlayerReplicationInfo(kfPC.PlayerReplicationInfo);
    if (kfPC != none && kfRepInfo != none) {
        kfPC.SelectedVeterancy= perk;

        if (KFGameReplicationInfo(kfPC.GameReplicationInfo).bWaveInProgress && kfPC.SelectedVeterancy != kfRepInfo.ClientVeteranSkill) {
            kfPC.ClientMessage(Repl(kfPC.YouWillBecomePerkString, "%Perk%", perk.default.VeterancyName));
        } else if (!kfPC.bChangedVeterancyThisWave) {
            if (kfPC.SelectedVeterancy != kfRepInfo.ClientVeteranSkill) {
                kfPC.ClientMessage(Repl(kfPC.YouAreNowPerkString, "%Perk%", kfPC.SelectedVeterancy.Default.VeterancyName));
            }
            if (kfPC.GameReplicationInfo.bMatchHasBegun) {
                kfPC.bChangedVeterancyThisWave = true;
            }

            kfRepInfo.ClientVeteranSkill = kfPC.SelectedVeterancy;
            kfRepInfo.ClientVeteranSkillLevel= level;

            if (KFHumanPawn(kfPC.Pawn) != none) {
                KFHumanPawn(kfPC.Pawn).VeterancyChanged();
            }    
        } else {
            kfPC.ClientMessage(kfPC.PerkChangeOncePerWaveString);
        }
        desiredPerkLevel= level;
    }
}

simulated function changePerk(int perkIndex) {
    ownerController.SelectedVeterancy= veterancyTypes[perkIndex];
    sendPerkToServer(ownerController.SelectedVeterancy, desiredPerkLevel);
}

simulated function changeRandomPerk() {
    changePerk(Rand(veterancyTypes.Length));
}

static function MSPLinkedReplicationInfo findLRI(PlayerReplicationInfo pri) {
    local LinkedReplicationInfo lriIt;

    if (pri == None) {
        return None;
    }
    for(lriIt= pri.CustomReplicationInfo; lriIt != None && lriIt.class != class'MSPLinkedReplicationInfo';
            lriIt= lriIt.NextReplicationInfo) {
    }
    if (lriIt == None) {
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

defaultproperties {
    interactionClass="MinSP.MSPInteraction"
}
