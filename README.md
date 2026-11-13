# Ciné-Club Imagerie

Plateforme de l'équipe de la BU Imagerie : Hervé propose des films, l'équipe note, critique et joue.
Site statique (GitHub Pages) + Supabase pour les comptes et les données.

## Mise en route

1. Créer un projet sur https://supabase.com (offre gratuite, région Europe).
2. SQL Editor : coller `schema.sql` et exécuter.
3. Définir les deux codes d'invitation (SQL Editor) :
   ```sql
   update public.app_settings
   set team_code = 'code-equipe-a-choisir', director_code = 'code-herve-a-choisir';
   ```
4. Authentication > Providers > Email : désactiver « Confirm email » (sinon chacune doit valider un e-mail).
5. Project Settings > API : copier l'URL et la clé `anon` dans `config.js`.
6. Settings > Pages du dépôt : branche `main`, dossier `/ (root)`.

## Rôles

- Hervé s'inscrit avec le code directeur (un seul compte possible).
- Les consultantes s'inscrivent avec le code équipe.
- Les règles de sécurité sont dans `schema.sql` : seul Hervé peut proposer, programmer, lancer une séance, créer duels et défis, décerner les trophées.

## Base de films

La roulette et l'autocomplétion de « Proposer un film » interrogent Wikidata (données ouvertes CC0) depuis le navigateur : aucun compte ni clé n'est nécessaire.
Si Wikidata ne répond pas, la roulette retombe sur un catalogue local de 281 films.

## Fiche de chaque film

À la proposition d'un film, l'app complète automatiquement la fiche (affiche, année, durée, réalisation, distribution, synopsis, lien Wikipédia) depuis Wikidata et Wikipédia (CC0 / CC BY-SA), sans clé.
Pour ajouter la note du public, des avis publics et un synopsis plus complet en français, créez une clé API gratuite sur https://www.themoviedb.org/settings/api et collez-la dans `tmdbKey` (config.js). Les données TMDB sont affichées avec leur mention de source.
Hervé peut relancer la recherche avec « Actualiser les infos » dans la fiche du film.

## GIF dans un avis

Dans un avis, on peut coller l'adresse d'un GIF (lien giphy.com ou image en https), sans configuration.
Pour activer la recherche de GIF dans l'app, créez une clé gratuite sur https://developers.giphy.com et collez-la dans `giphyKey` (config.js).

## Mot de passe oublié

Sur l'écran de connexion, « Mot de passe oublié ? » envoie un e-mail avec un lien. Pour que ce lien ramène sur le site, dans Supabase :
Authentication > URL Configuration : mettre l'adresse du site dans « Site URL » et l'ajouter dans « Redirect URLs ».

## Book-Club

Le même site sert aussi un club de lecture : ajoutez `?club=livres` à l'adresse (le bouton « Films / Livres » en haut à droite fait le lien).
Mêmes comptes et même base Supabase, mais chaque club a ses propres propositions, notes, élections, badges et classement :
les données du book-club sont stockées avec le préfixe `b_` (`b_films`, `b_ratings`, ...). Il faut relancer `schema.sql`
(règles de sécurité) pour que les membres puissent écrire dans ces collections. Les livres viennent d'Open Library (gratuit, sans clé).
