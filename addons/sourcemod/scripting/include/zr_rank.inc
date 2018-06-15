#if defined _zr_rank_included
  #endinput
#endif
#define _zr_rank_included

/*********************************************************
 * Gets the players place (rank)
 *
 * @param client		The client to check
 * @return				The current position (rank) of the client		
 *********************************************************/
native int ZR_Rank_GetPlace(int client);

/*********************************************************
 * Gets the number of a player's points
 *
 * @param client		The client to get the points
 * @return				The number of points		
 *********************************************************/
native int ZR_Rank_GetPoints(int client);

/*********************************************************
 * Gets the number of a player's Zombie Kills
 *
 * @param client		The client to get the zombie kills
 * @return				The number of zombie kills		
 *********************************************************/
native int ZR_Rank_GetZombieKills(int client);

/*********************************************************
 * Gets the number of a player's Human Infects
 *
 * @param client		The client to get the zombie kills
 * @return				The number of human infects		
 *********************************************************/
native int ZR_Rank_GetHumanInfects(int client);

/*********************************************************
 * Sets points of a certain player
 *
 * @param client		The client to get the points
 * @param points		Number of points to set
 * @return				The number of points	
 *********************************************************/
native bool ZR_Rank_SetPoints(int client, int points);
