-- 1.1 Create table shipping_country_rates
CREATE TABLE shipping_country_rates (
	shipping_country_id SERIAL,
	shipping_country TEXT,
	shipping_country_base_rate NUMERIC(14,3),
	CONSTRAINT shipping_country_rates_shipping_country_id_pkey PRIMARY KEY (shipping_country_id)
);
CREATE INDEX shipping_country_rates_i ON public.shipping_country_rates(shipping_country);
COMMENT ON COLUMN public.shipping_country_rates.shipping_country is 'название страны отправки товара';
COMMENT ON COLUMN public.shipping_country_rates.shipping_country_base_rate is 'налог на доставку в страну - являющийся процентом от';

-- 1.2 Adding data into table shipping_country_rates
INSERT INTO shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT DISTINCT shipping_country, shipping_country_base_rate 
FROM shipping; 