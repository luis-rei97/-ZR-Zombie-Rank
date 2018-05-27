/* [CS:GO] Zombie Reloaded Rank Connect Message
 *
 *  Copyright (C) 2017 Hallucinogenic Troll
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <zr_rank>

#pragma semicolon 1
#pragma newdecls required

// ConVars
ConVar g_CVAR_ZR_Rank_ConnectMessage_Type;
ConVar g_CVAR_ZR_Rank_ConnectMessage_HudText_Red;
ConVar g_CVAR_ZR_Rank_ConnectMessage_HudText_Green;
ConVar g_CVAR_ZR_Rank_ConnectMessage_HudText_Blue;

// Variables to store ConVar Values;
int g_ZR_Rank_ConnectMessage_Type;
int g_ZR_Rank_ConnectMessage_HudText_Red;
int g_ZR_Rank_ConnectMessage_HudText_Green;
int g_ZR_Rank_ConnectMessage_HudText_Blue;

public Plugin myinfo = 
{
	name = "[ZR Rank] Connect's Message",
	author = "Hallucinogenic Troll",
	description = "It shows a message when a player connect, with his points.",
	version = "1.0",
	url = "http://HallucinogenicTrollConfigs.com/"
};

public void OnPluginStart()
{	
	g_CVAR_ZR_Rank_ConnectMessage_Type = CreateConVar("zr_rank_connectmessage_type", "1", "Type of HUD that you want to use in the connect message (0 = Disable, 1 = HintText, 2 = CenterText, 3 = Chat, 4 = HudText)", _, true, 0.0, true, 4.0);
	g_CVAR_ZR_Rank_ConnectMessage_HudText_Red = CreateConVar("zr_rank_connectmessage_hudtext_red", "255", "RGB Code for the Red Color used in the HudText (\"zr_rank_connectmessage_type\" needs to be set on 4)", _, true, 0.0, true, 255.0);
	g_CVAR_ZR_Rank_ConnectMessage_HudText_Green = CreateConVar("zr_rank_connectmessage_hudtext_green", "255", "RGB Code for the Green Color used in the HudText (\"zr_rank_connectmessage_type\" needs to be set on 4)", _, true, 0.0, true, 255.0);
	g_CVAR_ZR_Rank_ConnectMessage_HudText_Blue = CreateConVar("zr_rank_connectmessage_hudtext_blue", "255", "RGB Code for the Blue Color used in the HudText (\"zr_rank_connectmessage_type\" needs to be set on 4)", _, true, 0.0, true, 255.0);

	AutoExecConfig(true, "zr_rank_connectmessage", "zr_rank");
}

public void OnConfigsExecuted()
{
	g_ZR_Rank_ConnectMessage_Type = g_CVAR_ZR_Rank_ConnectMessage_Type.IntValue;
	g_ZR_Rank_ConnectMessage_HudText_Red = g_CVAR_ZR_Rank_ConnectMessage_HudText_Red.IntValue;
	g_ZR_Rank_ConnectMessage_HudText_Green = g_CVAR_ZR_Rank_ConnectMessage_HudText_Green.IntValue;
	g_ZR_Rank_ConnectMessage_HudText_Blue = g_CVAR_ZR_Rank_ConnectMessage_HudText_Blue.IntValue;
}

public void OnClientPostAdminCheck(int client)
{
	if(!g_ZR_Rank_ConnectMessage_Type)
	{
		return;
	}
	
	int points = ZR_Rank_GetPoints(client);
		
	for (int i = 0; i < MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			/*
				Type of HUD that you want to use in the connect message:
					0 = Disable
					1 = HintText
					2 = CenterText
					3 = Chat
					4 = HudText
			*/
			switch(g_ZR_Rank_ConnectMessage_Type)
			{
				case 1:
				{
					PrintHintText(i, "%N connected to the server, with %d points", client, points);
				}
				case 2:
				{
					PrintCenterText(i, "%N connected to the server, with %d points", client, points);
				}
				case 3:
				{
					PrintToChat(i, "%N connected to the server, with %d points", client, points);
				}
				case 4:
				{
					SetHudTextParams(-1.0, 0.125, 5.0, g_ZR_Rank_ConnectMessage_HudText_Red, g_ZR_Rank_ConnectMessage_HudText_Green, g_ZR_Rank_ConnectMessage_HudText_Blue, 255, 0, 0.25, 1.5, 0.5);
					ShowHudText(i, 5, "%N connected to the server, with %d points", client, points);
				}
			}
		}
	}
}

stock bool IsValidClient(int client)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		return true;
	}
	
	return false;
}