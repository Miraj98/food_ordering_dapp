# Food ordering dApp
This dApp has the following functions:

(1) **place_order()**: This function places the customer's order. The person has to initially pay twice the total amount of his bill.
    The extra money acts as a "safety deposit" so that the customer confirms the final payment (when he/she receives the order) in which the bill amount is transferred to the contract owner's address.
    The "safety deposit" is returned when the user confirms the payout.
    
(2) **update_order()**: This function is called by the restaurant when a particular person's order is completed and ready for delivery.

(3) **cancel_order()**: This function can be called the customer if he/she wants to cancel the order. For the cancellation request to go through, the food should not be ready yet.

(4) **confirm_payout()**: This function is called by the customer to confirm the delivery of his/her order. The extra money that the customer had paid as a "safety deposit" is returned and the rest is transferred to contract owner's address.

## Assumptions

It is assumed that once a customer has placed an order, he/she does not try to place another order until the previous order is paid for or cancelled successfully.
