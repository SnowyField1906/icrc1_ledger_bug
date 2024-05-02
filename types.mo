import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Time "mo:base/Time";

module {
    public type ActorManagement = actor {
        create_canister : {
            settings : ?{
                controllers : ?[Principal];
                compute_allocation : ?Nat;
                memory_allocation : ?Nat;
                freezing_threshold : ?Nat;
            };
        } -> async { canister_id : Principal };

        install_code : {
            arg : [Nat8];
            wasm_module : [Nat8];
            mode : { #reinstall; #upgrade; #install };
            canister_id : Principal;
        } -> async ();
    };

    public type Token = {
        e8s : Nat64;
    };
    public type Account = {
        owner : Principal;
        subaccount : ?Blob;
    };

    public type InitialBalance = (Account, Nat);

    public type InitArgs = {
        minting_account : Account;
        fee_collector_account : ?Account;
        transfer_fee : Nat;
        decimals : ?Nat8;
        max_memo_length : ?Nat16;
        token_symbol : Text;
        token_name : Text;
        metadata : [(Text, { #Nat : Nat; #Int : Int; #Blob : Blob; #Text : Text })];
        initial_balances : [InitialBalance];
        feature_flags : ?{ icrc2 : Bool };
        maximum_number_of_accounts : ?Nat64;
        accounts_overflow_trim_quantity : ?Nat64;
        archive_options : {
            num_blocks_to_archive : Nat64;
            max_transactions_per_response : ?Nat64;
            trigger_threshold : Nat64;
            max_message_size_bytes : ?Nat64;
            cycles_for_archive_creation : ?Nat64;
            node_max_memory_size_bytes : ?Nat64;
            controller_id : Principal;
            more_controller_ids : ?[Principal];
        };
    };

    public type TransferArgs = {
        from_subaccount : ?Blob;
        to : Account;
        amount : Nat;
        fee : ?Nat;
        memo : ?Blob;
        created_at_time : ?Nat64;
    };
    public type TransferResult = {
        #Ok : Nat;
        #Err : {
            #BadFee : { expected_fee : Nat };
            #BadBurn : { min_burn_amount : Nat };
            #InsufficientFunds : { balance : Nat };
            #TooOld;
            #CreatedInFuture : { ledger_time : Nat64 };
            #TemporarilyUnavailable;
            #Duplicate : { duplicate_of : Nat };
            #GenericError : { error_code : Nat; message : Text };
        };
    };

    public type ApproveArgs = {
        from_subaccount : ?Blob;
        spender : Account;
        amount : Nat;
        expected_allowance : ?Nat;
        expires_at : ?Nat64;
        fee : ?Nat;
        memo : ?Blob;
        created_at_time : ?Nat64;
    };
    public type ApproveResult = {
        #Ok : Nat;
        #Err : {
            #BadFee : { expected_fee : Nat };
            #InsufficientFunds : { balance : Nat };
            #AllowanceChanged : { current_allowance : Nat };
            #Expired : { ledger_time : Nat64 };
            #TooOld;
            #CreatedInFuture : { ledger_time : Nat64 };
            #Duplicate : { duplicate_of : Nat };
            #TemporarilyUnavailable;
            #GenericError : { error_code : Nat; message : Text };
        };
    };

    public type AllowanceArgs = {
        account : Account;
        spender : Account;
    };
    public type Allowance = {
        allowance : Nat;
        expires_at : ?Nat;
    };

    public type TransferFromArgs = {
        spender_subaccount : ?Blob;
        from : Account;
        to : Account;
        amount : Nat;
        fee : ?Nat;
        memo : ?Blob;
        created_at_time : ?Nat64;
    };
    public type TransferFromResult = {
        #Ok : Nat;
        #Err : {
            #BadFee : { expected_fee : Nat };
            #BadBurn : { min_burn_amount : Nat };
            #InsufficientFunds : { balance : Nat };
            #InsufficientAllowance : { allowance : Nat };
            #TooOld;
            #CreatedInFuture : { ledger_time : Nat64 };
            #Duplicate : { duplicate_of : Nat };
            #TemporarilyUnavailable;
            #GenericError : { error_code : Nat; message : Text };
        };
    };
};