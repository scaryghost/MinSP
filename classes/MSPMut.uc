class MSPMut extends Mutator
    config(MinSP);

var() config array<string> veterancyNames;
var() config int minPerkLevel, maxPerkLevel;
var() config bool loadStandardPerks;

var int levelUpperBound, levelLowerBound;
var string loginMenuClass, interactionClass;
var array<string> uniqueNames;
var array<class<KFVeterancyTypes> > loadedVeterancyTypes;
var String version;

simulated function Tick(float DeltaTime) {
    local PlayerController localController;

    localController= Level.GetLocalPlayerController();
    if (localController != none) {
        localController.Player.InteractionMaster.AddInteraction(interactionClass, localController.Player);
    }
    Disable('Tick');
}

function PostBeginPlay() {
    local int i;
    local array<string> packages;
    local class<KFVeterancyTypes> loadedVetType;
    local KFGameType kfGT;

    kfGT= KFGameType(Level.Game);
    if (kfGT == none) {
        Destroy();
        return;
    }

    if (minPerkLevel > maxPerkLevel || minPerkLevel < levelLowerBound) {
        Warn("MSPMut: minPerkLevel set to invalid level.  Defaulting to "$levelLowerBound);
        minPerkLevel= levelLowerBound;
    } else if (maxPerkLevel > levelUpperBound) {
        Warn("MSPMut: maxPerkLevel set to invalid level.  Defaulting to "$levelUpperBound);
        maxPerkLevel= levelUpperBound;
    }

    AddToPackageMap();
    DeathMatch(Level.Game).LoginMenuClass= loginMenuClass;

    for(i= 0; i < veterancyNames.Length; i++) {
        uniqueInsert(uniqueNames, veterancyNames[i]);
    }
    if(loadStandardPerks) {
        log("MSPMut: Loading perks from stock KF");
        for(i= 0; i < kfGT.LoadedSkills.Length; i++) {
            uniqueInsert(uniqueNames, String(kfGT.LoadedSkills[i]));
        }
    }

    log("Attempting to load"@uniqueNames.Length@"veterancy names");
    i= 0;
    while(i < uniqueNames.Length) {
        loadedVetType= class<KFVeterancyTypes>(DynamicLoadObject(uniqueNames[i], class'Class'));
        if (loadedVetType == none) {
            Warn("Failed to load perk"@uniqueNames[i]);
            uniqueNames.remove(i, 1);
        } else {
            log("Successfully loaded"@uniqueNames[i]);
            loadedVeterancyTypes[loadedVeterancyTypes.Length]= loadedVetType;
            uniqueInsert(packages, string(loadedVetType.Outer.name));
            i++;
        }
    }
    for(i= 0; i < packages.Length; i++) {
        AddToPackageMap(packages[i]);
    }
    log("Successfully loaded"@loadedVeterancyTypes.Length@"veterancy names.");
    log("Added"@packages.Length@"package names to the package map");
    
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local KFPlayerReplicationInfo kfPRepInfo;
    local MSPLinkedReplicationInfo mspLRepInfo;

    kfPRepInfo= KFPlayerReplicationInfo(Other);
    if (kfPRepInfo != none && kfPRepInfo.Owner != None) {
        mspLRepInfo= kfPRepInfo.Spawn(class'MSPLinkedReplicationInfo', kfPRepInfo.Owner);
        mspLRepInfo.mut= Self;
        mspLRepInfo.NextReplicationInfo= kfPRepInfo.CustomReplicationInfo;
        mspLRepInfo.minPerkLevel= minPerkLevel;
        mspLRepInfo.maxPerkLevel= maxPerkLevel;
        mspLRepInfo.desiredPerkLevel= maxPerkLevel;
        mspLRepInfo.ownerPRI= kfPRepInfo;
        kfPRepInfo.CustomReplicationInfo= mspLRepInfo;
        kfPRepInfo.ClientVeteranSkillLevel= mspLRepInfo.desiredPerkLevel;
    }

    return super.CheckReplacement(Other, bSuperRelevant);
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState) {
   // append the mutator name.
    local int i, j;

    super.GetServerDetails(ServerState);

    i= ServerState.ServerInfo.Length;
    ServerState.ServerInfo.Length= i + loadedVeterancyTypes.Length + 2;
    for(j= 0; j < loadedVeterancyTypes.Length; j++) {
        ServerState.ServerInfo[i].Key= "MinSP.perk";
        ServerState.ServerInfo[i].Value= String(loadedVeterancyTypes[j].name);
        i++;
    }
    ServerState.ServerInfo[i].Key= "MinSP.minPerkLevel";
    ServerState.ServerInfo[i].Value= String(minPerkLevel);
    ServerState.ServerInfo[i + 1].Key= "MinSP.maxPerkLevel";
    ServerState.ServerInfo[i + 1].Value= String(maxPerkLevel);
}

function ModifyPlayer(Pawn Other) {
    Other.PlayerReplicationInfo.bReadyToPlay= true;
    super.ModifyPlayer(Other);
}

function sendVeterancyTypes(MSPLinkedReplicationInfo mspLRepInfo) {
    mspLRepInfo.addVeterancyTypes(loadedVeterancyTypes);
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting(default.GroupName, "veterancyNames", "Veterancy Names", 1, 1, "Text", "128",,,);
    PlayInfo.AddSetting(default.GroupName, "minPerkLevel", "Minimum Perk Level", 1, 1, "Text", "0.1;0:6");
    PlayInfo.AddSetting(default.GroupName, "maxPerkLevel", "Maximum Perk Level", 1, 1, "Text", "0.1;0:6");
    PlayInfo.AddSetting(default.GroupName, "loadStandardPerks", "Use Standard Perks", 1, 1, "Check");
}

static event string GetDescriptionText(string property) {
    switch(property) {
        case "veterancyNames":
            return "Classnames of the perks to use in full `<package>.<classname>` format";
        case "minPerkLevel":
            return "Lowest allowed perk level";
        case "maxPerkLevel":
            return "Highest allowed perk level";
        case "loadStandardPerks":
            return "Include perks from the stock game";
        default:
            return super.GetDescriptionText(property);
    }
}

static function uniqueInsert(out array<string> list, string key) {
    local int index, low, high, mid;

    if (list.Length == 0) {
        list[list.Length]= key;
        return;
    }

    low= 0;
    high= list.Length - 1;
    index= -1;
    mid= -1;

    while(low <= high) {
        mid= (low+high)/2;
        if (list[mid] < key) {
            low= mid + 1;
        } else if (list[mid] > key) {
            high= mid - 1;
        } else {
            index= mid;
            break;
        }
    }
    if (low > high) {
        list.Insert(low, 1);
        list[low]= key;
    }
}

defaultproperties {
    RemoteRole= ROLE_SimulatedProxy
    bAlwaysRelevant= true
    
    GroupName="KFMinSP"
    FriendlyName="Minimalist Server Perks"
    Description="Minimalist environment for using custom perks.  Version 1.0.8"
    version="1.0.8"

    loginMenuClass="MinSP.InvasionLoginMenu"
    interactionClass="MinSP.MSPInteraction"

    maxPerkLevel=6
    minPerkLevel=0
    levelUpperBound=6 
    levelLowerBound=0
}
