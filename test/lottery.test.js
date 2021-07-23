const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
const {abi, bytecode} = require('../compile.js');

let accounts;
let lottery;

describe('Lottery contract', () => {
    it('interface is had a value', () => {
        assert.ok(abi, "Interface is not ok");
    });
    it('bytecode is had a value', () => {
        assert.ok(bytecode, "Bytecode is not ok");
    });
});

beforeEach(async () => {
    accounts = await web3.eth.getAccounts(); 
    lottery = await new web3.eth.Contract(JSON.parse(abi))
        .deploy({data: bytecode, arguments: ['1000']})
            .send({from: accounts[0], gas: '1000000'});
});

describe('Deploy testing', async () => {
    it('Accounts are existed succesfully', () => {
        assert.isArray(accounts, "I have a bad news. Accounts is not array or empty");
    });
    it('', () => {
        
    });
});

