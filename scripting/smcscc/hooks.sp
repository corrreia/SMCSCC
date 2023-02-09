

public void OnConfigsExecuted()
{
	// GetConVarString(g_Cvar_DBConnection, g_DBConnection, sizeof(g_DBConnection));

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)	// THIS IS WAY BETTER THAN OnClientConnected
{
	if (IsFakeClient(client))
	{
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
	else if (IsValidClient(client))
	{
		HookPlayer(client);
	}
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client))
	{
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
	else if (IsValidClient(client))
	{
		UnhookPlayer(client);
	}
}

public void HookPlayer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
}

public void UnhookPlayer(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
}

Action GiveNamedItemPre(int client, char classname[64], CEconItemView &item, bool &ignoredCEconItemView, bool &OriginIsNULL, float Origin[3])
{
	if (IsValidClient(client))
	{
		int team	 = GetClientTeam(client);
		int defIndex = g_clients[client].getKnifeDefIndex(team);

		if (defIndex != 0 && eItems_IsDefIndexKnife(eItems_GetWeaponDefIndexByClassName(classname)))
		{
			ignoredCEconItemView = true;

			char buffer[64];
			eItems_GetWeaponClassNameByDefIndex(defIndex, buffer, sizeof(buffer));
			strcopy(classname, sizeof(classname), buffer);

			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public void GiveNamedItemPost(int client, const char[] classname, const CEconItemView item, int entity, bool OriginIsNULL, const float Origin[3])	  // runs when player switches weapon
{
	if (IsValidClient(client) && IsValidEntity(entity))
	{
		if (eItems_IsValidWeapon(entity))
		{
			if (eItems_IsDefIndexKnife(eItems_GetWeaponDefIndexByClassName(classname)))
			{
				EquipPlayerWeapon(client, entity);
			}
			SetWeaponProps(client, entity);
		}
	}
}

public Action ChatListener(int client, const char[] command, int args)
{
	if (client < 1)
	{
		return Plugin_Continue;
	}

	char msg[128];
	GetCmdArgString(msg, sizeof(msg));
	StripQuotes(msg);

	eWaitingType type = g_clients[client].getWaitingType();
	int team = g_clients[client].getWaitingTeam();
	int weaponNum = g_clients[client].getWaitingWeaponNum();

	if (type == WAITING_TAG && IsValidClient(client) && !IsChatTrigger())
	{
		CleanNameTag(msg, sizeof(msg));

		g_clients[client].setWaitingType(NONE);

		if (StrEqual(msg, "!abort"))
		{
			PrintToChat(client, "Name tag operation aborted.");
			return Plugin_Handled;
		}

		if (StrEqual(msg, "!delete"))
		{
			g_clients[client].setWeaponNameTag(team, weaponNum, "", 1);

			PrintToChat(client, "Name tag deleted.");
			RefreshSkin(client, weaponNum);
			return Plugin_Handled;
		}

		g_clients[client].setWeaponNameTag(team, weaponNum, msg, sizeof(msg));

		RefreshSkin(client, weaponNum);
		PrintToChat(client, "Name tag successfully applied");
	}
	else if (type == WAITING_WEAPON_SEED && IsValidClient(client) && !IsChatTrigger())
	{
		g_clients[client].setWaitingType(NONE);

		PrintToChatAll("%s", msg);
		if (StrEqual(msg, "!abort"))
		{
			PrintToChat(client, "Weapon seed operation aborted.");
			return Plugin_Handled;
		}

		int seed = StringToInt(msg);

		if (seed < 0)
		{
			PrintToChat(client, "Invalid seed.");
			return Plugin_Handled;
		}

		g_clients[client].setWeaponSeed(team, weaponNum, seed);

		RefreshSkin(client, weaponNum);
		PrintToChat(client, "Weapon seed successfully applied");
	}
	else if (type == WAITING_GLOVE_SEED && IsValidClient(client) && !IsChatTrigger()) {
		g_clients[client].setWaitingType(NONE);

		PrintToChatAll("%s", msg);
		if (StrEqual(msg, "!abort"))
		{
			PrintToChat(client, "Glove seed operation aborted.");
			return Plugin_Handled;
		}

		int seed = StringToInt(msg);

		if (seed < 0)
		{
			PrintToChat(client, "Invalid seed.");
			return Plugin_Handled;
		}

		g_clients[client].setGloveSeed(team, seed);

		RefreshGloves(client);

		PrintToChat(client, "Glove seed successfully applied");
	}

	return Plugin_Continue;
}

public Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (float(GetClientHealth(victim)) - damage > 0.0)	  // if player is not dead
		return Plugin_Continue;

	if (!(damagetype & DMG_SLASH) && !(damagetype & DMG_BULLET))	// if player is not killed by knife or bullet
		return Plugin_Continue;

	if (!IsValidClient(attacker))	 // if attacker is not a player
		return Plugin_Continue;

	if (!eItems_IsValidWeapon(weapon))	  // if weapon is not valid
		return Plugin_Continue;

	int weaponDefIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	int team		   = GetClientTeam(attacker);
	int weaponNum	   = eItems_GetWeaponNumByDefIndex(weaponDefIndex);
	int attackerSkinDefIndex = g_clients[attacker].getWeaponSkinDefIndex(team, weaponNum);
	bool statTrak = g_clients[attacker].getWeaponStatTrak(team, weaponNum);

	if ((weaponDefIndex == -1) || attackerSkinDefIndex == -1 || !statTrak)	// if weapon is not a knife and has a skin and has stattrak
		return Plugin_Continue;

	if (GetEntProp(weapon, Prop_Send, "m_nFallbackStatTrak") == -1)
		return Plugin_Continue;

	int previousOwner;
	if ((previousOwner = GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner")) != INVALID_ENT_REFERENCE && previousOwner != attacker)
		return Plugin_Continue;

	g_clients[attacker].plusOneStatTrak(team, weaponNum);

	// UPDATE DATABASE

	return Plugin_Continue;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int clientIndex = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(clientIndex))
	{
		RefreshGloves(clientIndex);
	}
}
