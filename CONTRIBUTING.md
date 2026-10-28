# Contribuer à Slashers (fork Hyltaria)

Ce dépôt est un fork maintenu du gamemode **Slashers** d'Utopia Games, utilisé sur le serveur Garry's Mod Hyltaria.

## Flux de travail

1. **Une issue d'abord** : chaque bug ou fonctionnalité a une issue (modèles « Bug » et « Fonctionnalité »).
2. **Une branche par sujet**, créée depuis `master` :

   | Préfixe | Usage | Exemple |
   |---|---|---|
   | `fix/` | correction de bug | `fix/proxy-collisions` |
   | `feat/` | nouvelle fonctionnalité | `feat/tfa-4-weapons` |
   | `refactor/` | réorganisation sans changement de comportement | `refactor/round-state` |
   | `chore/` | outillage, CI, dépendances | `chore/repo-setup` |
   | `docs/` | documentation | `docs/convars` |

3. **Pull Request vers `master`**, avec `Closes #<numéro>` dans la description. On ne pousse jamais directement sur `master`.
4. La CI (lint) doit être verte, puis la PR est relue et testée sur un serveur avant d'être fusionnée.

## Messages de commit

Format [Conventional Commits](https://www.conventionalcommits.org/fr/) :

```
<type>(<portée>): <résumé à l'impératif, en minuscules>

<corps optionnel : le pourquoi, pas le comment>

Refs #12
```

- **types** : `fix`, `feat`, `refactor`, `perf`, `chore`, `ci`, `docs`
- **portées courantes** : `rounds`, `classes`, `maps`, `subway`, `selvage`, `stamina`, `votemap`, `weapons`, `entities`, `hud`, `net`
- un commit = un changement logique ; il doit pouvoir être relu seul.

## Tester avant une PR

- Lancer un serveur local / de test avec les contenus Workshop de la collection.
- Vérifier la console **serveur et client** : aucune nouvelle erreur Lua.
- Tester sur la ou les maps concernées, avec au moins 3 joueurs (bots possibles : `bot` dans la console).
- Commandes utiles : `sls_restartround [steamid]` (superadmin), `lua_openscript`, `developer 1`.

## Lint

La CI exécute [glualint](https://github.com/FPtje/GLuaFixer) :

- **bloquant** : erreurs de syntaxe, `goto`, clés dupliquées (règles de `.glualint.json`) ;
- **indicatif** : toutes les règles sur les fichiers modifiés par la PR (annotations dans l'onglet « Files changed »).

En local : `glualint lint gamemode entities`.

## Versions et releases

- [SemVer](https://semver.org/lang/fr/) avec le suffixe `-hyltaria` tant que le fork diverge de l'original : `1.3.0-hyltaria`.
- Mettre à jour `CHANGELOG.md` et `GM.Version` (`gamemode/shared.lua`).
- Pousser un tag `vX.Y.Z[-suffixe]` : la CI crée la release GitHub avec le zip prêt à installer (`gamemodes/slashers/...`).
- Pour tester une branche sur le serveur sans release : onglet **Actions → Release → Run workflow**, puis télécharger l'artefact.

## Conventions de code

- Indentation : tabulations (voir `.editorconfig`).
- Pas de nouvelle variable globale : `local` partout, sauf API volontairement partagée (préfixe `SLS_` / table `GM`).
- Ne jamais faire confiance au client : tout `net.Receive` côté serveur vérifie l'expéditeur, son équipe, l'état de la manche et limite la fréquence.
- Textes affichés : clés de traduction dans `gamemode/languages/*.lua` (au minimum `en.lua` et `fr.lua`).
- Nouvelles convars : `FCVAR_ARCHIVE`, une description, et documentées dans `convars.txt`.
