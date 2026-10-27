-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:45
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-08-07T18:52:51+02:00

local GM = GM or GAMEMODE
GM.CONFIG = {}

GM.CONFIG["disabled_modules"] = {
	-- ["goal"] = true, -- set true to disable module
}

-- Armes pour le tueur
GM.CONFIG["killer_weapons"] = {
	"tfa_nmrih_chainsaw",
	-- "tfa_nmrih_kknife",
	"tfa_nmrih_fireaxe",
	"tfa_nmrih_machete"
}
-- Armes pour les survivants
GM.CONFIG["survivors_weapons"] = {
	"weapon_flashlight"
}
-- Points ajoutés de choosekiller ajoutés à chaque manche terminée
GM.CONFIG["round_choosekiller_add"] = 10
-- Temps de démarrage de la manche (secondes)
GM.CONFIG["round_freeze_start"] = 10
-- Durée d'attente lors d'une fin de manche
GM.CONFIG["round_duration_end"] = 30

-- Entités Killerhelp porte
GM.CONFIG["killerhelp_door_entities"] = {
	"prop_door_rotating",
	"func_door_rotating"
}
-- Entités sorties
GM.CONFIG["killerhelp_exit_entities"] = {
	"brush_car_1",
	"brush_car_2",
	"door_exit_1",
	"door_exit_2",
	"door_exit_3",
	"door_exit_4"
}

-- Contenu Workshop
-- Addons envoyés aux joueurs avec resource.AddWorkshop.
-- Mettre "workshop_download" à false si le serveur fournit déjà le contenu
-- par sa propre collection Workshop (host_workshop_collection) ou un content privé.
GM.CONFIG["workshop_download"] = true
GM.CONFIG["workshop_addons"] = {
	"788009163",  -- Utopia Games - Slashers content 1
	"857992903",  -- Utopia Games - Slashers content 2
	"1247351614", -- Slashers Season 2 Shared Map Content (requis par slash_motel)
	"787790694",  -- slash_highschool
	"787938932",  -- slash_summercamp
	"798554357",  -- slash_selvage
	"858049276",  -- slash_subway
	"1091061063", -- slash_lodge
	"1247285424", -- slash_motel
}
-- Fichiers vérifiés côté client : s'il en manque un, une fenêtre prévient le joueur
GM.CONFIG["content_check_files"] = {
	"models/steinman/slashers/sport_pm.mdl", -- content 1
	"models/steinman/slashers/bates_pm.mdl", -- content 2
}
-- Page Workshop ouverte par cette fenêtre ("" = pas de bouton)
GM.CONFIG["content_workshop_id"] = "788009163"
