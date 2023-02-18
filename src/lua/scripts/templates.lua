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
			.left{text-align:left}
			.powstatus{color:green;font-size:small;}
			a,a:visited{color:var(--text-color)}
			body,html{height:100%%;text-align:center;}
			body{display:flex;flex-direction:column;background-color:var(--bg-color);color:var(--text-color);font-family:Helvetica,Arial,sans-serif;max-width:60em;margin:0 auto;padding: 0 20px}
			details{transition: border-left-color 0.5s;max-width:1200px;text-align:left;border-left: 2px solid var(--text-color);padding:10px}
			code{background-color:#dfdfdf30;border-radius:4px;padding:0 3px;color:#ff6590}
			img,h3{margin:0 0 5px 0}
			li{margin-bottom: 1em}
			footer{font-size:x-small;margin-top:auto;padding:10px;text-align:center;border-top:1px solid #80808040;padding:10px}
			img{display:inline}
			textarea,input{background:var(--bg-color);color:var(--text-color);border:1px solid var(--text-color);width:100%%;box-sizing: border-box;resize:none;padding:0.5em;font-family:inherit}
			.pt{padding-top:30vh;display:flex;align-items:center;word-break:break-all;justify-content: center;}
			.pt img{margin-right:10px}
			details[open]{border-left-color: #1400ff}			
			.b{display:inline-block;background:#6b93f7;border-radius:50%%;margin:10px;height:16px;width:16px;box-shadow:0 0 0 0 #6b93f720;transform:scale(1)}
			.b:nth-of-type(1){animation:p 3s infinite}
			.b:nth-of-type(2){animation:p 3s .5s infinite}
			.b:nth-of-type(3){animation:p 3s 1s infinite}
			@keyframes p{0%%{transform:scale(.95);box-shadow:0 0 0 0 #6b93f790}70%%{transform:scale(1);box-shadow:0 0 0 10px #6b93f700}100%%{transform:scale(.95);box-shadow:0 0 0 0 #6b93f700}}
		</style>
		<noscript>
			<style>.jsonly{display:none}</style>
		</noscript>
		<script src="/.basedflare/js/argon2.js"></script>
		<script src="/.basedflare/js/challenge.js"></script>
	</head>
	<body data-pow="%s" data-diff="%s" data-time="%s" data-kb="%s" data-mode="%s">
		%s
		%s
		%s
		<noscript>
			<br>
			<p class="red left">JavaScript is required on this page.</p>
			%s
		</noscript>
		<div class="powstatus"></div>
		<footer>
			<p>Node: <code>%s</code></p>
			<p>Performance & security by <a href="https://gitgud.io/fatchan/haproxy-protection/">haproxy-protection</a></p>
		</footer>
	</body>
</html>
]]

_M.noscript_extra_argon2 = [[
			<details>
				<summary>No JavaScript?</summary>
				<ol>
					<li>
						<p>Run this in a linux terminal (requires <code>argon2</code> package installed):</p>
						<code style="word-break: break-all;">
							echo "Q0g9IiQyIjtCPSQocHJpbnRmIDAlLjBzICQoc2VxIDEgJDUpKTtlY2hvICJXb3JraW5nLi4uIjtJPTA7d2hpbGUgdHJ1ZTsgZG8gSD0kKGVjaG8gLW4gJENIJEkgfCBhcmdvbjIgJDEgLWlkIC10ICQ2IC1rICQ3IC1wIDEgLWwgMzIgLXIpO0U9JHtIOjA6JDV9O1tbICRFID09ICRCIF1dICYmIGVjaG8gIk91dHB1dDoiICYmIGVjaG8gJDEjJDIjJDMjJDQjJEkgJiYgZXhpdCAwOygoSSsrKSk7ZG9uZTsK" | base64 -d | bash -s %s %s %s %s %s %s %s
						</code>
					<li>Paste the script output into the box and submit:
					<form method="post">
						<textarea name="pow_response" placeholder="script output" required></textarea>
						<div><input type="submit" value="submit" /></div>
					</form>
				</ol>
			</details>
]]

_M.noscript_extra_sha256 = [[
			<details>
				<summary>No JavaScript?</summary>
				<ol>
					<li>
						<p>Run this in a linux terminal (requires <code>perl</code>):</p>
						<code style="word-break: break-all;">
							echo "dXNlIHN0cmljdDt1c2UgRGlnZXN0OjpTSEEgcXcoc2hhMjU2X2hleCk7cHJpbnQgIldvcmtpbmcuLi4iO215JGM9IiRBUkdWWzBdIi4iJEFSR1ZbMV0iO215JGlkPSRBUkdWWzRdKzA7bXkkZD0iMCJ4JGlkO215JGk9MDt3aGlsZSgxKXtsYXN0IGlmICRkIGVxIHN1YnN0ciBzaGEyNTZfaGV4KCRjLCRpKSwwLCRpZDskaSsrfXByaW50IlxuT3V0cHV0OlxuJEFSR1ZbMF0jJEFSR1ZbMV0jJEFSR1ZbMl0jJEFSR1ZbM10jJGlcbiI=" | base64 -d | perl -w - %s %s %s %s %s %s %s
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
			<img src="/favicon.ico" width="32" height="32" alt=" ">
			%s
		</h3>
]]

-- animation while waiting
_M.pow_section = [[
		<h3>
			Checking your browser for robots 🤖
		</h3>
		<div class="jsonly">
			<div id="loader"><div class="b"></div><div class="b"></div><div class="b"></div></div>
		</div>
]]
-- alternative, spinner animation
-- .loader{display:inline-block;position:relative;width:80px;height:80px}
-- .loader div{box-sizing:border-box;display:block;position:absolute;width:32px;height:32px;margin:10px;border:5px solid var(--text-color);border-radius:50%%;animation:loader 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;border-color:var(--text-color) transparent transparent transparent}
-- .loader div:nth-child(1){animation-delay:-0.45s}
-- .loader div:nth-child(2){animation-delay:-0.3s}
-- .loader div:nth-child(3){animation-delay:-0.15s}
-- @keyframes loader{0%%{transform:rotate(0deg)}100%%{transform:rotate(360deg)}}
-- <div class="jsonly">
-- <div class="loader"><div></div><div></div><div></div><div></div></div>
-- </div>

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
