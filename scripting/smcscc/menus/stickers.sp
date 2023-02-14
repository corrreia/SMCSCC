Menu CreateStickerMainMenu(int client)
{
	char buffer[32];
	char displayBuffer[32];

	if (!IsPlayerAlive(client))
	{
		PrintToChat(client, "You must be alive to use this command");
		return null;
	}

	int weapon         = eItems_GetActiveWeapon(client);
	int weaponDefIndex = eItems_GetWeaponDefIndexByWeapon(weapon);

	if (!eItems_IsValidWeapon(weapon))
	{
		PrintToChat(client, "You must be holding a weapon to use this command");
		return null;
	}

	int slots = eItems_GetWeaponStickersSlotsByDefIndex(weaponDefIndex);
	if (slots <= 0)
	{
		PrintToChat(client, "Is not possible to apply stickers in this weapon");
		return null;
	}

	int team = GetClientTeam(client);
	eItems_GetWeaponDisplayNameByDefIndex(weaponDefIndex, buffer, sizeof(buffer));

	Menu menu = new Menu(StickerMainMenuHandler);
	menu.SetTitle("Stickers for %s", buffer);

	for (int i = 0; i < slots; i++)
	{
		Format(buffer, sizeof(buffer), "slot_%d_%d_%d", team, weaponDefIndex, i);
		int stickerDefIndex = g_clients[client].getStickerDefIndex(team, eItems_GetWeaponNumByDefIndex(weaponDefIndex), i);

		if (stickerDefIndex == -1)
		{
			Format(displayBuffer, sizeof(displayBuffer), "Slot %d - <empty>", i+1);
			menu.AddItem(buffer, displayBuffer);
		}
		else
		{
			char nameBuffer[32];
			eItems_GetStickerDisplayNameByDefIndex(stickerDefIndex, nameBuffer, sizeof(nameBuffer));
			Format(displayBuffer, sizeof(displayBuffer), "Slot %d - %s", i+1, nameBuffer);
			menu.AddItem(buffer, displayBuffer);
		}
	}

	Format(buffer, sizeof(buffer), "slot_%d_%d_-1", team, weaponDefIndex);
	menu.AddItem(buffer, "All Stickers");

	// Format(buffer, sizeof(buffer), "wear_%d_%d_0", team, weaponDefIndex);
	// menu.AddItem(buffer, "Set Wear");

	// Format(buffer, sizeof(buffer), "rotation_%d_%d_-0", team, weaponDefIndex);
	// menu.AddItem(buffer, "Set Rotation");

	menu.ExitBackButton = true;

	return menu;
}

