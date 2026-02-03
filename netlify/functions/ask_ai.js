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
        const systemPrompt = `You are a helpful data analyst for Empowerment Farm.
Your goal is to answer questions based on the SURVEY DATA provided below.

DATA CONTEXT:
${JSON.stringify(dataContext)}

GUIDELINES:
- Be concise and friendly.
- Use emojis (🌻, 🐐, ✨).
- Cite specific numbers or quotes when possible.
- If the data doesn't answer the question, say so.`;

        // 3. Call OpenRouter (Buffered, not streaming for simplicity in standard functions)
        // Using the user's requested model: meta-llama/llama-3.3-70b-instruct:free
        const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${apiKey}`,
                "Content-Type": "application/json",
                "HTTP-Referer": "https://empowermentfarm.io", // Placeholder
                "X-Title": "Empowerment Farm Dashboard"
            },
            body: JSON.stringify({
                model: "openrouter/free",
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
