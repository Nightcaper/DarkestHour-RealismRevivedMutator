# 4th Infantry Division's Realism Revived - Realism Mutator
## Scripted by Hammer of the 4th ID, with special thanks to Basnett for answering many questions and code help


This thing was quite the challenge to fully rewrite from the ground up, with cleaner code, more flexible mechanics, and some of the new features of DH taken in to account. It took more than a month of work, is 300+ lines of code long, and really was my baby. I can't work on it anymore though, and it's actually fully functional as of writing this... and now that the 4th is pulling out of Darkest Hour, it's time for this to get released. I'm not happy about a lot of what happened, a lot of what people said about us, but this is the right thing to do.


It's really a shame how things turned out for our unit in the game, but I really can't let more than a month of work go to waste. I'm releasing this in good faith to the community at large, hoping it will be used and that people will update and add functionality to the code in the future, even maintain it when big changes happen to the game. Final advice to other Darkest Hour realism units before we get on to how to use the mutator:

"Darkest Hour is a -small- community. We need to be good to each other." - Captain S Bert of the 6th GA



=============================================================================================================


You will need to compile this mod. Make a folder in steamapps/common/Red Orchestra called "RealismRevived" and put the Classes folder, as well as its entire content, inside of this folder. This structure is important, otherwise it's not going to compile properly. Next, go in your DarkestHour/System folder, and open DarkestHour.ini. 


I'm going off memory from this point, in the section [Editor.Engine] there should be a bunch of lines saying "EditPackage=" with a bunch of packages. Go to the bottom of all that where it's "EditPackages=DH_Construction" or something to that degree. Make a space right underneath that line, and type without quotes, "EditPackages=RealismRevived".


Now, the batch file that came in the Github repository, "Build the Mutator.bat", make sure that's in your steamapps/common/Red Orchestra/System directory, and then run it. It should build the mod file. You need the two components it pops out... RealismRevived.u, and RealismRevived.ucl. If you're missing one of these, the mutator won't work properly! RealismRevived.ucl is in DarkestHour/System, and RealismRevived.u will be in Red Orchestra/System (yeah I know it's dumb, but it is what it is). Take both of these files, and you're going to need to upload them to your server by FTP and restart (upload them to DarkestHour/System on the server).


Pop in to webadmin once the server is restarted, go to the Mutators section, check the Realism Revived mutator, Set Selected Mutators, and then Restart Map and you're golden. 



Manual for using the mutator is below! 

==============================================================================================================



Welcome to the manual for the 4th Infantry Division Realism mutator! This manual assumes you have already enabled the mutator on your server and restarted the level/map. I will run you through everything you need to know.


-BIG WARNING-: Do NOT attempt to mess with the FriendlyFireScale, either by config, webadmin, etc, once the mutator is enabled! Just, don't. My implementation of disabling and enabling FF is very touchy and it's just way too easy to break it. Feel free to make a pull request if you can fix it.





First, you MUST be logged in as an admin, I guarantee you not a single command will work unless you are! That's the biggest change from the old mutator, only an admin can do basically anything, and this is how I designed it, get used to it. It's better, and safer.


Now, before you do -anything-... this is how the mutator works:


- You make the settings you want for your realism match. Round duration (in seconds), round limit, how many rounds you need to win for the match to end, reinforcements for allies, and reinforcements for axis. Do NOT enable the match before doing this, because you can't go back without disabling the match, which ends the game and loads another map (or the same map if that's the only one in your rotation).


- When you are SURE about all the settings that you have set (it won't tell you what you set, that's normal), then you enable the match. The changes won't happen until you call LIVE though, but what WILL happen, is the time limit will be infinite, reinforcements infinite, and friendly fire SHOULD be disabled. That will give you all the time you need to set up before LIVE.


- Now, when you have everyone in position, and you're basically ready to go live, you call LIVE through the mutator. All the changes happen at once, the mutator itself calls LIVE out so you don't have to, and it's game on!




Now... how do we do all of this? Alright, assuming you're logged in to admin, here are the commands...


Every command starts with 'mutate realism' without the quotes. So, for example, when I say a command is 'setroundtime' I mean you type 'mutate realism setroundtime'.


Open the console (~) and here are the commands:

enablerealismgame - This needs to be the FIRST command you type in! It enables a Realism gametype which overrides Advance, and any other gametype! It's needed, otherwise the moment you try to make a realism match on Advanced LIVE with 0 reinforcements, the game ends. After this command, make your settings below and then you're safe to enable a realism match and make it live.

