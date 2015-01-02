MinSP
=====
Minimalist Server Perks is a bare bones version of Marco's Server Perks mutator  (http://forums.tripwireinteractive.com/showthread.php?t=36065), providng the bare minimum environment for using custom 
perks.  The mutator can load any number of perks derived from the standard KF perk class, and allows users to choose 
their own perk levels in additional to their perk class.

## Version
1.0.8

## Install
Copy MinSP.u and MinSP.ucl to the 'system' folder in your Killing Floor directory.

## Configuration
You can either configure the mutator through the settings page or manually edit MinSP.ini.  The download does not 
contain the ini file; you will need to run the mutator once to create it.  Descriptions for the mutator settings are as 
follows:

    minPerkLevel        Lowest allowed perk level
    maxPerkLevel        Highest allowed perk level
    veterancyNames      Classname of the perks to use, in full '<package>.<classname>' format.  
                        Copy for as many perks as you want to use
    loadStandardPerks   Set to true if the standard KF perks should be loaded as well

## Compatiblity
Do not use this mod with Server Perks, or any other mutator that has its own perk system or trader UI.

## Special Thanks
    Marco       Used Server Perks code for creating a custom MOTD box in place of video asd
    DasB        Bug reports for version 1.0
