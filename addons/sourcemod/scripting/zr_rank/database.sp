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
			Format(buffer, sizeof(buffer), "CREATE TABLE IF NOT EXISTS zrank (SteamID VARCHAR(64) NOT NULL PRIMARY KEY DEFAULT '', playername VARCHAR(64) NOT NULL DEFAULT '', points INT NOT NULL DEFAULT 0, human_infects INT NOT NULL DEFAULT 0, zombie_kills INT NOT NULL DEFAULT 0);");
			
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
		LogError("ERRO %s", error);
		return;
	}

	if(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		g_ZR_Rank_Points[client] = SQL_FetchInt(results, 2);
		g_ZR_Rank_HumanInfects[client] = SQL_FetchInt(results, 3);
		g_ZR_Rank_ZombieKills[client] = SQL_FetchInt(results, 4);
		
		DBResult status;
		g_ZR_Rank_Place[client] = SQL_FetchInt(results, 5, status);
		if (status != DBVal_Data)
			SetFailState("Rank data not found in query (SQL_LoadPlayerCallback)");
	}
	else
	{
		char insert[256];
		char playername[64];
		GetClientName(client, playername, sizeof(playername));
		SQL_EscapeString(db, playername, playername, sizeof(playername));
		FormatEx(insert, 256, "INSERT INTO zrank (SteamID , playername, points, human_infects, zombie_kills) VALUES ('%s', '%s', %d, 0, 0);", g_ZR_Rank_SteamID[client], playername, g_ZR_Rank_StartPoints);
		SQL_TQuery(db, SQL_NothingCallback, insert);
	}
}

public void SQL_NothingCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("Query Fail: %s (SQL_NothingCallback)", error);
		return;
	}
}

public void SQL_GetRank(Handle DB, Handle results, const char[] error, any data)
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
	
	char SteamID[64];
	
	if (SQL_HasResultSet(results) && SQL_FetchRow(results))
	{		
		SQL_FetchString(results, 0 , SteamID, sizeof(SteamID));
		
		if(StrEqual(g_ZR_Rank_SteamID[client], SteamID, true))
		{
			DBResult status;
			
			g_ZR_Rank_Place[client] = SQL_FetchInt(results, 5, status);
			
			if (status != DBVal_Data)
				SetFailState("Rank data not found in query (SQL_GetRank)");
			
			CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Show Rank", g_ZR_Rank_Place[client], g_iMaxPlayers, g_ZR_Rank_Points[client], g_ZR_Rank_HumanInfects[client], g_ZR_Rank_ZombieKills[client]);
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

	char SteamID[64];
	char Name[64];
	char buffer[256];
	
	Menu menu = new Menu(Menu_Top10_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Points");
	menu.SetTitle(buffer);
	
	if (!SQL_HasResultSet(results))
		return;
	
	int count = 1;
	
	while(SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , SteamID, sizeof(SteamID));
		SQL_FetchString(results, 1, Name, sizeof(Name));
		int points = SQL_FetchInt(results, 2);
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Points", count, Name, points);
		menu.AddItem(SteamID, buffer, ITEMDRAW_DISABLED);
		count++;
	}
	
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public void SQL_GetMaxPlayers(Handle DB, Handle results, const char[] error, any data)
{
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}
	
	if (SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		g_iMaxPlayers = SQL_FetchInt(results, 0);
	}
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

	char SteamID[64];
	char Name[64];
	char buffer[256];
	
	Menu menu = new Menu(Menu_Top10_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Zombie Kills");
	menu.SetTitle(buffer);
	
	if (!SQL_HasResultSet(results))
		return;
	
	int count = 1;
	
	while(SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , SteamID, sizeof(SteamID));
		SQL_FetchString(results, 1, Name, sizeof(Name));
		int kills = SQL_FetchInt(results, 4);
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Zombie Kills", count, Name, kills);
		menu.AddItem(SteamID, buffer, ITEMDRAW_DISABLED);
		count++;
	}
	
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public void SQL_GetTopInfectedHumans(Handle DB, Handle results, const char[] error, any data)
{
	int client;
	
	if ((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (results == INVALID_HANDLE)
	{
		LogError(error);
		return;
	}

	char SteamID[64];
	char Name[64];
	char buffer[256];
	
	Menu menu = new Menu(Menu_Top10_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Top Order By Human Infects");
	menu.SetTitle(buffer);
	
	if (!SQL_HasResultSet(results))
		return;
	
	int count = 1;
	
	while(SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , SteamID, sizeof(SteamID));
		SQL_FetchString(results, 1, Name, sizeof(Name));
		int infects = SQL_FetchInt(results, 3);
		FormatEx(buffer, sizeof(buffer), "%t", "X - Y Humans Infected", count, Name, infects);
		menu.AddItem(SteamID, buffer, ITEMDRAW_DISABLED);
		count++;
	}
	
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public int Menu_Top10_Handler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		delete menu;
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}
