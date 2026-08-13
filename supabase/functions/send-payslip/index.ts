// 薪資單寄送後台：只有會計系統的授權帳號能呼叫，透過 Resend 從自家網域寄出
const ALLOWED = [
  'vickychien127@gmail.com',
  'pas.pagamo@gmail.com',
  'a-chuen@yahoo.com.tw',
  'betty29205313@gmail.com',
];
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  const json = (obj: unknown, status = 200) =>
    new Response(JSON.stringify(obj), { status, headers: { ...CORS, 'Content-Type': 'application/json' } });
  try {
    const auth = req.headers.get('Authorization') ?? '';
    const uRes = await fetch(`${Deno.env.get('SUPABASE_URL')}/auth/v1/user`, {
      headers: { Authorization: auth, apikey: Deno.env.get('SUPABASE_ANON_KEY') ?? '' },
    });
    const user = await uRes.json().catch(() => ({}));
    const email = String(user?.email ?? '').toLowerCase();
    if (!uRes.ok || !ALLOWED.includes(email)) return json({ error: '沒有寄信權限，請用會計系統的帳號登入' }, 403);

    const { mails } = await req.json();
    if (!Array.isArray(mails) || !mails.length) return json({ error: '沒有要寄的信' }, 400);
    if (mails.length > 60) return json({ error: '一次最多 60 封' }, 400);
    for (const m of mails) {
      if (!m?.to || !m?.subject || !m?.html) return json({ error: '每封信都要有 to、subject、html' }, 400);
    }

    const key = Deno.env.get('RESEND_API_KEY');
    if (!key) return json({ error: '後台還沒設定 RESEND_API_KEY' }, 500);
    const from = Deno.env.get('MAIL_FROM') ?? '家功場放學趣 <payroll@our-reading-space.com>';
    const rRes = await fetch('https://api.resend.com/emails/batch', {
      method: 'POST',
      headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(mails.map((m: { to: string; subject: string; html: string }) => ({
        from, to: [m.to], subject: m.subject, html: m.html,
      }))),
    });
    const rData = await rRes.json().catch(() => ({}));
    if (!rRes.ok) return json({ error: `Resend 回報錯誤：${rData?.message ?? rRes.status}` }, 502);
    return json({ ok: true, sent: mails.length, by: email });
  } catch (e) {
    return json({ error: String((e as Error)?.message ?? e) }, 500);
  }
});
