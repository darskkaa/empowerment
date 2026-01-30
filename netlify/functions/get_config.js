exports.handler = async function (event, context) {
  // Return the environment variables from Netlify
  // Supports both manual vars (SUPABASE_URL, ANON_KEY) and 
  // Netlify Supabase integration vars (SUPABASE_DATABASE_URL, SUPABASE_ANON_KEY)

  // Get URL - try multiple possible names
  const supabaseUrl = process.env.SUPABASE_URL ||
    process.env.SUPABASE_DATABASE_URL?.replace(/^postgres(ql)?:\/\//, 'https://').split('/')[0] + '.supabase.co' ||
    null;

  // Get anon key - try multiple possible names  
  const anonKey = process.env.ANON_KEY ||
    process.env.SUPABASE_ANON_KEY ||
    process.env.ANON_KEY_SUPABASE_ANON_KEY ||
    null;

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      SUPABASE_URL: supabaseUrl,
      ANON_KEY: anonKey
    })
  };
};
