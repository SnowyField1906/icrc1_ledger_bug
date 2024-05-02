import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Acorn {
  'acornPrincipal' : ActorMethod<[], [] | [Principal]>,
  'init' : ActorMethod<[Uint8Array | number[]], undefined>,
}
export interface _SERVICE extends Acorn {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: ({ IDL }: { IDL: IDL }) => IDL.Type[];
