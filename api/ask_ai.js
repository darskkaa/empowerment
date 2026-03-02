// Vercel serverless: AI chat for Emp Farm dashboard (OpenRouter).

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ error: { message: "Method Not Allowed" } });
  }

  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    return res.status(500).json({
      error: { message: "Server Setup Error: Missing OpenRouter API Key" },
    });
  }

  try {
    const { messages, context: dataContext } = req.body || {};

    const systemPrompt = `You are a helpful data analyst for Emp Farm.
Your goal is to answer questions based on the SURVEY DATA provided below.

DATA CONTEXT:
${JSON.stringify(dataContext || {})}

GUIDELINES:
- **TRUTHFULNESS IS PARAMOUNT.** Only answer based on the provided data.
- **Handling 100% Claims:** If a metric is 100%, DO NOT state it as a general fact. Instead, say "According to the [X] responses in this survey..." or "100% of the respondents so far...". This builds trust.
- **Privacy:** Never ask for or mention real names. The data provided to you is anonymized.
- **Donations:** Note that donation interest is only collected from adults (18+).
- **Tone:** Be concise, friendly, and use emojis (🌻, 🐐, ✨).
- If the data doesn't answer the question, explicitly say "I don't have that information in the dataset."`;

    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://empfarm.vercel.app",
        "X-Title": "Emp Farm Dashboard",
      },
      body: JSON.stringify({
        model: "arcee-ai/trinity-large-preview:free",
        provider: { data_collection: "deny" },
        messages: [{ role: "system", content: systemPrompt }, ...(messages || [])],
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`OpenRouter API Error: ${err}`);
    }

    const data = await response.json();
    res.setHeader("Content-Type", "application/json");
    return res.status(200).json(data);
  } catch (error) {
    console.error("Function Error:", error);
    return res.status(500).json({ error: { message: error.message } });
  }
}
