class MSPLinkedReplicationInfo extends LinkedReplicationInfo;

var array<class<KFVeterancyTypes> > veterancyTypes;

simulated function addVeterancyType(class<KFVeterancyTypes> type) {
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
