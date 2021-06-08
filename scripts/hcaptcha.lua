hcaptcha = {}

local url = require("net.url")
local https = require("ssl.https")
local json = require("json")
local utils = require("utils")
local cookie = require("cookie")
local floating_hash = utils.get_floating_hash()

function hcaptcha.view(applet)
    local hcaptcha_secret = os.getenv("HCAPTCHA_SECRET")
    local hcaptcha_sitekey = os.getenv("HCAPTCHA_SITEKEY")
    local response
    if applet.method == "GET" then
        response =
            [[
        <form method="POST">
        <div class="h-captcha" data-sitekey="%s"></div>
        <script src="https://hcaptcha.com/1/api.js" async defer></script>
        <input type="submit" value="Submit">
        </form>
        ]]
        response = string.format(response, hcaptcha_sitekey)
    elseif applet.method == "POST" then
        local parsed_body = url.parseQuery(applet.receive(applet))

        if parsed_body["h-captcha-response"] then
            local url =
                string.format(
                "https://hcaptcha.com/siteverify?secret=%s&response=%s",
                hcaptcha_secret,
                parsed_body["h-captcha-response"]
            )
            local body, code, headers, status = https.request(url)
            local api_response = json:decode(body)

            if api_response.success == true then
                print("HCAPTCHA SUCCESSFULLY PASSED")
                applet:add_header("set-cookie", string.format("z_ddos_protection=%s; Max-Age=14400; Path=/", floating_hash))
            else
                print("HCAPTCHA FAILED", body)
            end
        end

        response = "Thank you for submitting"
    end

    applet:set_status(200)
    applet:add_header("content-type", "text/html")
    applet:add_header("content-length", string.len(response))
    applet:start_response()
    applet:send(response)
end

function hcaptcha.check_captcha_status(txn)
    print("CAPTCHA STATUS CHECK START")
    local raw_request_cookies = txn.sf:hdr("Cookie")
    local parsed_request_cookies = cookie.get_cookie_table(raw_request_cookies)

    print("RECEIVED SECRET COOKIE: ", parsed_request_cookies["z_ddos_protection"])
    print("OUR SECRET COOKIE: ", floating_hash)

    if parsed_request_cookies["z_ddos_protection"] == floating_hash then
        print("CAPTCHA STATUS CHECK SUCCESS")
        return txn:set_var("txn.captcha_passed", true);
    end

    print("CAPTCHA STATUS CHECK FINISH")
end