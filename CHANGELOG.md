# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.3.0-hyltaria] - 2026-10-27
Reprise du gamemode par Hyltaria (base : GitHub Ylan03/Slashers). Phase 1 : corrections de bugs.

### Ajouté
- Convar `slashers_generator_duration` (5 par défaut) : temps à maintenir E sur le générateur.
- Message réseau `sls_client_ready` : le serveur attend que le client soit chargé avant de lui envoyer la caméra, l'état de la manche, la liste des maps et la popup Workshop. Nouveau hook serveur `sls_PlayerReady(ply)`.
- Hook serveur `sls_round_GetNextMap` (utilisé par le votemap, sinon rotation des maps).
- Fonction partagée `SLS_IsInvisible(ply)` (variable réseau `sls_invisible`).
- Contenu Workshop configurable dans `config.lua` : `workshop_download`, `workshop_addons`, `content_check_files`, `content_workshop_id`.

### Corrigé
- **Crash possible sur slash_subway** : le hook `ShouldCollide` du Proxy changeait de résultat sans `CollisionRulesChanged()` ; un seul hook maintenant, basé sur une variable réseau.
- **Endurance** : un message réseau était envoyé à chaque frame ; le serveur jouait n'importe quel son demandé par un client. Respiration gérée côté serveur avec hystérésis.
- **Générateur** : `GetNWEntity` sur une valeur booléenne empêchait la validation ; progression indépendante du tickrate ; plus de spam de notifications.
- Chronomètres envoyés en entier 16 bits (faux après ~9 h de map) → `WriteFloat`.
- Chasemode : le serveur vérifie l'expéditeur et la cible (exploit / erreurs Lua).
- Proxy : état d'invisibilité remis à zéro entre les manches, plus d'erreur si aucune arme, timers protégés, la mort d'un survivant ne rend plus le Proxy visible.
- Proxy : seuls les survivants vivants peuvent signaler qu'ils voient le tueur.
- Myers : reset de fin de manche (faute de frappe `resetEnRound`), `WriteInt(2, 2)` qui débordait, victime choisie au hasard.
- Capacité du tueur : seul le tueur de la manche en cours peut l'utiliser (anti-spam).
- Portes cassables : `PhysicsInitConvex(wood1)` (variable inexistante).
- Votemap : erreur quand personne ne votait (la map ne changeait jamais), choix de map vérifié côté serveur, changement de map fait en fin de dernière manche.
- Lampe : `SetNWEntity(..., nil)` → `NULL`, lumière supprimée quand l'arme est retirée / le joueur meurt.
- Entités créées au chargement des fichiers (`ents.Create` hors fonction) dans jerrican, radio, mère de Bates.
- Clés de Roland : nombre de clés en variable réseau (HUD faux dès la 2ᵉ manche), timers par arme, annulation si on ne vise plus la porte.
- Hook HUD de la mère de Bates renommé (écrasait celui de Ghostface / Myers).
- Erreurs quand `ClassID` est nil (killerhelp, cri de mort, F1, écran de début).
- Jerrican / radio : double utilisation, `SendOmit` sur un tueur invalide ; la radio n'affiche plus d'erreur après l'appel.
- Joueur arrivant en cours de manche : la caméra n'est plus désactivée pour tout le monde.
- Spectateur : suppression du `SetParent` joueur → joueur.
- Map sans `camera_view` ou `button_escape` : avertissement au lieu d'une erreur.
- Boucles `table.remove` dans `ipairs` (messages, notifications, portes Ghostface, traces de Jason).
- HUD recalculé quand la résolution change ; touches `+use` / `+menu` lues avec `input.LookupBinding`.
- Variables globales involontaires dans les notifications et objectifs.
- slash_motel et le Season 2 Shared Map Content n'étaient pas envoyés aux joueurs (`resource.AddWorkshop`).
- La fenêtre « contenu manquant » vérifie la présence réelle des fichiers (avant : l'abonnement aux items Utopia, donc affichée à tort avec une collection privée).

## [1.2.0] - 2018-08-06
### Added
- New map (slash_motel)
- New killer (Norman Bates)
- Add Brazilian Portuguese translation by @Viking321

## [1.1.1] - 2017-08-13
### Added
- Polish translation by @danx91

### Changed
- Change objectives spawn positions on slash_highschool.

### Fixed
- Fixed shy ability on slash_subway
- Fixed shy ability on slash_selvage
- Fixed votemap

## [1.1.0] - 2017-08-10
### Added
- Language support system. (Make your own in gamemode/languages/xx.lua)
- Russian translation by @RealPackages.
- German translation by @Sodak.
- French translation by @Guilhem-Pech.
- Votemap.
- Add config convars. See convars.txt for description.

### Changed
- Add toggle for f1menu.
- Ghostface's ability has now a detection radius.
- Myers's ability has now a cooldown.
- Dead player can't chat with a live player.
- The shy girl can see trap on slash_lodge and see the Proxy icon if he invisible on slash_subway.
- [*For developpers*] New killer/map system. Incompatible with older custom killer/map.

### Removed
- Config vars in config.lua replaced by convars.
