<h1>[ZR/ZP] Rank System</h1>

<p>A simple rank system destined to servers with any plugins related to the Zombie Gamemode (that is supported currently).</p>

<h2>Requirements: </h2>

- [Sourcemod](https://www.sourcemod.net/);
- [Zombie Reloaded](https://forums.alliedmods.net/showthread.php?t=277597) <b>OR</b> [Zombie Plague](https://forums.alliedmods.net/showthread.php?t=290657);
- [ColorVariables](https://forums.alliedmods.net/showthread.php?t=267743) (To Compile);

<h3>MySQL</h3>
<p>Add this to your databases.cfg in <i>addons/sourcemod/configs</i> and change it as you need.

```
"zr_rank"
{
  "driver"    "mysql"
  "host"      "YOUR_HOST_ADDRESS"
  "database"  "YOUR_DATABASE_NAME"
  "user"      "DATABASE_USERNAME"
  "pass"      "USERNAME_PASSWORD"
}
```

<h3>Installation</h3>

1. Put the file <b>zr_rank.smx</b> in <i>addons/sourcemod/plugins</i>;
2. Put the file <b>zr_rank.phrases.txt</b> in <i>addons/sourcemod/translations</i>

<h3>Commands</h3>

- <b>sm_rank</b> - It shows your positions in the rank and your total points;
- <b>sm_top NUMBER</b> - It shows the Top NUMBER players listed in the database, order by Points;
- <b>sm_topkills NUMBER</b> - It shows the Top NUMBER players listed in the database, order by Zombies Killed;
- <b>sm_topinfects NUMBER</b> - It shows the Top NUMBER players listed in the database, order by Infected Humans;
- <b>sm_humanwins NUMBER</b> - It shows the Top NUMBER players listed in the database, order by Round Wins as Human;
- <b>sm_zombiewins NUMBER</b> - It shows the Top NUMBER players listed in the database, order by Round Wins as Zombie;
- <b>sm_resetrank_all</b> - It will reset all the players in the database (needs <b>ROOT FLAG</b> to have access)

<h3>ConVars</h3>

- <b>zr_rank_startpoints</b> (Default: 100) - Number of points that a new player starts;
- <b>zr_rank_infecthuman</b> (Default: 1) - Number of points that you get when you infect an human (0 will disable it)
- <b>zr_rank_killzombie</b> (Default: 1) - Number of points that you get when you kill a zombie (0 will disable it)
- <b>zr_rank_killzombie_headshot</b> (Default: 2) - Number of points that you get when you kill a zombie with an headshot (0 will disable it);
- <b>zr_rank_killzombie_knife</b> (Default: 5) - Number of points that you get when you kill a zombie with a knife (0 will disable it);
- <b>zr_rank_killzombie_he</b> (Default: 3) - Number of points that you get when you kill a zombie with a He Grenade (0 will disable it);
- <b>zr_rank_killzombie_smokeflashbang</b> (Default: 20) - Number of points that you get when you kill a zombie with a Smoke/Flashbang (0 will disable it);
- <b>zr_rank_stabzombie_left</b> (Default: 1) - Number of points that you get when you stab a zombie with left mouse button (0 will disable it);  
- <b>zr_rank_stabzombie_right</b> (Default: 1) - Number of points that you get when you stab a zombie with right mouse button (0 will disable it);
- <b>zr_rank_maxplayers_top</b> (Default: 50) - Max number of players that are shown in the top commands;
- <b>zr_rank_minplayers</b> (Default: 4) - Minimum players for activating the rank system (0 will disable this function);
- <b>zr_rank_beinginfected</b> (Default: 1) - How many points you lost if you got infected by a zombie;
- <b>zr_rank_beingkilled</b> (Default: 1) - How many points you lost if you get killed by an human;
- <b>zr_rank_allow_warmup</b> (Default: 0) - Allow players to get or lose points during Warmup;
- <b>zr_rank_prefix</b> (Default: [{green}ZR Rank{default}] - Prefix to be used in every chat's plugin (You can use ColorVariables colors code);
- <b>zr_rank_suicide</b> (Default: 0) - How many points a player lose when he suicides;
- <b>zr_rank_roundwin_human</b> (Default: 1) - How many points a player gets when he wins the round as an human;
- <b>zr_rank_roundwin_zombie</b> (Default: 1) - How many points a player gets when he wins the round as an zombie;

```SourcePawn
/*********************************************************
 * Get's the number of a player's points
 *
 * @param client		The client to get the points
 * @return				The number of points		
 *********************************************************/
native int ZR_Rank_GetPoints(int client);

/*********************************************************
 * Get's the number of a player's Zombie Kills
 *
 * @param client		The client to get the zombie kills
 * @return				The number of points		
 *********************************************************/
native int ZR_Rank_GetZombieKills(int client);

/*********************************************************
 * Get's the number of a player's Human Infects
 *
 * @param client		The client to get the zombie kills
 * @return				The number of points		
 *********************************************************/
native int ZR_Rank_GetHumanInfects(int client);

/*********************************************************
 * Get's the number of a player's Round Wins as Zombie
 *
 * @param client		The client to get the round wins
 * @return				The number of round wins		
 *********************************************************/
native int ZR_Rank_GetRoundWins_Zombie(int client);

/*********************************************************
 * Get's the number of a player's Round Wins as Human
 *
 * @param client		The client to get the round wins
 * @return				The number of round wins		
 *********************************************************/
native int ZR_Rank_GetRoundWins_Human(int client);

/*********************************************************
 * Sets points to a certain player
 *
 * @param client		The client to get the points
 * @param points		Number of points to set
 * @return				The number of points	
 *********************************************************/
native bool ZR_Rank_SetPoints(int client, int points);
```

<h3>Changelog</h3>

<p>To see the full changelog, check the CHANGELOG.md file -> https://github.com/hallucinogenic/-ZR-Zombie-Rank/blob/master/CHANGELOG.md</p>

<h3>To-Do List</h3>

- Translations -> <b>DONE</b>;
- Support for more than 10 players in the sm_top command; -> <b>DONE</b>
- Lose points by being infected or killed; -> <b>DONE</b>
- Better checker for left and right mouse buttons when you stab a zombie;
- A simple API for another sub-plugins; - <b>Partialy DONE</b>
- A WebPage to show the rank of any player;
- Optimize the code (<b><i><u>A LOT</b></i></u>);
- Other suggestions given to me;

I hope you enjoyed, and I'll keep this repository updated as soon as I update the plugin!

My Steam Profile if you have any questions -> http://steamcommunity.com/id/HallucinogenicTroll/

My Website -> http://HallucinogenicTrollConfigs.com/
