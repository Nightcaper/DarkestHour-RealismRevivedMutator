class DHGameType_Realism extends DHGameType
    abstract;

// As of 1/29/2018, gametypes are abstract and their implementation is in DarkestHourGame.uc. This may not be the case at some point though...

// GameTypes may change in the future which will break my mutator. This file may need to be updated if and when it happens.


defaultproperties
{
    GameTypeName="Realism"
    bUseInfiniteReinforcements=True
    bRoundEndsAtZeroReinf=False
    bUseReinforcementWarning=False
}