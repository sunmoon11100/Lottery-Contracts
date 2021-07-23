//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    uint public playersCount;                   // Счётчик уникальных участников
    address payable public owner;               // Адрес организатора
    address payable internal deposit;           // Адрес зачисления комиссии организатора
    address payable public manager;             // Адрес менеджера
    address payable internal managersWallet;    // Адрес кошелька менеджера
    uint public ownersTax;                      // Доля организатора
    uint public managersTips;                   // Процент прибыли менеджера от прибыли организатора
    
    uint public maxTickets;                     // Максимальное число билетов
    uint public ticketPrice;                    // Стоимость 1 билета
    address payable[] public ticketsArray;      // Массив билетов, которым при покупке присваиваются адреса покупателей
    mapping(address => uint[]) playersTickets;  // Хранит номера купленных билетов по их покупателям
    enum State{Started, Stopped}
    State public state;                         // Статус лотереи
    
    modifier onlyManager(){
        require(msg.sender == manager);
        _;
    }
    modifier notManager(){
        require(msg.sender != manager && msg.sender != managersWallet);
        _;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    modifier notOwner(){
        require(msg.sender != owner && msg.sender != deposit);
        _;
    }
    
    modifier lotteryStarted(){
        require(state == State.Started);
        _;
    }
    
    constructor(uint _maxTickets){
        owner = payable(msg.sender);
        deposit = owner;
        manager = owner;
        managersWallet = owner;
        ownersTax = 1;
        managersTips = 50;
        maxTickets = _maxTickets;
        ticketPrice = 0.01 ether;
        state = State.Stopped;
    }
    
    /**
     * *********************ПУБЛИЧНЫЕ ФУНКЦИИ*********************
     */
    
    // Получить баланс контракта
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    // Рандомайзер
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, playersCount)));
    }
    
    // Принять участие в лотерее
    function tryLuck() public payable lotteryStarted notOwner notManager {
        require(msg.value >= ticketPrice);
        uint tickets;
        
        // Считаем количество уникальных участников.
        // Когда в лотерею заходит новый участник его адрес помещается в mapping playersTickets,
        // а билеты один за другим попадают в массив.
        // Если по данному адресу в маппинге массив нулевой длины, значит участник новый
        if(playersTickets[msg.sender].length == 0){
            playersCount++;
        }
        
        // Подсчёт числа билетов с одной транзакции
        // Делим платёж на цену билета, и вычитаем остаток от деления, получая целое число билетов
        tickets = (msg.value / ticketPrice) - (msg.value % ticketPrice);
        
        // Закрепление всех приобретённых билетов за покупателем
        // Последовательно помещаем адрес покупателя в конец массива столько раз, сколько
        // им было куплено билетов
        for(uint i = 1; i <= tickets; i++){
            ticketsArray.push(payable(msg.sender));
            playersTickets[msg.sender].push(ticketsArray.length - 1);
        }
        
        // Проверим, не последний ли это был билет. Если куплен последний билет, вызываем
        // завершение лотереи
        if(ticketsArray.length == maxTickets){
            Luck();
        }
    }
    
    /**
     * *********************БЛОК ФУНКЦИЙ МЕНЕДЖЕРА*********************
     */
    
    // Вызываем завершение лотереи по инициативе менеджера
    function doThemLuck() public onlyManager {
        pickWinner();
    }
    
    // Запустить лотерею
    function startLottery() public onlyManager returns(bool){
        require(deposit != address(0));
        state = State.Started;
        return true;
    }
    
    function changeManagerWallet(address payable _newWallet) public onlyManager returns(bool){
        managersWallet = _newWallet;
        return true;
    }
    
    function getManagerWallet() public view onlyManager returns(address payable){
        return managersWallet;
    }
    
    /**
     * *********************ФУНКЦИИ ОРГАНИЗАТОРА*********************
     */
    
    // Получить адрес для перечисления доли организатора
    function getDeposit() public view onlyOwner returns(address payable){
        return deposit;
    }
    
    // Указать адрес для перечисления доли организатора
    function setDeposit(address payable _deposit) public onlyOwner returns (bool){
        require(state == State.Stopped);
        deposit = _deposit;
        return true;
    }
    
    // Сменить манагера
    function setManager(address payable _manager) public onlyOwner returns(bool){
        manager = _manager;
        managersWallet = manager;
        return true;
    }
    
    // Изменить комиссию организатора
    function changeOwnerTax(uint _newTax) public onlyOwner returns(bool){
        require(_newTax <= 100 && _newTax >= 0);
        ownersTax = _newTax;
        return true;
    }
    
    // Изменить комиссию манагера
    function changeManagerTips(uint _newTips) public onlyOwner returns(bool){
        require(_newTips <= 100 && _newTips >= 0);
        managersTips = _newTips;
        return true;
    }
    
    /**
     * *********************ВНУТРЕННИЕ ФУНКЦИИ*********************
     */
    receive() external payable{
        tryLuck();
    }
    
    // Вызываем завершение лотереи через окончание билетов из tryLuck
    function Luck() internal {
        pickWinner();
    }
    // Завершение лотереи, отправка выигрыша и комиссий
    function pickWinner() internal {
        uint r = random();
        address payable winner;
        uint index = r % playersCount;
        winner = ticketsArray[index];
        
        // Вычисляем, сколько должно уйти победителю за вычетом комиссии организатора
        uint winnerPrize = (getBalance()/100)*(100 - ownersTax);
        winner.transfer(winnerPrize);
        
        // Если менеджер и организатор не одно лицо, то выделяем долю и менеджеру
        if(managersWallet != deposit){
            uint tips;
            tips = (getBalance()/100)*(100 - (100 - managersTips)); 
            managersWallet.transfer(tips);
        }
        
        // Радуем организатора остатком тортика в конце вечеринки
        deposit.transfer(getBalance());
        
        // Обнуляем всё для новой вечеринки
        cleanParty();
        state = State.Stopped;
    }
    
    function cleanParty() internal {
        ticketsArray = new address payable[](0);
    }
}