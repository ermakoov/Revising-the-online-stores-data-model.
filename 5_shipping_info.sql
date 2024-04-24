-- 4.1 Create table shipping_info with unique deliveries
CREATE TABLE shipping_info (
 	shippingid SERIAL,
 	vendorid INT8,
 	shipping_plan_datetime TIMESTAMP,
 	payment_amount NUMERIC(14,2),
 	shipping_country_id INT,
 	agreementid INT,
 	transfer_type_id INT,
 	CONSTRAINT shipping_info_shipping_country_id_fkey FOREIGN KEY (shipping_country_id) REFERENCES shipping_country_rates(shipping_country_id),
 	CONSTRAINT shipping_agreement_agreementid_fkey FOREIGN KEY (agreementid) REFERENCES shipping_agreement(agreementid),
 	CONSTRAINT shipping_transfer_rates_transfer_type_fkey FOREIGN KEY (transfer_type_id) REFERENCES shipping_transfer(transfer_type_id) 	
 );
СREATE INDEX shipping_info_shipping_id ON public.shipping_info(shippingid);
COMMENT ON COLUMN public.shipping_info.shippingid is 'уникальный идентификатор доставки';
COMMENT ON COLUMN public.shipping_info.vendorid is 'уникальный идентификатор вендора';
COMMENT ON COLUMN public.shipping_info.payment_amount is 'сумма платежа покупателя';
COMMENT ON COLUMN public.shipping_info.shipping_plan_datetime is 'плановое дата время доставки';
COMMENT ON COLUMN public.shipping_info.shipping_transfer_id is 'идентификатор типа и модели доставки - связь с таблицей shipping_transfer';
COMMENT ON COLUMN public.shipping_info.shipping_agremeent_id is 'уникальный идентификатор договора с вендором - связь с таблицейshipping_agremeent';
COMMENT ON COLUMN public.shipping_info.shipping_country_rate_id is 'уникальные идентификатор справочной информации по стоимости доставки в странах - связь с таблицей shipping_country_rates';

 
-- 4.2 Query for data to be filled in table shipping_info
INSERT INTO shipping_info (vendorid, shipping_plan_datetime, payment_amount, shipping_country_id, agreementid, transfer_type_id)
SELECT vendorid, shipping_plan_datetime, payment_amount, shipping_country_id, sa.agreementid, transfer_type_id
FROM shipping s
JOIN shipping_country_rates sс  ON (s.shipping_country, s.shipping_country_base_rate) = (sс.shipping_country, sс.shipping_country_base_rate)
JOIN shipping_transfer st ON 
    CAST(SPLIT_PART(s.shipping_transfer_description, ':', 1) AS VARCHAR) = st.transfer_type
    AND CAST(SPLIT_PART(s.shipping_transfer_description, ':', 2) AS VARCHAR) = st.transfer_model
    AND s.shipping_transfer_rate = st.shipping_transfer_rate  
JOIN shipping_agreement sa ON 
    CAST(SPLIT_PART(s.vendor_agreement_description, ':', 1) AS INT) = sa.agreementid
    AND CAST(SPLIT_PART(s.vendor_agreement_description, ':', 2) AS VARCHAR) =  sa.agreement_number
    AND CAST(SPLIT_PART(s.vendor_agreement_description, ':', 3) AS NUMERIC(14,2)) = sa.agreement_rate
    AND CAST(SPLIT_PART(s.vendor_agreement_description, ':', 4) AS NUMERIC(14,3)) = sa.agreement_commission;