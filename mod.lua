
Hooks:PostHook(HUDTeammate, "init", "init_health_as_number_standalone", function(self, ...)
    local host, port = "127.0.0.1", 8001
    local socket = require("socket")
    local tcp = assert(socket.tcp())
    tcp:connect(host,port);
    tcp:send("I have the high ground")
    tcp:close()
end)
