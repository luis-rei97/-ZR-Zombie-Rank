// Hooks every say command to check if it is similar to console commands;
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(StrEqual(command, "rank"))
	{
		Command_Rank(client, 1);
	}
	else if(StrEqual(command, "mystats"))
	{
		Command_MyStats(client, 1);
	}
}

public Action Command_Rank(int client, int args)
{
	if(!IsValidClient(client))
	{
		return;
	}
	
	GetRank(client);
}

public Action Command_ResetMyRank(int client, int args)
{
	if(!IsValidClient(client))
	{
		return;
	}
	
	char buffer[512];
	Menu menu = new Menu(Menu_ResetData_Handler);
	FormatEx(buffer, sizeof(buffer), "%t", "Want to Reset Data");
	menu.SetTitle(buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Yes");
	menu.AddItem("yes", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "No");
	menu.AddItem("no", buffer);
	
	menu.ExitButton = false;
	menu.Display(client, 0);
}

public Action Command_MyStats(int client, int args)
{
	if(!IsValidClient(client))
	{
		return;
	}
	
	char name[MAX_NAME_LENGTH + 2];
	char buffer[512];
	Menu menu = new Menu(Menu_Nothing_Handler);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Stats");
	menu.SetTitle(buffer);
	
	GetClientName(client, name, sizeof(name));
	FormatEx(buffer, sizeof(buffer), "%t", "Player Name", name);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player SteamID", g_ZR_Rank_SteamID[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Points", g_ZR_Rank_Points[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Zombie Kills", g_ZR_Rank_ZombieKills[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player Human Infects", g_ZR_Rank_HumanInfects[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player RoundWins Zombie", g_ZR_Rank_RoundWins_Zombie[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Player RoundWins Human", g_ZR_Rank_RoundWins_Human[client]);
	menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public Action Command_ResetRank_All(int client, int args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}
	
	char query[255];
	Format(query, sizeof(query), "TRUNCATE TABLE zrank;");

	SQL_TQuery(db, SQL_NothingCallback, query);
	
	for (int i = 1; i < MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
	
	CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Reset All");
	
	return Plugin_Handled;
}

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

public int Menu_ResetData_Handler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		switch(choice)
		{
			case 0:
			{
				ResetRank(client);
				CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Your Rank Reset");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public int Menu_Nothing_Handler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}