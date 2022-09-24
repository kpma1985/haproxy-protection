function finishRedirect() {
	window.location=location.search.slice(1)+location.hash || "/";
}

function postResponse(powResponse, captchaResponse) {
	const body = {
		'pow_response': powResponse,
	};
	if (captchaResponse) {
		body['h-captcha-response'] = captchaResponse;
		body['g-recaptcha-response'] = captchaResponse;
	}
	fetch('/bot-check', {
		method: 'POST',
		headers: {
		  'Content-Type': 'application/x-www-form-urlencoded',
		},
		body: new URLSearchParams(body),
		redirect: 'manual',
	}).then(res => {
		finishRedirect();
	})
}

const powFinished = new Promise((resolve, reject) => {
	window.addEventListener('DOMContentLoaded', async () => {
		const { time, kb, pow, diff } = document.querySelector('[data-pow]').dataset;
		const argonOpts = {
			time: time,
			mem: kb,
			hashLen: 32,
			parallelism: 1,
			type: argon2.ArgonType.Argon2id,
		};
		console.log('Got pow', pow, 'with difficulty', diff);
		const diffString = '0'.repeat(diff);
		const combined = pow;
		const [userkey, challenge, signature] = combined.split("#");
		const start = Date.now();
		if (window.Worker) {
			const threads = Math.min(8,Math.ceil(window.navigator.hardwareConcurrency/2));
			let finished = false;
			const messageHandler = (e) => {
				if (finished) { return; }
				finished = true;
				workers.forEach(w => w.terminate());
				const [workerId, answer] = e.data;
				console.log('Worker', workerId, 'returned answer', answer, 'in', Date.now()-start+'ms');
				const dummyTime = 5000 - (Date.now()-start);
				window.setTimeout(() => {
					resolve(`${combined}#${answer}`);
				}, dummyTime);
			}
			const workers = [];
			for (let i = 0; i < threads; i++) {
				const argonWorker = new Worker('/js/worker.js');
				argonWorker.onmessage = messageHandler;
				workers.push(argonWorker);
			}
			workers.forEach(async (w, i) => {
				await new Promise(res => setTimeout(res, 100));
				w.postMessage([userkey, challenge, diffString, argonOpts, i, threads]);
			});
		} else {
			console.warn('No webworker support, running in main/UI thread!');
			let i = 0;
			let start = Date.now();
			while(true) {
				const hash = await argon2.hash({
					pass: challenge + i.toString(),
					salt: userkey,
					...argonOpts,
				});
				if (hash.hashHex.startsWith(diffString)) {
					console.log('Main thread found solution:', hash.hashHex, 'in', (Date.now()-start)+'ms');
					break;
				}
				++i;
			}
			const dummyTime = 5000 - (Date.now()-start);
			window.setTimeout(() => {
				resolve(`${combined}#${i}`);
			}, dummyTime);
		}
	});
}).then((powResponse) => {
	const hasCaptchaForm = document.getElementById('captcha');
	if (!hasCaptchaForm) {
		postResponse(powResponse);
	}
	return powResponse;
});

function onCaptchaSubmit(captchaResponse) {
	const captchaElem = document.querySelector('[data-sitekey]');
	captchaElem.insertAdjacentHTML('afterend', `<div class="lds-ring"><div></div><div></div><div></div><div></div></div>`);
	captchaElem.remove();
	powFinished.then((powResponse) => {
		postResponse(powResponse, captchaResponse);
	});
}

