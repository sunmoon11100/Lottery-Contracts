const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
const {interface, bytecode} = require('../compile');

let accounts;
let lottery;
beforeEach(async () => {
    accounts = await web3.eth.getAccounts(); 
    // lottery = await new web3.eth.Contract(JSON.parse(interface))
    //     .deploy({data: bytecode, arguments: ['1000']})
    //         .send({from: accounts[0], gas: '1000000'});
});

describe('Lottery contract', () => {
    it('Accounts got', () => {
        console.log(accounts);
    });
});