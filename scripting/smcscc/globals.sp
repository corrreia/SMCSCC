
eClient g_clients[MAXPLAYERS + 1];

enum eWaitingType
{
	NONE		   = 0,
	WAITING_TAG	   = 1,
	WAITING_WEAPON_SEED = 2,
	WAITING_GLOVE_SEED = 3,
	WAITING_STICKER_SEARCH = 4,
}

enum struct eGlove
{
	int	  gloveDefIndex;
	int	  skinDefIndex;
	float floatValue;
	int	  seed;
}

enum struct eSticker{
	int	  	defIndex;
	float  	wear;
	int 	rotation;
}

enum struct eWeapon
{
	int	  weaponDefIndex;
	int	  skinDefIndex;
	char  nameTag[20];
	float floatValue;
	int	  seed;
	bool  statTrak;
	int	  statTrakCount;

	ArrayList arStickers; //up to 5
}

enum struct eClient
{
	char		 steamID64[32];

	ArrayList	 arWeaponsT;
	ArrayList	 arWeaponsCT;
	eGlove		 gloveT;
	eGlove		 gloveCT;
	int			 knifeTDefIndex;
	int			 knifeCTDefIndex;
	int 		 musicKitDefIndex;

	eWaitingType waitingType;
	int			 TN[2];	   // TD[0] = team, TD[1] = weaponnum

	void init(){

		this.steamID64		 = "\0";
		this.arWeaponsT		 = new ArrayList(sizeof(eWeapon), eItems_GetWeaponCount());
		this.arWeaponsCT	 = new ArrayList(sizeof(eWeapon), eItems_GetWeaponCount());
		this.knifeTDefIndex	 = 0;
		this.knifeCTDefIndex = 0;
		this.waitingType	 = NONE;
		this.TN				 = { 0, 0 };

		for (int j = 0; j < eItems_GetWeaponCount(); j++){
			eWeapon weapon;
			weapon.weaponDefIndex = -1;
			weapon.skinDefIndex	  = -1;
			weapon.nameTag[0]	  = '\0';
			weapon.floatValue	  = 0.0;
			weapon.seed			  = -1;
			weapon.statTrak		  = false;
			weapon.statTrakCount  = 0;

			weapon.arStickers = new ArrayList(sizeof(eSticker), 5);
			for (int i = 0; i < 5; i++){
				eSticker sticker;
				sticker.defIndex = -1;
				sticker.wear = 0.0;
				sticker.rotation = 0;

				weapon.arStickers.SetArray(i, sticker);
			}

			this.arWeaponsT.SetArray(j, weapon);
			this.arWeaponsCT.SetArray(j, weapon);
		}

		eGlove glove;
		glove.gloveDefIndex = -1;
		glove.skinDefIndex	= -1;
		glove.floatValue	= 0.0;
		glove.seed			= -1;

		this.gloveT			= glove;
		this.gloveCT		= glove;
	}

	void clear(){
		this.arWeaponsT.Clear();
		this.arWeaponsCT.Clear();
		this.init();
	}

	// MAIN GETTERS

	bool setSteamID64(char[] steamID64){
		if (strlen(steamID64) != 17)
			return false;

		strcopy(this.steamID64, sizeof(this.steamID64), steamID64);
		return true;
	}

	bool setKnifeDefIndex(int team, int knifeDefIndex){
		//if team == 0 then do for both teams

		if (team != 0 && team != 2 && team != 3)
			return false;

		if (team == 0 || team == 2)
			this.knifeTDefIndex = knifeDefIndex;
		
		if (team == 0 || team == 3)
			this.knifeCTDefIndex = knifeDefIndex;

		return true;
	}

	bool setWaitingType(eWaitingType waitingType, int team = 0, int weaponNum = 0){

		this.waitingType = waitingType;
		this.TN[0]		 = team;
		this.TN[1]		 = weaponNum;

		return true;
	}

	// MAIN SETTERS

	int getSteamID64(char[] steamID64, int size){
		return strcopy(steamID64, size, this.steamID64);
	}

