#include "skins.sp"
#include "knifes.sp"
#include "gloves.sp"
#include "stickers.sp"

Menu CreateMainMenu(int client)
{
	Menu menu = new Menu(MainMenuHandler);

	menu.SetTitle("Main Menu", client);

	menu.AddItem("skins", "Skins");	   // 0

	menu.AddItem("knifes", "Knifes");	 // 1

	menu.AddItem("gloves", "Gloves");	 // 2

	menu.AddItem("stickers", "Stickers");	 // 3

	menu.AddItem("pins", "Pins and Coins");	   // 4

	menu.AddItem("music", "Music Kits");	// 5

	menu.AddItem("agents", "Agents");	 // 6

	menu.AddItem("patches", "Patches");	   // 7

	menu.ExitButton = true;

	return menu;
}

public int MainMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				switch (selection)
				{
					case 0:
					{
						CreateSkinsMenu(client).Display(client, 60);
					}
					case 1:
					{
						CreateKnifesMenu(client).Display(client, 60);
					}
					case 2:
					{
						CreateGlovesMenu(client).Display(client, 60);
					}
					case 3:
					{
						CreateStickerMainMenu(client).Display(client, 60);
					}
					case 4:
					{
						PrintToChat(client, "Pins and Coins");
					}
					case 5:
					{
						PrintToChat(client, "Music Kits");
					}
					case 6:
					{
						PrintToChat(client, "Agents");
					}
					case 7:
					{
						PrintToChat(client, "Patches");
					}
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;	 //??
}