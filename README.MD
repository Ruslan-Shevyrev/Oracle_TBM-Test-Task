# TBM-Test-Task

TBM Test Task.

## English

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
	
## Russian

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

<table>
	<tr>
		<td valign="center" width="49%"><img src="https://github.com/Ruslan-Shevyrev/Ruslan-Shevyrev/blob/main/logoRS/logo_mini.gif" title="logo"></td>
		<td valign="center" width="49%"><img src="https://github.com/Ruslan-Shevyrev/Ruslan-Shevyrev/blob/main/logoRS/logoRS_FULL.png" title="RuslanShevyrev"></td>
	</tr>
</table>