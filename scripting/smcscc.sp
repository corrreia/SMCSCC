#include <cstrike>
#include <eItems>
#include <PTaH>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
// #undef REQUIRE_PLUGIN
// #include <updater>

#pragma semicolon 1
#pragma newdecls required

#include "smcscc/globals.sp"
#include "smcscc/functions.sp"
#include "smcscc/utils.sp"
#include "smcscc/menus/main.sp"
#include "smcscc/hooks.sp"

public Plugin myinfo =
{
	name        = "Super Mega CS:GO Skin Changer Collection",
	author      = "Tomás Correia",
	description = "All in one CS:GO items management",
	version     = "0.0.2",
	url         = "https://github.com/corrreia/SMCSCC"
};

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Only CS:GO servers are supported!");
		return;
	}

	if (PTaH_Version() < 101000)
	{
		char sBuf[16];
		PTaH_Version(sBuf, sizeof(sBuf));
		SetFailState("PTaH extension needs to be updated. (Installed Version: %s - Required Version: 1.1.3+) [ Download from: https://ptah.zizt.ru ]", sBuf);
		return;
	}

	InitGValriables();

	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItemPost, Hook, GiveNamedItemPost);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);

	//LoadTranslations("weapons.phrases");

	//ConVar g_Cvar_DBConnection = CreateConVar("sm_smcscc_mongodb_string", "connection-string-here", "Database connection string For MongoDB");
	//ConVar g_Cvar_main = CreateConVar("sm_smcscc_main_menu", "sm_smcscc", "Main command for the plugin");

	//AutoExecConfig(true, "smcscc");

	//			Chat commands
	AddCommandListener(ChatListener, "say");
	AddCommandListener(ChatListener, "say2");
	AddCommandListener(ChatListener, "say_team");

	RegConsoleCmd("sm_smcscc", CommandInv);
	RegConsoleCmd("sm_inv", CommandInv);
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "eItems"))
	{
		
	}
}

public Action CommandInv(int client, int args)
{
	if (IsValidClient(client))
	{
		CreateMainMenu(client).Display(client, 60);
	}
	return Plugin_Handled;
}