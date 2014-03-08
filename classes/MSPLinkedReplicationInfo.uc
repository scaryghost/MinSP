class MSPLinkedReplicationInfo extends LinkedReplicationInfo;

var array<class<KFVeterancyTypes> > veterancyTypes;
var MSPMut mut;
var bool initialized;

replication {
    reliable if (Role == ROLE_Authority)
        flushToClient;
}

simulated function Tick(float DeltaTime) {
    super.Tick(DeltaTime);

    if (!initialized && Role == ROLE_Authority) {
        mut.sendVeterancyTypes(self);
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

static function MSPLinkedReplicationInfo findLRI(PlayerReplicationInfo pri) {
    local LinkedReplicationInfo lriIt;

    for(lriIt= pri.CustomReplicationInfo; lriIt != None && lriIt.class != class'MSPLinkedReplicationInfo';
            lriIt= lriIt.NextReplicationInfo) {
    }
    if (lriIt == None) {
        return None;
    }
    return MSPLinkedReplicationInfo(lriIt);
}
