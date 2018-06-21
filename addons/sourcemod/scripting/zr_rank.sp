/* [CS:GO] Zombie Reloaded Rank
 *
 *  Copyright (C) 2017 Hallucinogenic Troll
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#undef REQUIRE_PLUGIN
#include <zombiereloaded>
#include <zombieplague>
#define REQUIRE_PLUGIN
#include <colorvariables>

#pragma semicolon 1
#pragma newdecls required

#include "zr_rank/variables.sp"
#include "zr_rank/database.sp"
#include "zr_rank/top_menu.sp"
#include "zr_rank/events.sp"
#include "zr_rank/natives.sp"

public Plugin myinfo =
{
	name = "[ZR] Rank",
	author = "Hallucinogenic Troll",
	description = "Zombie Rank for Zombie Reloaded Servers",
	version = "1.5",
	url = "http://HallucinogenicTrollConfigs.com/"
};

public void OnPluginStart()
{
	// Connection to the database;
	SQL_TConnect(OnSQLConnect, "zr_rank");
	
	// ConVars
	g_CVAR_ZR_Rank_StartPoints 	= CreateConVar("zr_rank_startpoints", "100", "How many points that a new player starts", _, true, 0.0, false);
	g_CVAR_ZR_Rank_InfectHuman = CreateConVar("zr_rank_infecthuman", "1", "How many points you get when you infect an human (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie = CreateConVar("zr_rank_killzombie", "1", "How many points you get when you kill a zombie (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie_Headshot = CreateConVar("zr_rank_killzombie_headshot", "2", "How many points you get when you kill a zombie with an headshot", _, true, 0.0, false);
	g_CVAR_ZR_Rank_StabZombie_Left = CreateConVar("zr_rank_stabzombie_left", "1", "How many points you get when you stab a zombie with left mouse button (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_StabZombie_Right = CreateConVar("zr_rank_stabzombie_right", "1", "How many points you get when you stab a zombie with right mouse button (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie_Knife = CreateConVar("zr_rank_killzombie_knife", "5", "How many points you get when you kill a zombie with a knife (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie_HE = CreateConVar("zr_rank_killzombie_he", "3", "How many points you get when you kill a zombie with a HE Grenade (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie_SmokeFlashbang = CreateConVar("zr_rank_killzombie_smokeflashbang", "20", "How many points you get when you kill a zombie with a Smoke Grenade or a Flashbang (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_MaxPlayers_Top = CreateConVar("zr_rank_maxplayers_top", "50", "Max number of players that are shown in the top commands", _, true, 1.0, false);
	g_CVAR_ZR_Rank_MinPlayers = CreateConVar("zr_rank_minplayers", "4", "Minimum players for activating the rank system (0 will disable this function)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_Prefix = CreateConVar("zr_rank_prefix", "[{purple}ZR Rank{default}]", "Prefix to be used in every chat's plugin");
	g_CVAR_ZR_Rank_BeingInfected = CreateConVar("zr_rank_beinginfected", "1", "How many points you lost if you got infected by a zombie", _, true, 0.0, false);
	g_CVAR_ZR_Rank_BeingKilled = CreateConVar("zr_rank_beingkilled", "1", "How many points you lost if you get killed by an human", _, true, 0.0, false);
	g_CVAR_ZR_Rank_AllowWarmup = CreateConVar("zr_rank_allow_warmup", "0", "Allow players to get or lose points during Warmup", _, true, 0.0, true, 0.0);
	g_CVAR_ZR_Rank_Suicide = CreateConVar("zr_rank_suicide", "0", "How many points do you lose when you suicide (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_RoundWin_Zombie = CreateConVar("zr_rank_roundwin_zombie", "1", "How many points you get by winning a round as a zombie", _, true, 0.0, false);
	g_CVAR_ZR_Rank_RoundWin_Human = CreateConVar("zr_rank_roundwin_human", "1", "How many points you get by winning a round as an human", _, true, 0.0, false);

	
	// Events
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("round_start",Event_RoundStart, EventHookMode_PostNoCopy);
	
	// Commands
	RegConsoleCmd("sm_rank", Command_Rank, "Shows a player rank in the menu");
	RegConsoleCmd("sm_top", Command_Top, "Shows the Top Players List, order by points");
	RegConsoleCmd("sm_topkills", Command_TopZombieKills, "Show the Top Players List, order by Zombie Kills");
	RegConsoleCmd("sm_topinfects", Command_TopInfectedHumans, "Show the Top Players List, order by Infected Humans");
	RegConsoleCmd("sm_humanwins", Command_TopWinRounds_Human, "Show the Top Players List, order by Round Wins as a Human");
	RegConsoleCmd("sm_zombiewins", Command_TopWinRounds_Zombie, "Show the Top Players List, order by Round Wins as a Zombie");
	RegAdminCmd("sm_resetrank_all", Command_ResetRank_All, ADMFLAG_ROOT, "Deletes all the players that are in the database");
	
	// Exec Config
	AutoExecConfig(true, "zr_rank", "zr_rank");
	
	LoadTranslations("zr_rank.phrases");
	
	//Late Load
	g_ZR_Rank_NumPlayers = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnAllPluginsLoaded()
{
	ZombieReloaded = LibraryExists("zombiereloaded");
	ZombiePlague = LibraryExists("zombieplague");
}
 
public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "zombiereloaded"))
	{
		ZombieReloaded = false;
	}
	else if(StrEqual(name, "zombieplague"))
	{
		ZombiePlague = false;
	}
}
 
public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "zombiereloaded"))
	{
		ZombieReloaded = true;
	}
	else if(StrEqual(name, "zombieplague"))
	{
		ZombiePlague = true;
	}
}

public void OnConfigsExecuted()
{
	g_CVAR_ZR_Rank_Prefix.GetString(g_ZR_Rank_Prefix, sizeof(g_ZR_Rank_Prefix));
	g_ZR_Rank_InfectHuman = g_CVAR_ZR_Rank_InfectHuman.IntValue;
	g_ZR_Rank_KillZombie = g_CVAR_ZR_Rank_KillZombie.IntValue;
	g_ZR_Rank_KillZombie_Headshot = g_CVAR_ZR_Rank_KillZombie_Headshot.IntValue;
	g_ZR_Rank_StartPoints = g_CVAR_ZR_Rank_StartPoints.IntValue;
	g_ZR_Rank_StabZombie_Left = g_CVAR_ZR_Rank_StabZombie_Left.IntValue;
	g_ZR_Rank_StabZombie_Right = g_CVAR_ZR_Rank_StabZombie_Right.IntValue;
	g_ZR_Rank_KillZombie_Knife = g_CVAR_ZR_Rank_KillZombie_Knife.IntValue;
	g_ZR_Rank_KillZombie_HE = g_CVAR_ZR_Rank_KillZombie_HE.IntValue;
	g_ZR_Rank_KillZombie_SmokeFlashbang = g_CVAR_ZR_Rank_KillZombie_SmokeFlashbang.IntValue;
	g_ZR_Rank_MaxPlayers_Top = g_CVAR_ZR_Rank_MaxPlayers_Top.IntValue;
	g_ZR_Rank_AllowWarmup = g_CVAR_ZR_Rank_AllowWarmup.IntValue;
	g_ZR_Rank_MinPlayers = g_CVAR_ZR_Rank_MinPlayers.IntValue;
	g_ZR_Rank_BeingInfected = g_CVAR_ZR_Rank_BeingInfected.IntValue;
	g_ZR_Rank_BeingKilled = g_CVAR_ZR_Rank_BeingKilled.IntValue;
	g_ZR_Rank_Suicide = g_CVAR_ZR_Rank_Suicide.IntValue;
	g_ZR_Rank_RoundWin_Zombie = g_CVAR_ZR_Rank_RoundWin_Zombie.IntValue;
	g_ZR_Rank_RoundWin_Human = g_CVAR_ZR_Rank_RoundWin_Human.IntValue;
}

public void OnClientPostAdminCheck(int client)
{
	g_ZR_Rank_Points[client] = g_ZR_Rank_StartPoints;
	g_ZR_Rank_ZombieKills[client] = 0;
	g_ZR_Rank_HumanInfects[client] = 0;
	g_ZR_Rank_RoundWins_Zombie[client] = 0;
	g_ZR_Rank_RoundWins_Human[client] = 0;
	g_ZR_Rank_NumPlayers++;
	
	LoadPlayerInfo(client);
}

public void OnClientDisconnect(int client)
{
	if(!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}
	
	g_ZR_Rank_NumPlayers--;
	char update[512];
	char playername[64];
	GetClientName(client, playername, sizeof(playername));
	GetClientAuthId(client, AuthId_Steam3, g_ZR_Rank_SteamID[client], sizeof(g_ZR_Rank_SteamID[]));
	SQL_EscapeString(db, playername, playername, sizeof(playername));
	FormatEx(update, sizeof(update), "UPDATE  zrank SET playername = '%s', points =  %i , human_infects = %i, zombie_kills = %i, roundwins_zombie = %i, roundwins_human = %i WHERE  SteamID = '%s';", playername, g_ZR_Rank_Points[client], g_ZR_Rank_ZombieKills[client], g_ZR_Rank_HumanInfects[client], g_ZR_Rank_RoundWins_Zombie[client], g_ZR_Rank_RoundWins_Human[client], g_ZR_Rank_SteamID[client]);
	
	SQL_TQuery(db, SQL_NothingCallback, update);
}

public void LoadPlayerInfo(int client)
{
	char buffer[2048];

	GetClientAuthId(client, AuthId_Steam3, g_ZR_Rank_SteamID[client], sizeof(g_ZR_Rank_SteamID[]));
	if(db != INVALID_HANDLE)
	{
		Format(buffer, sizeof(buffer), "SELECT * FROM zrank WHERE SteamID = '%s';", g_ZR_Rank_SteamID[client]);
		SQL_TQuery(db, SQL_LoadPlayerCallback, buffer, client);
	}
}

public Action Command_Rank(int client, int args)
{
	GetRank(client);
	
	return Plugin_Handled;
}

stock void GetRank(int client)
{
	char query[255];
	Format(query, sizeof(query), "SELECT * FROM zrank ORDER BY points DESC;");
	
	SQL_TQuery(db, SQL_GetRank, query, GetClientUserId(client));
}

public Action Command_ResetRank_All(int client, int args)
{
	char query[255];
	Format(query, sizeof(query), "TRUNCATE TABLE zrank;");

	SQL_TQuery(db, SQL_NothingCallback, query);
	
	for (int i = 1; i < MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
	
	CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Reset All");
	
	return Plugin_Handled;
}

stock bool IsValidClient(int client)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		return true;
	}
	
	return false;
}