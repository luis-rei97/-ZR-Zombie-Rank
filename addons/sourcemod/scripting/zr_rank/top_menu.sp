public Action Command_Top(int client, int args)
{
	int num = 0;
	
	if(args < 1)
	{
		num = 10;
	}
	else
	{
		char buffer[24];
		GetCmdArg(1, buffer, sizeof(buffer));		
		num = StringToInt(buffer);
	}
	
	
	if(g_ZR_Rank_MaxPlayers_Top < num)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show More Than X Players", g_ZR_Rank_MaxPlayers_Top);
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT playername, points, SteamID FROM zrank ORDER BY points DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTop, query, GetClientUserId(client));
	
	return Plugin_Handled;
}

public Action Command_TopInfectedHumans(int client, int args)
{
	int num;
	
	if(args < 1)
	{
		num = 10;
	}
	else
	{
		char buffer[24];
		GetCmdArg(1, buffer, sizeof(buffer));		
		num = StringToInt(buffer);
	}
	
	
	if(num > g_ZR_Rank_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show More Than X Players", g_ZR_Rank_MaxPlayers_Top);
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT playername, human_infects FROM zrank ORDER BY human_infects DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTopInfectedHumans, query, GetClientUserId(client));
	
	return Plugin_Handled;
}


public Action Command_TopZombieKills(int client, int args)
{
	int num;
	
	if(args < 1)
	{
		num = 10;
	}
	else
	{
		char buffer[24];
		GetCmdArg(1, buffer, sizeof(buffer));		
		num = StringToInt(buffer);
	}
	
	if(num > g_ZR_Rank_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show More Than X Players", g_ZR_Rank_MaxPlayers_Top);
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT playername, zombie_kills FROM zrank ORDER BY zombie_kills DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTopZombieKills, query, GetClientUserId(client));
	
	return Plugin_Handled;
}

public Action Command_TopWinRounds_Human(int client, int args)
{
	int num;
	
	if(args < 1)
	{
		num = 10;
	}
	else
	{
		char buffer[24];
		GetCmdArg(1, buffer, sizeof(buffer));		
		num = StringToInt(buffer);
	}
	
	if(num > g_ZR_Rank_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show More Than X Players", g_ZR_Rank_MaxPlayers_Top);
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT playername, roundwins_human FROM zrank ORDER BY roundwins_human DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTopWinRounds_Human, query, GetClientUserId(client));
	
	return Plugin_Handled;
}

public Action Command_TopWinRounds_Zombie(int client, int args)
{
	int num;
	
	if(args < 1)
	{
		num = 10;
	}
	else
	{
		char buffer[24];
		GetCmdArg(1, buffer, sizeof(buffer));		
		num = StringToInt(buffer);
	}
	
	if(num > g_ZR_Rank_MaxPlayers_Top)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show More Than X Players", g_ZR_Rank_MaxPlayers_Top);
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "SELECT playername, roundwins_zombie FROM zrank ORDER BY roundwins_zombie DESC LIMIT %d;", num);
	
	SQL_TQuery(db, SQL_GetTopWinRounds_Zombie, query, GetClientUserId(client));
	
	return Plugin_Handled;
}