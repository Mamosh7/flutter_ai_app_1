const functions = require("firebase-functions");
const {OpenAI} = require("openai");
const cors = require("cors")({origin: true});

// Initialize the OpenAI API client with your API key
const openai = new OpenAI({
  apiKey: functions.config().openai.key,
  // Ensure this key is set in the Firebase config
});

exports.chat = functions.https.onRequest((request, response) => {
  cors(request, response, async () => {
    try {
      if (request.method !== "POST") {
        return response.status(405).send("Method Not Allowed");
      }

      // Ensure the header is application/json
      if (request.get("Content-Type") !== "application/json") {
        return response.status(400).send("Bad Req: Expected application/json");
      }

      const {prompt} = request.body;
      if (!prompt) {
        return response.status(400).send("Bad Req: Misin 'prompt' in req body");
      }

      // Send the prompt to OpenAI's API
      const gptResponse = await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        // Change to the model you're subscribed to if different
        prompt: prompt,
        max_tokens: 150,
      });

      // Log the full OpenAI response for debugging
      console.log(JSON.stringify(gptResponse.data, null, 2));

      // Respond with the text completion
      response.json({
        response: gptResponse.data.choices[0].text.trim(),
      });
    } catch (error) {
      // Enhanced error logging
      console.error("Error details:", error);
      response.status(500).send("Internal Server Error: " + error.message);
    }
  });
});
