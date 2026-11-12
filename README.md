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
