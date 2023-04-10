import { Secp256k1Keypair, bcs, TransactionBlock, JsonRpcProvider, Connection } from "@mysten/sui.js";

const conn = new Connection({
  fullnode: "https://fullnode.testnet.sui.io:443"
})
const packageId =
  "0x24951211e27af7f0d1a37a12a387e7bf31e4dba866b794b7c1d0991c3be051e9"; //testnet
const privateKey = [
  119, 231, 41, 153, 132, 67, 193, 179, 241, 231, 46, 56, 61, 15, 135, 2, 30,
  124, 220, 231, 236, 197, 181, 209, 158, 56, 75, 229, 216, 102, 78, 203,
];
const keypair = Secp256k1Keypair.fromSecretKey(Uint8Array.from(privateKey));
console.log(keypair.getPublicKey());

let hexPubKey = Buffer.from(keypair.getPublicKey().toBytes()).toString('hex');

const pubKeyMove = `0x${hexPubKey}`; // this is how it should be stored in move to work

console.log(`Move public key format: ${hexPubKey}`); // this is what we keep for move


// here we need the object id and the address of the owner
// I used the id that the test will spawn every time to get correct data
let owner = "0x6f2d5e80dd21cb2c87c80b227d662642c688090dc81adbd9c4ae1fe889dfaf71";
let obj = "0x034401905bebdf8c04f3cd5f04f442a39372c8dc321c29edfb4f9cb30b23ab96";
const level = 10;

const objBcs = bcs.ser("address", obj).toBytes();
const levelBcs = bcs.ser("u64", level).toBytes();

const rawMsg = new Uint8Array(objBcs.length + levelBcs.length);
rawMsg.set(objBcs);
rawMsg.set(levelBcs, objBcs.length);
console.log(`Message: ${rawMsg}`); // this is the raw message we need
const signed = keypair.signData(rawMsg);
console.log(`Signature: ${signed}`);
