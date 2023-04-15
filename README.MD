# TBM-Test-Task

TBM Test Task.

## English

In the **SCRIPT_FOR_TASKS.sql** file there is a script for creating three tables.

You need to create triggers that will process the logic and statistics of data in this tables.

Functional requirements:
1) When changing the discount field (**ORDERS.DISCOUNT**), row orders sum (**ORDERS_DETAIL.STR_SUM**) must be recalculated.
2) When adding row order, deleting row order or changing row order price or count, order sum (ORDERS.AMOUNT) must be recalculated.
3) When changing row order price or count, row order sum (ORDERS_DETAIL.STR_SUM) must be recalculated automatically.
4) Field Serial Number (ORDERS_DETAIL.IDX) must be generated automatically and row number must have no gaps (sequence must be 1,2, … row orders count).
5) Discount value (ORDERS.DISCOUNT) can be between 0 and 100.
6) Row sum is calculated as price(ORDERS_DETAIL.PRICE)*count(ORDERS_DETAIL.QTY)*(1-discount(ORDERS.DISCOUNT)/100).
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
	
<table>
	<tr>
		<td valign="center" width="49%"><img src="https://github.com/Ruslan-Shevyrev/Ruslan-Shevyrev/blob/main/logoRS/logo_mini.gif" title="logo"></td>
		<td valign="center" width="49%"><img src="https://github.com/Ruslan-Shevyrev/Ruslan-Shevyrev/blob/main/logoRS/logoRS_FULL.png" title="RuslanShevyrev"></td>
	</tr>
</table>