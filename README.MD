# TBM-Test-Task

TBM Test Task.

## Task

The task is in the **Task** folder.

## Task in English

In the **SCRIPT_FOR_TASKS.sql** file there is a script for creating three tables.

You need to create triggers that will process the logic and statistics of data in this tables.

Functional requirements:
1) When changing the discount field (**ORDERS.DISCOUNT**), row orders sum (**ORDERS_DETAIL.STR_SUM**) must be recalculated.
2) When adding row order, deleting row order or changing row order price or count, order sum (**ORDERS.AMOUNT**) must be recalculated.
3) When changing row order price or count, row order sum (**ORDERS_DETAIL.STR_SUM**) must be recalculated automatically.
4) Field Serial Number (**ORDERS_DETAIL.IDX**) must be generated automatically and row number must have no gaps (sequence must be 1,2, … row orders count).
5) Discount value (**ORDERS.DISCOUNT**) can be between 0 and 100.
6) Row sum is calculated as price(**ORDERS_DETAIL.PRICE**)\*count(**ORDERS_DETAIL.QTY**)\*(1-discount(**ORDERS.DISCOUNT**)/100).
7) Restrictions:\
	You can change only the following fields:\
		ORDERS.N_DOC\
		ORDERS.DATE_DOC\
		ORDERS.DISCOUNT\
		ORDERS_DETAIL.ID_ORDER\
		ORDERS_DETAIL.PRICE\
		ORDERS_DETAIL.QTY\
		ORDERS_DETAIL.ID_ORDER.\
	Other fields must be calculated automatically.
	
## Task in Russian

В файле **SCRIPT_FOR_TASKS.sql** скрипт для создания трех таблиц.

Необходимо создать триггеры которые будут обрабатывать логику и целостность данных в этих таблицах.

Функциональные требования:
1) При изменении поля скидка (**ORDERS.DISCOUNT**) должны пересчитываться суммы по строкам заказа (**ORDERS_DETAIL.STR_SUM**).
2) При добавлении строки заказа, удалении строки заказа  или изменении цены или количества по строке заказа должна изменяться сумма заказа (**ORDERS.AMOUNT**).
3) При изменении цены или количества по строке заказа должна автоматически пересчитываться сумма по строке заказа (**ORDERS_DETAIL.STR_SUM**).
4) Поле порядковый номер (**ORDERS_DETAIL.IDX**) в строке заказа должно формироваться автоматически и в нумерации строк заказа не должно быть пропусков (последовательность должна быть строго 1,2, … количество строк заказа).
5) Значение скидки (**ORDERS.DISCOUNT**) может иметь значение от 0 до 100.
6) Сумма по строке вычисляется следующим образом = цена(**ORDERS_DETAIL.PRICE**)\*количество(**ORDERS_DETAIL.QTY**)\*(1-скидка(ORDERS.DISCOUNT)/100).
7) Ограничения:\
	Изменять можно только следующие поля:\
		ORDERS.N_DOC\
		ORDERS.DATE_DOC\
		ORDERS.DISCOUNT\
		ORDERS_DETAIL.ID_ORDER\
		ORDERS_DETAIL.PRICE\
		ORDERS_DETAIL.QTY\
		ORDERS_DETAIL.ID_ORDER.\
	Остальные должны пересчитываться автоматически.

## Solution

The solution is in the **Solution** folder.

### T_ORDERS.sql

```
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
```

### T_ORDERS_DETAIL_COMP.sql

```
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
END BEFORE EACH ROW;

AFTER EACH ROW IS
BEGIN
	--2) При добавлении строки заказа, удалении строки заказа  или изменении цены или количества по строке заказа должна изменяться сумма заказа (orders.amount).
		IF INSERTING THEN
			UPDATE ORDERS O SET O.AMOUNT = ((SELECT NVL(AMOUNT, 0) FROM orders WHERE ID = :NEW.ID_ORDER) + :NEW.STR_SUM) WHERE O.ID = :NEW.ID_ORDER;
		END IF;

		IF DELETING THEN
			UPDATE ORDERS O SET O.AMOUNT = ((SELECT SUM(AMOUNT) FROM orders WHERE ID = :OLD.ID_ORDER) - :OLD.STR_SUM) WHERE O.ID = :OLD.ID_ORDER;
		END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
	--4) Поле в строке заказа orders_detail.idx  порядковый номер должен формироваться автоматически и в нумерации строк заказа не должно быть пропусков. Последовательность должна быть строго 1,2, … количество строк заказа.
	IF IS_INDEXIS THEN
		FOR I IN IDX_TABLE.FIRST..IDX_TABLE.LAST LOOP
			IDX_NUM:=1;

		 	FOR c IN (SELECT OD.IDX, 
							OD.ID
						FROM ORDERS_DETAIL OD
						WHERE OD.ID_ORDER = IDX_TABLE(I)
						ORDER BY OD.IDX NULLS LAST)
			LOOP
		 		UPDATE ORDERS_DETAIL
					SET IDX = IDX_NUM
					WHERE ID = c.ID;
		 		IDX_NUM:=IDX_NUM+1;
		 	END LOOP;

		END LOOP;

		IDX_TABLE.DELETE;
	END IF;
END AFTER STATEMENT;

END T_ORDERS_DETAIL_COMP;
```

<table>
	<tr>
		<td valign="center" width="49%"><img src="https://github.com/Ruslan-Shevyrev/Ruslan-Shevyrev/blob/main/logoRS/logo_mini.gif" title="logo"></td>
		<td valign="center" width="49%"><img src="https://github.com/Ruslan-Shevyrev/Ruslan-Shevyrev/blob/main/logoRS/logoRS_FULL.png" title="RuslanShevyrev"></td>
	</tr>
</table>