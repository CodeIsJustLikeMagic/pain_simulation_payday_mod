
Hooks:PostHook(HUDTeammate, "init", "init_health_as_number_standalone", function(self, ...)
    log("hello there")
    dohttpreq("http://localhost:8001/ihavethehighground", function(data)
        log("answer "+data)
    end)
end)
