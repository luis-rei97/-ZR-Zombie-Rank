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
			Format(buffer, sizeof(buffer), "CREATE TABLE if NOT EXISTS zrank (SteamID VARCHAR(64) NOT NULL PRIMARY KEY default '', playername VARCHAR(64) NOT NULL default '', points int NOT NULL default 0);");
			
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
	
	char SteamID[64];
	GetClientAuthId(client, AuthId_Steam3, SteamID, sizeof(SteamID));

	if(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		g_ZR_Rank_Points[client] = SQL_FetchInt(results, 2);
	}
	else
	{
		char insert[256];
		char playername[64];
		GetClientName(client, playername, sizeof(playername));
		SQL_EscapeString(db, playername, playername, sizeof(playername));
		
		FormatEx(insert, 256, "INSERT INTO zrank (SteamID , playername, points) VALUES ('%s', '%s', %d);", SteamID, playername, g_ZR_Rank_StartPoints);
		SQL_TQuery(db, SQL_NothingCallback, insert);
	}
}

public void SQL_NothingCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
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
			PrintToChat(client, "%s You are in \x0E%d/%d\x01, with \x04%d points\x01!", PREFIX, i, g_MaxPlayers, g_ZR_Rank_Points[client]);
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
	
	g_MaxPlayers = SQL_GetRowCount(results);

	char SteamID[64];
	char Name[64];
	int points;
	char buffer[256];
	
	
	Menu menu = new Menu(Menu_Top10_Handler);
	menu.SetTitle("[ZR] Rank Top 10");
	
	while(SQL_HasResultSet(results) && SQL_FetchRow(results))
	{
		SQL_FetchString(results, 0 , SteamID, sizeof(SteamID));
		SQL_FetchString(results, 1, Name, sizeof(Name));
		FormatEx(buffer, sizeof(buffer), "%s - %d points", Name, points);
		menu.AddItem(SteamID, buffer);
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