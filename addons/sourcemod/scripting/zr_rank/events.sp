public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if(g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		CPrintToChatAll("%s %t", g_ZR_Rank_Prefix, "Warmup End");
		return;
	}
	
	g_ZR_Rank_PostInfect = false;
	g_ZR_Rank_PostRound = false;
	g_ZR_Rank_PostRoundTimer = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iPlayerDamage[i] = 0;
	}
	
	if (roundTimer != null)
	{
		KillTimer(roundTimer);
		roundTimer = null;
	}
	
	// Time to wait before allowing humans to be awarded round end points
	roundTimer = CreateTimer(180.0, Round_Timer);
}

public Action Round_Timer(Handle timer)
{
	g_ZR_Rank_PostRoundTimer = true;
	roundTimer = null;
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	// Stop other point events until next round
	g_ZR_Rank_PostRound = true;
	
	if (g_ZR_Rank_PostRoundTimer)
	{
		int winningTeam = GetEventInt(event, "winner");
		if (g_ZR_Rank_Win_Human > 0 && winningTeam == 3)
		{			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					// Award damage dealt as a human
					if (g_iPlayerDamage[i] > 0 && g_ZR_Rank_Damage_Reward)
					{
						int remainder = (g_iPlayerDamage[i] / g_ZR_Rank_Damage_Bonus);
						if (remainder > 0)
						{
							CPrintToChat(i, "%s %t", g_ZR_Rank_Prefix, "Damage Bonus", (remainder * g_ZR_Rank_Damage_Reward), g_iPlayerDamage[i]);
							g_ZR_Rank_Points[i] += (remainder * g_ZR_Rank_Damage_Reward);
						}
					}
					if (GetClientTeam(i) == 3)
					{
						// Award them if they survived to the end
						if (IsPlayerAlive(i))
						{
							CPrintToChat(i, "%s %t", g_ZR_Rank_Prefix, "Human Win", g_ZR_Rank_Win_Human);
							g_ZR_Rank_Points[i] += g_ZR_Rank_Win_Human;
						}
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if(g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return Plugin_Continue;
	}
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	if(!IsValidClient(victim) || !IsValidClient(attacker) || !g_ZR_Rank_PostInfect || g_ZR_Rank_PostRound || g_ZR_Rank_NumPlayers < g_ZR_Rank_MinPlayers)
	{
		return Plugin_Continue;
	}
	
	if (!IsPlayerAlive(attacker))
		return Plugin_Continue;
	
	if(ZR_IsClientHuman(attacker))
	{
		if(GetClientTeam(victim) == 2)
		{
			char weapon_name[100];
			int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
			int damage = event.GetInt("dmg_health");
			g_iPlayerDamage[attacker] += damage;
			GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
			
			if(StrEqual(weapon_name, "weapon_knife"))
			{
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
	if(g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return Plugin_Continue;
	}
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	if (!IsValidClient(victim))
		return Plugin_Continue;
	
	if(!g_ZR_Rank_KillZombie || !g_ZR_Rank_PostInfect || g_ZR_Rank_PostRound || (g_ZR_Rank_NumPlayers < g_ZR_Rank_MinPlayers))
	{
		return Plugin_Continue;
	}
	
	//Human committed suicide
	if ((GetClientTeam(victim) == 3) && ((victim == attacker) || !attacker))
	{
		if (g_ZR_Rank_Suicide_Human > 0)
		{
			g_ZR_Rank_Points[victim] -= g_ZR_Rank_Suicide_Human;
			CPrintToChat(victim, "%s %t", g_ZR_Rank_Prefix, "Human Suicide", g_ZR_Rank_Suicide_Human);
		}
		return Plugin_Continue;
	}
	
	if (!IsValidClient(attacker))
		return Plugin_Continue;

	if(GetClientTeam(attacker) == 3)
	{
		
		if (!IsPlayerAlive(attacker))
			return Plugin_Continue;
			
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

public int ZR_OnClientInfected(int client, int attacker, bool motherInfect, bool respawnOverride, bool respawn)
{
	if(g_ZR_Rank_AllowWarmup && (GameRules_GetProp("m_bWarmupPeriod") == 1))
	{
		return;
	}
	
	if (motherInfect)
	{
		if (g_ZR_Rank_NumPlayers < g_ZR_Rank_MinPlayers)
			CPrintToChatAll("%s %t", g_ZR_Rank_Prefix, "Player Limit", g_ZR_Rank_MinPlayers);
		g_ZR_Rank_PostInfect = true;
		return;
	}

	if (!IsValidClient(client) || !IsValidClient(attacker))
		return;
	
	if (!IsPlayerAlive(attacker))
		return;
	
	if(!g_ZR_Rank_InfectHuman && !g_ZR_Rank_BeingInfected)
	{
		return;
	}
	
	if (g_ZR_Rank_NumPlayers < g_ZR_Rank_MinPlayers)
	{
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Player Limit", g_ZR_Rank_MinPlayers);
		CPrintToChat(attacker, "%s %t", g_ZR_Rank_Prefix, "Player Limit", g_ZR_Rank_MinPlayers);
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
		CPrintToChat(client, "%s %t", g_ZR_Rank_Prefix, "Infected by Zombie", g_ZR_Rank_BeingInfected);
	}
}
