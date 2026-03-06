require("dotenv").config()
const express = require("express")
const axios = require("axios")
const cors = require("cors")

const app = express()
app.use(cors())
app.use(express.json())

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

app.listen(3000, () => {
    console.log("Auth server running on port 3000")
})