ALTER TABLE `transfers` 
CHANGE COLUMN `fees` `fees` DECIMAL(12,2) NOT NULL;

DROP function IF EXISTS `checkIdAvailable`;

DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `checkIdAvailable`(id_customer BIGINT) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
	DECLARE count INT;
    SET count = (SELECT count(id) FROM customers WHERE id = id_customer);
    IF count <> 0 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END//
DELIMITER ;

DROP function IF EXISTS `validateAmount`;

DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `validateAmount`(amount DECIMAL(65,0)) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
    DECLARE is_valid BOOLEAN;
    SET is_valid = amount REGEXP '^[0-9]+$';
    IF is_valid THEN
        SET is_valid = LENGTH(amount) <= 12;
    END IF;
    IF is_valid THEN
        SET is_valid = amount REGEXP '^[0-9]+$';
    END IF;
    RETURN is_valid;
END//
DELIMITER ;

DROP procedure IF EXISTS `update_money`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_money`(IN id_customer BIGINT, IN amount DECIMAL(65,0))
BEGIN
IF id_customer > 0 THEN
		IF (SELECT checkIdAvailable(id_customer)) THEN
			IF (SELECT validateAmount(amount)) THEN
				SET @balance = (SELECT balance FROM customers WHERE id = id_customer) + amount;
				IF (SELECT validateAmount(@balance)) THEN
					UPDATE `customers` SET balance = @balance WHERE id = id_customer;
					COMMIT;
					SELECT 'Giao dịch thành công.' AS `message`;
				ELSE
					ROLLBACK;
					SELECT 'Tổng tiền gửi vượt quá định mức. Tổng tiền gửi nhỏ hơn 12 chữ số.' AS `message`;
                END IF;
			ELSE
				ROLLBACK;
				SELECT 'Số tiền gửi không hợp lệ. Phải lớn hơn 0 và nhỏ hơn 12 chữ số.' AS `message`;
			END IF;
		ELSE
			ROLLBACK;
			SELECT 'ID hiện tại không có.' AS `message`;
		END IF;
    ELSE
		ROLLBACK;
		SELECT 'ID không hợp lệ. ID phải là số nguyên và lớn hơn 0' AS `message`;
    END IF;
END$$
DELIMITER ;


DROP procedure IF EXISTS `withdraw_money`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `withdraw_money`(IN id_customer INT, IN amount DECIMAL(65,0))
BEGIN
    SET @balance = (SELECT balance FROM customers WHERE id = id_customer);
    START TRANSACTION;
    IF id_customer > 0 THEN
		IF (SELECT checkIdAvailable(id_customer)) THEN
			IF (SELECT validateAmount(amount)) THEN
				IF amount < @balance THEN
					IF amount > 0 THEN
						UPDATE `customers` SET balance = balance - amount WHERE id = id_customer;
						COMMIT;
						SELECT 'Giao dịch thành công.' AS `message`;
					ELSE	
						ROLLBACK;
						SELECT 'Số tiền rút phải lớn hơn 0' AS `message`;
					END IF;
				ELSE	
					ROLLBACK;
					SELECT CONCAT('Không đủ số dư để rút tiền. Vui lòng rút số tiền nhỏ hơn ', @balance, ' VNĐ') AS `message`;
				END IF;
			ELSE
				ROLLBACK;
				SELECT 'Số tiền rút không hợp lệ. Phải lớn hơn 0 và nhỏ hơn 12 chữ số.' AS `message`;
			END IF;
		ELSE
			ROLLBACK;
			SELECT 'ID hiện tại không có.' AS `message`;
		END IF;
    ELSE
		ROLLBACK;
		SELECT 'ID không hợp lệ. ID phải là số nguyên và lớn hơn 0' AS `message`;
    END IF;
END$$
DELIMITER ;


DROP procedure IF EXISTS `transfer`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer`(IN sender_id BIGINT, IN recipient_id BIGINT, IN amount DECIMAL(65,0))
BEGIN
	DECLARE fees DECIMAL(12,2);
    DECLARE fees_amount DECIMAL(12,0);
    DECLARE transaction_amount DECIMAL(12,0);
	START TRANSACTION;
	IF recipient_id > 0 AND sender_id > 0 THEN
		IF (SELECT checkIdAvailable(sender_id)) THEN
			IF (SELECT checkIdAvailable(recipient_id)) THEN
				IF (SELECT validateAmount(amount)) THEN
					SET fees = 0.10;
					SET fees_amount = fees * amount;
					SET transaction_amount = amount + fees_amount;
                    SET @balance_sender = (SELECT balance FROM customers WHERE id = sender_id) - transaction_amount;
                    SET @balance_recipient = (SELECT balance FROM customers WHERE id = recipient_id) + amount;
                    IF (SELECT validateAmount(@balance_recipient)) THEN
						IF transaction_amount < (SELECT balance FROM customers WHERE id = sender_id) THEN
							UPDATE customers SET balance =  @balance_sender WHERE id = sender_id;
							UPDATE customers SET balance = @balance_recipient WHERE id = recipient_id;
							insert into transfers (created_at,fees, fees_amount, transaction_amount, transfer_amount, recipient_id, sender_id)
							values (CURDATE(),0.10, fees_amount, amount + fees_amount , amount, recipient_id, sender_id);
							COMMIT;
							select 'Giao dịch thành công.' as `message`;
						ELSE
							ROLLBACK;
							select 'Không đủ số dư để chuyển tiền.' as `message`;
						END IF;
                    ELSE
						ROLLBACK;
						SELECT 'Vượt quá định mức tổng tiền người nhận. Tổng tiền định mức nhỏ hơn 12 chữ số.' AS `message`;
                    END IF;
				ELSE
					ROLLBACK;
					SELECT 'Số tiền để chuyển không hợp lệ. Phải lớn hơn 0 và nhỏ hơn 12 chữ số.' AS `message`;
				END IF;
            ELSE
				ROLLBACK;
				SELECT 'ID người nhận không tồn tại.' AS `message`;
            END IF;
		ELSE
			ROLLBACK;
			SELECT 'ID người chuyển không tồn tại.' AS `message`;
		END IF;
    ELSE
		ROLLBACK;
		SELECT 'ID người chuyển hoặc người nhận không hợp lệ. ID phải là số nguyên và lớn hơn 0' AS `message`;
    END IF;
END$$
DELIMITER ;

DROP VIEW IF EXISTS `transfer_info`;

CREATE VIEW transfer_info AS
SELECT
	c_sender.id AS sender_id,
    c_sender.full_name AS sender_name,
    c_recipient.id AS receiver_id,
    c_recipient.full_name AS receiver_name,transfer_info
    t.transfer_amount AS transfer_amount,
    t.transaction_amount AS transaction_amount,
    t.fees AS transfer_fees,
    t.fees_amount AS fees_amount
FROM customers AS c_sender
join transfers AS t on c_sender.id = t.sender_id
join customers as c_recipient on c_recipient.id = t.recipient_id;