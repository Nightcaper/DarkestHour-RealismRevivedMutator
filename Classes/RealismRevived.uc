/*
///////////////////////////////////////////////////////////////

The 29th Infantry Division made the original Realism mutator

Hammer/Soociki, AKA me, did a full rewrite from the ground up
since so much has changed about how DH works, and I really
didn't like how the original mutator worked. Sorry, but the
code was pretty ugly.

Special thanks to Basnett for answering many questions, and
pushing any changes I made to the DH original codebase to get
this mutator to work properly, as well as he himself making
his own changes that without them, this mutator couldn't
accomplish what it set out to do.


Another special thanks to the 4th Infantry Division for being
the hosting platform for all of this testing, and constant
support through development.



Publically released in good faith to the Darkest Hour Community


"Steadfast and Loyal" - The 4th Infantry Division


1/29/2018


///////////////////////////////////////////////////////////////
*/

class RealismRevived extends Mutator
    Config(RealismMatch);


var DarkestHourGame RealismGameInfo;
var DH_LevelInfo RealismLevelInfo;
var DHSetupPhaseManager RealismPhaseManager;

var bool bIsMatchEnabled;
var bool bIsMatchLive;
var bool bIsFFDisabled;
var bool bConstructionsEnabled;
var bool bRallyPointsEnabled;

var config int ConfigAlliesReinforcements;
var config int ConfigAxisReinforcements;
var config int ConfigWinLimit;
var config int ConfigRoundLimit;
var config int ConfigRoundDuration;



// You can translate these strings for other languages. Pretty nifty!

var localized string CriticalErrorMessage;
var localized string EnableMatchMessage;
var localized string DisableMatchMessage;
var localized string ErrorNotRefereeMessage;
var localized string RoundDurationChangedMessage;
var localized string NeedMoreTimeMessage;
var localized string AlliesReinforcementChangedMessage;
var localized string AxisReinforcementChangedMessage;
var localized string RoundLimitChangedMessage;
var localized string WinLimitChangedMessage;
var localized string ErrorCannotModifyEnabledMatchMessage;
var localized string ErrorMatchAlreadyEnabledMessage;
var localized string MatchLiveCalledOffMessage;
var localized string MatchSetLiveMessage;
var localized string ErrorLiveOnNoMatchMessage;
var localized string ErrorWrongTeamIndexMessage;
var localized string LiveRoundOverMessage;
var localized string ConstructionsEnabledMessage;
var localized string ConstructionsDisabledMessage;
var localized string RallyPointsEnabledMessage;
var localized string RallyPointsDisabledMessage;
var localized string InfiniteReinforcementsMessage;
var localized string ErrorWrongGameTypeMessage;
var localized string RealismGameTypeEnabledMessage;




struct RealismMatchSettings
{
    var int AlliesReinforcements;
    var int AxisReinforcements;
    var int WinLimit;
    var int RoundLimit;
    var int RoundDuration;
};

var RealismMatchSettings MainMatch;
var RealismMatchSettings CurMatch;
var RealismMatchSettings QuickMatch;


function PostBeginPlay()
{

    foreach AllActors(class'DarkestHourGame', RealismGameInfo)
    {
        break;
    }

    foreach AllActors(class'DH_LevelInfo', RealismLevelInfo)
    {
        break;
    }
    
    foreach AllActors(class'DHSetupPhaseManager', RealismPhaseManager)
    {
        break;
    }

    if ( RealismGameInfo == None || RealismLevelInfo == None )
    {
        Log(CriticalErrorMessage);
    }

    if( RealismPhaseManager != None )
    {
        RealismPhaseManager.SetupPhaseDuration = 0;
        RealismPhaseManager.SpawningEnabledTime = 0;
    }

    MainMatch.AlliesReinforcements = ConfigAlliesReinforcements;
    MainMatch.AxisReinforcements = ConfigAxisReinforcements;
    MainMatch.WinLimit = ConfigWinLimit;
    MainMatch.RoundLimit = ConfigRoundLimit;
    MainMatch.RoundDuration = ConfigRoundDuration;

    // I don't like how I implemented this. It's inflexible and forces you not to change FriendlyFireScale. Someone please fix this in the future.
    RealismGameInfo.FriendlyFireScale = 1.0;
    bIsFFDisabled = false;

}


