import web3combined from "./web3";
import deploy from '../deploy.js';

const deployed = deploy();
const address = deployed.address;
const abi = deployed.abi;

console.log(`ABI: ${abi} Address: ${address}`);

export default new web3combined.eth.Contract(abi, address);