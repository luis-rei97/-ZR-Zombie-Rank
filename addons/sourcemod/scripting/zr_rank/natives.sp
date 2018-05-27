public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("ZR_Rank_GetPoints", Native_ZR_Rank_GetPoints);
	CreateNative("ZR_Rank_SetPoints", Native_ZR_Rank_SetPoints);

	RegPluginLibrary("zr_rank");
	
	return APLRes_Success;
}

public int Native_ZR_Rank_GetPoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	return g_ZR_Rank_Points[client];
}

public int Native_ZR_Rank_SetPoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int points = GetNativeCell(2);
	
	g_ZR_Rank_Points[client] = points;
	
	return view_as<int>(points);
}