function Mutate(string MutateString, PlayerController Sender)
{
    local array<string> Tokens;
    local string Command;
    local int Argument;
 
    Split(MutateString, " ", Tokens);
 
    if ( Tokens[0] ~= "Realism" )
    {
        if (!IsReferee(Sender))
        {
            Level.Game.Broadcast(self, ErrorNotRefereeMessage);
            return;
        }
       
        Command = Tokens[1];
       
        if (Command ~= "EnableMatch")
        {
            PreMatchSetup(MainMatch, Sender);
            return;
        }
        else if (Command ~= "EnableRealismGame")
        {
            EnableRealism();
            return;
        }
        else if (Command ~= "DisableMatch")
        {
            bIsMatchEnabled = false;
            Level.Game.Broadcast(self, DisableMatchMessage);
            RealismGameInfo.EndGame(Sender.PlayerReplicationInfo, DisableMatchMessage);
            return;
        }
        else if (Command ~= "EnableQuickMatch")
        {
            PreMatchSetup(QuickMatch, Sender);
            return;
        }
        else if (Command ~= "MatchLive")
        {
            MatchLive(CurMatch);
            return;
        }

        if (!bIsMatchEnabled)
        {
            Argument = int(Tokens[2]);
   
            if (Command ~= "SetRoundTime")
            {
                MainMatch.RoundDuration = Argument;
                Level.Game.Broadcast(self, RoundDurationChangedMessage);
                return;
            }
            else if (Command ~= "NeedMoreTime")
            {
                SetRoundDuration(0);
                Level.Game.Broadcast(self, NeedMoreTimeMessage);
                return;
            }
            else if ( Command ~= "ToggleConstructions" )
            {
                ToggleConstructions();
            }
            else if ( Command ~= "ToggleRallyPoints" )
            {
                ToggleRallyPoints();
            }
            else if ( Command ~= "InfiniteReinforcements" )
            {
                SetInfiniteReinforcements();
            }
            else if (Command ~= "SetAlliesReinforcements")
            {
                MainMatch.AlliesReinforcements = Argument;
                Level.Game.Broadcast(self, AlliesReinforcementChangedMessage);
                return;
            }
            else if (Command ~= "SetAxisReinforcements")
            {
                MainMatch.AxisReinforcements = Argument;
                Level.Game.Broadcast(self, AxisReinforcementChangedMessage);
                return;
            }
            else if (Command ~= "SetRoundLimit")
            {
                MainMatch.RoundLimit = Argument;
                Level.Game.Broadcast(self, RoundLimitChangedMessage);
                return;
            }
            else if (Command ~= "SetWinLimit")
            {
                MainMatch.WinLimit = Argument;
                Level.Game.Broadcast(self, WinLimitChangedMessage);
                return;
            }
        }
        else
        {
            Level.Game.Broadcast(self, ErrorCannotModifyEnabledMatchMessage);
        }
    }

    super.Mutate(MutateString, Sender);
}


function PreMatchSetup(RealismMatchSettings Settings, PlayerController Referee)
{
    if( !bIsMatchEnabled && RealismLevelInfo.GameTypeClass == class'RealismRevived.DHGameType_Realism' )
    {
        Level.Game.Broadcast(self, EnableMatchMessage);
        bIsMatchEnabled = true;
        CurMatch.RoundLimit = Settings.RoundLimit;
        CurMatch.WinLimit = Settings.WinLimit;
        CurMatch.RoundDuration = Settings.RoundDuration;
        CurMatch.AlliesReinforcements = Settings.AlliesReinforcements;
        CurMatch.AxisReinforcements = Settings.AxisReinforcements;

        SetRoundDuration(0);
        SetReinforcements(AXIS_TEAM_INDEX, -1);
        SetReinforcements(ALLIES_TEAM_INDEX, -1);
        ToggleFF();
        GotoState('MatchPrimed');
    }
    else if ( RealismLevelInfo.GameTypeClass != class'RealismRevived.DHGameType_Realism' )
    {
        Level.Game.Broadcast(self, ErrorWrongGameTypeMessage);
    }
    else
    {
        Level.Game.Broadcast(self, ErrorMatchAlreadyEnabledMessage);
    }
}

