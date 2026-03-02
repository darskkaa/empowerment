// Vercel serverless: returns Supabase config (env vars stay server-side).
// Supports SUPABASE_URL + ANON_KEY or Vercel Supabase integration vars.

export default async function handler(req, res) {
  const supabaseUrl =
    process.env.SUPABASE_URL ||
    (process.env.SUPABASE_DATABASE_URL &&
      process.env.SUPABASE_DATABASE_URL.replace(/^postgres(ql)?:\/\//, "https://").split("/")[0] + ".supabase.co") ||
    null;

  const anonKey =
    process.env.ANON_KEY ||
    process.env.SUPABASE_ANON_KEY ||
    process.env.ANON_KEY_SUPABASE_ANON_KEY ||
    null;

  // Trim to avoid 401 from accidental whitespace in env vars
  const url = typeof supabaseUrl === "string" ? supabaseUrl.trim() : null;
  const key = typeof anonKey === "string" ? anonKey.trim() : null;

  res.setHeader("Content-Type", "application/json");
  res.status(200).json({
    SUPABASE_URL: url,
    ANON_KEY: key,
  });
}
