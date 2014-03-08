class PerkSelectList extends KFPerkSelectList;

var MSPLinkedReplicationInfo mspLRepInfo;

function InitList(KFSteamStatsAndAchievements StatsAndAchievements) {
    local int i;
    local KFPlayerController KFPC;

    // Grab the Player Controller for later use
    KFPC= KFPlayerController(PlayerOwner());
    mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(PlayerOwner().PlayerReplicationInfo);

    // Hold onto our reference
    KFStatsAndAchievements= StatsAndAchievements;

    // Update the ItemCount and select the first item
    ItemCount= mspLRepInfo.veterancyTypes.Length;
    SetIndex(0);

    PerkName.Remove(0, PerkName.Length);
    PerkLevelString.Remove(0, PerkLevelString.Length);
    PerkProgress.Remove(0, PerkProgress.Length);

    for (i= 0; i < ItemCount; i++) {
        PerkName[PerkName.Length] = mspLRepInfo.veterancyTypes[i].default.VeterancyName;
        PerkLevelString[PerkLevelString.Length] = LvAbbrString @ KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).ClientVeteranSkillLevel;
        PerkProgress[PerkProgress.Length] = 0;

        if (mspLRepInfo.veterancyTypes[i] == KFPC.SelectedVeterancy) {
            SetIndex(i);
        }
    }

    if (bNotify) {
        CheckLinkedObjects(Self);
    }

    if (MyScrollBar != none) {
        MyScrollBar.AlignThumb();
    }
}
