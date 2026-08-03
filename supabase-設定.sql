-- ============================================================
-- 會計系統雲端空間設定（在 Supabase 專案 nvnrkzveyehcnlaszzin 的
-- SQL Editor 貼上執行；跑之前把下面的「會計Email」換成真的信箱）
-- 只新增一個獨立的 accounting 空間，完全不動跟讀平台的任何東西。
-- ============================================================

-- 1. 建立私人儲存空間 accounting
insert into storage.buckets (id, name, public)
values ('accounting', 'accounting', false)
on conflict (id) do nothing;

-- 2. 只允許 Vicky 和會計人員讀寫這個空間
--    ★ 把 'accountant@example.com' 換成會計人員的 Email（要跟她登入帳號一致）
create policy "accounting_read" on storage.objects
  for select to authenticated
  using (bucket_id = 'accounting'
    and auth.email() in ('vickychien127@gmail.com', 'accountant@example.com'));

create policy "accounting_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'accounting'
    and auth.email() in ('vickychien127@gmail.com', 'accountant@example.com'));

create policy "accounting_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'accounting'
    and auth.email() in ('vickychien127@gmail.com', 'accountant@example.com'));

create policy "accounting_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'accounting'
    and auth.email() in ('vickychien127@gmail.com', 'accountant@example.com'));

-- ============================================================
-- 之後要換會計人員：把上面四條 policy 刪掉重建（換 Email 即可），
-- 或叫 Claude 產生新的 SQL。
-- ============================================================
