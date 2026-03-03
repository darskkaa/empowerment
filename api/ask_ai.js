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

    // [DEBUG H3/H5] Request shape (no PII)
    console.log("[H3] ask_ai: hasApiKey=" + !!apiKey);
    console.log("[H5] ask_ai: messagesLength=" + (messages && messages.length) + " contextType=" + (dataContext === null || dataContext === undefined ? "null" : typeof dataContext));

    const systemPrompt = `You are a data analyst for Emp Farm. You answer ONLY from the live survey data below. You never guess, infer, or add information that is not in the data.

DATA (this is the only source of truth):
${JSON.stringify(dataContext || {})}

DATA DICTIONARY (map user questions to these DATA keys before answering):
- Connection scores / "connection and calmness" / "how do connection and calmness scores look?" → averages.connection, averages.nature, averages.calmness; per_program_metrics[program].avg_connection, avg_nature, avg_calmness
- Calmness scores → averages.calmness; per_program_metrics[program].avg_calmness
- Best month / most visits / busiest month → monthly_trends (report the month with the highest count)
- Peak times / busiest times → peak_times (array of strings like "5AM (5 visits)")
- Donation interest / donation pipeline / giving pipeline → donations (total_eligible_18plus, yes, maybe, no; adults 18+ only)
- Program feedback (e.g. yoga, Open Farm) → reviews_by_program[program], per_program_metrics[program]

RULES (strict):
1. **Data only.** Every claim must come from the DATA above. If the data does not contain the answer, say so in one short sentence, then state what the data *does* show that is relevant (e.g. "We have X respondents aged 0–17, but there are no satisfaction or enjoyment metrics broken down by age—only overall averages.").
2. **No hallucination.** Do not invent numbers, segments, or trends. Do not say "likely" or "probably" about things not in the data.
3. **100% and small samples.** For 100% or small N, phrase as "Among the [N] respondents in this dataset..." not as a general fact.
4. **Check mapping first.** Before saying "I don't have that," check the DATA DICTIONARY: if the question (or a close paraphrase) maps to a DATA key, answer from that key and include the actual numbers. Only say "I don't have that in the dataset" when there is no mapping and no relevant field in DATA. When a mapping exists (e.g. "Donation Interest Pipeline" → donations), always report the numbers (e.g. "Among 44 eligible adults (18+), 1 said yes, 23 maybe, 20 no.").
5. **Concise and helpful.** Keep replies short (2–4 sentences unless summarizing). Use emojis sparingly (🌻 ✨). No filler.
6. **Privacy.** Data is anonymized; do not refer to or ask for names.
7. **Donations.** Donation interest is only for adults (18+); demographics may include 0–17 but donation_interest does not apply to them.
8. **Dates.** current_date_iso is today. For "this month" or "how many visits this month" use visits_this_month. monthly_trends keys are "Mon YYYY" (e.g. "Mar 2026"). most_recent_month_in_data and most_recent_month_visits describe the latest month in the dataset.`;

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
      console.log("[H3] ask_ai: OpenRouter not ok status=" + response.status + " body=" + (err && err.slice(0, 200)));
      throw new Error(`OpenRouter API Error: ${err}`);
    }

    const data = await response.json();
    const content = data?.choices?.[0]?.message?.content;
    if (content == null) {
      console.log("[H3] ask_ai: response missing content");
      return res.status(502).json({
        error: { message: "Invalid API response: no content from assistant." },
      });
    }
    console.log("[H3] ask_ai: success");
    res.setHeader("Content-Type", "application/json");
    return res.status(200).json(data);
  } catch (error) {
    console.error("[H3] ask_ai Function Error:", error);
    return res.status(500).json({ error: { message: error.message } });
  }
}