public int StickerMainMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[32];
				char buffer2[4][32];
				menu.GetItem(selection, buffer, sizeof(buffer));
				ExplodeString(buffer, "_", buffer2, 4, 32);    // [0] = type, [1] = team, [2] = weapon, [3] = pos

				int team           = StringToInt(buffer2[1]);
				int weaponDefIndex = StringToInt(buffer2[2]);
				int pos            = StringToInt(buffer2[3]);

				if (StrEqual(buffer2[0], "slot"))
				{
					CreateStickersMenu(client, team, weaponDefIndex, pos).Display(client, 60);
				}
				else if (StrEqual(buffer2[0], "wear"))
				{
					// CreateStickerWearMenu(client, weaponDefIndex, team, pos).Display(client, 60);
				}
				else if (StrEqual(buffer2[0], "rotation"))
				{
					// CreateStickerRotationMenu(client, weaponDefIndex, team, pos).Display(client, 60);
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

Menu CreateStickersMenu(int client, int team, int weaponDefIndex, int pos)
{
	Menu menu = new Menu(StickersMenuHandler);

	char buffer[32];

	if (IsPlayerAlive(client))
	{
		menu.SetTitle("Sticker Menu", client);

		Format(buffer, sizeof(buffer), "all_%d_%d_%d", team, weaponDefIndex, pos);
		menu.AddItem(buffer, "All Stickers");

		Format(buffer, sizeof(buffer), "search_%d_%d_%d", team, weaponDefIndex, pos);
		menu.AddItem(buffer, "Search Stickers");

		menu.ExitBackButton = true;

		return menu;
	}
	else {
		PrintToChat(client, "You must be alive to use this command");
		return null;
	}
}

public int StickersMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[32];
				menu.GetItem(selection, buffer, sizeof(buffer));

				char buffer2[4][32];
				ExplodeString(buffer, "_", buffer2, 4, 32);    // [0] = type, [1] = team, [2] = weapon, [3] = pos

				int team           = StringToInt(buffer2[1]);
				int weaponDefIndex = StringToInt(buffer2[2]);
				int pos            = StringToInt(buffer2[3]);

				if (StrEqual(buffer2[0], "all"))
				{
					CreateStickerSetsMenu(client, team, weaponDefIndex, pos).Display(client, 60);
				}
				else    // search
				{
					PrintToChat(client, "Please enter the sticker name you are searching for in chat. Type '!cancel' to cancel the search.");
					g_clients[client].setWaitingType(WAITING_STICKER_SEARCH);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateStickerMainMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

Menu CreateStickerSetsMenu(int client, int team, int weaponDefIndex, int pos)
{
	Menu menu = new Menu(StickerSetsMenuHandler);

	if (IsPlayerAlive(client))
	{
		menu.SetTitle("Chose the collection", client);

		char buffer[32];
		char displayBuffer[32];

		for (int set = 0; set < eItems_GetStickersSetsCount(); set++)
		{
			Format(buffer, sizeof(buffer), "set_%d_%d_%d_%d", team, weaponDefIndex, pos, set);
			eItems_GetStickerSetDisplayNameByStickerSetNum(set, displayBuffer, sizeof(displayBuffer));
			menu.AddItem(buffer, displayBuffer);
		}

		menu.ExitBackButton = true;

		return menu;
	}
	else {
		PrintToChat(client, "You must be alive to apply stickers.");
		return null;
	}
}

public int StickerSetsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[32];
				char buffer2[5][32];
				menu.GetItem(selection, buffer, sizeof(buffer));
				ExplodeString(buffer, "_", buffer2, 5, 32);    // [0] = type, [1] = team, [2] = weapon, [3] = pos, [4] = set

				int team           = StringToInt(buffer2[1]);
				int weaponDefIndex = StringToInt(buffer2[2]);
				int pos            = StringToInt(buffer2[3]);
				int setNum         = StringToInt(buffer2[4]);

				CreateSetStickersMenu(client, team, weaponDefIndex, pos, setNum).Display(client, 60);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateStickerMainMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

Menu CreateSetStickersMenu(int client, int team, int weaponDefIndex, int pos, int setNum)
{
	Menu menu = new Menu(SetStickersMenuHandler);

	if (IsPlayerAlive(client))
	{
		menu.SetTitle("Chose the sticker", client);

		char buffer[32];
		char displayBuffer[32];

		for (int sticker = 0; sticker < eItems_GetStickersCount(); sticker++)
		{
			if (eItems_IsStickerInSet(setNum, sticker))
			{
				Format(buffer, sizeof(buffer), "sticker_%d_%d_%d_%d_%d", team, weaponDefIndex, pos, setNum, sticker);
				eItems_GetStickerDisplayNameByStickerNum(sticker, displayBuffer, sizeof(displayBuffer));
				menu.AddItem(buffer, displayBuffer);
			}
		}

		menu.ExitBackButton = true;

		return menu;
	}
	else {
		PrintToChat(client, "You must be alive to apply stickers.");
		return null;
	}
}

public int SetStickersMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[32];
				char buffer2[6][32];
				menu.GetItem(selection, buffer, sizeof(buffer));
				ExplodeString(buffer, "_", buffer2, 6, 32);    // [0] = type, [1] = team, [2] = weapon, [3] = pos, [4] = set, [5] = sticker

				int team           = StringToInt(buffer2[1]);
				int weaponDefIndex = StringToInt(buffer2[2]);
				int pos            = StringToInt(buffer2[3]);
				int set            = StringToInt(buffer2[4]);
				int sticker        = eItems_GetStickerDefIndexByStickerNum(StringToInt(buffer2[5]));

				int weaponNum = eItems_GetWeaponNumByDefIndex(weaponDefIndex);
				g_clients[client].setStickerDefIndex(team, weaponNum, pos, sticker);

				PrintToChat(client, "%d", g_clients[client].getStickerDefIndex(team, weaponNum, pos));

				RefreshSkin(client, weaponNum);

				PTaH_ForceFullUpdate(client); //so that the sticker is shown on the weapon

				CreateSetStickersMenu(client, team, weaponDefIndex, pos, set).Display(client, 60);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateStickerMainMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}