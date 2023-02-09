Menu CreateGlovesMenu(int client)
{
	Menu menu = new Menu(GlovesMenuHandler);

	menu.SetTitle("Glove Menu", client);

	menu.AddItem("0", "Both");

	menu.AddItem("2", "T");

	menu.AddItem("3", "CT");

	menu.ExitBackButton = true;

	return menu;
}

public int GlovesMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char info[32];
				menu.GetItem(selection, info, sizeof(info));

				CreateGloveCustomMenu(client, StringToInt(info)).Display(client, 60);
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

public Menu CreateGloveCustomMenu(int client, int team)
{
	Menu menu = new Menu(GloveCustomMenuHandler);

	// get display name of the weapon
	char buffer[32];	// team_weapoNum_type
	Format(buffer, sizeof(buffer), "%s Glove ", team == 0 ? "T/CT" : team == 2 ? "T"
																			   : "CT");

	menu.SetTitle(buffer, client);

	Format(buffer, sizeof(buffer), "%d_skin", team);
	menu.AddItem(buffer, "Choose Glove");

	//------------ (this part only is available if the glove has a skin	)
	bool gloveHasSkin = g_clients[client].getGloveDefIndex(team) != -1;

	Format(buffer, sizeof(buffer), "%d_float", team);
	menu.AddItem(buffer, "Change Float", gloveHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	Format(buffer, sizeof(buffer), "%d_seed", team);
	menu.AddItem(buffer, "Change Seed", gloveHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	//------------

	menu.ExitBackButton = true;

	return menu;
}

public int GloveCustomMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char buffer[32];
			menu.GetItem(selection, buffer, sizeof(buffer));
			char buffer2[2][16];
			ExplodeString(buffer, "_", buffer2, 2, 32);	   // buffer2[0] = team, buffer2[1] = type

			int team = StringToInt(buffer2[0]);

			if (StrEqual(buffer2[1], "skin"))
			{
				CreateGloveSkinMenu(client, team).Display(client, 60);
			}
			else if (StrEqual(buffer2[1], "float"))
			{
				CreateGloveFloatMenu(client, team).Display(client, 60);
			}
			else if (StrEqual(buffer2[1], "seed"))
			{
				PrintToChat(client, "Write your desired seed into chat. To abort, type !abort.");
				g_clients[client].setWaitingType(WAITING_GLOVE_SEED, team);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateGlovesMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

public Menu CreateGloveSkinMenu(int client, int team)
{
	Menu menu = new Menu(GloveSkinMenuHandler);

	char gloveTypeName[32];
	char buffer[32];

	menu.SetTitle("Chose Glove Type", client);

	int nrOfSkins = eItems_GetGlovesCount();

	Format(buffer, sizeof(buffer), "%d_%d", team, -1);
	menu.AddItem(buffer, "Default");

	for (int i = 0; i < nrOfSkins; i++)
	{
		eItems_GetGlovesDisplayNameByGlovesNum(i, gloveTypeName, sizeof(gloveTypeName));
		Format(buffer, sizeof(buffer), "%d_%d", team, i);
		menu.AddItem(buffer, gloveTypeName);
	}

	menu.ExitBackButton = true;

	return menu;
}

public int GloveSkinMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char buffer[32];
			menu.GetItem(selection, buffer, sizeof(buffer));
			char buffer2[2][16];
			ExplodeString(buffer, "_", buffer2, 2, 32);	   // buffer2[0] = team, buffer2[1] = gloveNum
			int team	 = StringToInt(buffer2[0]);
			int gloveNum = StringToInt(buffer2[1]);

			if (gloveNum == -1)
			{
				g_clients[client].setGloveSkinDefIndex(team, -1, -1);
				CreateGloveCustomMenu(client, team).Display(client, 60);
			}
			else {
				CreateSubGloveSkinMenu(client, team, gloveNum).Display(client, 60);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateGlovesMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

public Menu CreateSubGloveSkinMenu(int client, int team, int gloveNum)
{
	Menu menu = new Menu(SubGloveSkinMenuHandler);

	char buffer[32];

	menu.SetTitle("Chose Glove Skin", client);

	ArrayList skins = new ArrayList();
	eItems_GetSkinsDefIndexArrByGloveNum(gloveNum, skins);

	for (int i = 0; i < skins.Length; i++)
	{
		char skinName[32];
		Format(buffer, sizeof(buffer), "%d_%d_%d", team, gloveNum, skins.Get(i));	 // team_gloveNum_skinDefIndex
		eItems_GetSkinDisplayNameByDefIndex(skins.Get(i), skinName, sizeof(skinName));
		menu.AddItem(buffer, skinName);
	}

	menu.ExitBackButton = true;

	return menu;
}

public int SubGloveSkinMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char buffer[32];
			menu.GetItem(selection, buffer, sizeof(buffer));
			char buffer2[3][16];
			ExplodeString(buffer, "_", buffer2, 3, 32);	   // buffer2[0] = team, buffer2[1] = gloveNum, buffer2[2] = skinDefIndex
			int team		  = StringToInt(buffer2[0]);
			int gloveDefIndex = eItems_GetGlovesDefIndexByGlovesNum(StringToInt(buffer2[1]));
			int skinDefIndex  = StringToInt(buffer2[2]);

			PrintToChat(client, "team %d, gloveDefIndex %d, skinDefIndex %d", team, gloveDefIndex, skinDefIndex);

			g_clients[client].setGloveSkinDefIndex(team, gloveDefIndex, skinDefIndex);

			RefreshGloves(client);

			CreateGloveCustomMenu(client, team).Display(client, 60);
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateGlovesMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 0;
}

public Menu CreateGloveFloatMenu(int client, int team)
{
	char  buffer[32];
	Menu  menu	   = new Menu(GloveFloatMenuHandler);

	float fValue   = g_clients[client].getGloveFloat(team);
	int	  defIndex = g_clients[client].getGloveDefIndex(team);
	int	  wear	   = RoundFloat(fValue * 100.0);

	eItems_GetGlovesDisplayNameByDefIndex(defIndex, buffer, sizeof(buffer));
	Format(buffer, sizeof(buffer), "%s - %d%", buffer, wear);
	menu.SetTitle(buffer);

	Format(buffer, sizeof(buffer), "%d_floatinc", team);
	menu.AddItem(buffer, "Increase 5%", wear == 100 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	Format(buffer, sizeof(buffer), "%d_floatdec", team);
	menu.AddItem(buffer, "Decrease 5%", wear == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.ExitBackButton = true;

	return menu;
}

public int GloveFloatMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[32];
				menu.GetItem(selection, buffer, sizeof(buffer));
				char buffer2[2][16];
				ExplodeString(buffer, "_", buffer2, 1, 16);	   // buffer2[0] = team, buffer2[1] = floatinc/floatdec

				int	  team		 = StringToInt(buffer2[0]);

				float floatValue = g_clients[client].getGloveFloat(team);

				if (StrEqual(buffer2[1], "floatinc"))
				{
					g_clients[client].setGloveFloat(team, floatValue + 0.05);

					if (floatValue < 0.0)
						g_clients[client].setGloveFloat(team, 0.0);
				}
				else if (StrEqual(buffer2[1], "floatdec"))
				{
					g_clients[client].setGloveFloat(team, floatValue - 0.05);

					if (floatValue > 1.0)
						g_clients[client].setGloveFloat(team, 1.0);
				}

				RefreshGloves(client);

				CreateGloveFloatMenu(client, team).Display(client, 60);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateGlovesMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}