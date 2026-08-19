-- ============================================================
-- 會計系統雲端空間設定（在 Supabase 專案 nvnrkzveyehcnlaszzin 的
-- SQL Editor 貼上執行；跑之前把下面的「會計Email」換成真的信箱）
-- 只新增一個獨立的 accounting 空間，完全不動跟讀平台的任何東西。
-- ============================================================

-- 1. 建立私人儲存空間 accounting
insert into storage.buckets (id, name, public)
values ('accounting', 'accounting', false)
on conflict (id) do nothing;

-- 2. 允許 Vicky 與會計 a-chuen 讀寫這個空間（2026-08-19 加回 a-chuen）
drop policy if exists "accounting_read" on storage.objects;
drop policy if exists "accounting_select" on storage.objects;
drop policy if exists "accounting_insert" on storage.objects;
drop policy if exists "accounting_update" on storage.objects;
drop policy if exists "accounting_delete" on storage.objects;

create policy "accounting_read" on storage.objects
  for select to authenticated
  using (bucket_id = 'accounting'
    and auth.email() in ('vickychien127@gmail.com', 'a-chuen@yahoo.com.tw'));

create policy "accounting_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'accounting'
    and auth.email() in ('vickychien127@gmail.com', 'a-chuen@yahoo.com.tw'));

create policy "accounting_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'accounting'
    and auth.email() in ('vickychien127@gmail.com', 'a-chuen@yahoo.com.tw'));

create policy "accounting_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'accounting'
    and auth.email() in ('vickychien127@gmail.com', 'a-chuen@yahoo.com.tw'));

-- ============================================================
-- 若未來要增加會計人員，必須由 Vicky 明確決定後再修改四條 policy。
-- ============================================================
