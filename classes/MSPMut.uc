class MSPMut extends Mutator
    config(MinSP);

var() config array<string> veterancyNames;
var() config int minPerkLevel, maxPerkLevel;

var int levelUpperBound, levelLowerBound;
var string loginMenuClass;
var array<string> uniqueNames;
var array<class<KFVeterancyTypes> > loadedVeterancyTypes;

function PostBeginPlay() {
    local int i;
    local array<string> packages;
    local class<KFVeterancyTypes> loadedVetType;

    if (KFGameType(Level.Game) == none) {
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
        kfPRepInfo.CustomReplicationInfo= mspLRepInfo;
        kfPRepInfo.ClientVeteranSkillLevel= mspLRepInfo.desiredPerkLevel;
    }

    return super.CheckReplacement(Other, bSuperRelevant);
}

function sendVeterancyTypes(MSPLinkedReplicationInfo mspLRepInfo) {
    local int j;

    for(j= 0; j < loadedVeterancyTypes.Length; j++) {
        mspLRepInfo.addVeterancyType(loadedVeterancyTypes[j], uniqueNames[j]);
    }
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting(default.GroupName, "veterancyNames", "Veterancy Names", 1, 1, "Text", "128",,,);
    PlayInfo.AddSetting(default.GroupName, "minPerkLevel", "Minimum Perk Level", 1, 1, "Text", "0.1;0:6");
    PlayInfo.AddSetting(default.GroupName, "maxPerkLevel", "Maximum Perk Level", 1, 1, "Text", "0.1;0:6");
}

static event string GetDescriptionText(string property) {
    switch(property) {
        case "veterancyNames":
            return "Classnames of the perks to use in full `<package>.<classname>` format";
        case "minPerkLevel":
            return "Lowest allowed perk level";
        case "maxPerkLevel":
            return "Highest allowed perk level";
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
    GroupName="KFMinSP"
    FriendlyName="Minimalist Server Perks"
    Description="Minimalist environment for using custom perks"

    loginMenuClass="MinSP.InvasionLoginMenu"

    maxPerkLevel=6
    minPerkLevel=0
    levelUpperBound=6 
    levelLowerBound=0
}
