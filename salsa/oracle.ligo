type storage is record [
    oracleAddress : address;
    lastPrice : nat;
]

type return is list(operation) * storage

type getParams is string
type updateParams is address

type actions is 
| GetPrice of getParams
| UpdateOracle of updateParams

function getPrice(const asset : string; var s : storage) : return is
block {
    //var upd : (timestamp * nat) := (Tezos.now, 0n);
    var upd : michelson_pair(timestamp, "", nat, "") := (Tezos.now, 0n);
    case (Tezos.call_view("getPrice", asset, s.oracleAddress) : option(michelson_pair(timestamp, "", nat, ""))) of
    None -> failwith("bad asset")
    | Some(u) -> upd := u
    end;
    s.lastPrice := upd.1;
} with((nil : list(operation)), s)

function updateOracle(const oracle : address; var s : storage) : return is
block {
    s.oracleAddress := oracle
} with((nil : list(operation)), s)



function main (const p : actions; const s: storage) : return is
case p of 
| GetPrice(u) -> getPrice(u, s)
| UpdateOracle(v) -> updateOracle(v, s)
end