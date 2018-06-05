// Chat's main prefix;
#define PREFIX "[\x0EZR Rank\x01]"


// ConVars
ConVar g_CVAR_ZR_Rank_InfectHuman;
ConVar g_CVAR_ZR_Rank_KillZombie;
ConVar g_CVAR_ZR_Rank_KillZombie_Headshot;
ConVar g_CVAR_ZR_Rank_StartPoints;
ConVar g_CVAR_ZR_Rank_StabZombie_Left;
ConVar g_CVAR_ZR_Rank_StabZombie_Right;
ConVar g_CVAR_ZR_Rank_KillZombie_Knife;
ConVar g_CVAR_ZR_Rank_KillZombie_HE;
ConVar g_CVAR_ZR_Rank_KillZombie_SmokeFlashbang;
ConVar g_CVAR_ZR_Rank_MaxPlayers_Top;

ConVar g_CVAR_ZR_Rank_MinPlayers;
ConVar g_CVAR_ZR_Rank_BeingInfected;
ConVar g_CVAR_ZR_Rank_BeingKilled;


// Variables to Store ConVar Values;
int g_ZR_Rank_InfectHuman;
int g_ZR_Rank_KillZombie;
int g_ZR_Rank_KillZombie_Headshot;
int g_ZR_Rank_StartPoints;
int g_ZR_Rank_StabZombie_Left;
int g_ZR_Rank_StabZombie_Right;
int g_ZR_Rank_KillZombie_Knife;
int g_ZR_Rank_KillZombie_HE;
int g_ZR_Rank_KillZombie_SmokeFlashbang;
int g_ZR_Rank_MaxPlayers_Top;

int g_ZR_Rank_MinPlayers;
int g_ZR_Rank_BeingInfected;
int g_ZR_Rank_BeingKilled;

bool g_ZR_Rank_PostInfect;

// Stores the main points, that are given after some events;
int g_ZR_Rank_Points[MAXPLAYERS + 1];
int g_ZR_Rank_ZombieKills[MAXPLAYERS + 1];
int g_ZR_Rank_HumanInfects[MAXPLAYERS + 1];
int g_ZR_Rank_NumPlayers = 0;
char g_ZR_Rank_SteamID[MAXPLAYERS + 1][64];

int g_MaxPlayers;
// Handle for the database;
Handle db;

// Check if it is MySQL that you set on the databases.cfg
bool IsMySql;

stock bool IsValidClient(int client)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		return true;
	}
	
	return false;
}
