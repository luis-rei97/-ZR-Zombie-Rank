public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		CPrintToChatAll("%s %t", g_ZR_Rank_Prefix, "Warmup End");
		return;
	}
	
	g_ZR_Rank_PostInfect = false;
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if(g_ZR_Rank_NumPlayers < g_ZR_Rank_MinPlayers)
	{
		return;
	}
	
	
	int winner = event.GetInt("winner");
	
	for (int i = 1; i < MaxClients; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
		{
			if(winner == 2)
			{
				if((ZombieReloaded && ZR_IsClientZombie(i)) || (ZombiePlague && ZP_IsPlayerZombie(i)))
				{
					if(g_ZR_Rank_RoundWin_Zombie > 0)
					{
						g_ZR_Rank_Points[i] += g_ZR_Rank_RoundWin_Zombie;
						CPrintToChat(i, "%s %t", g_ZR_Rank_Prefix, "Won Round As Zombie", g_ZR_Rank_RoundWin_Zombie);
					}
				}
			}
			else if(winner == 3)
			{
				if((ZombieReloaded && ZR_IsClientHuman(i)) || (ZombiePlague && ZP_IsPlayerHuman(i))) 
				{
					if(g_ZR_Rank_RoundWin_Human > 0)
					{
						g_ZR_Rank_Points[i] += g_ZR_Rank_RoundWin_Human;
						CPrintToChat(i, "%s %t", g_ZR_Rank_Prefix, "Won Round As Human", g_ZR_Rank_RoundWin_Human);
					}
				}
			}
		}
	}
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return Plugin_Continue;
	}
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	if(!IsValidClient(victim) || !IsValidClient(attacker) || !g_ZR_Rank_PostInfect || g_ZR_Rank_NumPlayers < g_ZR_Rank_MinPlayers)
	{
		return Plugin_Continue;
	}
	
	if (!IsPlayerAlive(attacker))
		return Plugin_Continue;
	
	if((ZombieReloaded && ZR_IsClientHuman(attacker)) || (ZombiePlague && ZP_IsPlayerHuman(attacker)))
	{
		if(GetClientTeam(victim) == 2)
		{
			char weapon_name[100];
			int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
			GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
			
			if(StrEqual(weapon_name, "weapon_knife"))
			{
				int damage = event.GetInt("dmg_health");
				
				if(damage < 50 && g_ZR_Rank_StabZombie_Left > 0)
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_StabZombie_Left;
					CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Stab Zombie Left Won", g_ZR_Rank_StabZombie_Left);
				}
				else if(damage > 50 && g_ZR_Rank_StabZombie_Right > 0)
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_StabZombie_Right;
					CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Stab Zombie Right Won", g_ZR_Rank_StabZombie_Right);
				}	
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return Plugin_Continue;
	}
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	if (!IsValidClient(victim) || !IsValidClient(attacker))
	{
		return Plugin_Continue;
	}
	
	if(victim == attacker)
	{
		if(g_ZR_Rank_Suicide > 0)
		{
			g_ZR_Rank_Points[attacker] -= g_ZR_Rank_Suicide;
			CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Lost Points By Suicide", g_ZR_Rank_Suicide);
		}
		
		return Plugin_Continue;
	}
	
	if (!IsPlayerAlive(attacker))
	{
		return Plugin_Continue;		
	}
	
	if((ZombieReloaded && ZR_IsClientHuman(attacker)) || (ZombiePlague && ZP_IsPlayerHuman(attacker)))
	{
		if(GetClientTeam(victim) == 2)
		{
			char weapon[32];
			event.GetString("weapon", weapon, sizeof(weapon));
			
			if(g_ZR_Rank_KillZombie_Knife > 0 && StrEqual(weapon, "knife", true))
			{
				g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_Knife;
				g_ZR_Rank_ZombieKills[attacker]++;
				CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Kill Zombie Knife", g_ZR_Rank_KillZombie_Knife);
			}
			else if(g_ZR_Rank_KillZombie_HE > 0 && StrEqual(weapon, "hegrenade", true))
			{
				g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_HE;
				g_ZR_Rank_ZombieKills[attacker]++;
				CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Kill Zombie HE", g_ZR_Rank_KillZombie_HE);
			}
			else if(g_ZR_Rank_KillZombie_SmokeFlashbang > 0)
			{
				if(StrEqual(weapon, "smokegrenade", true))
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_SmokeFlashbang;
					g_ZR_Rank_ZombieKills[attacker]++;
					CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Kill Zombie Smoke", g_ZR_Rank_KillZombie_SmokeFlashbang);
				}
				else if(StrEqual(weapon, "flashbang", true))
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_SmokeFlashbang;
					g_ZR_Rank_ZombieKills[attacker]++;
					CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Kill Zombie Flashbang", g_ZR_Rank_KillZombie_SmokeFlashbang);
				}
				else if(StrEqual(weapon, "decoy", true))
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_SmokeFlashbang;
					g_ZR_Rank_ZombieKills[attacker]++;
					CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Kill Zombie Decoy", g_ZR_Rank_KillZombie_SmokeFlashbang);
				}
			}
			else
			{
				bool headshot = event.GetBool("headshot");
				
				if(g_ZR_Rank_KillZombie_Headshot > 0 && headshot)
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_Headshot;
					g_ZR_Rank_ZombieKills[attacker]++;
					CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Kill Zombie Headshot", g_ZR_Rank_KillZombie_Headshot);
			
				}
				else
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie;
					g_ZR_Rank_ZombieKills[attacker]++;
					CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Kill Zombie Normal", g_ZR_Rank_KillZombie);
				}
			}
			
			if(g_ZR_Rank_BeingKilled > 0)
			{
				g_ZR_Rank_Points[victim] -= g_ZR_Rank_BeingKilled;
				CPrintToChat(victim, "%s %t", g_ZR_Rank_Prefix, "Killed by Human", g_ZR_Rank_BeingKilled);
			}
		}
	}
	return Plugin_Continue;
}

