delimiter //
create procedure toDeposit(
    in cash double,
    in customerId int
)
begin
    declare balance1 double;
    INSERT INTO `deposits` (`created_at`, `customer_id`, `transaction_amount`) 
    VALUES (date(now()), customerId, cash);
    select balance into balance1
    from customers where id = customerId;
    UPDATE `customers` SET `balance` = (balance1 + cash) WHERE (`id` = customerId);
end //
delimiter //
create procedure withDraw(
    in customerId int,
    in money double
)
begin
    declare balance1 double;
    select balance into balance1
    from customers where id = customerId;
    if (balance1 >= money) then
        INSERT INTO `withdraws` (`created_at`, `customer_id`, `transaction_amount`) 
        VALUES (date(now()), customerId, money);
        
        UPDATE `customers` SET `balance` = (balance1 - money) WHERE (`id` = customerId);
    end if;
end //
delimiter //
create procedure toTransfer(
    IN senderId int,
    IN receiverId int,
    IN money double
)
begin
    declare total double;
    declare balance1 double;
    declare balance2 double;
    
    select money + (money * 0.1) into total;
    
    select balance into balance1
    from customers where id = senderId;
    
    select balance into balance2
    from customers where id = receiverId;
    
    if(total <= balance1) then
        INSERT INTO `transfers` (`created_at`, `fees_amount`, `transaction_amount`, `transfer_amount`, `recipient_id`, `sender_id`) 
        VALUES (date(now()), (money * 0.1), total, money, receiverId, senderId);
        
        UPDATE `customers` SET `balance` = (balance1 - total) WHERE (`id` = senderId);
        UPDATE `customers` SET `balance` = (balance2 + money) WHERE (`id` = receiverId);
        
    end if;
end//
create view transferHistory as
select sender_id, recipient_id, fees_amount, transfer_amount, created_at 
from `transfers`;
drop procedure toTransfer;