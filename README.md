<h1>[ZR] Simple Rank System</h1>

<p>A simple rank system destined to servers with the Zombie Reloaded Plugin.</p>
<p>It has only MySQL Support for now, and it's still in beta, so it will be changed through time!</p>

<h2>Requirements: </h2>
<ul>
  <li>Sourcemod - https://www.sourcemod.net/</li>
  <li>Zombie Reloaded Plugin - https://forums.alliedmods.net/showthread.php?t=277597</li>  
</ul>

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

<h3>Commands</h3>
<ul>
  <li><b>sm_rank</b> - It shows your positions in the rank and your total points;</li>
  <li><b>sm_top NUMBER</b> - It shows the Top NUMBER players listed in the database, order by Points;</li>
  <li><b>sm_topzkills NUMBER</b> - It shows the Top NUMBER players listed in the database, order by Zombies Killed;</li>
  <li><b>sm_topihumans NUMBER</b> - It shows the Top NUMBER players listed in the database, order by Infected Humans;</li>
  <li><b>sm_resetrank_all</b> - It will reset all the players in the database (needs <b>ROOT FLAG</b> to have access)</li>
</ul>

<h3>ConVars</h3>
<ul>
  <li><b>zr_rank_startpoints</b> (Default: 100) - Number of points that a new player starts;</li>
  <li><b>zr_rank_infecthuman</b> (Default: 1) - Number of points that you get when you infect an human (0 will disable it)</li>
  <li><b>zr_rank_killzombie</b> (Default: 1) - Number of points that you get when you kill a zombie (0 will disable it)</li>
  <li><b>zr_rank_killzombie_headshot</b> (Default: 2) - Number of points that you get when you kill a zombie with an headshot (0 will disable it);</li>
  <li><b>zr_rank_killzombie_knife</b> (Default: 5) - Number of points that you get when you kill a zombie with a knife (0 will disable it);</li>
  <li><b>zr_rank_killzombie_he</b> (Default: 3) - Number of points that you get when you kill a zombie with a He Grenade (0 will disable it);</li>
  <li><b>zr_rank_killzombie_smokeflashbang</b> (Default: 20) - Number of points that you get when you kill a zombie with a Smoke/Flashbang (0 will disable it);</li>
  <li><b>zr_rank_stabzombie_left</b> (Default: 1) - Number of points that you get when you stab a zombie with left mouse button (0 will disable it);</li>  
  <li><b>zr_rank_stabzombie_right</b> (Default: 1) - Number of points that you get when you stab a zombie with right mouse button (0 will disable it);</li>
  <li><b>zr_rank_maxplayers_top</b> (Default: 50) - Max number of players that are shown in the top commands</li>
</ul>

<h3>To-Do List</h3>
<ul>
  <li>Translations;</li>
  <li>Support for more than 10 players in the sm_top command; -> DONE</li>
  <li>Better checker for left and right mouse buttons when you stab a zombie;</li>
  <li>A simple API for another sub-plugins;</li>
  <li>A WebPage to show the rank of any player;</li>
  <li>Optimize the code (<b><i><u>A LOT</b></i></u>);</li>
  <li>Other suggestions given to me;</li>
</ul>

I hope you enjoyed, and I'll keep this repository updated as soon as I update the plugin!

My Steam Profile if you have any questions -> http://steamcommunity.com/id/HallucinogenicTroll/

My Website -> http://HallucinogenicTrollConfigs.com/
