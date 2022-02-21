type amt is nat

type token_id is nat

type account is (address * amt)


type storage is record [
    ledger  :   big_map(token_id, account)
]

type return is list (operation) * storage

(* entry points parameters *)
//type lockParams is michelson_pair(address, "sender", michelson_pair(amt, "value", nat, "days"), "")
type lockParams is (address * token_id * amt)
type releaseParams is token_id

(* entry points *)
type entryAction is 
 | Lock of lockParams
 | Release of releaseParams


function lock(const sender_t : address; const token : token_id; const value : amt; var stor : storage) : return is 
 block {
     case (stor.ledger[token]) of
     Some(t_) -> failwith("token exists")
     | None -> skip
     end;
     stor.ledger[token] := (sender_t, value);
 } with ((nil :  list(operation)), stor)

 function release(const token : token_id; var stor : storage) : return is 
  block {
      case stor.ledger[token] of
        Some(a_) -> skip
      | None -> failwith("Invalid token")
      end;
      // TODO: 
      // if Tezos.sender =/= main contract then failwith
      // add paramater receiver : address to this function
      // transfer tez to receiver (writer account or option holder) account
      remove token from map stor.ledger;
  } with ((nil :  list(operation)), stor)

 function main(const action : entryAction; var s : storage) : return is 
  block {
      skip
  } with case action of
    | Lock(params) -> lock(params.0, params.1, params.2, s)
    | Release(params) -> release(params, s)
    end;

 