function MatchLive(RealismMatchSettings Settings)
{
    if( bIsMatchEnabled )
    {
        if( bIsMatchLive )
        {
            bIsMatchLive = false;
            SetRoundDuration(0);
            SetReinforcements(AXIS_TEAM_INDEX, -1);
            SetReinforcements(ALLIES_TEAM_INDEX, -1);
            ToggleFF();
            // I want to make sure people get the message. It's easy to miss in the heat of fire.
            Level.Game.Broadcast(self, MatchLiveCalledOffMessage);
            Level.Game.Broadcast(self, MatchLiveCalledOffMessage);
        }
        else
        {
            bIsMatchLive = true;
            SetRoundLimit(Settings.RoundLimit);
            SetWinLimit(Settings.WinLimit);
            SetRoundDuration(Settings.RoundDuration);
            SetReinforcements(AXIS_TEAM_INDEX, Settings.AxisReinforcements);
            SetReinforcements(ALLIES_TEAM_INDEX, Settings.AlliesReinforcements);
            ToggleFF();
            Level.Game.Broadcast(self, MatchSetLiveMessage);
        }
    }
    else
    {
        Level.Game.Broadcast(self, ErrorLiveOnNoMatchMessage);
    }
}

function EnableRealism()
{
    RealismLevelInfo.GameTypeClass = class'RealismRevived.DHGameType_Realism';
    RealismGameInfo.bIsAttritionEnabled = false;
    RealismGameInfo.ResetGame();
    Level.Game.Broadcast(self, RealismGameTypeEnabledMessage);
}

function SetReinforcements(int TeamIndex, int amount)
{
    if ( TeamIndex == AXIS_TEAM_INDEX || TeamIndex == ALLIES_TEAM_INDEX )
    {
        RealismGameInfo.ModifyReinforcements( TeamIndex, amount, true, false);
    }
    else
    {
        Level.Game.Broadcast(self, ErrorWrongTeamIndexMessage);
    }
}

function SetInfiniteReinforcements()
{
    if( !bIsMatchEnabled )
    {
        RealismGameInfo.ModifyReinforcements(ALLIES_TEAM_INDEX, -1, true, false);
        RealismGameInfo.ModifyReinforcements(AXIS_TEAM_INDEX, -1, true, false);
        Level.Game.Broadcast(self, InfiniteReinforcementsMessage);
    }
    else
    {
        Level.Game.Broadcast(self, ErrorCannotModifyEnabledMatchMessage);
    }
}

function SetRoundLimit(int amount)
{
    // All three of these have to be set to make sure it doesn't conflict with RO or DH's old core functionality of RoundLimit.
    RealismGameInfo.RoundLimit = amount;
    RealismGameInfo.GRI.RoundLimit = amount;
    RealismGameInfo.GRI.DHRoundLimit = amount;
}

function SetWinLimit(int amount)
{
    RealismGameInfo.WinLimit = amount;
}

function SetRoundDuration(int NewSeconds)
{
    if ( RealismGameInfo != None )
    {
        RealismGameInfo.RoundDuration = NewSeconds;
        RealismGameInfo.GRI.RoundDuration = NewSeconds;
        RealismGameInfo.GRI.DHRoundDuration = NewSeconds;
        RealismGameInfo.GRI.RoundEndTime = RealismGameInfo.GRI.ElapsedTime + NewSeconds; // setting time is wonky without this.
    }
}

function bool IsReferee( PlayerController Sender )
{
    return Sender.PlayerReplicationInfo.bAdmin || Sender.PlayerReplicationInfo.bSilentAdmin;
}

function ToggleConstructions()
{
    bConstructionsEnabled = RealismGameInfo.GRI.bAreConstructionsEnabled;

    if( !bConstructionsEnabled )
    {
        RealismGameInfo.GRI.bAreConstructionsEnabled = true;
        Level.Game.Broadcast(self, ConstructionsEnabledMessage);
    }
    else
    {
        RealismGameInfo.GRI.bAreConstructionsEnabled = false;
        Level.Game.Broadcast(self, ConstructionsDisabledMessage);
    }
}

function ToggleRallyPoints()
{
    bRallyPointsEnabled = RealismGameInfo.SquadReplicationInfo.bAreRallyPointsEnabled;

    if( !bRallyPointsEnabled )
    {
        RealismGameInfo.SquadReplicationInfo.bAreRallyPointsEnabled = true;
        Level.Game.Broadcast(self, RallyPointsEnabledMessage);
    }
    else
    {
        RealismGameInfo.SquadReplicationInfo.bAreRallyPointsEnabled = false;
        Level.Game.Broadcast(self, RallyPointsDisabledMessage);
    }
}