	int getKnifeDefIndex(int team){
		if (team != 2 && team != 3)
			return 0;

		if (team == 2)
			return this.knifeTDefIndex;
		else
			return this.knifeCTDefIndex;
	}

	eWaitingType getWaitingType(){
		return this.waitingType;
	}

	int getWaitingTeam(){
		return this.TN[0];
	}

	int getWaitingWeaponNum(){
		return this.TN[1];
	}

	// GETTERS AND SETTER FOR WEAPONS

	int setWeaponDefIndex(int team, int weaponNum, int weaponDefIndex){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			weapon.weaponDefIndex = weaponDefIndex;
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			weapon.weaponDefIndex = weaponDefIndex;
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int setWeaponSkinDefIndex(int team, int weaponNum, int skinDefIndex){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			weapon.skinDefIndex = skinDefIndex;
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			weapon.skinDefIndex = skinDefIndex;
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int setWeaponNameTag(int team, int weaponNum, char[] nameTag, int size){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			CleanNameTag(nameTag, size);
			strcopy(weapon.nameTag, sizeof(weapon.nameTag), nameTag);
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			CleanNameTag(nameTag, size);
			strcopy(weapon.nameTag, sizeof(weapon.nameTag), nameTag);
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int setWeaponFloat(int team, int weaponNum, float floatValue){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			weapon.floatValue = floatValue;
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			weapon.floatValue = floatValue;
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int setWeaponSeed(int team, int weaponNum, int seed){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			weapon.seed = seed;
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			weapon.seed = seed;
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int setWeaponStatTrak(int team, int weaponNum, bool statTrak){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			weapon.statTrak = statTrak;
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			weapon.statTrak = statTrak;
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int setWeaponStattrakCount(int team, int weaponNum, int statTrakCount){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			weapon.statTrakCount = statTrakCount;
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			weapon.statTrakCount = statTrakCount;
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int plusOneStatTrak(int team, int weaponNum){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			weapon.statTrakCount++;
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			weapon.statTrakCount++;
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int switchStatTrak(int team, int weaponNum){
		//team can be 2 ,3 or 0, if 0 then it will be set for both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			weapon.statTrak = !weapon.statTrak;
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}
		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			weapon.statTrak = !weapon.statTrak;
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}
		return 1;
	}

	int getWeaponDefIndex(int team, int weaponNum){
		//if team is 0 it will check if both 
		//teams have the same defindex, if not it will return -1

		if (team != 0 && team != 2 && team != 3)
			return -1;
		
		eWeapon weaponT;
		eWeapon weaponCT;

		this.arWeaponsT.GetArray(weaponNum, weaponT);
		this.arWeaponsCT.GetArray(weaponNum, weaponCT);

		if (team == 0)
		{
			if (weaponT.weaponDefIndex == weaponCT.weaponDefIndex)
				return weaponT.weaponDefIndex;
			else
				return -1;
		}
		else if (team == 2)
			return weaponT.weaponDefIndex;
		else if (team == 3)
			return weaponCT.weaponDefIndex;
		else
			return -1;
	}

	int getWeaponSkinDefIndex(int team, int weaponNum){

		if (team != 0 && team != 2 && team != 3)
			return -1;
		
		eWeapon weaponT;
		eWeapon weaponCT;

		this.arWeaponsT.GetArray(weaponNum, weaponT);
		this.arWeaponsCT.GetArray(weaponNum, weaponCT);

		if (team == 0)
		{
			if (weaponT.skinDefIndex == weaponCT.skinDefIndex)
				return weaponT.skinDefIndex;
			else
				return -1;
		}
		else if (team == 2)
			return weaponT.skinDefIndex;
		else if (team == 3)
			return weaponCT.skinDefIndex;
		else
			return -1;
	}

	int getWeaponNameTag(int team, int weaponNum, char[] nameTag, int length){
		
		eWeapon weapon;
		if (team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			strcopy(nameTag, length, weapon.nameTag);
			return 1;
		}
		else if (team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			strcopy(nameTag, length, weapon.nameTag);
			return 1;
		}
		
		return -1;
	}

	float getWeaponFloat(int team, int weaponNum){

		if (team != 2 && team != 3)
			return -1.0;

		eWeapon weapon;
		if (team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			return weapon.floatValue;
		}
		else if (team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			return weapon.floatValue;
		}
		
		return -1.0;
	}

	int getWeaponSeed(int team, int weaponNum){

		if (team != 2 && team != 3)
			return -1;
		
		eWeapon weapon;
		if (team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			return weapon.seed;
		}
		else if (team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			return weapon.seed;
		}
		
		return -1;
	}

	bool getWeaponStatTrak(int team, int weaponNum){
		if (team != 2 && team != 3)
			return false;
		
		eWeapon weapon;
		if (team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			return weapon.statTrak;
		}
		else if (team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			return weapon.statTrak;
		}
		
		return false;
	}

	int getWeaponStatTrakCount(int team, int weaponNum){

		if (team != 2 && team != 3)
			return -1;
		
		eWeapon weapon;
		if (team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			return weapon.statTrakCount;
		}
		else if (team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			return weapon.statTrakCount;
		}

		return -1;
	}

	// GETTERS AND SETTER FOR GLOVES

	int getGloveDefIndex(int team){
		//if team is 0 it will check if both
		//teams have the same defindex, if not it will return -1

		if (team != 0 && team != 2 && team != 3)
			return -1;

		if (team == 0)
		{
			if (this.gloveT.gloveDefIndex == this.gloveCT.gloveDefIndex)
				return this.gloveT.gloveDefIndex;
			else
				return -1;
		}
		else if (team == 2)
			return this.gloveT.gloveDefIndex;
		else if (team == 3)
			return this.gloveCT.gloveDefIndex;
		
		return -1;
	}

	int getGloveSkinDefIndex(int team){
		//if team is 0 it will check if both
		//teams have the same defindex, if not it will return -1

		if (team != 0 && team != 2 && team != 3)
			return -1;

		if (team == 0)
		{
			if (this.gloveT.skinDefIndex == this.gloveCT.skinDefIndex)
				return this.gloveT.skinDefIndex;
			else
				return -1;
		}
		else if (team == 2)
			return this.gloveT.skinDefIndex;
		else if (team == 3)
			return this.gloveCT.skinDefIndex;
		
		return -1;
	}

	float getGloveFloat(int team){
		if (team != 2 && team != 3)
			return -1.0;

		if (team == 2)
			return this.gloveT.floatValue;
		else if (team == 3)
			return this.gloveCT.floatValue;
		
		return -1.0;
	}

	int getGloveSeed(int team){
		if (team != 2 && team != 3)
			return -1;

		if (team == 2)
			return this.gloveT.seed;
		else if (team == 3)
			return this.gloveCT.seed;
		
		return -1;
	}

	int setGloveSkinDefIndex(int team, int defIndex, int skinDefIndex){
		//if team is 0 it will set both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		if (team == 0 || team == 2)
		{
			this.gloveT.skinDefIndex = skinDefIndex;
			this.gloveT.gloveDefIndex = defIndex;
		}

		if (team == 0 || team == 3)
		{
			this.gloveCT.skinDefIndex = skinDefIndex;
			this.gloveCT.gloveDefIndex = defIndex;
		}

		return 0;
	}

	int setGloveFloat(int team, float floatValue){
		//if team is 0 it will set both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		if (team == 0 || team == 2)
		{
			this.gloveT.floatValue = floatValue;
		}

		if (team == 0 || team == 3)
		{
			this.gloveCT.floatValue = floatValue;
		}

		return 0;
	}

	int setGloveSeed(int team, int seed){
		//if team is 0 it will set both teams

		if (team != 0 && team != 2 && team != 3)
			return -1;

		if (team == 0 || team == 2)
		{
			this.gloveT.seed = seed;
		}

		if (team == 0 || team == 3)
		{
			this.gloveCT.seed = seed;
		}
		
		return 0;
	}


	// GETTERS AND SETTER FOR STICKERS

	int getStickerDefIndex(int team, int weaponNum, int pos){
		if (team != 2 && team != 3)
			return -1;

		if (weaponNum < 0 || weaponNum >= eItems_GetWeaponCount())
			return -1;

		if (pos < 0 || pos >= 5)
			return -1;

		eWeapon weapon;
		if (team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			return sticker.defIndex;

		}
		else if (team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			return sticker.defIndex;
		}

		return -1;
	}

	float getStickerWear(int team, int weaponNum, int pos){
		if (team != 2 && team != 3)
			return -1.0;

		if (pos < 0 || pos >= 5)
			return -1.0;

		eWeapon weapon;
		if (team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			return sticker.wear;

		}
		else if (team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			return sticker.wear;
		}

		return -1.0;
	}

	int getStickerRotation(int team, int weaponNum, int pos){
		if (team != 2 && team != 3)
			return -1;

		if (pos < 0 || pos >= 5)
			return -1;

		eWeapon weapon;
		if (team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			return sticker.rotation;

		}
		else if (team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			return sticker.rotation;
		}

		return -1;
	}

	int setStickerDefIndex(int team, int weaponNum, int pos, int defIndex){
		//if pos == -1 it will set all stickers
		//if team == 0 it will set all teams

		if (team != 2 && team != 3 && team != 0)
			return -1;

		if (pos == -1)
		{
			for (int i = 0; i < 5; i++)
			{
				this.setStickerDefIndex(team, weaponNum, i, defIndex);
			}
			return 0;
		}

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			sticker.defIndex = defIndex;
			weapon.arStickers.SetArray(pos, sticker);
			this.arWeaponsT.SetArray(weaponNum, weapon);
		}

		if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			sticker.defIndex = defIndex;
			weapon.arStickers.SetArray(pos, sticker);
			this.arWeaponsCT.SetArray(weaponNum, weapon);
		}

		return 0;
	}

	int setStickerWear(int team, int weaponNum, int pos, float wear){
		//if pos == -1 it will set all stickers
		//if team == 0 it will set all teams

		if (team != 2 && team != 3 && team != 0)
			return -1;

		if (pos == -1)
		{
			for (int i = 0; i < 5; i++)
			{
				this.setStickerWear(team, weaponNum, i, wear);
			}
			return 0;
		}

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			sticker.wear = wear;
			weapon.arStickers.SetArray(pos, sticker);
			this.arWeaponsT.SetArray(weaponNum, weapon);
			return 0;
		}
		else if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			sticker.wear = wear;
			weapon.arStickers.SetArray(pos, sticker);
			this.arWeaponsCT.SetArray(weaponNum, weapon);
			return 0;
		}

		return -1;
	}

	int setStickerRotation(int team, int weaponNum, int pos, int rotation){
		//if pos == -1 it will set all stickers
		//if team == 0 it will set all teams

		if (team != 2 && team != 3 && team != 0)
			return -1;

		if (pos == -1)
		{
			for (int i = 1; i < 5; i++)
			{
				this.setStickerRotation(team, weaponNum, i, rotation);
			}
			return 0;
		}

		eWeapon weapon;
		if (team == 0 || team == 2)
		{
			this.arWeaponsT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			sticker.rotation = rotation;
			weapon.arStickers.SetArray(pos, sticker);
			this.arWeaponsT.SetArray(weaponNum, weapon);
			return 0;
		}
		else if (team == 0 || team == 3)
		{
			this.arWeaponsCT.GetArray(weaponNum, weapon);
			eSticker sticker;
			weapon.arStickers.GetArray(pos, sticker);
			sticker.rotation = rotation;
			weapon.arStickers.SetArray(pos, sticker);
			this.arWeaponsCT.SetArray(weaponNum, weapon);
			return 0;
		}

		return -1;
	}

	//Music Kit

	int getMusicKit(){
		return this.musicKitDefIndex;
	}

	void setMusicKit(int defIndex){
		this.musicKitDefIndex = defIndex;
	}
}

public void InitGValriables()
{
	//g_arKnifesDefIndexes = new ArrayList();

	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		g_clients[i].init();
	}
	PrintToServer("[SMCSCC] Clients array initialized.");

	PrintToServer("[SMCSCC] Global variables initialized.");
}