public int OnSQLConnect(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("Database failure: %s", error);
		
		SetFailState("Databases dont work");
	}
	else
	{
		db = hndl;
		
		char buffer[3096];
		SQL_GetDriverIdent(SQL_ReadDriver(db), buffer, sizeof(buffer));
		IsMySql = StrEqual(buffer,"mysql", false) ? true : false;
		
		if(IsMySql)
		{
			Format(buffer, sizeof(buffer), "CREATE TABLE IF NOT EXISTS zrank (SteamID VARCHAR(64) NOT NULL PRIMARY KEY DEFAULT '', playername VARCHAR(64) NOT NULL DEFAULT '', points INT NOT NULL DEFAULT 0, human_infects INT NOT NULL DEFAULT 0, zombie_kills INT NOT NULL DEFAULT 0, roundwins_zombie INT NOT NULL DEFAULT 0, roundwins_human INT NOT NULL DEFAULT 0);");
			
			SQL_TQuery(db, OnSQLConnectCallback, buffer);
		}
	}
}

public int OnSQLConnectCallback(Handle owner, Handle hndl, char [] error, any data)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("Query failure: %s", error);
		return;
	}
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientPostAdminCheck(client);
		}
	}
}

public void SQL_LoadPlayerCallback(Handle DB, Handle results, const char[] error, any client)
{
	if(!IsClientInGame(client) || IsFakeClient(client))
	{
		return;
	}
	
	if(results == INVALID_HANDLE)
	{
		LogError("ERROR %s", error);
		return;
	}

	if(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		g_ZR_Rank_Points[client] = SQL_FetchInt(results, 2);
		g_ZR_Rank_HumanInfects[client] = SQL_FetchInt(results, 3);
		g_ZR_Rank_ZombieKills[client] = SQL_FetchInt(results, 4);
		g_ZR_Rank_RoundWins_Zombie[client] = SQL_FetchInt(results, 5);
		g_ZR_Rank_RoundWins_Human[client] = SQL_FetchInt(results, 6);
	}
	else
	{
		char insert[512];
		char playername[64];
		GetClientName(client, playername, sizeof(playername));
		FormatEx(insert, sizeof(insert), "INSERT INTO zrank (SteamID , playername, points, human_infects, zombie_kills, roundwins_zombie, roundwins_human) VALUES ('%s', '%s', %d, 0, 0, 0, 0);", g_ZR_Rank_SteamID[client], playername, g_ZR_Rank_StartPoints);
		SQL_TQuery(db, SQL_NothingCallback, insert);
	}
}

public void SQL_NothingCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[ZR Rank] Query Fail: %s", error);
		return;
	}
}

public void SQL_GetRank(Handle DB, Handle results, const char[] error, any data)
{
	int client, i = 0;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}
	g_MaxPlayers = SQL_GetRowCount(results);
	
	char SteamID[64];
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		i++;
		
		SQL_FetchString(results, 0 , SteamID, sizeof(SteamID));
		
		if(StrEqual(g_ZR_Rank_SteamID[client], SteamID, true))
		{
			CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show Rank", i, g_MaxPlayers, g_ZR_Rank_Points[client], g_ZR_Rank_HumanInfects[client], g_ZR_Rank_ZombieKills[client]);
			break;
		}
	}
}

public void SQL_GetTop(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	char Name[64];
	int points;
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Top10_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Points");
	menu.SetTitle(buffer);
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0, Name, sizeof(Name));
		points = SQL_FetchInt(results, 1);
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Points", Name, points);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public void SQL_GetTopZombieKills(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	int zombie_kills;
	char Name[64];
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Top10_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Zombie Kills");
	menu.SetTitle(buffer);
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , Name, sizeof(Name));
		zombie_kills = SQL_FetchInt(results, 1);
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Zombie Kills", Name, zombie_kills);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public void SQL_GetTopInfectedHumans(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	int human_infects;
	char Name[64];
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Top10_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Human Infects");
	menu.SetTitle(buffer);
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , Name, sizeof(Name));
		human_infects = SQL_FetchInt(results, 1);
		
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Humans Infected", Name, human_infects);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public void SQL_GetTopWinRounds_Human(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	int roundwins_human;
	char Name[64];
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Top10_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Round Wins Human");
	menu.SetTitle(buffer);
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , Name, sizeof(Name));
		roundwins_human = SQL_FetchInt(results, 1);
		
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Round Wins Human", Name, roundwins_human);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public void SQL_GetTopWinRounds_Zombie(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	int roundwins_zombie;
	char Name[64];
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Top10_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Round Wins Zombie");
	menu.SetTitle(buffer);
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , Name, sizeof(Name));
		roundwins_zombie = SQL_FetchInt(results, 1);
		
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Round Wins Zombie", Name, roundwins_zombie);
		menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public int Menu_Top10_Handler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}