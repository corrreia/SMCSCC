Menu CreateKnifesMenu(int client)
{
	Menu menu = new Menu(KnifesMenuHandler);

	menu.SetTitle("Knife Menu", client);

	menu.AddItem("0", "Both");

	menu.AddItem("2", "T");

	menu.AddItem("3", "CT");

	menu.ExitBackButton = true;

	return menu;
}

public int KnifesMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char info[32];
				menu.GetItem(selection, info, sizeof(info));

				CreateKnifeSetMenu(client, StringToInt(info)).Display(client, 60);
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

public Menu CreateKnifeSetMenu(int client, int team)
{
	char buffer[32];
	char knifeName[32];
	Menu menu = new Menu(KnifeSetMenuHandler);

	menu.SetTitle("Select the Knife", client);

	Format(buffer, sizeof(buffer), "%d_%d", team, -1);
	menu.AddItem(buffer, "Default");

	for (int i = 0; i < g_arKnifesDefIndexes.Length; i++)
	{
		int defindex = g_arKnifesDefIndexes.Get(i);
		Format(buffer, sizeof(buffer), "%d_%d", team, defindex);
		eItems_GetWeaponDisplayNameByDefIndex(defindex, knifeName, sizeof(knifeName));
		menu.AddItem(buffer, knifeName);
	}

	menu.ExitBackButton = true;

	return menu;
}

public int KnifeSetMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[30];
				menu.GetItem(selection, buffer, sizeof(buffer));
				char buffer2[2][16];
				ExplodeString(buffer, "_", buffer2, 2, 16);

				int team	 = StringToInt(buffer2[0]);
				int defIndex = StringToInt(buffer2[1]);

				SetClientKnife(client, team, defIndex);

				RefreshKnife(client);	 //, eItems_GetWeaponNumByDefIndex(defIndex));

				CreateKnifeSetMenu(client, team).Display(client, 60);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateKnifesMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}