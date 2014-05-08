class MSPLinkedReplicationInfo extends LinkedReplicationInfo;

var string interactionClass;
var KFPlayerController ownerController;
var localized string perkChangeTraderMsg;
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
        }
        localController= Level.GetLocalPlayerController();
        if (localController != none) {
            localController.Player.InteractionMaster.AddInteraction(interactionClass, localController.Player);
        }
        initialized= true;
    }
}

simulated function flushToClient(string vetName) {
    veterancyTypes[veterancyTypes.Length]= class<KFVeterancyTypes>(DynamicLoadObject(vetName, class'Class'));
}

function addVeterancyType(class<KFVeterancyTypes> type, string vetName) {
    local int i;
    local PlayerController localController;

    localController= Level.GetLocalPlayerController();
    for(i= 0; i < veterancyTypes.Length && veterancyTypes[i] != type; i++) {
    }
    if (i >= veterancyTypes.Length) {
        veterancyTypes[veterancyTypes.Length]= type;
        if (localController == none) {
            flushToClient(vetName);
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
            kfPC.ClientMessage(perkChangeTraderMsg);
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

defaultproperties {
    interactionClass="MinSP.MSPInteraction"

    perkChangeTraderMsg="You can only change perks during trader time"
}
