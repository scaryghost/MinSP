class MSPMut extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local PlayerReplicationInfo pri;
    local LinkedReplicationInfo lri;

    pri= PlayerReplicationInfo(Other);
    if (pri != none && pri.Owner != None) {
        lri= pri.Spawn(class'MSPLinkedReplicationInfo', pri.Owner);
        lri.NextReplicationInfo= pri.CustomReplicationInfo;
        pri.CustomReplicationInfo= lri;
    }

    return true;
}

defaultproperties {
    GroupName="KFMinSP"
    FriendlyName="Minimalist Server Perks"
    Description="Minimalist enviornment for using custom perks"
}
