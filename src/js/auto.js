(() => {
	const doBotCheck = async () => {
		try {
			const json = await fetch("/.basedflare/bot-check", { headers: { "accept": "application/json" }})
				.then(res => res.json());
			if (json && json.ch) {
				if (json.ca) {
					// TODO: captcha popup
				} else {
					const [ userkey, challenge, _expiry, _signature ] = json.ch.split("#");
					const [ mode, diff, argon_time, argon_kb ] = json.pow.split("#");
					if (mode === "argon2") {
						if (!argon2) {
							await new Promise((res) => {
								const script = document.createElement("script");
								script.onload = () => res();
								script.src = something;
								document.head.appendChild(script);
							})
						}
					}
					console.log(json)
					const diffString = "0".repeat(diff);
					const cpuThreads = window.navigator.hardwareConcurrency;
					const isTor = location.hostname.endsWith(".onion");
					const workerThreads = (isTor || cpuThreads === 2) ? cpuThreads : Math.max(Math.ceil(cpuThreads / 2), cpuThreads - 1);
					const workers = [];
					let finished = false;
					const messageHandler = (e) => {
						if (e.data.length === 1) {
							return console.log(e.data[0]);
						}
						if (finished) return;
						finished = true;
						workers.forEach((w) => w.terminate());
						const [_workerId, answer] = e.data;
						fetch("/.basedflare/bot-check", {
							method: "POST",
							headers: {
								"Content-Type": "application/x-www-form-urlencoded",
							},
							body: new URLSearchParams({
								"pow_response": `${json.ch}#${answer}`,
							}),
							redirect: "manual",
						}).then((res) => {
							if (res.status >= 400) {
								console.error("basedflare post status >= 400", res);
							}
						}).catch((e) => {
							console.error(e)
						});
					};
					for (let i = 0; i < workerThreads; i++) {
						const powWorker = new Worker("/.basedflare/js/worker.min.js");
						powWorker.onmessage = messageHandler;
						workers.push(powWorker);
						powWorker.postMessage([
							userkey,
							challenge,
							diff,
							diffString,
							{
								time: argon_time,
								mem: argon_kb,
								hashLen: 32,
								parallelism: 1,
								type: argon2 ? argon2.ArgonType.Argon2id : null,
								mode: mode,
							},
							i,
							workerThreads,
						]);
					}
				}
			}
		} catch(e) {
			console.error(e);
		}
	};
	const cookieMinLife = 600;
	const checkCookie = () => {
		const powCookie = document.cookie
			.split("; ")
			.find((row) => row.startsWith("_basedflare_pow="));
		if (powCookie) {
			powCookieValue = powCookie.split("=")[1];
			const expiry = powCookieValue.split("#")[2];
			const remainingSecs = ((expiry*1000) - Date.now()) / 1000;
			console.log('Basedflare cookie check, valid for', remainingSecs, 'seconds');
			if (remainingSecs < cookieMinLife) {
				return doBotCheck();
			}
			setTimeout(checkCookie, Math.floor(((remainingSecs-cookieMinLife-(Math.random()*300))*1000)));
		}
	}
	checkCookie();
})();