public void ZP_OnClientInfected(int client, int attacker)
{
	if(!g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return;
	}

	if (!IsValidClient(client) || !IsValidClient(attacker))
		return;
	
	if (!IsPlayerAlive(attacker))
		return;
	
	if(!g_ZR_Rank_InfectHuman || g_ZR_Rank_NumPlayers < g_ZR_Rank_MinPlayers)
	{
		return;
	}
	
	if(g_ZR_Rank_InfectHuman > 0)
	{
		g_ZR_Rank_Points[attacker] += g_ZR_Rank_InfectHuman;
		CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Infect Human", g_ZR_Rank_InfectHuman);
	}
	
	g_ZR_Rank_HumanInfects[attacker]++;
	
	if(g_ZR_Rank_BeingInfected > 0)
	{		
		g_ZR_Rank_Points[client] -= g_ZR_Rank_BeingInfected;
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Infected by Human", g_ZR_Rank_BeingInfected);
	}
}

public int ZR_OnClientInfected(int client, int attacker, bool motherInfect, bool respawnOverride, bool respawn)
{
	if(!g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return;
	}
	
	if (motherInfect)
	{
		g_ZR_Rank_PostInfect = true;
		return;
	}

	if (!IsValidClient(client) || !IsValidClient(attacker))
		return;
	
	if (!IsPlayerAlive(attacker))
		return;
	
	if(!g_ZR_Rank_InfectHuman || g_ZR_Rank_NumPlayers < g_ZR_Rank_MinPlayers)
	{
		return;
	}
	
	if(g_ZR_Rank_InfectHuman > 0)
	{
		g_ZR_Rank_Points[attacker] += g_ZR_Rank_InfectHuman;
		CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Infect Human", g_ZR_Rank_InfectHuman);
	}
	
	g_ZR_Rank_HumanInfects[attacker]++;
	
	if(g_ZR_Rank_BeingInfected > 0)
	{		
		g_ZR_Rank_Points[client] -= g_ZR_Rank_BeingInfected;
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Infected by Human", g_ZR_Rank_BeingInfected);
	}
}
