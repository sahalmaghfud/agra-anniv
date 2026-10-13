create table if not exists public.pesan_anggun (
  id uuid primary key default gen_random_uuid(),
  pesan text not null check (char_length(btrim(pesan)) between 1 and 2000),
  created_at timestamptz not null default now()
);

alter table public.pesan_anggun enable row level security;

with latest_message as (
  select pesan
  from public.pesan_anggun
  order by created_at desc
  limit 1
)
insert into public.pesan_anggun (id, pesan)
select '00000000-0000-4000-8000-000000000001'::uuid, pesan
from latest_message
on conflict (id) do update
set pesan = excluded.pesan,
    created_at = now();

delete from public.pesan_anggun
where id <> '00000000-0000-4000-8000-000000000001'::uuid;

revoke all on table public.pesan_anggun from anon, authenticated;
revoke select (pesan, created_at), insert (pesan)
  on table public.pesan_anggun
  from anon, authenticated;
grant select (id, pesan, created_at) on table public.pesan_anggun to anon;
grant insert (id, pesan) on table public.pesan_anggun to anon;
grant update (id, pesan, created_at) on table public.pesan_anggun to anon;

drop policy if exists "Public can read Anggun messages"
  on public.pesan_anggun;
create policy "Public can read Anggun messages"
  on public.pesan_anggun
  for select
  to anon
  using (true);

drop policy if exists "Public can add Anggun messages"
  on public.pesan_anggun;
create policy "Public can add Anggun messages"
  on public.pesan_anggun
  for insert
  to anon
  with check (
    id = '00000000-0000-4000-8000-000000000001'::uuid
    and char_length(btrim(pesan)) between 1 and 2000
  );

drop policy if exists "Public can replace Anggun message"
  on public.pesan_anggun;
create policy "Public can replace Anggun message"
  on public.pesan_anggun
  for update
  to anon
  using (id = '00000000-0000-4000-8000-000000000001'::uuid)
  with check (
    id = '00000000-0000-4000-8000-000000000001'::uuid
    and char_length(btrim(pesan)) between 1 and 2000
  );
