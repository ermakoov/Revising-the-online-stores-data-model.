-- 3.1 Create delivery type guide - table shipping_transfer
CREATE TABLE shipping_transfer (
	transfer_type_id SERIAL,
	transfer_type VARCHAR,
	transfer_model VARCHAR,
	shipping_transfer_rate NUMERIC(14,3),
	CONSTRAINT shipping_transfer_id_pkey PRIMARY KEY(transfer_type_id)	
);
CREATE INDEX transfer_model ON public.shipping_transfer(transfer_model);
COMMENT ON COLUMN public.shipping_transfer.transfer_type is 'тип доставки - 1p означает модель когда наша компания берет ответственность за доставку на себя, 3p - вендор ответственнен за отправку заказа самостоятельно';
COMMENT ON COLUMN public.shipping_transfer.transfer_model is 'модель доставки - каким способом заказ доставляется до точки. car - машиной, train - поездом, ship - кораблем, airplane - самолетом, multiplie - комбинированный';
COMMENT ON COLUMN public.shipping_transfer.shipping_transfer_rate is 'процент стоимости доставки для вендора в зависимости от типа и модели доставки, который мы взимаем для покрытия расходов';

-- 3.2 Adding data into table shipping_transfer
INSERT INTO shipping_transfer (transfer_type, transfer_model, shipping_transfer_rate)
SELECT DISTINCT  CAST(std[1] AS VARCHAR), CAST(std[2] AS VARCHAR), shipping_transfer_rate
FROM (SELECT regexp_split_to_array(shipping_transfer_description, ':') std, shipping_transfer_rate 
      FROM shipping) A
ORDER BY CAST(std[1] AS VARCHAR);