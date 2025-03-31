.pragma library

function callAI(params, timer, mistralApiKey, callback){
    var xhr = new XMLHttpRequest();
    var url = "https://api.mistral.ai/v1/chat/completions"; // Correct endpoint

    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Accept", "application/json");
    xhr.setRequestHeader("Authorization", "Bearer " + mistralApiKey);

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    var commentary = response.choices[0].message.content;
                    console.info("Success! Callback called with: "+ commentary)
                    callback(commentary);
                } catch (e) {
                    console.error("Error parsing response:", e);
                    callback("Error parsing response");
                }
            } else if (xhr.status == 429){
                timer.interval = timer.getRandomizedDelay();
                console.warn(`Rate limited, retrying in ${timer.interval}ms`)
                timer.currentDelay *= 2;
                timer.restart();
            }
            else
            {
                console.error("Failed to fetch AI commentary. Status:", xhr.status);
                console.error("Status text:", xhr.statusText);
                console.error("Response:", xhr.responseText);
                console.info("Response headers:", xhr.getAllResponseHeaders());
                console.info("Authorization: Bearer " + mistralApiKey.substring(0, 4) + "..."); // Log only first 4 chars of API key

                // Try to parse error response if possible
                try {
                    var errorResponse = JSON.parse(xhr.responseText);
                    console.error("Error details:", errorResponse);
                    callback("Error: " + (errorResponse.error?.message || "Unknown error"));
                } catch (e) {
                    callback("Error fetching commentary (Status " + xhr.status + ")");
                }
            }
        }
    };

    xhr.onerror = function(e) {
        console.error("Network error occurred:", e);
        callback("Network error occurred");
    };

    try {
        xhr.send(params);
    } catch (e) {
        console.error("Error sending request:", e);
        // Log the request details
        console.log("Request URL:", url);
        console.log("Authorization: Bearer " + mistralApiKey.substring(0, 4) + "..."); // Log only first 4 chars of API key
        console.log("Request body:", params);
        callback("Error sending request");
    }
    }

function fetchAICommentary(newsData, agentName, agentDescription, timer, mistralApiKey, callback) {
    var modelName = "mistral-tiny"; // or "mistral-small", "mistral-medium" depending on your needs
    var agentStr = `You are a ${agentName}: ${agentDescription}`
    console.log("Agetn: " + agentStr)
    var contentStr = `Provide a tweet on this:\nTitle:${newsData.title}\ndescription:${newsData.description}\ncontent:${newsData.content}`
    console.log("Message: " + contentStr)
    var messages = [
                {
                    role: "system",
                    content: agentStr
                },
                {
                    role: "user",
                    content: contentStr
                }
            ];
    var params = JSON.stringify({
        model: modelName,
        messages: messages,
        temperature: 0.7, // You can adjust this parameter
        max_tokens: 100
    });
    timer.currentParams = params;
    timer.currentCallback = callback;
    callAI(params, timer, mistralApiKey, callback );
}