setroundtime <number in seconds> - This sets the time, in SECONDS. Set to 0 for unlimited time. Basically you'll have to convert minutes to seconds so you can put the right amount in. Sorry, that's just how it is...


needmoretime - Actually a useful command. Sets time to unlimited so you have more time to make match settings, just in case people are messing about or you need to convert seconds to minutes. Don't worry, this won't mess with your settings... once you set your time, enable the match and call LIVE, it will override what this did, with your settings.


infinitereinforcements - Right up there with needmoretime, this can help especially in levels that use a phase manager dictating your reinforcements (almost every advance map). Even after enabling a realism game, you may have to do this if you have guys teamkilling each other left and right before you enable a match. This won't affect how you set the reinforcements in your realism match, don't worry.


setalliesreinforcements <number> - Sets the ally reinforcements. -1 is infinite... but you don't want that in realism. Set it to 0 and everyone only has one life, usually the setting you want. Remember that these changes won't happen until LIVE, so don't worry if someone isn't on the server yet. They can still spawn in UNTIL you call LIVE.


setaxisreinforcements <number> Same as above, but for the Axis team. I could have had the command be the same and apply to both teams, but someone might want to do differing reinforcements for their realism for whatever reason (handicaps for smaller units), and could be nice to have a bit of a wave system going!


setroundlimit <number> - Sets the max rounds for both teams. Make sure that WinLimit is ALWAYS lower than this! Set this to 1 if you're just doing a one round skirm anyway.


setwinlimit <number> - Sets the wins a team needs before they are declared the winner. You can't see this on the scoreboard by original design, so don't worry if you can't see the change during LIVE. Set this to 1 if you're just doing a one round skirm anyway. Otherwise I recommend being smart about this one. For example, in a 5 round match, a win limit of 3 would be best.


toggleconstructions - Turn constructions on or off in -any- gametype

togglerallypoints - Turn rally points on or off in -any- gametype





Alright, after setting all the match parameters (I made them have defaults in case you did NOT set them anyway), you use these to control the flow of the match. These commands work the same as above, with having to do 'mutate realism' before them in the console:



enablematch - This actually enables the match. Time limit is set to unlimited, reinforcements infinite, and friendly fire SHOULD be disabled. This gives you enough time to actually set up, and this command should be typed the very MOMENT you have all the settings that you want, and all you have to do is brief people on how this will go down, where everyone will start, whether it's attack/defense, move people in to their proper places, all that good stuff. You have literally all the time in the world to do this so don't rush it, rely on enablematch after you've set your settings to be the stage where you can "bring it all together" before LIVE.


disablematch - This is what you use if you mess up and enable the match before actually setting what you need to set. Anyways, you use this to disable the match, either because you mis-set, or did NOT set, something you wanted/needed to. You should not need this if you did set the settings as you need, unless a special circumstance during the skirm requires it. It ends the game, either resetting the same map (if it's the only map in your rotation list) or switching to another one (Not the best solution, but yeah... make a pull request if you can do better). This is the only, reliable, way I can reset the entire match so you can make all your settings again.


enablequickmatch - I'm glad I implemented this command. This is a no-nonsense, jump you in to the fray, command that automatically enables a match with the following settings: everyone has one life, one round, one win, unlimited time. This is the most common type of skirmish, but if you need one just like this with a 30 minute time limit instead, just use 'enablematch' without setting any of the settings.


matchlive - The golden command, the one command that matters the most. Once you type this command, it's on. All the settings happen at once, LIVE is called in the chat by the mutator, and everyone's locked in... friendly fire will be re-enabled... or should. Now, here's the crazy thing, what I changed about it, what it didn't have before... you can call a CEASE FIRE by calling this same command before the match is over. That's right, you can UN-LIVE it. Let's say someone wasn't in their proper place, or someone broke a rule you set for the match, and you need to stop the match because otherwise the skirmish would be unfair. Just type 'mutate realism matchlive' again, and the chat will blow up with "CEASE FIRE CEASE FIRE!!", reinforcements infinite again, time limit infinite again, and friendly fire should be off once again.



That's it, that's all the commands. Just follow those instructions, and you should have no issue setting you your practice, or real, skirmishes. This mutator took a lot of work, and is very different from how the 29ths mutator worked. I will no longer be working on this actively, so you get what you get.


Oh, right... if you look in the code, there are config variables that represent match settings too. I really didn't want to encourage people to do their settings by the ini files since it seems a bit too old school... but, yeah, you COULD. Just don't run any of the commands to change match settings if you do, because they will always overwrite the ini values that you set. If you didn't understand anything I just said in this paragraph, ignore it... it's really not important for setting up a match. Either method works.
