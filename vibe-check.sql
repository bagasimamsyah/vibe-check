-- =====================================================================
-- VIBE CHECK — papan karakter belajar kelas
-- Membutuhkan komitmen-quest.sql (tabel kq_rooms & fungsi kq_*) yang SUDAH terpasang.
-- Hanya MENAMBAH tabel/fungsi berawalan vc_; tidak mengubah Komitmen Quest / Norma Kelas.
-- Kelas (kode, token pengajar, buka/tutup) memakai kq_rooms yang sama.
-- =====================================================================

create table if not exists public.vc_submissions (
  id          uuid primary key default gen_random_uuid(),
  room_id     uuid not null references public.kq_rooms(id) on delete cascade,
  client_id   uuid not null,
  name        text not null,
  arch        text not null check (arch in ('penjelajah','perekat','perancang','penggerak')),
  tally       jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (room_id, client_id)          -- satu HP = satu hasil (main ulang menimpa)
);
create index if not exists vc_submissions_room_idx on public.vc_submissions(room_id);
alter table public.vc_submissions enable row level security;
revoke all on public.vc_submissions from anon, authenticated;

-- ---------- peserta mengirim hasil ----------
create or replace function public.vc_submit(p_code text, p_client uuid, p_name text, p_arch text, p_tally jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare r public.kq_rooms; v_tally jsonb; v_name text;
begin
  r := public.kq_room(p_code);
  if r.id is null then raise exception 'Kode kelas tidak ditemukan'; end if;
  if not r.is_open then raise exception 'Pengisian sudah ditutup pengajar'; end if;
  if p_client is null then raise exception 'Identitas perangkat kosong'; end if;
  if p_arch is null or p_arch not in ('penjelajah','perekat','perancang','penggerak') then raise exception 'Karakter tidak dikenal'; end if;
  v_name := nullif(public.kq_clean(p_name, 24), '');
  if v_name is null then raise exception 'Nama wajib diisi'; end if;
  -- simpan hanya skor 0..20 untuk 4 karakter yang dikenal
  select coalesce(jsonb_object_agg(k, least(greatest(coalesce((p_tally->>k)::int, 0), 0), 20)), '{}'::jsonb) into v_tally
  from unnest(array['penjelajah','perekat','perancang','penggerak']) k
  where jsonb_typeof(coalesce(p_tally, '{}'::jsonb)) = 'object' and coalesce(p_tally->>k, '') ~ '^\d{1,3}$';
  if (select count(*) from public.vc_submissions where room_id = r.id) >= 500
     and not exists (select 1 from public.vc_submissions where room_id = r.id and client_id = p_client) then
    raise exception 'Kelas sudah penuh (500 peserta)';
  end if;
  insert into public.vc_submissions(room_id, client_id, name, arch, tally)
  values (r.id, p_client, v_name, p_arch, coalesce(v_tally, '{}'::jsonb))
  on conflict (room_id, client_id) do update set name = excluded.name, arch = excluded.arch, tally = excluded.tally, updated_at = now();
  return jsonb_build_object('ok', true, 'total', (select count(*) from public.vc_submissions where room_id = r.id));
end $$;

-- ---------- papan pengajar ----------
create or replace function public.vc_results(p_code text) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare r public.kq_rooms;
begin
  r := public.kq_room(p_code);
  if r.id is null then raise exception 'Kode kelas tidak ditemukan'; end if;
  return jsonb_build_object(
    'code', r.code, 'title', r.title, 'is_open', r.is_open,
    'total', (select count(*) from public.vc_submissions where room_id = r.id),
    'arch', coalesce((select jsonb_object_agg(arch, c) from (select arch, count(*) c from public.vc_submissions
       where room_id = r.id group by arch) a), '{}'::jsonb),
    'people', coalesce((select jsonb_agg(jsonb_build_object('id', left(client_id::text, 8), 'name', name, 'arch', arch) order by created_at)
       from public.vc_submissions where room_id = r.id), '[]'::jsonb),
    'updated_at', (select max(updated_at) from public.vc_submissions where room_id = r.id)
  );
end $$;

-- ---------- reset jawaban (butuh token pengajar) ----------
create or replace function public.vc_reset(p_code text, p_token uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare r public.kq_rooms;
begin
  r := public.kq_room(p_code);
  if r.id is null then raise exception 'Kode kelas tidak ditemukan'; end if;
  if r.admin_token is distinct from p_token then raise exception 'Token admin salah'; end if;
  delete from public.vc_submissions where room_id = r.id;
  return jsonb_build_object('ok', true);
end $$;

revoke execute on function public.vc_submit(text,uuid,text,text,jsonb), public.vc_results(text), public.vc_reset(text,uuid) from public;
grant execute on function public.vc_submit(text,uuid,text,text,jsonb), public.vc_results(text), public.vc_reset(text,uuid) to anon, authenticated;
