#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <zombiereloaded>

#pragma semicolon 1
#pragma newdecls required

#include "zr_rank/variables.sp"
#include "zr_rank/database.sp"
#include "zr_rank/events.sp"

public Plugin myinfo =
{
	name = "[ZR] Rank",
	author = "Hallucinogenic Troll",
	description = "Zombie Rank for Zombie Reloaded Servers",
	version = "1.0",
	url = "http://HallucinogenicTrollConfigs.com/"
};

public void OnPluginStart()
{
	// Connection to the database;
	SQL_TConnect(OnSQLConnect, "zr_rank");
	
	// ConVars
	g_CVAR_ZR_Rank_StartPoints = CreateConVar("zr_rank_startpoints", "100", "How many points that a new player starts", _, true, 0.0, false);
	g_CVAR_ZR_Rank_InfectHuman = CreateConVar("zr_rank_infecthuman", "1", "How many points you get when you infect an human (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie = CreateConVar("zr_rank_killzombie", "1", "How many points you get when you kill a zombie (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie_Headshot = CreateConVar("zr_rank_killzombie_headshot", "1", "How many points you get when you kill a zombie with an headshot", _, true, 0.0, false);
	g_CVAR_ZR_Rank_StabZombie_Left = CreateConVar("zr_rank_stabzombie_left", "1", "How many points you get when you stab a zombie with left mouse button (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_StabZombie_Right = CreateConVar("zr_rank_stabzombie_right", "1", "How many points you get when you stab a zombie with right mouse button (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie_Knife = CreateConVar("zr_rank_killzombie_knife", "5", "How many points you get when you kill a zombie with a knife (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie_HE = CreateConVar("zr_rank_killzombie_he", "3", "How many points you get when you kill a zombie with a HE Grenade (0 will disable it)", _, true, 0.0, false);
	g_CVAR_ZR_Rank_KillZombie_SmokeFlashbang = CreateConVar("zr_rank_killzombie_smokeflashbang", "20", "How many points you get when you kill a zombie with a Smoke Grenade or a Flashbang (0 will disable it)", _, true, 0.0, false);
	
	// Events
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	
	// Commands
	RegConsoleCmd("sm_rank", Command_Rank, "Shows a player rank in the menu");
	RegConsoleCmd("sm_top", Command_Top, "Shows the Top Players List, order by points");
	RegAdminCmd("sm_resetrank_all", Command_ResetRank_All, ADMFLAG_ROOT, "Deletes all the players that are in the database");
	
	
	AutoExecConfig(true, "zr_rank");
}

public void OnConfigsExecuted()
{
	g_ZR_Rank_InfectHuman = g_CVAR_ZR_Rank_InfectHuman.IntValue;
	g_ZR_Rank_KillZombie = g_CVAR_ZR_Rank_KillZombie.IntValue;
	g_ZR_Rank_KillZombie_Headshot = g_CVAR_ZR_Rank_KillZombie_Headshot.IntValue;
	g_ZR_Rank_StartPoints = g_CVAR_ZR_Rank_StartPoints.IntValue;
	g_ZR_Rank_StabZombie_Left = g_CVAR_ZR_Rank_StabZombie_Left.IntValue;
	g_ZR_Rank_StabZombie_Right = g_CVAR_ZR_Rank_StabZombie_Right.IntValue;
	g_ZR_Rank_KillZombie_Knife = g_CVAR_ZR_Rank_KillZombie_Knife.IntValue;
	g_ZR_Rank_KillZombie_HE = g_CVAR_ZR_Rank_KillZombie_HE.IntValue;
	g_ZR_Rank_KillZombie_SmokeFlashbang = g_CVAR_ZR_Rank_KillZombie_SmokeFlashbang.IntValue;
}

public void OnClientPostAdminCheck(int client)
{
	// Resets the points, since it could had a player with this index before;
	g_ZR_Rank_Points[client] = g_ZR_Rank_StartPoints;
	LoadPlayerInfo(client);
}

public void OnClientDisconnect(int client)
{
	char update[256];
	char SteamID[64];
	char playername[64];
	GetClientName(client, playername, sizeof(playername));
	GetClientAuthId(client, AuthId_Steam3, SteamID, sizeof(SteamID));
	SQL_EscapeString(db, playername, playername, sizeof(playername));
	FormatEx(update, 256, "UPDATE  zrank SET points =  %i WHERE  SteamID = '%s';", g_ZR_Rank_Points[client], SteamID);
	SQL_TQuery(db, SQL_NothingCallback, update);
}

public void LoadPlayerInfo(int client)
{
	char SteamID[64];
	GetClientAuthId(client, AuthId_Steam3, SteamID, sizeof(SteamID));
	
	char buffer[2048];

	if(db != INVALID_HANDLE)
	{
		Format(buffer, sizeof(buffer), "SELECT * FROM zrank WHERE SteamID = '%s';", SteamID);
		SQL_TQuery(db, SQL_LoadPlayerCallback, buffer, client);
	}
}

public Action Command_Rank(int client, int args)
{	
	// Prints all users out
	char SteamID[64];
	GetClientAuthId(client, AuthId_Steam3, SteamID, sizeof(SteamID));
	
	strcopy(g_ZR_Rank_SteamID[client], sizeof(g_ZR_Rank_SteamID[]), SteamID);
	char query[255];
	Format(query, sizeof(query), "SELECT * FROM zrank ORDER BY points DESC;");
	
	// Send our Query to the Function
	SQL_TQuery(db, SQL_GetRank, query, GetClientUserId(client));
	
	return Plugin_Handled;
}


public Action Command_Top(int client, int args)
{	
	char S_Top_MaxPlayers[64];
	GetCmdArg(1, S_Top_MaxPlayers, sizeof(S_Top_MaxPlayers));
	
	int Top_MaxPlayers;
	
	if(strlen(S_Top_MaxPlayers) > 0)
	{
		Top_MaxPlayers = StringToInt(S_Top_MaxPlayers);
	}
	else
	{
		Top_MaxPlayers = 10;
	}
	
	// Prints all users out
	char SteamID[64];
	GetClientAuthId(client, AuthId_Steam3, SteamID, sizeof(SteamID));
	
	strcopy(g_ZR_Rank_SteamID[client], sizeof(g_ZR_Rank_SteamID[]), SteamID);
	char query[255];
	Format(query, sizeof(query), "SELECT * FROM zrank ORDER BY points DESC LIMIT %d;", Top_MaxPlayers);
	
	// Send our Query to the Function
	SQL_TQuery(db, SQL_GetTop, query, GetClientUserId(client));
	
	return Plugin_Handled;
}

public Action Command_ResetRank_All(int client, int args)
{
	char query[255];
	Format(query, sizeof(query), "DELETE FROM zrank WHERE 1;");

	SQL_TQuery(db, SQL_NothingCallback, query);
	
	for (int i = 1; i < MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
	
	PrintToChat(client, "%s All that has been reseted!", PREFIX);
	
	return Plugin_Handled;
}
