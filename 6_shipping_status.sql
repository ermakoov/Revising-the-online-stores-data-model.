-- 5.1 Create table shipping_status with deliveries status
CREATE TABLE shipping_status (
	shippingid INT8,
	status TEXT,
	state TEXT,
	shipping_start_fact_datetime TIMESTAMP,
	shipping_end_fact_datetime TIMESTAMP,
	CONSTRAINT shipping_status_shippingid_pkey PRIMARY KEY(shippingid)
);   
CREATE INDEX shipping_status_shipping_id ON public.shipping_status(shippingid);
COMMENT ON COLUMN public.shipping_status.shippingid is 'уникальный идентификатор доставки';
COMMENT ON COLUMN public.shipping_status.status is 'последний актуальный status доставки в таблице shipping по данному shippingid';
COMMENT ON COLUMN public.shipping_status.state is 'последний актуальный state доставки в таблице shipping по данному shippingid';
COMMENT ON COLUMN public.shipping_status.shipping_start_fact_datetime is 'фактическоу время запуска доставки - state = booked';
COMMENT ON COLUMN public.shipping_status.shipping_end_fact_datetime is 'фактическое время выполнение доставки - state = recieved';

-- 5.2 Query for data to be filled in table shipping_status
-- Create timestamp table with max shipping data value
WITH ship_max AS ( 
	SELECT shippingid,
		   MAX(CASE WHEN state = 'booked' THEN state_datetime ELSE NULL END) AS shipping_start_fact_datetime,
		   MAX(CASE WHEN state = 'recieved' THEN state_datetime ELSE NULL END) AS shipping_end_fact_datetime,
		   MAX(state_datetime) AS max_state_datetime
	FROM shipping s 
	GROUP BY shippingid
)
-- Adding data
INSERT INTO shippping_status (shippingid, status, state, shipping_start_fact_datetime, shipping_end_fact_datetime)
SELECT sm.shippingid,
	   s.status,
	   s.state,
	   sm.shipping_start_fact_datetime,
	   sm.shipping_end_fact_datetime
FROM ship_max sm
LEFT JOIN shipping s ON sm.shippingid = s.shippingid AND sm.max_state_datetime = s.state_datetime
ORDER BY shippingid;