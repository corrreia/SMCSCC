Menu CreateSkinsMenu(int client)
{
	Menu menu = new Menu(SkinsMenuHandler);

	menu.SetTitle("Skin Menu", client);

	menu.AddItem("all", "All Weapons");	   // menu to configure all weapons

	if (IsPlayerAlive(client))
	{
		// max 3 weapons (primary, secondary, melee)
		// im using eItems_GetInSlotweaponNum(int client, int iSlot); to get the weapon
		for (int i = 0; i < 3; i++)
		{
			int	 weaponNum = eItems_GetInSlotWeaponNum(client, i);
			char displayName[32];
			char buffer[32];

			eItems_GetWeaponDisplayNameByWeaponNum(weaponNum, displayName, sizeof(displayName));

			int	 weaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(weaponNum);
			bool defaultKnife	= eItems_IsDefIndexKnife(weaponDefIndex) && !eItems_IsSkinnableDefIndex(weaponDefIndex);

			if (weaponNum != -1 && !defaultKnife)
			{
				Format(buffer, sizeof(buffer), "%d", weaponNum);
				menu.AddItem(buffer, displayName);
			}
		}
	}

	menu.ExitBackButton = true;

	return menu;
}

public int SkinsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char info[32];
				menu.GetItem(selection, info, sizeof(info));

				if (StrEqual(info, "all"))
				{
					CreateTeamChoseMenu(client).Display(client, 60);	// create the menu to choose the team, and display it
				}
				else
				{
					int team	  = GetClientTeam(client);									// get the team of the player
					int weaponNum = StringToInt(info);										// get the weapon defindex
					CreateWeaponCustomMenu(client, team, weaponNum).Display(client, 60);	// create the menu to configure the skin, and display it
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateMainMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

public Menu CreateTeamChoseMenu(int client)
{
	Menu menu = new Menu(TeamChoseMenuHandler);

	menu.SetTitle("Choose Team", client);

	menu.AddItem("0", "Both");
	menu.AddItem("2", "T");
	menu.AddItem("3", "CT");

	menu.ExitBackButton = true;

	return menu;
}

public int TeamChoseMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char info[32];
				menu.GetItem(selection, info, sizeof(info));

				CreateAllWeaponsMenu(client, StringToInt(info)).Display(client, 60);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateSkinsMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

public Menu CreateAllWeaponsMenu(int client, int team)	   // team = 2, 3 (both, t, ct)
{
	Menu menu = new Menu(AllWeaponsMenuHandler);

	menu.SetTitle("All Weapons", client);

	int weaponCount = eItems_GetWeaponCount();
	for (int weaponNum = 0; weaponNum < weaponCount; weaponNum++)
	{
		int weaponDef = eItems_GetWeaponDefIndexByWeaponNum(weaponNum);
		if (eItems_IsSkinnableDefIndex(weaponDef))
		{
			if (eItems_GetWeaponTeamByWeaponNum(weaponNum) == team || eItems_GetWeaponTeamByWeaponNum(weaponNum) == 0)
			{
				char displayName[32];
				char info[32];

				eItems_GetWeaponDisplayNameByWeaponNum(weaponNum, displayName, sizeof(displayName));

				Format(info, sizeof(info), "%d_%d", team, weaponNum);
				menu.AddItem(info, displayName);
			}
		}
	}

	menu.ExitBackButton = true;

	return menu;
}

public int AllWeaponsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char info[32];
				menu.GetItem(selection, info, sizeof(info));

				// get team and defindex from the info param (team_defindex)
				char buffer[2][16];
				ExplodeString(info, "_", buffer, 2, 32);

				CreateWeaponCustomMenu(client, StringToInt(buffer[0]), StringToInt(buffer[1]))
					.Display(client, 60);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateTeamChoseMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

public Menu CreateWeaponCustomMenu(int client, int team, int weaponNum)
{
	Menu menu = new Menu(SkinCustomMenuHandler);

	// get display name of the weapon
	char buffer[32];	// team_weapoNum_type
	char weaponName[32];
	eItems_GetWeaponDisplayNameByWeaponNum(weaponNum, weaponName, sizeof(weaponName));

	menu.SetTitle(weaponName, client);

	Format(buffer, sizeof(buffer), "%d_%d_skin", team, weaponNum);
	menu.AddItem(buffer, "Choose Skin");

	//------------ (this part only is available if the weapon has a skin	)
	bool weaponHasSkin = GetWeaponSkinDefIndex(client, team, weaponNum) != -1;

	Format(buffer, sizeof(buffer), "%d_%d_nametag", team, weaponNum);
	menu.AddItem(buffer, "Change Nametag", weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	Format(buffer, sizeof(buffer), "%d_%d_float", team, weaponNum);
	menu.AddItem(buffer, "Change Float", weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	Format(buffer, sizeof(buffer), "%d_%d_stattrak", team, weaponNum);
	if (GetWeaponStatTrak(client, team, weaponNum))

		menu.AddItem(buffer, "StatTrak [On]", weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	else
		menu.AddItem(buffer, "StatTrak [Off]", weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	Format(buffer, sizeof(buffer), "%d_%d_seed", team, weaponNum);
	menu.AddItem(buffer, "Change Seed", weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	//------------

	menu.ExitBackButton = true;

	return menu;
}

public int SkinCustomMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char buffer[30];
			menu.GetItem(selection, buffer, sizeof(buffer));
			char buffer2[3][16];
			ExplodeString(buffer, "_", buffer2, 3, 32);	   // buffer2[0] = team, buffer2[1] = weaponNum, buffer2[2] = type

			int team	  = StringToInt(buffer2[0]);
			int weaponNum = StringToInt(buffer2[1]);

			if (StrEqual(buffer2[2], "skin"))
			{
				CreateSkinMenu(client, team, weaponNum).Display(client, 60);
			}
			else if (StrEqual(buffer2[2], "float"))
			{
				CreateFloatMenu(client, team, weaponNum).Display(client, 60);
			}
			else if (StrEqual(buffer2[2], "stattrak"))
			{
				SwitchWeaponStatTrak(client, team, weaponNum);

				RefreshSkin(client, weaponNum);
				CreateWeaponCustomMenu(client, team, weaponNum).Display(client, 60);
			}
			else if (StrEqual(buffer2[2], "nametag"))
			{
				PrintToChat(client, "Write your desired name tag into chat. To abort, type !abort, to delete type !delete.");
				eClient clientStruct;
				g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
				clientStruct.waitingType = WAITING_TAG;
				clientStruct.TN[0]		 = team;
				clientStruct.TN[1]		 = weaponNum;
				g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));
			}
			else if (StrEqual(buffer2[2], "seed"))
			{
				PrintToChat(client, "Write your desired seed into chat. To abort, type !abort.");
				eClient clientStruct;
				g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
				clientStruct.waitingType = WAITING_W_SEED;
				clientStruct.TN[0]		 = team;
				clientStruct.TN[1]		 = weaponNum;
				g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateSkinsMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

public Menu CreateSkinMenu(int client, int team, int weaponNum)
{
	Menu menu = new Menu(SkinMenuHandler);

	char weaponName[32];
	char buffer[32];
	eItems_GetWeaponDisplayNameByWeaponNum(weaponNum, weaponName, sizeof(weaponName));

	menu.SetTitle(weaponName, client);

	ArrayList skins = new ArrayList();
	eItems_GetSkinsDefIndexArrByWeaponNum(weaponNum, skins);

	Format(buffer, sizeof(buffer), "%d_%d_-1", team, weaponNum);
	menu.AddItem(buffer, "Remove Skin");

	for (int i = 0; i < skins.Length; i++)
	{
		char skinName[32];
		Format(buffer, sizeof(buffer), "%d_%d_%d", team, weaponNum, skins.Get(i));	  // team_weaponNum_skinDefIndex
		eItems_GetSkinDisplayNameByDefIndex(skins.Get(i), skinName, sizeof(skinName));
		menu.AddItem(buffer, skinName);
	}

	menu.ExitBackButton = true;

	return menu;
}

public int SkinMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char buffer[30];
			menu.GetItem(selection, buffer, sizeof(buffer));
			char buffer2[3][16];
			ExplodeString(buffer, "_", buffer2, 3, 32);	   // buffer2[0] = team, buffer2[1] = weaponNum, buffer2[2] = skinDefIndex
			int team		 = StringToInt(buffer2[0]);
			int weaponNum	 = StringToInt(buffer2[1]);
			int skinDefIndex = StringToInt(buffer2[2]);

			SetWeaponSkinDefIndex(client, team, weaponNum, skinDefIndex);
			RefreshSkin(client, weaponNum);

			CreateSkinMenu(client, team, weaponNum).Display(client, 60);
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateSkinsMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

public Menu CreateFloatMenu(int client, int team, int weaponNum)
{
	char  buffer[60];
	Menu  menu	 = new Menu(FloatMenuHandler);

	float fValue = GetWeaponFloatValue(client, team, weaponNum);	// 0.0 float = 100% wear, 1.0 float = 0% wear
	int	  wear	 = RoundFloat(fValue * 100.0);

	eItems_GetWeaponDisplayNameByWeaponNum(weaponNum, buffer, sizeof(buffer));
	Format(buffer, sizeof(buffer), "%s - %d%", buffer, wear);
	menu.SetTitle(buffer);

	Format(buffer, sizeof(buffer), "%d_%d_floatinc", team, weaponNum);
	menu.AddItem(buffer, "Increase 5%", wear == 100 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	Format(buffer, sizeof(buffer), "%d_%d_floatdec", team, weaponNum);
	menu.AddItem(buffer, "Decrease 5%", wear == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.ExitBackButton = true;

	return menu;
}

public int FloatMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[30];
				menu.GetItem(selection, buffer, sizeof(buffer));
				char buffer2[3][16];
				ExplodeString(buffer, "_", buffer2, 3, 16);	   // buffer2[0] = team, buffer2[1] = weaponNum, buffer2[2] = floatinc/floatdec

				int	  weaponNum	 = StringToInt(buffer2[1]);
				int	  team		 = StringToInt(buffer2[0]);

				float floatValue = GetWeaponFloatValue(client, team, weaponNum);

				if (StrEqual(buffer2[2], "floatinc"))
				{
					SetWeaponFloatValue(client, team, weaponNum, floatValue + 0.05);

					if (floatValue < 0.0)
						SetWeaponFloatValue(client, team, weaponNum, 0.0);

					RefreshSkin(client, weaponNum);

					CreateFloatMenu(client, team, weaponNum).Display(client, 60);
				}
				else if (StrEqual(buffer2[2], "floatdec"))
				{
					SetWeaponFloatValue(client, team, weaponNum, floatValue - 0.05);

					if (floatValue > 1.0)
						SetWeaponFloatValue(client, team, weaponNum, 1.0);

					RefreshSkin(client, weaponNum);

					CreateFloatMenu(client, team, weaponNum).Display(client, 60);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateSkinsMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}