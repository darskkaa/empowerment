export const handler = async (event, context) => {
    // 1. Security Check
    if (event.httpMethod !== 'POST') {
        return { statusCode: 405, body: 'Method Not Allowed' };
    }

    const apiKey = process.env.OPENROUTER_API_KEY;
    if (!apiKey) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: { message: "Server Setup Error: Missing OpenRouter API Key" } })
        };
    }

    try {
        const { messages, context: dataContext } = JSON.parse(event.body);

        // 2. Prepare System Prompt with Data
        // We inject the data here, keeping it hidden from the client-side network tab (mostly)
        // although the client sent it, so it's moot. But this keeps the prompt logic central.
        const systemPrompt = `You are a helpful data analyst for Emp Farm.
Your goal is to answer questions based on the SURVEY DATA provided below.

DATA CONTEXT:
${JSON.stringify(dataContext)}

GUIDELINES:
- **TRUTHFULNESS IS PARAMOUNT.** Only answer based on the provided data.
- **Handling 100% Claims:** If a metric is 100%, DO NOT state it as a general fact. Instead, say "According to the [X] responses in this survey..." or "100% of the respondents so far...". This builds trust.
- **Privacy:** Never ask for or mention real names. The data provided to you is anonymized.
- **Donations:** Note that donation interest is only collected from adults (18+).
- **Tone:** Be concise, friendly, and use emojis (🌻, 🐐, ✨).
- If the data doesn't answer the question, explicitly say "I don't have that information in the dataset."`;

        // 3. Call OpenRouter (Buffered, not streaming for simplicity in standard functions)
        // Using the user's requested model: meta-llama/llama-3.3-70b-instruct:free
        const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${apiKey}`,
                "Content-Type": "application/json",
                "HTTP-Referer": "https://empfarm.netlify.app",
                "X-Title": "Emp Farm Dashboard"
            },
            body: JSON.stringify({
                model: "arcee-ai/trinity-large-preview:free",
                provider: {
                    data_collection: "deny"
                },
                messages: [
                    { role: "system", content: systemPrompt },
                    ...messages
                ]
            })
        });

        if (!response.ok) {
            const err = await response.text();
            throw new Error(`OpenRouter API Error: ${err}`);
        }

        const data = await response.json();

        return {
            statusCode: 200,
            body: JSON.stringify(data)
        };

    } catch (error) {
        console.error("Function Error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: { message: error.message } })
        };
    }
};
