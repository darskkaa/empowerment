exports.handler = async function(event, context) {
  // Return the environment variables from Netlify
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      SUPABASE_URL: process.env.SUPABASE_URL,
      ANON_KEY: process.env.ANON_KEY
    })
  };
};
