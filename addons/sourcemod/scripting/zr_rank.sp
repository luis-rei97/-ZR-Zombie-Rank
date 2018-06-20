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
#include <sdktools_gamerules>
#include <cstrike>
#include <zombiereloaded>
#include <colorvariables>

#pragma semicolon 1
#pragma newdecls required

#include "zr_rank/variables.sp"
#include "zr_rank/database.sp"
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
	g_CVAR_ZR_Rank_StartPoints					= CreateConVar("zr_rank_startpoints", "100", "How many points that a new player starts", _, true, 0.0);
	g_CVAR_ZR_Rank_InfectHuman					= CreateConVar("zr_rank_infecthuman", "1", "How many points you get when you infect an human (0 will disable it)", _, true, 0.0);
	g_CVAR_ZR_Rank_KillZombie					= CreateConVar("zr_rank_killzombie", "2", "How many points you get when you kill a zombie (0 will disable it)", _, true, 0.0);
	g_CVAR_ZR_Rank_KillZombie_Headshot			= CreateConVar("zr_rank_killzombie_headshot", "3", "How many points you get when you kill a zombie with an headshot", _, true, 0.0);
	g_CVAR_ZR_Rank_KillZombie_Assist			= CreateConVar("zr_rank_killzombie_assist", "1", "How many points you get when you assist a zombie kill", _, true, 0.0);
	g_CVAR_ZR_Rank_StabZombie_Left				= CreateConVar("zr_rank_stabzombie_left", "0", "How many points you get when you stab a zombie with left mouse button (0 will disable it)", _, true, 0.0);
	g_CVAR_ZR_Rank_StabZombie_Right				= CreateConVar("zr_rank_stabzombie_right", "0", "How many points you get when you stab a zombie with right mouse button (0 will disable it)", _, true, 0.0);
	g_CVAR_ZR_Rank_KillZombie_Knife				= CreateConVar("zr_rank_killzombie_knife", "5", "How many points you get when you kill a zombie with a knife (0 will disable it)", _, true, 0.0);
	g_CVAR_ZR_Rank_KillZombie_HE				= CreateConVar("zr_rank_killzombie_he", "3", "How many points you get when you kill a zombie with a HE Grenade (0 will disable it)", _, true, 0.0);
	g_CVAR_ZR_Rank_KillZombie_SmokeFlashbang	= CreateConVar("zr_rank_killzombie_smokeflashbang", "20", "How many points you get when you kill a zombie with a Smoke Grenade or a Flashbang (0 will disable it)", _, true, 0.0);
	g_CVAR_ZR_Rank_MaxPlayers_Top				= CreateConVar("zr_rank_maxplayers_top", "50", "Max number of players that are shown in the top commands", _, true, 1.0);
	g_CVAR_ZR_Rank_MinPlayers					= CreateConVar("zr_rank_minplayers", "10", "Minimum players for activating the rank system (0 will disable this function)", _, true, 0.0);
	g_CVAR_ZR_Rank_Prefix						= CreateConVar("zr_rank_prefix", "{lime}[ZR Rank]{default}", "Prefix to be used in plugin messages");
	g_CVAR_ZR_Rank_BeingInfected				= CreateConVar("zr_rank_beinginfected", "3", "How many points you lose if you are infected by a zombie", _, true, 0.0);
	g_CVAR_ZR_Rank_Suicide_Human				= CreateConVar("zr_rank_suicide_human", "1", "How many points you lose if you suicide as a human", _, true, 0.0);
	g_CVAR_ZR_Rank_Win_Human					= CreateConVar("zr_rank_win_human", "10", "How many points you get for winning the round as human", _, true, 0.0);
	g_CVAR_ZR_Rank_BeingKilled					= CreateConVar("zr_rank_beingkilled", "1", "How many points you lose if you are killed by an human", _, true, 0.0);
	g_CVAR_ZR_Rank_AllowWarmup					= CreateConVar("zr_rank_allow_warmup", "0", "Allow players to get or lose points during Warmup", _, true, 0.0);
	g_CVAR_ZR_Rank_Damage_Bonus					= CreateConVar("zr_rank_damage_bonus", "800", "Every X amount of damage dealt per round, reward X amount of points", _, true, 0.0);
	g_CVAR_ZR_Rank_Damage_Reward				= CreateConVar("zr_rank_damage_reward", "1", "How many points players receive per X amount of total damage dealt each round", _, true, 0.0);
	g_CVAR_ZR_Rank_Infect_Bonus					= CreateConVar("zr_rank_infect_bonus", "3", "Every X amount of infects per round, reward X amount of points", _, true, 0.0);
	g_CVAR_ZR_Rank_Infect_Reward				= CreateConVar("zr_rank_infect_reward", "2", "How many points players receive per X amount of infects each round", _, true, 0.0);
	g_CVAR_ZR_Rank_Multiplier					= CreateConVar("zr_rank_multiplier", "1", "Multiply certain point events by this amount (0 will disable point gain / loss)", _, true, 0.0);
	
	HookConVarChange(g_CVAR_ZR_Rank_StartPoints, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_InfectHuman, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_KillZombie, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_KillZombie_Headshot, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_KillZombie_Assist, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_StabZombie_Left, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_StabZombie_Right, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_KillZombie_Knife, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_KillZombie_HE, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_KillZombie_SmokeFlashbang, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_MaxPlayers_Top, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_MinPlayers, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_Prefix, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_BeingInfected, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_Suicide_Human, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_Win_Human, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_BeingKilled, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_AllowWarmup, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_Damage_Bonus, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_Damage_Reward, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_Infect_Bonus, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_Infect_Reward, OnConVarChange);
	HookConVarChange(g_CVAR_ZR_Rank_Multiplier, OnConVarChange);
	
	// Events
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("round_start",Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end",Event_RoundEnd, EventHookMode_Pre);
	
	// Commands
	RegConsoleCmd("sm_rank", Command_Rank, "Shows a player rank in the menu");
	RegConsoleCmd("sm_top", Command_Rank, "Shows the Top Players List, order by points");
	RegConsoleCmd("sm_topkills", Command_Rank, "Show the Top Players List, order by Zombie Kills");
	RegConsoleCmd("sm_topinfects", Command_Rank, "Show the Top Players List, order by Infected Humans");
	
	// Admin commands
	RegAdminCmd("sm_resetrank_all", Command_ResetRank_All, ADMFLAG_ROOT, "Deletes all the players that are in the database");
	
	// Exec Config
	AutoExecConfig(true, "zr_rank");
	
	LoadTranslations("zr_rank.phrases");
	
	// Late Load
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnConfigsExecuted()
{
	// Get cvar string
	g_CVAR_ZR_Rank_Prefix.GetString(g_ZR_Rank_Prefix, sizeof(g_ZR_Rank_Prefix));
	// Get cvar ints
	g_ZR_Rank_InfectHuman 					= GetConVarInt(g_CVAR_ZR_Rank_InfectHuman);
	g_ZR_Rank_KillZombie 					= GetConVarInt(g_CVAR_ZR_Rank_KillZombie);
	g_ZR_Rank_KillZombie_Headshot 			= GetConVarInt(g_CVAR_ZR_Rank_KillZombie_Headshot);
	g_ZR_Rank_KillZombie_Assist 			= GetConVarInt(g_CVAR_ZR_Rank_KillZombie_Assist);
	g_ZR_Rank_StartPoints 					= GetConVarInt(g_CVAR_ZR_Rank_StartPoints);
	g_ZR_Rank_StabZombie_Left 				= GetConVarInt(g_CVAR_ZR_Rank_StabZombie_Left);
	g_ZR_Rank_StabZombie_Right 				= GetConVarInt(g_CVAR_ZR_Rank_StabZombie_Right);
	g_ZR_Rank_KillZombie_Knife 				= GetConVarInt(g_CVAR_ZR_Rank_KillZombie_Knife);
	g_ZR_Rank_KillZombie_HE 				= GetConVarInt(g_CVAR_ZR_Rank_KillZombie_HE);
	g_ZR_Rank_KillZombie_SmokeFlashbang 	= GetConVarInt(g_CVAR_ZR_Rank_KillZombie_SmokeFlashbang);
	g_ZR_Rank_MaxPlayers_Top				= GetConVarInt(g_CVAR_ZR_Rank_MaxPlayers_Top);
	g_ZR_Rank_AllowWarmup 					= GetConVarInt(g_CVAR_ZR_Rank_AllowWarmup);
	g_ZR_Rank_MinPlayers 					= GetConVarInt(g_CVAR_ZR_Rank_MinPlayers);
	g_ZR_Rank_BeingInfected 				= GetConVarInt(g_CVAR_ZR_Rank_BeingInfected);
	g_ZR_Rank_Suicide_Human 				= GetConVarInt(g_CVAR_ZR_Rank_Suicide_Human);
	g_ZR_Rank_Win_Human 					= GetConVarInt(g_CVAR_ZR_Rank_Win_Human);
	g_ZR_Rank_BeingKilled 					= GetConVarInt(g_CVAR_ZR_Rank_BeingKilled);
	g_ZR_Rank_Damage_Bonus 					= GetConVarInt(g_CVAR_ZR_Rank_Damage_Bonus);
	g_ZR_Rank_Damage_Reward 				= GetConVarInt(g_CVAR_ZR_Rank_Damage_Reward);
	g_ZR_Rank_Infect_Bonus 					= GetConVarInt(g_CVAR_ZR_Rank_Infect_Bonus);
	g_ZR_Rank_Infect_Reward 				= GetConVarInt(g_CVAR_ZR_Rank_Infect_Reward);
	g_ZR_Rank_Multiplier	 				= GetConVarInt(g_CVAR_ZR_Rank_Multiplier);
}

public void OnConVarChange(Handle cvar, const char[] oldVal, const char[] newVal)
{
    OnConfigsExecuted();
}

public void OnMapEnd()
{
	if (roundTimer != null)
	{
		KillTimer(roundTimer);
		roundTimer = null;
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_ZR_Rank_Points[client] = g_ZR_Rank_StartPoints;
	g_ZR_Rank_ZombieKills[client] = 0;
	g_ZR_Rank_HumanInfects[client] = 0;
	g_ZR_Rank_Place[client] = 0;
	g_ZR_Rank_NumPlayers = GetClientCount(false);
	g_fCmdTime[client] = 0.0;
	g_fQueryTime[client] = 0.0;
	g_iPlayerDamage[client] = 0;
	g_iPlayerInfects[client] = 0;
	
	LoadPlayerInfo(client);
}

public void OnClientDisconnect(int client)
{
	if (client < 1 || client > MaxClients)
		return;
		
	g_ZR_Rank_Place[client] = -1;
	g_ZR_Rank_NumPlayers--;

	UpdateQuery(client);
}

stock void UpdateQuery(int client)
{
	if (!IsValidClient(client))
		return;

	char update[256];
	char playername[64];
	GetClientName(client, playername, sizeof(playername));
	GetClientAuthId(client, AuthId_Steam3, g_ZR_Rank_SteamID[client], sizeof(g_ZR_Rank_SteamID[]));
	
	if (g_ZR_Rank_Points[client] < 0)
		g_ZR_Rank_Points[client] = 0;
	
	SQL_EscapeString(db, playername, playername, sizeof(playername));
	FormatEx(update, 256, "UPDATE zrank SET playername = '%s', points =  %i , human_infects = %i, zombie_kills = %i WHERE SteamID = '%s';", playername, g_ZR_Rank_Points[client], g_ZR_Rank_HumanInfects[client], g_ZR_Rank_ZombieKills[client], g_ZR_Rank_SteamID[client]);
	
	SQL_TQuery(db, SQL_NothingCallback, update);
}

public Action Command_Rank(int client, int args)
{
	if (!IsValidClient(client))
	{
		return Plugin_Handled;
	}

	// Prevent command spam
	if (g_fCmdTime[client] > GetGameTime())
		return Plugin_Handled;

	int num = 10;
	char sName[128], buffer[24];
	GetCmdArg(0, sName, sizeof(sName));
	
	if(args >= 1)
	{
		GetCmdArg(1, buffer, sizeof(buffer));
		if (StringToInt(buffer) > 0)
			num = StringToInt(buffer);		
	}
	
	if (StrEqual(sName, "sm_rank", false)) {
		GetRank(client);
	} else if (StrEqual(sName, "sm_top", false)) {
		Function_Top(client, num);
	} else if (StrEqual(sName, "sm_topkills", false)) {
		Function_TopZombieKills(client, num);
	} else if (StrEqual(sName, "sm_topinfects", false)) {
		Function_TopInfectedHumans(client, num);
	}
	
	g_fCmdTime[client] = GetGameTime() + 5.0;
	
	return Plugin_Handled;
}

public void GetMaxPlayers()
{
	char buffer[2048];

	if(db != INVALID_HANDLE)
	{
		Format(buffer, sizeof(buffer), "SELECT COUNT(SteamID) FROM zrank;");
		SQL_TQuery(db, SQL_GetMaxPlayers, buffer);
	}
}

public void LoadPlayerInfo(int client)
{
	char buffer[2048];

	GetClientAuthId(client, AuthId_Steam3, g_ZR_Rank_SteamID[client], sizeof(g_ZR_Rank_SteamID[]));
	if(db != INVALID_HANDLE)
	{
		Format(buffer, sizeof(buffer), "SELECT a.*,b.rank FROM zrank a,(SELECT c.*,@rownum := @rownum + 1 AS rank FROM zrank c,(SELECT @rownum := 0) r ORDER BY(points) DESC) b WHERE a.SteamID = b.SteamID AND b.SteamID = '%s';", g_ZR_Rank_SteamID[client]);
		SQL_TQuery(db, SQL_LoadPlayerCallback, buffer, client);
	}
}

stock void GetRank(int client)
{
	char query[255];
	Format(query, sizeof(query), "SELECT a.*,b.rank FROM zrank a,(SELECT c.*,@rownum := @rownum + 1 AS rank FROM zrank c,(SELECT @rownum := 0) r ORDER BY(points) DESC) b WHERE a.SteamID = b.SteamID AND b.SteamID = '%s';", g_ZR_Rank_SteamID[client]);
	
	SQL_TQuery(db, SQL_GetRank, query, GetClientUserId(client));
}

public void Function_Top(int client, int num)
{
	if (num > g_ZR_Rank_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show More Than X Players", g_ZR_Rank_MaxPlayers_Top);
		return;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT * FROM zrank ORDER BY points DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTop, query, GetClientUserId(client));
	
	return;
}

public void Function_TopInfectedHumans(int client, int num)
{
	if (num > g_ZR_Rank_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show More Than X Players", g_ZR_Rank_MaxPlayers_Top);
		return;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT * FROM zrank ORDER BY human_infects DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTopInfectedHumans, query, GetClientUserId(client));
	
	return;
}


public void Function_TopZombieKills(int client, int num)
{	
	if (num > g_ZR_Rank_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show More Than X Players", g_ZR_Rank_MaxPlayers_Top);
		return;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT * FROM zrank ORDER BY zombie_kills DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTopZombieKills, query, GetClientUserId(client));
	
	return;
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
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		return true;
	}
	
	return false;
}
