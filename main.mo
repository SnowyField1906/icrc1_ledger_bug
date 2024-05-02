import Types "types";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";

shared ({ caller = facade }) actor class Acorn() = this {
    private stable var acornActor : ?(
        actor {
            icrc1_name : query () -> async (Text);
            icrc1_symbol : query () -> async (Text);
            icrc1_decimals : query () -> async (Nat8);
            icrc1_total_supply : query () -> async (Nat);
            icrc1_fee : query () -> async (Nat);
            icrc1_minting_account : query () -> async (?Types.Account);
            icrc1_balance_of : query (Types.Account) -> async (Nat);
            icrc1_transfer : (Types.TransferArgs) -> async (Types.TransferResult);

            icrc2_approve : (Types.ApproveArgs) -> async (Types.ApproveResult);
            icrc2_allowance : query (Types.AllowanceArgs) -> async (Types.Allowance);
            icrc2_transfer_from : (Types.TransferFromArgs) -> async (Types.TransferFromResult);
        }
    ) = null;

    public shared ({ caller }) func init(ledgerWasm : Blob) : async () {
        ExperimentalCycles.add(100_000_000_000);

        let IC0 : Types.ActorManagement = actor ("aaaaa-aa");
        let { canister_id = acorn } = await IC0.create_canister({
            settings = ?{
                controllers = ?[Principal.fromActor(this)];
                compute_allocation = null;
                memory_allocation = null;
                freezing_threshold = null;
            };
        });

        let acornInitArgs : Types.InitArgs = {
            token_symbol = "ACORN";
            token_name = "Acorn Token";
            transfer_fee = 0;
            decimals = ?8;
            feature_flags = ?{ icrc2 = true };
            minting_account = { owner = Principal.fromActor(this); subaccount = null };
            fee_collector_account = null;
            initial_balances = [
                (
                    { owner = caller; subaccount = null },
                    60_000_000,
                ),
                (
                    { owner = Principal.fromActor(this); subaccount = null },
                    40_000_000,
                ),
            ];
            metadata = [];
            archive_options = {
                num_blocks_to_archive = 1000;
                trigger_threshold = 2000;
                controller_id = Principal.fromActor(this);
                max_transactions_per_response = null;
                max_message_size_bytes = null;
                cycles_for_archive_creation = null;
                node_max_memory_size_bytes = null;
                more_controller_ids = null;
            };
            send_whitelist = null;
            max_memo_length = null;
            max_message_size_bytes = null;
            transaction_window = null;
            maximum_number_of_accounts = null;
            accounts_overflow_trim_quantity = null;
        };

        await IC0.install_code({
            mode = #install;
            canister_id = acorn;
            wasm_module = Blob.toArray(ledgerWasm);
            arg = Blob.toArray(to_candid (acornInitArgs));
        });

        acornActor := ?(actor (Principal.toText(acorn)));
    };

    public query func acornPrincipal() : async ?Principal {
        switch (acornActor) {
            case (null) null;
            case (?acornActor) ?Principal.fromActor(acornActor);
        };
    };
};