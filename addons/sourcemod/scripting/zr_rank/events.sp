public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if(!IsValidClient(attacker))
	{
		return Plugin_Continue;
	}
	
	if(ZR_IsClientHuman(attacker))
	{
		int victim = GetClientOfUserId(event.GetInt("userid"));
		
		if(ZR_IsClientZombie(victim))
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
					PrintToChat(attacker, "%s You won \x0B1 point(s)\x01 by stabbing a zombie with the mouse left button!", PREFIX, g_ZR_Rank_StabZombie_Left);
				}
				else if(damage > 50 && g_ZR_Rank_StabZombie_Right > 0)
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_StabZombie_Right;
					PrintToChat(attacker, "%s You won \x0B1 point(s)\x01 by stabbing a zombie with the mouse right button!", PREFIX, g_ZR_Rank_StabZombie_Right);
				}	
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	if(!attacker || !victim || victim == attacker || !g_ZR_Rank_KillZombie)
	{
		return Plugin_Continue;
	}
	
	if(ZR_IsClientHuman(attacker))
	{
		if(GetClientTeam(victim) == 2)
		{
			char weapon[32];
			event.GetString("weapon", weapon, sizeof(weapon));
			
			if(g_ZR_Rank_KillZombie_Knife > 0 && StrEqual(weapon, "knife", true))
			{
				g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_Knife;
				g_ZR_Rank_ZombieKills[attacker]++;
				PrintToChat(attacker, "%s You won \x0B%d point(s)\x01 by killing a zombie with a knife!", PREFIX, g_ZR_Rank_KillZombie_Knife);
			}
			else if(g_ZR_Rank_KillZombie_HE > 0 && StrEqual(weapon, "hegrenade", true))
			{
				g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_HE;
				g_ZR_Rank_ZombieKills[attacker]++;
				PrintToChat(attacker, "%s You won \x0B%d point(s)\x01 by killing a zombie with a knife!", PREFIX, g_ZR_Rank_KillZombie_HE);
			}
			else if(g_ZR_Rank_KillZombie_SmokeFlashbang > 0 && (StrEqual(weapon, "smokegrenade", true) || StrEqual(weapon, "flashbang", true)))
			{
				g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_SmokeFlashbang;
				g_ZR_Rank_ZombieKills[attacker]++;
				PrintToChat(attacker, "%s You won \x0B%d point(s)\x01 by killing a zombie with a knife!", PREFIX, g_ZR_Rank_KillZombie_SmokeFlashbang);
			}
			else
			{
				bool headshot = event.GetBool("headshot");
				
				if(g_ZR_Rank_KillZombie_Headshot > 0 && headshot)
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie_Headshot;
					g_ZR_Rank_ZombieKills[attacker]++;
					PrintToChat(attacker, "%s You won \x0B%d point(s)\x01 by killing a zombie, with an headshot!", PREFIX, g_ZR_Rank_KillZombie_Headshot);
			
				}
				else
				{
					g_ZR_Rank_Points[attacker] += g_ZR_Rank_KillZombie;
					g_ZR_Rank_ZombieKills[attacker]++;
					PrintToChat(attacker, "%s You won \x0B%d point(s)\x01 by killing a zombie!", PREFIX, g_ZR_Rank_KillZombie);
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public int ZR_OnClientInfected(int client, int attacker, bool motherInfect, bool respawnOverride, bool respawn)
{
	if(!client || !attacker || motherInfect || !g_ZR_Rank_InfectHuman)
	{
		return;
	}
	
	g_ZR_Rank_Points[client] += g_ZR_Rank_InfectHuman;
	g_ZR_Rank_HumanInfects[client]++;
	PrintToChat(attacker, "%s You won \x0B%d point(s)\x01 by infecting an human!", PREFIX, g_ZR_Rank_InfectHuman);
	
}