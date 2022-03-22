hostName = "localhost"
serverPort = 8001

Hooks:PostHook(HUDTeammate, "init", "init_health_as_number_standalone", function(self, ...)
    local http = require("http")
    response, err = http.request("POST", "http://localhost:8001", {body = "I have the high ground"})
end)
