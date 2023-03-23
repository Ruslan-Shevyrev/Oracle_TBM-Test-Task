drop table orders_detail;

drop table orders;

drop table sku;

-- Таблица с Товаром
CREATE TABLE sku
(
  ID          NUMBER,
  NAME        VARCHAR2(200) not null
);

COMMENT ON TABLE sku IS 'Таблица каталог товаров.';

COMMENT ON COLUMN sku.id IS 'Первичный ключ';

COMMENT ON COLUMN sku.name IS 'Название товара.';


ALTER TABLE sku ADD (
  CONSTRAINT pk_sku
  PRIMARY KEY
  (id));

-- Таблица заказа
CREATE TABLE orders
(
  ID          NUMBER,
  N_DOC       NUMBER,
  DATE_DOC    DATE,
  AMOUNT      NUMBER,
  DISCOUNT    NUMBER
);


COMMENT ON TABLE orders IS 'Таблица содержащая заказы.';

COMMENT ON COLUMN orders.id IS 'Первичный ключ';

COMMENT ON COLUMN orders.n_doc IS '№ заказа.';

COMMENT ON COLUMN orders.date_doc IS 'Дата заказа.';

COMMENT ON COLUMN orders.amount IS 'Сумма заказа расчетное значение (сумма деталей заказа).';

COMMENT ON COLUMN orders.discount IS 'Скидка в процентах от 0 до 100.';


ALTER TABLE orders ADD (
  CONSTRAINT pk_orders
  PRIMARY KEY
  (id));

CREATE TABLE orders_detail
(
  ID          NUMBER,
  ID_ORDER    NUMBER not null,
  ID_SKU      NUMBER not null,
  PRICE       NUMBER,
  QTY         NUMBER,
  STR_SUM     NUMBER,
  IDX         NUMBER 
);

COMMENT ON TABLE orders_detail IS 'Таблица содержащая заказы.';

COMMENT ON COLUMN orders_detail.id IS 'Первичный ключ';

COMMENT ON COLUMN orders_detail.id_order IS 'тдентификатор заказа';

COMMENT ON COLUMN orders_detail.id_sku IS 'идентификатор товара';

COMMENT ON COLUMN orders_detail.price IS 'Цена товара за единицу.';

COMMENT ON COLUMN orders_detail.qty IS 'кол-во товара.';

COMMENT ON COLUMN orders_detail.str_sum IS 'Сумма по строке с учетом скидки.';

COMMENT ON COLUMN orders_detail.idx IS 'Порядковый номер строки заказа (не должно быть пропусков).';


ALTER TABLE orders_detail ADD (
  CONSTRAINT pk_orders_detail
  PRIMARY KEY
  (id));
  
  
ALTER TABLE orders_detail ADD (
  CONSTRAINT fk_orders_detail_sku 
  FOREIGN KEY (id_sku) 
  REFERENCES sku (id)
  ENABLE VALIDATE,
  CONSTRAINT fk_orders_detail_order 
  FOREIGN KEY (id_order) 
  REFERENCES orders (id)
  ENABLE VALIDATE);
