class MSPSteamStats extends KFSteamStatsAndAchievements;

var MSPLinkedReplicationInfo kfrLRepInfo;

function WaveEnded() {
    super.WaveEnded();

    if (kfrLRepInfo == None) {
        kfrLRepInfo= class'MSPLinkedReplicationInfo'.static.
                findLRI(PlayerController(Owner).PlayerReplicationInfo);
    }
    kfrLRepInfo.sendPerkToServer(kfrLRepInfo.desiredPerk, kfrLRepInfo.desiredPerkLevel);
}

function OnObjectiveCompleted(name ObjectiveName) {
    super.OnObjectiveCompleted(ObjectiveName);

    if (kfrLRepInfo == None) {
        kfrLRepInfo= class'MSPLinkedReplicationInfo'.static.
                findLRI(PlayerController(Owner).PlayerReplicationInfo);
    }
    kfrLRepInfo.sendPerkToServer(kfrLRepInfo.desiredPerk, kfrLRepInfo.desiredPerkLevel);
}
