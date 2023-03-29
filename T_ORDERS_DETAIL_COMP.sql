CREATE OR REPLACE TRIGGER T_ORDERS_DETAIL_COMP
	FOR UPDATE OR INSERT OR DELETE
		ON ORDERS_DETAIL
COMPOUND TRIGGER
	TYPE IDX_TABLE_TYPE IS TABLE OF NUMBER;
	IDX_TABLE IDX_TABLE_TYPE := IDX_TABLE_TYPE();
	I					NUMBER := 1;
	IDX_NUM				NUMBER;
	IS_INDEXIS			BOOLEAN:=FALSE;
	nAMOUNT				NUMBER;
	nDISCOUNT			NUMBER;
	nORDERS_DET_SUM		NUMBER;
BEFORE EACH ROW IS
BEGIN
	IF INSERTING THEN
		--Блок для пересчета индексов
		IDX_TABLE.EXTEND();
		IDX_TABLE(I):= :NEW.ID_ORDER;
		I:=I+1;
		IS_INDEXIS:=TRUE;

		IF :NEW.ID IS NOT NULL THEN
			raise_application_error( -20555, 'ID запрещен для изменения' );
		ELSE 
			:NEW.ID := ID_SEQ.NEXTVAL;
		END IF;
	END IF;

	IF DELETING THEN
		IDX_TABLE.EXTEND();
		IDX_TABLE(I):= :OLD.ID_ORDER;
		I:=I+1;
		IS_INDEXIS:=TRUE;
	END IF;

	IF UPDATING THEN
		IF :NEW.ID IS NOT NULL AND :NEW.ID <> :OLD.ID THEN
			raise_application_error( -20555, 'ID запрещен для изменения' );
		ELSE 
			:NEW.ID:= :OLD.ID;
		END IF;

		IS_INDEXIS:=FALSE;
		-- 2) При добавлении строки заказа, удалении строки заказа  или изменении цены или количества по строке заказа должна изменяться сумма заказа (orders.amount).
			IF (NVL(:NEW.PRICE, 0) <> nvl(:OLD.PRICE, 0)) OR (NVL(:NEW.QTY, 0) <> NVL(:OLD.QTY, 0)) THEN

				SELECT NVL(AMOUNT, 0), 
						DISCOUNT 
					INTO nAMOUNT, 
						nDISCOUNT 
					FROM orders 
					WHERE ID = :OLD.ID_ORDER;

				nORDERS_DET_SUM := COALESCE(:NEW.PRICE, :OLD.PRICE, 0) * COALESCE(:NEW.QTY, :OLD.QTY, 0) * (1 - nDISCOUNT / 100);

				UPDATE ORDERS O SET 
						O.AMOUNT = nAMOUNT - :OLD.STR_SUM + nORDERS_DET_SUM
					WHERE O.ID = :OLD.ID_ORDER;
	-- 3) При изменении цены или количества по строке заказа должна автоматом пересчитываться сумма по строке заказа (orders_detail.str_sum).
				:NEW.STR_SUM := nORDERS_DET_SUM;
			 END IF;
	   	END IF;
	   
	-- 6) Сумма по строке вычисляется следующим образом = цена(orders_detail.price)*количество(orders_detail.qty)*(1-скидка(orders.descount)/100)
   		IF INSERTING OR UPDATING THEN
   			--Пересчет суммы
			IF :NEW.STR_SUM IS NULL THEN 
				SELECT DISCOUNT INTO nDISCOUNT FROM orders WHERE ID = :NEW.ID_ORDER;
		 	
		 		:NEW.STR_SUM := :NEW.PRICE * :NEW.QTY * (1 - nDISCOUNT / 100);
			END IF;
		END IF;

  end before each row;
  
  after each row is
  BEGIN
	--2) При добавлении строки заказа, удалении строки заказа  или изменении цены или количества по строке заказа должна изменяться сумма заказа (orders.amount).
	  	IF INSERTING THEN
	  		UPDATE ORDERS O SET O.AMOUNT = ((SELECT nvl(AMOUNT, 0) FROM orders WHERE ID = :NEW.ID_ORDER) + :NEW.STR_SUM) WHERE O.ID = :NEW.ID_ORDER;
	  	END IF;
  
	  	IF DELETING THEN
	  		UPDATE ORDERS O SET O.AMOUNT = ((SELECT sum(AMOUNT) FROM orders WHERE ID = :OLD.ID_ORDER) - :OLD.STR_SUM) WHERE O.ID = :OLD.ID_ORDER;
	  	END IF;
  END after each row;
 
  after statement is
  BEGIN
	--4) Поле в строке заказа orders_detail.idx  порядковый номер должен формироваться автоматически и в нумерации строк заказа не должно быть пропусков. Последовательность должна быть строго 1,2, … количество строк заказа.
	IF IS_INDEXIS THEN 
		FOR I IN IDX_TABLE.FIRST..IDX_TABLE.LAST LOOP
			IDX_NUM:=1;
		 	FOR c IN (SELECT OD.IDX, OD.ID FROM ORDERS_DETAIL OD WHERE OD.ID_ORDER = IDX_TABLE(I) ORDER BY OD.IDX NULLS LAST) LOOP
		 		UPDATE ORDERS_DETAIL SET IDX = IDX_NUM WHERE ID = c.ID;
		 		IDX_NUM:=IDX_NUM+1;
		 	END LOOP;
		END LOOP;
		IDX_TABLE.DELETE;
	END IF;
  end after statement;
end T_ORDERS_DETAIL_COMP;