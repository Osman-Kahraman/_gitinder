require("dotenv").config()
const express = require("express")
const axios = require("axios")
const cors = require("cors")

const app = express()
app.use(cors())
app.use(express.json())

const supportedLanguages = [
    "Swift", "Python", "JavaScript", "TypeScript", "Go", "Rust", "C++", "C",
    "C#", "Java", "Kotlin", "Dart", "PHP", "Ruby", "Elixir",
    "Scala", "Haskell", "Lua", "Shell", "PowerShell",
    "Objective-C", "Groovy", "Assembly", "R", "MATLAB"
]

const starLimits = [10, 50, 100, 500, 1000, 5000]
const recentlyUpdatedOptions = [0, 1, 7, 30]

app.post("/oauth/exchange", async (req, res) => {
    const { code } = req.body

    try {
        const response = await axios.post(
            "https://github.com/login/oauth/access_token",
            {
                client_id: process.env.CLIENT_ID,
                client_secret: process.env.CLIENT_SECRET,
                code: code
            },
            {
                headers: { Accept: "application/json" }
            }
        )

        res.json(response.data)
    } catch (error) {
        res.status(500).json({ error: "Token exchange failed" })
    }
})

app.post("/ai/preferences", async (req, res) => {
    const { description, currentPreferences } = req.body
    const trimmedDescription = typeof description === "string" ? description.trim() : ""

    if (!trimmedDescription) {
        return res.status(400).json({ error: "Description is required" })
    }

    if (!process.env.OPENAI_API_KEY) {
        return res.status(500).json({ error: "OpenAI API key is not configured" })
    }

    try {
        const response = await axios.post(
            "https://api.openai.com/v1/responses",
            {
                model: process.env.OPENAI_MODEL || "gpt-4.1-mini",
                input: [
                    {
                        role: "system",
                        content: [
                            "Convert a natural-language repository discovery request into _gitinder preferences.",
                            "Return practical GitHub search keywords, not a sentence.",
                            "Use only supported languages when selecting languages.",
                            "Prefer small/medium discovery-friendly repos unless the user asks otherwise.",
                            "The starLimit means GitHub search uses stars:<starLimit."
                        ].join(" ")
                    },
                    {
                        role: "user",
                        content: JSON.stringify({
                            description: trimmedDescription,
                            currentPreferences,
                            supportedLanguages,
                            allowedStarLimits: starLimits,
                            allowedRecentlyUpdatedDays: recentlyUpdatedOptions
                        })
                    }
                ],
                text: {
                    format: {
                        type: "json_schema",
                        name: "repo_preferences",
                        strict: true,
                        schema: {
                            type: "object",
                            additionalProperties: false,
                            properties: {
                                selectedLanguages: {
                                    type: "array",
                                    items: { type: "string", enum: supportedLanguages },
                                    maxItems: 5
                                },
                                starLimit: {
                                    type: "integer",
                                    enum: starLimits
                                },
                                recentlyUpdatedDays: {
                                    type: "integer",
                                    enum: recentlyUpdatedOptions
                                },
                                searchQuery: {
                                    type: "string",
                                    description: "Plain GitHub search keywords/topics without language, stars, or pushed qualifiers."
                                },
                                reasoningSummary: {
                                    type: "string",
                                    description: "A short user-facing explanation of the chosen preferences."
                                }
                            },
                            required: [
                                "selectedLanguages",
                                "starLimit",
                                "recentlyUpdatedDays",
                                "searchQuery",
                                "reasoningSummary"
                            ]
                        }
                    }
                }
            },
            {
                headers: {
                    Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
                    "Content-Type": "application/json"
                }
            }
        )

        const outputText = extractOutputText(response.data)
        const preferences = JSON.parse(outputText)

        res.json({
            selectedLanguages: preferences.selectedLanguages.filter(language => supportedLanguages.includes(language)).slice(0, 5),
            starLimit: starLimits.includes(preferences.starLimit) ? preferences.starLimit : 100,
            recentlyUpdatedDays: recentlyUpdatedOptions.includes(preferences.recentlyUpdatedDays) ? preferences.recentlyUpdatedDays : 0,
            searchQuery: cleanSearchQuery(preferences.searchQuery),
            reasoningSummary: preferences.reasoningSummary
        })
    } catch (error) {
        const status = error.response?.status || 500
        const message = error.response?.data?.error?.message || "AI preference generation failed"
        res.status(status).json({ error: message })
    }
})

function extractOutputText(responseData) {
    if (typeof responseData.output_text === "string") {
        return responseData.output_text
    }

    for (const item of responseData.output || []) {
        for (const content of item.content || []) {
            if (typeof content.text === "string") {
                return content.text
            }
        }
    }

    throw new Error("Missing OpenAI output text")
}

function cleanSearchQuery(query) {
    if (typeof query !== "string") {
        return ""
    }

    return query
        .replace(/\blanguage:[^\s]+/gi, "")
        .replace(/\bstars:[^\s]+/gi, "")
        .replace(/\bpushed:[^\s]+/gi, "")
        .replace(/\s+/g, " ")
        .trim()
}

app.listen(3000, () => {
    console.log("Auth server running on port 3000")
})
