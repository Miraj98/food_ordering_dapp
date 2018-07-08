

pragma solidity ^0.4.24;

contract FoodOrdering {
    
    struct foodItem {
        uint256 foodID; //Every food item is identified through a unique ID.
        uint256 quantity; //Amount of the particular food ordered by a customer.
        address customer; //Ethereum address of the person ordering the food item.
        bool prepared; //boolean to check if food delivered or not.
    }
    
    mapping (address => uint256) numberof_orders; //Keeps track of thow many food items the user ordered.
    mapping (uint256 => uint256) public prices; //This mapping represents a "digital menu card". Every food item mapped to its price.

    foodItem[] public pending_orders; //Keeps a track of current pending orders.
    foodItem[] public completed_orders; //Keeps a track of orders prepared but not yet confirmed by the customer as reached/delivered to them. 
    event order_completed (address _addr, bool completed);
    address owner; //Owner of the smart contract.
    
    //The constructor sets up the "digital menu card" and the "owner" of the contract.
    function FoodOrdering (uint256[] menuList, uint256[] _prices) public {
        //Setting up the "digital menu card"...
        require (menuList.length == _prices.length);
        for (uint256 i = 0; i < menuList.length; i++) {
            prices[menuList[i]] = _prices[i]*10**18;
        }
        //Setting up the owner of smart contract...b
        owner = msg.sender;
    }

    /*
        This program will work the following way:
        (1) A user can order food using the @place_order() function which will push the user's order
            to @pending_orders[] 

        (2) The restaurant will confirm when a particular order is ready using  @update_order() 
            and pushing it to @completed_orders[]

        (3)  The user will be able to cancel his/her order using @cancel_order() if the order still
             exists in @pending_orders[]

        (4) @confirm_payout() will mark the end this service with the user confriming the payout once he/she
            recieve their order.
    */


    
    function confirm_payout() public {
        foodItem[] delivered_orders;
        uint256 totalBill = 0;
        for (uint256 i = 0; i < completed_orders.length; i++) {
            if (completed_orders[i].customer == msg.sender) {
                delivered_orders.push(completed_orders[i]);
                totalBill += prices[delivered_orders[i].foodID]*delivered_orders[i].quantity;
                for (uint256 k = i; k < completed_orders.length - 1; k++){
                    completed_orders[k] = completed_orders[k+1];
                }
                delete completed_orders[completed_orders.length-1];
                completed_orders.length--;
                i--;
            }
        }
        if (delivered_orders.length == numberof_orders[msg.sender] && totalBill > 0) {
            owner.transfer(totalBill);
            msg.sender.transfer(totalBill);
        }
    }
    
    function place_order(uint256[] foodItem_list, uint256[]_quantity) public payable {
        require (foodItem_list.length == _quantity.length);
        uint256 _totalAmount = billAmount(foodItem_list, _quantity);
        require (msg.value == 2*_totalAmount);
        numberof_orders[msg.sender] = foodItem_list.length;
        for (uint i = 0; i < foodItem_list.length; i++) {
            pending_orders.push(foodItem({
                foodID: foodItem_list[i],
                quantity: _quantity[i],
                customer: msg.sender,
                prepared: false
            }));
        }
    }
    
    function cancel_order() public returns (bool) {
        uint256 orders_cancelled = 0;
        uint256 amount_refund = 0;
        for (uint256 i = 0; i < pending_orders.length; i++) {
            if (pending_orders[i].customer == msg.sender) {
                amount_refund += prices[pending_orders[i].foodID]*pending_orders[i].quantity;
                for (uint256 k = i; k < pending_orders.length - 1; k++) {
                    pending_orders[k] = pending_orders[k+1];
                }
                delete pending_orders[pending_orders.length - 1];
                pending_orders.length--;
                i--;
                orders_cancelled += 1;
                if (orders_cancelled == numberof_orders[msg.sender]) {
                    break;
                }
            }
        }
        
        if (amount_refund > 0 && orders_cancelled == numberof_orders[msg.sender]) {
            msg.sender.transfer(amount_refund);
            return true;
        }
        else {
            return false;
        }
    }
    
    function update_orders (address _addr) public {
        require (owner == msg.sender);
        uint256 orders_updated = 0;
        for (uint256 i = 0; i < pending_orders.length; i++) {
            if (pending_orders[i].customer == _addr) {
                pending_orders[i].prepared = true;
                completed_orders.push(pending_orders[i]);
                for (uint256 k = i; k < pending_orders.length - 1; k ++) {
                    pending_orders[k] = pending_orders[k+1];
                }
                delete pending_orders[pending_orders.length - 1];
                pending_orders.length--;
                i--;
                orders_updated += 1;
                if (orders_updated == numberof_orders[_addr]) {
                    return;
                }
            }
        }
    }
    
    function getContractBalance() public returns(uint) {
        require(msg.sender == owner);
        return this.balance;
    }
    
    function billAmount(uint256[] foodItem_list, uint256[]_quantity) private returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < foodItem_list.length; i++) {
            totalAmount += prices[foodItem_list[i]]*_quantity[i];
        }
        return totalAmount;
    }

}
