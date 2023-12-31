async function nativeHash(data, method) {
	const buffer = new TextEncoder('utf-8').encode(data);
	const hashBuffer = await crypto.subtle.digest(method, buffer)
	const hashArray = Array.from(new Uint8Array(hashBuffer));
	return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

onmessage = async function(e) {
	const [userkey, challenge, diff, diffString, powOpts, id, threads] = e.data;
	if (powOpts.mode === "argon2") {
		importScripts('/.basedflare/js/argon2.min.js');
	}
	console.log('Worker thread', id, 'started');
	let i = id;
	if (id === 0) {
		setInterval(() => {
			postMessage([i]);
		}, 500);
	}
	while(true) {
		let hash;
		if (powOpts.mode === "argon2") {
			const argonHash = await argon2.hash({
				pass: challenge + i.toString(),
				salt: userkey,
				...powOpts,
			});
			hash = argonHash.hashHex;
		} else {
			hash = await nativeHash(userkey + challenge + i.toString(), 'sha-256');
		}
		// This throttle seems to really help some browsers not stop the workers abruptly
		i % 10 === 0 && await new Promise(res => setTimeout(res, 10));
		if (hash.toString().startsWith(diffString)
			&& ((parseInt(hash[diffString.length],16) &
				0xff >> (((diffString.length+1)*8)-diff)) === 0)) {
			console.log('Worker', id, 'found solution');
			postMessage([id, i]);
			break;
		}
		i+=threads;
	}
}
