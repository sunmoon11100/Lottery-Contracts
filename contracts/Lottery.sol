//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address payable[] public players;
    address payable public manager;
    
    constructor(){
        manager = payable(msg.sender);
    }
    
    receive() external payable{
        require(manager != msg.sender);
        require(msg.value == 0.1 ether);
        players.push(payable(msg.sender));
    }
    
    function getBalance() public view returns(uint){
        require(manager == msg.sender);
        return address(this).balance;
    }
    
    function totalPlayers() public view returns(uint){
        return players.length;
    }
    
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    function pickWinner() public {
        require(msg.sender == manager);
        require(players.length >= 3);
        
        uint r = random();
        address payable winner;
        
        uint index = r % players.length;
        winner = players[index];
        
        uint winnerPrize = (getBalance()/100)*99;
        
        winner.transfer(winnerPrize);
        manager.transfer(getBalance());
        
        players = new address payable[](0);
    }
}