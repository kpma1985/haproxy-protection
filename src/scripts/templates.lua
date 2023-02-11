local _M = {}

-- main page template
_M.body = [[
<!DOCTYPE html>
<html>
	<head>
		<meta name='viewport' content='width=device-width initial-scale=1'>
		<title>Hold on...</title>
		<style>
			:root{--text-color:#c5c8c6;--bg-color:#1d1f21}
			@media (prefers-color-scheme:light){:root{--text-color:#333;--bg-color:#EEE}}
			.h-captcha,.g-recaptcha{min-height:85px;display:block}
			.red{color:red;font-weight:bold}
			.powstatus{color:green;font-weight:bold}
			a,a:visited{color:var(--text-color)}
			body,html{height:100%%}
			body{display:flex;flex-direction:column;background-color:var(--bg-color);color:var(--text-color);font-family:Helvetica,Arial,sans-serif;max-width:1200px;margin:0 auto;padding: 0 20px}
			details{transition: border-left-color 0.5s;max-width:1200px;text-align:left;border-left: 2px solid var(--text-color);padding:10px}
			code{background-color:#dfdfdf30;border-radius:3px;padding:0 3px;}
			img,h3,p{margin:0 0 5px 0}
			footer{font-size:x-small;margin-top:auto;margin-bottom:20px;text-align:center}
			img{display:inline}
			.pt{padding-top:15vh;display:flex;align-items:center;word-break:break-all}
			.pt img{margin-right:10px}
			details[open]{border-left-color: #1400ff}
			.lds-ring{display:inline-block;position:relative;width:80px;height:80px}.lds-ring div{box-sizing:border-box;display:block;position:absolute;width:32px;height:32px;margin:10px;border:5px solid var(--text-color);border-radius:50%%;animation:lds-ring 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;border-color:var(--text-color) transparent transparent transparent}.lds-ring div:nth-child(1){animation-delay:-0.45s}.lds-ring div:nth-child(2){animation-delay:-0.3s}.lds-ring div:nth-child(3){animation-delay:-0.15s}@keyframes lds-ring{0%%{transform:rotate(0deg)}100%%{transform:rotate(360deg)}}
		</style>
		<noscript>
			<style>.jsonly{display:none}</style>
		</noscript>
		<script src="/.basedflare/js/argon2.js"></script>
		<script src="/.basedflare/js/challenge.js"></script>
	</head>
	<body data-pow="%s" data-diff="%s" data-time="%s" data-kb="%s">
		%s
		%s
		%s
		<noscript>
			<br>
			<p class="red">JavaScript is required on this page.</p>
			%s
		</noscript>
		<div class="powstatus"></div>
		<footer>
			<p>Security and Performance by <a href="https://gitgud.io/fatchan/haproxy-protection/">haproxy-protection</a></p>
			<p>Node: <code>%s</code></p>
		</footer>
	</body>
</html>
]]

_M.noscript_extra = [[
			<details>
				<summary>No JavaScript?</summary>
				<ol>
					<li>
						<p>Run this in a linux terminal (requires <code>argon2</code> package installed):</p>
						<code style="word-break: break-all;">
							echo "Q0g9IiQyIjtCPSQocHJpbnRmICcwJS4wcycgJChzZXEgMSAkNCkpO2VjaG8gIldvcmtpbmcuLi4iO0k9MDt3aGlsZSB0cnVlOyBkbyBIPSQoZWNobyAtbiAkQ0gkSSB8IGFyZ29uMiAkMSAtaWQgLXQgJDUgLWsgJDYgLXAgMSAtbCAzMiAtcik7RT0ke0g6MDokNH07W1sgJEUgPT0gJEIgXV0gJiYgZWNobyAiT3V0cHV0OiIgJiYgZWNobyAkMSMkMiMkMyMkSSAmJiBleGl0IDA7KChJKyspKTtkb25lOwo=" | base64 -d | bash -s %s %s %s %s %s %s
						</code>
					<li>Paste the script output into the box and submit:
					<form method="post">
						<textarea name="pow_response" placeholder="script output" required></textarea>
						<div><input type="submit" value="submit" /></div>
					</form>
				</ol>
			</details>
]]

-- title with favicon and hostname
_M.site_name_section = [[
		<h3 class="pt">
			<img src="/favicon.ico" width="32" height="32" alt="icon">
			%s
		</h3>
]]

-- spinner animation for proof of work
_M.pow_section = [[
		<h3>
			Checking your browser for robots 🤖
		</h3>
		<div class="jsonly">
			<div class="lds-ring"><div></div><div></div><div></div><div></div></div>
		</div>
]]

-- message, captcha form and submit button
_M.captcha_section = [[
		<h3>
			Please solve the captcha to continue.
		</h3>
		<div id="captcha" class="jsonly">
			<div class="%s" data-sitekey="%s" data-callback="onCaptchaSubmit"></div>
			<script src="%s" async defer></script>
		</div>
]]

return _M
