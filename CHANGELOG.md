<h1>[ZR/ZP] Rank System - Changelog</h1>

<p>Just to note every change that was made since the plugin's release.</p>
<p>If you want to see every function that the plugin has, read the [README](../README.md)  file;</p>

<h2>Version 1.0 </h2>

- Plugin Release

<h2>Version 1.1</h2>

<p><b>IF YOU USE A VERSION BEFORE THIS ONE, RESET YOUR DATABASE!</b></p>
	
- Added one CVAR: <b>zr_rank_maxplayers_top</b> (Default: 50) - Max number of players that are shown in the top commands
- Changed <b>sm_top</b> command. Now you can set the limit (maximum value is set by the <b>zr_rank_maxplayers_top</b> command) of top players in this command.
	- Now you can use like this: <b>sm_top NUMBER</b> (if you don't add a number, it will set 10 by default).
- Added <b>sm_topzkills</b> command! It shows the top players list order by Zombie Kills;
- Added <b>sm_topihuman</b> command! It shows the top players list order by Infected Humans;
- Cleaned a lot of useless code;

<h2>Version 1.2</h2>

- Added an API so that developers can make another plugins related to this plugin! Natives added:
	- <b>ZR_Rank_GetPoints</b> - It will return the number of points that a player has;
	- <b>ZR_Rank_SetPoints</b> - It will set the number of points that you want, on a player;
- Added a CVAR: <b>zr_rank_minplayers</b> (Default: 4) - It set the minimum players that it's needed to get or lose points when you are infected/killed;
- Added a CVAR: <b>zr_rank_beinginfected</b> (Default: 1) - It set the number of points that you lose when you get infected by a zombie;
- Added a CVAR: <b>zr_rank_beingkilled</b> (Default: 1) - It set the number of points that you lose when you are killed by a human;
- Added a Sub-plugin: <b><i>[ZR Rank] Connect Message</i></b> which shows a message when a player connects. It has the following CVARs:
	- <b>zr_rank_connectmessage_type</b> (Default: 1) - Type of HUD that you want to use in the connect message (0 = Disable, 1 = HintText, 2 = CenterText, 3 = Chat, 4 = HudText);
	- <b>zr_rank_connectmessage_hudtext_red</b> (Default: 255) - RGB Code for the Red Color used in the HudText ("zr_rank_connectmessage_type" needs to be set on 4);
	- <b>zr_rank_connectmessage_hudtext_green</b> (Default: 255) - RGB Code for the Green Color used in the HudText ("zr_rank_connectmessage_type" needs to be set on 4);
	- <b>zr_rank_connectmessage_hudtext_blue</b> (Default: 255) - RGB Code for the Blue Color used in the HudText ("zr_rank_connectmessage_type" needs to be set on 4);

<h2>Version 1.3</h2>

- Fixed a bug when a zombie is killed by a human and doesn't lose points;
- Fixed a bug with the Zombie Kills and Human Infects. Now it checks perfectly;
- Added two more natives:
	- <b>ZR_Rank_GetZombieKills</b> -> Returns the number of a client's Zombie Kills;
	- <b>ZR_Rank_GetHumanInfects</b> -> Returns the number of a client's Human Infections;

<h2>Version 1.4</h2>

- Merged Agent Wesker's Pull Request with the master repository;
- Fixed some minor bugs;
- Added translations (English and Portuguese);
- Added a new CVAR: <b>zr_rank_prefix</b> (Default: [{purple}ZR Rank{default}]) -> Changes every chat's plugin;
- Added a new CVAR: <b>zr_rank_allow_warmup</b> (Default: 0) -> Allow players to get or lose points during warmup;

<h2>Version 1.5</h2>

<p><b>IF YOU USE A VERSION BEFORE THIS ONE, RESET YOUR DATABASE!</b></p>

- Fixed some bugs related to the warmup checker;
- Added a new CVAR: <b>zr_rank_suicide</b> (Default: 0) - How many points a player lose when he suicides.
- Added a new CVAR: <b>zr_rank_roundwin_human</b> (Default: 1) - How many points a player gets when wins the round as an human;
- Added a new CVAR: <b>zr_rank_roundwin_zombie</b> (Default: 1) - How many points a player gets when wins the round as a zombie;
- Added a new Command: <b>sm_humanwins</b> - Show the Top Players List, order by Round Wins as Human;
- Added a new Command: <b>sm_zombiewins</b> - Show the Top Players List, order by Round Wins as Zombie;
- Added a new native: <b>ZR_Rank_GetRoundWins_Human</b> - It returns a number of Round Wins as Human of a player
- Added a new native: <b>ZR_Rank_GetRoundWins_Zombie</b> - It returns a number of Round Wins as Zombie of a player
- Renamed the command <b>sm_topzkills</b> to <b>sm_topkills</b>;
- Renamed the command <b>sm_topihumans</b> to <b>sm_topinfects</b>;
- Added support for <b>[Zombie Plague](https://forums.alliedmods.net/showthread.php?t=290657)</b> (Not sure if it works 100%, only in theory);






