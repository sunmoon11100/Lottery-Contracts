const path = require('path');
const fs = require('fs');
const lotteryPath = path.resolve(__dirname, 'contracts', 'Lottery.sol');
const source = fs.readFileSync(lotteryPath, 'utf8');
const solc = require('solc');

const input = JSON.stringify({
    language: 'Solidity',
    sources: {
        'Lottery.sol' : {
            content: source
        }
    },
    settings: {
        outputSelection: {
            '*': {
                '*': [ '*' ]
            }
        }
    }
}); 

module.exports = solc.compile(input, 1).contracts[':Lottery'];