CREATE OR REPLACE TRIGGER T_ORDERS_BINUPD
	BEFORE INSERT OR UPDATE
		ON ORDERS FOR EACH ROW
DECLARE
	nAMOUNT NUMBER;
BEGIN
	-- 5) Значение скидки (orders.discount) может иметь значение от 0 до 100
	IF :NEW.DISCOUNT < 0 OR :NEW.DISCOUNT > 100 THEN
		raise_application_error(-20555, 'Скидка не может быть меньше 0 и больше 100');
	END IF;

	--1) При изменении поля скидка (orders.descount) должны пересчитываться суммы по строкам заказа (orders_detail.str_sum).
	IF UPDATING('DISCOUNT') THEN
		IF :NEW.discount IS NOT NULL AND :NEW.discount <> :OLD.discount THEN
			UPDATE ORDERS_DETAIL O SET O.STR_SUM = O.PRICE * O.QTY * (1 - :NEW.discount / 100) WHERE O.ID_ORDER = :OLD.ID;
			SELECT sum(STR_SUM) INTO nAMOUNT FROM ORDERS_DETAIL WHERE ID_ORDER = :OLD.ID;
			:NEW.AMOUNT:=nAMOUNT;
		END IF;
	END IF;

	IF UPDATING THEN
		IF :NEW.ID IS NOT NULL AND :NEW.ID <> :OLD.ID THEN
			raise_application_error(-20555, 'ID запрещен для изменения');
		ELSE 
			:NEW.ID:= :OLD.ID;
		END IF;
	END IF;

	IF INSERTING THEN
		IF :NEW.ID IS NOT NULL THEN 
			raise_application_error(-20555, 'ID запрещен для изменения');
		ELSE 
			:NEW.ID := ID_SEQ.NEXTVAL;
		END IF;
	END IF;
END;