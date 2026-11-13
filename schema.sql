-- Ciné-Club Imagerie : schéma Supabase
-- À coller en entier dans Supabase > SQL Editor > Run.

create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  name text not null,
  role text not null check (role in ('consultant','director')),
  created_at timestamptz not null default now()
);

create table public.app_settings (
  id int primary key default 1 check (id = 1),
  team_code text not null,
  director_code text not null
);
insert into public.app_settings values (1, 'CHANGE-ME-EQUIPE', 'CHANGE-ME-DIRECTEUR');

create table public.docs (
  coll text not null,
  id text not null,
  data jsonb not null default '{}'::jsonb,
  owner uuid default auth.uid(),
  updated_at timestamptz not null default now(),
  primary key (coll, id)
);

alter table public.profiles enable row level security;
alter table public.app_settings enable row level security;
alter table public.docs enable row level security;

create or replace function public.is_director() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'director')
$$;

-- Création de compte : refuse tout code d'invitation incorrect, attribue le rôle.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
declare s public.app_settings; code text := coalesce(new.raw_user_meta_data->>'invite',''); r text;
begin
  select * into s from public.app_settings where id = 1;
  if s.team_code like 'CHANGE-ME%' or s.director_code like 'CHANGE-ME%' then
    raise exception 'Ciné-club non configuré';
  end if;
  if code = s.director_code then
    if exists (select 1 from public.profiles where role = 'director') then
      raise exception 'Hervé a déjà un compte';
    end if;
    r := 'director';
  elsif code = s.team_code then r := 'consultant';
  else raise exception 'Code invalide';
  end if;
  insert into public.profiles (id, name, role)
  values (new.id, coalesce(nullif(trim(new.raw_user_meta_data->>'name'),''), split_part(new.email,'@',1)), r);
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

-- Lecture : tout membre connecté. Les visiteurs anonymes ne voient rien.
create policy profiles_read on public.profiles for select to authenticated using (true);
-- Le carnet personnel ('diary') n'est lisible que par son auteur, y compris pour Hervé.
create policy docs_read on public.docs for select to authenticated using (coll <> 'diary' or right(id, 36) = auth.uid()::text);

-- Écriture : Hervé écrit partout. Chaque membre écrit ses propres lignes (notes, votes, liste à voir, likes, avatar),
-- identifiées par un identifiant qui se termine par son id, et peut proposer des films (qu'il peut ensuite modifier ou retirer).
drop policy if exists docs_read on public.docs;
create policy docs_read on public.docs for select to authenticated using (coll <> 'diary' or right(id, 36) = auth.uid()::text);
drop policy if exists docs_insert on public.docs;
drop policy if exists docs_update on public.docs;
drop policy if exists docs_delete on public.docs;
create policy docs_insert on public.docs for insert to authenticated with check (
  public.is_director()
  or (coll in ('ratings','dvotes','watch','likes','members','ideas','noms','nvotes','diary')
      and right(id, 36) = auth.uid()::text
      and coalesce(data->>'userId', auth.uid()::text) = auth.uid()::text
      and coalesce(data->>'elected','false') <> 'true')
  or (coll = 'films' and owner = auth.uid()
      and coalesce(data->>'by','') = auth.uid()::text
      and coalesce(data->>'featured','false') <> 'true')
);
create policy docs_update on public.docs for update to authenticated using (
  public.is_director()
  or (coll in ('ratings','dvotes','watch','likes','members','ideas','noms','nvotes','diary') and right(id, 36) = auth.uid()::text)
  or (coll = 'films' and owner = auth.uid())
) with check (
  public.is_director()
  or (coll in ('ratings','dvotes','watch','likes','members','ideas','noms','nvotes','diary')
      and right(id, 36) = auth.uid()::text
      and coalesce(data->>'userId', auth.uid()::text) = auth.uid()::text
      and coalesce(data->>'elected','false') <> 'true')
  or (coll = 'films' and owner = auth.uid()
      and coalesce(data->>'by','') = auth.uid()::text
      and coalesce(data->>'featured','false') <> 'true')
);
create policy docs_delete on public.docs for delete to authenticated using (
  public.is_director()
  or (coll in ('ratings','dvotes','watch','likes','members','ideas','noms','nvotes','diary') and right(id, 36) = auth.uid()::text)
  or (coll = 'films' and owner = auth.uid())
);
