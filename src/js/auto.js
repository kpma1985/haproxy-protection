if (!window._basedflareAuto) {

	class BasedFlareAuto {

		constructor(cookieMinLife=600, maxFails=3) {
			this.finished = false;
			this.workers = [];
			this.fails = 0;
			this.cookieMinLife = cookieMinLife;
			this.maxFails = maxFails;
			this.timeout = null;
			this.scriptSrc = "/.basedflare/js/argon2.min.js";
			this.checkCookie();
		}

		checkCookie = () => {
			console.log('checkCookie');
			const powCookie = document.cookie
				.split("; ")
				.find((row) => row.startsWith("_basedflare_pow="));
			if (powCookie) {
				const powCookieValue = powCookie.split("=")[1];
				const expiry = powCookieValue.split("#")[2];
				const remainingSecs = ((expiry*1000) - Date.now()) / 1000;
				console.log('Basedflare cookie valid for', remainingSecs, 'seconds');
				if (remainingSecs <= this.cookieMinLife) {
					return this.doBotCheck();
				}
				this.timeout = setTimeout(this.checkCookie, Math.max(5000, Math.floor(((remainingSecs-this.cookieMinLife+(Math.random()*300))*1000))));
			}
		};

		includeScript = (scriptSrc) => {
			console.log('includeScript')
			return new Promise((res) => {
				const script = document.createElement("script");
				script.onload = () => res();
				script.src = scriptSrc;
				document.head.appendChild(script);
			});
		};

		messageHandler = (e, json) => {
			console.log('messageHandler')
			if (e.data.length === 1) { return; }
			if (this.finished) { return; }
			this.workers.forEach((w) => w.terminate());
			this.finished = true;
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
					this.fails++;
					console.error("basedflare post status >= 400", res);
				}
			}).catch((e) => {
				console.error(e);
			}).finally(() => {
				localStorage.removeItem('_basedflare-auto');
			});
		};

		checkRunning = () => {
			console.log('checkRunning')
			const lastCheckTime = localStorage.getItem('_basedflare-auto');
			if (lastCheckTime) {
				const lastCheckInt = parseInt(lastCheckTime);
				if (Date.now() - lastCheckInt < 120)  {
					console.log('Already running recently')
					return true;
				} //else its too old, we just continue
			}
		};

		doProofOfWork = async (json) => {
			console.log('doProofOfWork')
			this.workers = [];
			this.finished = false;
			const [ userkey, challenge, _expiry, _signature ] = json.ch.split("#");
			const [ mode, diff, argon_time, argon_kb ] = json.pow.split("#");
			if (mode === "argon2") {
				if (!window.argon2) {
					await this.includeScript(this.scriptSrc);
				}
			}
			const diffString = "0".repeat(diff);
			const cpuThreads = window.navigator.hardwareConcurrency;
			const isTor = location.hostname.endsWith(".onion");
			const workerThreads = (isTor || cpuThreads === 2) ? cpuThreads : Math.max(Math.ceil(cpuThreads / 2), cpuThreads - 1);
			for (let i = 0; i < workerThreads; i++) {
				const powWorker = new Worker("/.basedflare/js/worker.min.js");
				powWorker.onmessage = (e) => this.messageHandler(e, json);
				this.workers.push(powWorker);
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
						type: window.argon2 ? window.argon2.ArgonType.Argon2id : null,
						mode: mode,
					},
					i,
					workerThreads,
				]);
			}
		};

		doBotCheck = async () => {
			console.log('doBotCheck')
			if (this.checkRunning()) { return; }
			localStorage.setItem('_basedflare-auto', Date.now());
			try {
				const json = await fetch("/.basedflare/bot-check", {
						headers: {
							"accept": "application/json"
						}
					})
					.then(res => res.json());
				if (!json || !json.ch) {
					return;
				}
				console.log('Basedflare challenge successfully fetched', json);
				if (json.ca) {
					// TODO: doCaptchaPopup();
					console.warn('Basedflare auto captcha not yet supported');
				} else {
					await this.doProofOfWork(json);
				}
			} catch(e) {
				console.error(e);
				this.fails++;
			} finally {
				if (this.fails < this.maxFails) {
					this.timeout = setTimeout(this.checkCookie, 30000);
				}
			}
		};

	}

	window._basedflareAuto = new BasedFlareAuto();

}