function ToggleFF()
{
    if ( !bIsFFDisabled )
    {
        RealismGameInfo.FriendlyFireScale = 0.0;
    }
    else
    {
        RealismGameInfo.FriendlyFireScale = 1.0;
    }
    
    bIsFFDisabled = !bIsFFDisabled;
}


state MatchPrimed
{
    function Timer()
    {
        global.Timer();

        if( bIsMatchLive )
        {
            SetTimer(0.0, false);
            GotoState('MatchIsLive');
        }
    }

    Begin:
        SetTimer(1, true);
}

state MatchIsLive
{
    
    function Timer()
    {
        global.Timer();
        
        if( Level.Game.IsInState('RoundOver') )
        {
            bIsMatchLive = false;
            SetRoundDuration(0);
            SetReinforcements(AXIS_TEAM_INDEX, -1);
            SetReinforcements(ALLIES_TEAM_INDEX, -1);
            ToggleFF();
            Level.Game.Broadcast(self, LiveRoundOverMessage);
            SetTimer(0.0, false);
            GotoState('MatchPrimed');
        }
    }

    Begin:
        SetTimer(2, true);
}

defaultproperties
{
    GroupName="RealismRevived"
    FriendlyName="Realism Revived Public Release"
    Description="4th ID Realism Mutator - Released Publically In Good Faith"
    QuickMatch=(AlliesReinforcements=0,AxisReinforcements=0,WinLimit=1,RoundLimit=1,RoundDuration=0)
    ConfigAlliesReinforcements=0
    ConfigAxisReinforcements=0
    ConfigWinLimit=1
    ConfigRoundLimit=1
    ConfigRoundDuration=1800
    CriticalErrorMessage="[Realism Mutator - ERROR] Critical: No DarkestHourGame or DH_LevelInfo found on the level! This mutator will not properly work without it!"
    EnableMatchMessage="[Realism Match] Match has been enabled. Time limit and reinforcements are temporarily unlimited, and friendly fire is disabled for now. Make final preparations before LIVE is called!"
    DisableMatchMessage="[Realism Match] Match disabled, game end required to reset defaults."
    ErrorNotRefereeMessage="[Realism Match - ERROR] Referee attempting to change the settings is not currently logged in!"
    RoundDurationChangedMessage="[Realism Match] Round duration has been changed."
    NeedMoreTimeMessage="[Realism Match] Time limit turned off, take your time setting up the realism match."
    AlliesReinforcementChangedMessage="[Realism Match] Allies reinforcements have been changed."
    AxisReinforcementChangedMessage="[Realism Match] Axis reinforcements have been changed."
    RoundLimitChangedMessage="[Realism Match] Round limit has been changed."
    WinLimitChangedMessage="[Realism Match] Round win limit has been changed."
    ErrorCannotModifyEnabledMatchMessage="[Realism Match] Realism matches MUST be disabled before you can modify them!"
    ErrorMatchAlreadyEnabledMessage="[Realism Match - ERROR] A match has already been enabled! You will need to disable the match, reset all the settings and -then- enable the match!"
    MatchLiveCalledOffMessage="[Realism Match] ======= CEASE FIRE, CEASE FIRE!! ======= Match has been called off!"
    MatchSetLiveMessage="[Realism Match] ======= LIVE LIVE LIVE ======="
    ErrorLiveOnNoMatchMessage="[Realism Match - ERROR] No match has been enabled yet! You must enable a match before you can set it live!"
    ErrorWrongTeamIndexMessage="[Realism Match - ERROR] Reinforcements could not be set due to incorrect TeamIndex! This error should never occur, please contact the maintainer of this mutator!"
    LiveRoundOverMessage="[Realism Match] Round is over and no longer LIVE!"
    ConstructionsEnabledMessage="[Realism Match] Constructions have been enabled."
    ConstructionsDisabledMessage="[Realism Match] Constructions have been disabled."
    RallyPointsEnabledMessage="[Realism Match] Rally points have been enabled."
    RallyPointsDisabledMessage="[Realism Match] Rally points have been disabled."
    InfiniteReinforcementsMessage="[Realism Match] Reinforcements set to infinite. This won't impact the realism match you set up once you enable it and call LIVE."
    ErrorWrongGameTypeMessage="[Realism Match - ERROR] The Realism gametype is not enabled! Please enable the Realism gametype before trying to enable a match!"
    RealismGameTypeEnabledMessage="[Realism Match] Realism Gametype has been enabled. Please wait while the game resets."
}