import * as D from "./src/declarations/main/main.did.js";

import {
	Actor,
	ActorConfig,
	HttpAgent,
	HttpAgentOptions,
	type ActorSubclass,
	type Agent,
	type Identity,
} from "@dfinity/agent";
import { IDL } from "@dfinity/candid";
import { Secp256k1KeyIdentity } from "@dfinity/identity-secp256k1";
import { Principal } from "@dfinity/principal";
import { execSync } from "child_process";
import { readFileSync } from "fs";
import path from "path";
import pemfile from "pem-file";

declare interface CreateActorOptions {
	agent?: Agent;
	agentOptions?: HttpAgentOptions;
	actorOptions?: ActorConfig;
}

const agent = (identity?: Identity): Agent => {
	const dfxPort = execSync("dfx info replica-port", { encoding: "utf-8" });

	const a = new HttpAgent({
		identity,
		host: `http://127.0.0.1:${dfxPort}`,
		fetch,
	});
	a.fetchRootKey();

	return a;
};

function createActor<T>(
	canisterId: string | Principal,
	idlFactory: IDL.InterfaceFactory,
	options: CreateActorOptions = {}
): ActorSubclass<T> {
	const agent = options.agent || new HttpAgent({ ...options.agentOptions });

	return Actor.createActor(idlFactory, {
		agent,
		canisterId,
		...options.actorOptions,
	});
}

const deriveCurrentIdentity = (): Identity => {
	const agentName = execSync("dfx identity whoami").toString().trim();

	const pem = execSync(`dfx identity export ${agentName}`).toString().trim();
	const buf: Buffer = pemfile.decode(pem);

	if (buf.length != 118) {
		throw "expecting byte length 118 but got " + buf.length;
	}
	return Secp256k1KeyIdentity.fromSecretKey(buf.subarray(7, 39)) as Identity;
};

const derivePrincipal = (name: string): Principal => {
	let principal: string = process.env[
		`CANISTER_ID_${name.toUpperCase()}`
	] as string;

	if (!principal) {
		principal = execSync(`dfx canister id ${name}`).toString().trim();
	}

	return Principal.fromText(principal);
};

const main = (identity?: Identity): ActorSubclass<D._SERVICE> => {
	const principal = derivePrincipal("main");

	return createActor<D._SERVICE>(principal, D.idlFactory, {
		agent: agent(identity),
	});
};

const init = async () => {
	const absoluteDir = path.dirname(new URL(import.meta.url).pathname);
	const buffer = readFileSync(`${absoluteDir}/icrc1_ledger.wasm`);

	return await main(deriveCurrentIdentity()).init(buffer);
};

await init();
