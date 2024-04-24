-- 2.1 Create table shipping_agreement
CREATE TABLE shipping_agreement (
	agreementid INT,
	agreement_number VARCHAR,
	agreement_rate NUMERIC(14,2),
	agreement_commission NUMERIC(14,3),
	CONSTRAINT shipping_agreement_agreementid_pkey PRIMARY KEY(agreementid)
);
CREATE INDEX shipping_agremeent_id ON public.shipping_agremeent(agreementid);
COMMENT ON COLUMN public.shipping_agremeent.agreementid is 'идентификатор договора';
COMMENT ON COLUMN public.shipping_agremeent.agreement_number is 'номер договора в бухгалтерии';
COMMENT ON COLUMN public.shipping_agremeent.agreement_rate is 'ставка налога за стоимость доставки товара для вендора';
COMMENT ON COLUMN public.shipping_agremeent.agreement_number is 'комиссия - доля в платеже являющаяся доходом нашей компании отсделки';

-- 2.2 Adding data into table shipping_agreement
INSERT INTO shipping_agreement (agreementid, agreement_number, agreement_rate, agreement_commission)
SELECT DISTINCT CAST(vad[1] AS INT), CAST(vad[2] AS VARCHAR), CAST(vad[3] AS NUMERIC(14,2)), CAST(VAD[4] AS NUMERIC(14,3))
FROM (SELECT regexp_split_to_array(vendor_agreement_description, ':') vad
      FROM shipping) A
ORDER BY CAST(vad[1] AS INT);