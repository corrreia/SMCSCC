

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
		int defIndex = GetClientKnife(client, team);
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

	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));

	if (clientStruct.waitingType == WAITING_TAG && IsValidClient(client) && !IsChatTrigger())
	{
		CleanNameTag(msg, sizeof(msg));

		clientStruct.waitingType = NONE;

		if (StrEqual(msg, "!abort"))
		{
			PrintToChat(client, "Name tag operation aborted.");
			return Plugin_Handled;
		}

		if (StrEqual(msg, "!delete"))
		{
			SetWeaponNameTag(client, clientStruct.TN[0], clientStruct.TN[1], "");
			PrintToChat(client, "Name tag deleted.");
			RefreshSkin(client, clientStruct.TN[1]);
			g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));
			return Plugin_Handled;
		}

		SetWeaponNameTag(client, clientStruct.TN[0], clientStruct.TN[1], msg);

		g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));
		RefreshSkin(client, clientStruct.TN[1]);
		PrintToChat(client, "Name tag successfully applied");
	}
	else if (clientStruct.waitingType == WAITING_W_SEED && IsValidClient(client) && !IsChatTrigger())
	{
		clientStruct.waitingType = NONE;

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

		SetWeaponSeed(client, clientStruct.TN[0], clientStruct.TN[1], seed);

		g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));
		RefreshSkin(client, clientStruct.TN[1]);
		PrintToChat(client, "Weapon seed successfully applied");
	}
	else if (clientStruct.waitingType == WAITING_G_SEED && IsValidClient(client) && !IsChatTrigger()) {
		clientStruct.waitingType = NONE;

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

		SetGloveSeed(client, clientStruct.TN[0], seed);

		g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));

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

	if ((weaponDefIndex == -1) || (GetWeaponSkinDefIndex(attacker, team, weaponNum) == -1) || !GetWeaponStatTrak(attacker, team, weaponNum))	// if weapon is not a knife and has a skin and has stattrak
		return Plugin_Continue;

	if (GetEntProp(weapon, Prop_Send, "m_nFallbackStatTrak") == -1)
		return Plugin_Continue;

	int previousOwner;
	if ((previousOwner = GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner")) != INVALID_ENT_REFERENCE && previousOwner != attacker)
		return Plugin_Continue;

	PlusOneKill(attacker, team, weaponNum);

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
