
void SetWeaponProps(int client, int entity)	   // perfect
{
	int	 team			= GetClientTeam(client);
	int	 weaponDefIndex = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
	int	 weaponNum		= eItems_GetWeaponNumByDefIndex(weaponDefIndex);
	char weaponClass[32];
	eItems_GetWeaponClassNameByDefIndex(weaponDefIndex, weaponClass, sizeof(weaponClass));
	int	  skinDefIndex = GetWeaponSkinDefIndex(client, team, weaponNum);
	float skinFloat	   = GetWeaponFloatValue(client, team, weaponNum);
	int	  skinSeed	   = GetWeaponSeed(client, team, weaponNum);
	char  weaponTag[128];
	GetWeaponNameTag(client, team, weaponNum, weaponTag, sizeof(weaponTag));
	bool statTrak	   = GetWeaponStatTrak(client, team, weaponNum);
	int	 statTrakCount = GetWeaponStatTrakCount(client, team, weaponNum);

	if (weaponNum > -1 && skinDefIndex != -1)
	{
		static int IDHigh = 16384;
		SetEntProp(entity, Prop_Send, "m_iItemIDLow", -1);
		SetEntProp(entity, Prop_Send, "m_iItemIDHigh", IDHigh++);
		SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", skinDefIndex);
		SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", skinFloat == 0.0 ? 0.000001 : skinFloat == 1.0 ? 0.999999
																											  : skinFloat);

		if (skinSeed != -1)
		{
			SetEntProp(entity, Prop_Send, "m_nFallbackSeed", skinSeed);
		}
		else
		{
			SetWeaponSeed(client, team, weaponNum, GetRandomInt(0, 8192));
			SetEntProp(entity, Prop_Send, "m_nFallbackSeed", GetWeaponSeed(client, team, weaponNum));
		}

		SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", statTrak ? statTrakCount : -1);
		SetEntProp(entity, Prop_Send, "m_iEntityQuality", statTrak ? 9 : 0);

		if (strlen(weaponTag) > 0)
		{
			SetEntDataString(entity, FindSendPropInfo("CBaseAttributableItem", "m_szCustomName"), weaponTag, 128);
		}

		SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);
	}
}

void RefreshSkin(int client, int weaponNum)	   //! this is only for WEAPON SKINS, not for knives
{
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");	  // get the number of weapons the player has

	for (int i = 0; i < size; i++)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);	 // get the weapon entity
		if (eItems_IsValidWeapon(weapon))									 // if the weapon is an actual weapon
		{
			if (eItems_GetWeaponNumByWeapon(weapon) == weaponNum)
			{
				int previousOwner;
				if ((previousOwner = GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner")) != INVALID_ENT_REFERENCE && previousOwner != client)	   // the player is not the owner
				{
					return;
				}

				int offset	= FindDataMapInfo(client, "m_iAmmo") + (GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
				int ammo	= GetEntData(client, offset);
				int clip	= GetEntProp(weapon, Prop_Send, "m_iClip1");
				int reserve = GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");

				RemovePlayerItem(client, weapon);
				AcceptEntityInput(weapon, "KillHierarchy");

				char weaponClass[32];
				eItems_GetWeaponClassNameByWeapon(weapon, weaponClass, sizeof(weaponClass));
				GivePlayerItem(client, weaponClass);
				if (clip != -1)
				{
					SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
				}
				if (reserve != -1)
				{
					SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", reserve);
				}
				if (offset != -1 && ammo != -1)
				{
					SetEntData(client, offset, ammo, 4, true);
				}
			}
		}
	}
}

void RefreshKnife(int client)
{
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");	  // get the number of weapons the player has

	for (int i = 0; i < size; i++)
	{
		int weapon		   = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);	 // get the weapon entity
		int weaponDefIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

		if (eItems_IsValidWeapon(weapon) && eItems_IsDefIndexKnife(weaponDefIndex))
		{
			RemovePlayerItem(client, weapon);
			char weaponClass[32];
			eItems_GetWeaponClassNameByWeapon(weapon, weaponClass, sizeof(weaponClass));
			GivePlayerItem(client, weaponClass);
			break;
		}
	}
}

public void RefreshGloves(int client)
{
	int team = GetClientTeam(client);
	int seed = GetGloveSeed(client, team);

	if (GetGloveDefIndex(client, team) != -1)
	{
		int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
		if (ent != -1)
		{
			AcceptEntityInput(ent, "KillHierarchy");
		}

		FixCustomArms(client);

		ent = CreateEntityByName("wearable_item");
		if (ent != -1)
		{
			SetEntProp(ent, Prop_Send, "m_iItemIDLow", -1);

			SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", GetGloveDefIndex(client, team));
			SetEntProp(ent, Prop_Send, "m_nFallbackPaintKit", GetGloveSkinDefIndex(client, team));

			SetEntPropFloat(ent, Prop_Send, "m_flFallbackWear", GetGloveFloatValue(client, team));
			if (seed != -1)
			{
				SetEntProp(ent, Prop_Send, "m_nFallbackSeed", seed);
			}
			else
			{
				SetEntProp(ent, Prop_Send, "m_nFallbackSeed", GetRandomInt(1, 1000));
			}
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
			SetEntPropEnt(ent, Prop_Data, "m_hParent", client);
			SetEntPropEnt(ent, Prop_Data, "m_hMoveParent", client);
			SetEntProp(ent, Prop_Send, "m_bInitialized", 1);

			DispatchSpawn(ent);

			SetEntPropEnt(client, Prop_Send, "m_hMyWearables", ent);
			SetEntProp(client, Prop_Send, "m_nBody", 1);
		}
	}
}