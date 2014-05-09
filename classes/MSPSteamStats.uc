class MSPSteamStats extends KFSteamStatsAndAchievements;

var MSPLinkedReplicationInfo kfrLRepInfo;

function WaveEnded() {
    super.WaveEnded();

    if (kfrLRepInfo == None) {
        kfrLRepInfo= class'MSPLinkedReplicationInfo'.static.
                findLRI(PlayerController(Owner).PlayerReplicationInfo);
    }
    KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).
            ClientVeteranSkillLevel= kfrLRepInfo.desiredPerkLevel;
}
