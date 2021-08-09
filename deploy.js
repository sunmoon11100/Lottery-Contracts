const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');
const {abi, bytecode} = require('./compile');
const provider = new HDWalletProvider(
    'next private dentist clump voyage champion stone private arrow useful furnace soon',
    'https://rinkeby.infura.io/v3/5f63e1484039412f87d13fbc5edd262f'
);
const web3 = new Web3(provider); 

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    console.log("Attempting to deploy from account", accounts[0]);

    const result = await new web3.eth.Contract(JSON.parse(abi))
        .deploy({data: bytecode, arguments: ["Hi there!"]})
            .send({gas: "1000000", from: accounts[0]})
    console.log("Contract deployed to", result.options.address);
    console.log(`ABI: ${abi}`)
};

