CREATE VIEW shipping_datamart AS
SELECT ss.shippingid,
	   vendorid,
	   transfer_type,
	   DATE_PART('DAY', (shipping_end_fact_datetime - shipping_start_fact_datetime)) full_day_at_shipping, 
	   (CASE WHEN ss.status = 'finished' THEN 1 ELSE 0 END) is_shipping_finish,
	   (CASE WHEN shipping_end_fact_datetime > shipping_plan_datetime 
	    	 THEN DATE_PART('DAY', (shipping_end_fact_datetime - shipping_plan_datetime)) ELSE 0 END) delay_day_at_shipping,
	   payment_amount,
	   (payment_amount * (shipping_country_base_rate + agreement_rate + shipping_transfer_rate)) vat,
	   (payment_amount * agreement_commission) profit
FROM shipping_status ss
JOIN shipping_info si USING(shippingid)
JOIN shipping_transfer USING(transfer_type_id)
JOIN shipping_country_rates USING(shipping_country_id)
JOIN shipping_agreement USING(agreementid);