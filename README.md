Заказ в интернет-магазине — это набор купленных товаров и их количество. Покупатели привыкли получать заказы одномоментно, поэтому каждый заказ из набора товаров формируется в одну сущность доставки.

Интернет-магазину важно видеть, что сроки доставки соблюдаются, а её стоимость соответствует тарифам. Он платит за доставку самостоятельно, и стоимость доставки меняется в зависимости от страны — это базовая сумма, которую учитывает вендор. По договору он дополнительно получает прибыль за счет комиссии от вендора.

Но сейчас эти данные хранятся в одной таблице, `shipping`, где много дублированной и несистематизированной справочной информации. По сути там содержится весь лог доставки от момента оформления до выдачи заказа покупателю.

### Данные

1. Существующая модель данных:
<img width="235" alt="Screenshot_2022-05-30_at_15 56 11_1653915946c" src="https://github.com/ermakoov/Revising-the-online-stores-data-model./assets/159540686/b9814f17-2cce-43de-b5e7-e7b7bc57d4b3">

2. Таблица `shipping`, которая представляет собой последовательность действий при доставке, перечисленную ниже.
    
    - `shippingid` — уникальный идентификатор доставки.
    - `saleid` — уникальный идентификатор заказа. К одному заказу может быть привязано несколько строчек `shippingid`, то есть логов, с информацией о доставке.
    - `vendorid` — уникальный идентификатор вендора. К одному вендору может быть привязано множество `saleid` и множество строк доставки.
    - `payment` — сумма платежа (то есть дублирующаяся информация).
    - `shipping_plan_datetime` — плановая дата доставки.
    - `status` — статус доставки в таблице `shipping` по данному `shippingid`. Может принимать значения `in_progress` — доставка в процессе, либо `finished` — доставка завершена.
    - `state` — промежуточные точки заказа, которые изменяются в соответствии с обновлением информации о доставке по времени `state_datetime`.
        - booked (пер. «заказано»);
        - fulfillment — заказ доставлен на склад отправки;
        - queued (пер. «в очереди») — заказ в очереди на запуск доставки;
        - transition (пер. «передача») — запущена доставка заказа;
        - pending (пер. «в ожидании») — заказ доставлен в пункт выдачи и ожидает получения;
        - received (пер. «получено») — покупатель забрал заказ;
        - returned (пер. «возвращено») — покупатель возвратил заказ после того, как его забрал.
    - `state_datetime` — время обновления состояния заказа.
    - `shipping_transfer_description` — строка со значениями `transfer_type` и `transfer_model`, записанными через `:`. Пример записи — `1p:car`.
    
    `transfer_type` — тип доставки. `1p` означает, что компания берёт ответственность за доставку на себя, `3p` — что за отправку ответственен вендор.
    
    `transfer_model` — модель доставки, то есть способ, которым заказ доставляется до точки: `car` — машиной, `train` — поездом, `ship` — кораблем, `airplane` — самолетом, `multiple` — комбинированной доставкой.
    
    - `shipping_transfer_rate` — процент стоимости доставки для вендора в зависимости от типа и модели доставки, который взимается интернет-магазином для покрытия расходов.
    - `shipping_country` — страна доставки, учитывая описание тарифа для каждой страны.
    - `shipping_country_base_rate` — налог на доставку в страну, который является процентом от стоимости `payment_amount`.
    - `vendor_agreement_description` — строка, в которой содержатся данные `agreementid`, `agreement_number`, `agreement_rate`, `agreement_commission`, записанные через разделитель `:`. Пример записи — `12:vsp-34:0.02:0.023`.
        
        `agreementid` — идентификатор договора. `agreement_number` — номер договора в бухгалтерии. `agreement_rate` — ставка налога за стоимость доставки товара для вендора. `agreement_commission` — комиссия, то есть доля в платеже являющаяся доходом компании от сделки.
        

3. Данные изначальной таблицы лога `shipping`

shipping.csv

4. Скрипт создания таблицы `shipping`

0_create_shipping.sql

**Особенности данных:**

- Порядка 2% заказов исполняется с просрочкой, и это норма для вендоров. Вендор №3, у которого этот процент достигает 10%, скорее всего неблагонадёжен.
- Около 2% заказов не доходят до клиентов.
- В пределах нормы и то, что порядка 1.5% заказов возвращаются клиентами. При этом у вендора №21 50% возвратов. Он торгует электроникой и ноутбуками — очевидно, в его товарах много брака и стоит его изучить.

## План выполнения проекта

1. Создаем справочник стоимости доставки в страны `shipping_country_rates` из данных, указанных в `shipping_country` и `shipping_country_base_rate`, делаем первичный ключ таблицы — серийный id, то есть серийный идентификатор каждой строчки. Даем серийному ключу имя «shipping_country_id». Справочник должен состоять из уникальных пар полей из таблицы **shipping**.

2. Создаем справочник тарифов доставки вендора по договору `shipping_agreement` из данных строки `vendor_agreement_description` через разделитель `:`.
    
    Названия полей:
    
    - `agreementid`,
    - `agreement_number`,
    - `agreement_rate`,
    - `agreement_commission`.
    
    `Agreementid` делаем первичным ключом.

3. Создаем справочник о типах доставки `shipping_transfer` из строки `shipping_transfer_description` через разделитель `:`.
    
    Названия полей:
    
    - `transfer_type`,
    - `transfer_model`,
    - `shipping_transfer_rate` .
    
    Делаем первичный ключ таблицы — `transfer_type_id`. 

4. Создаем таблицу `shipping_info` с уникальными доставками `shippingid` и связываем её с созданными справочниками `shipping_country_rates`, `shipping_agreement`, `shipping_transfer` и константной информацией о доставке `shipping_plan_datetime` , `payment_amount` , `vendorid` .

5. Создаем таблицу статусов о доставке `shipping_status` и включаем туда информацию из лога `shipping` (`status` , `state`). Добавляем туда вычисляемую информацию по фактическому времени доставки `shipping_start_fact_datetime`, `shipping_end_fact_datetime` . Отражаем для каждого уникального `shippingid` его итоговое состояние доставки.

6. Создаем представление `shipping_datamart` на основании готовых таблиц для аналитики и включаем в него:
    - `shippingid`
    - `vendorid`
    - `transfer_type` — тип доставки из таблицы `shipping_transfer`
    - `full_day_at_shipping` — количество полных дней, в течение которых длилась доставка. Высчитывается как:`shipping_end_fact_datetime`-`shipping_start_fact_datetime`.
        - `is_delay` — статус, показывающий просрочена ли доставка. Высчитывается как:`shipping_end_fact_datetime` > `shipping_plan_datetime` → 1 ; 0
    - `is_shipping_finish` — статус, показывающий, что доставка завершена. Если финальный `status` = finished → 1; 0
    - `delay_day_at_shipping` — количество дней, на которые была просрочена доставка. Высчитывается как: `shipping_end_fact_datetime` > `shipping_end_plan_datetime` → `shipping_end_fact_datetime` − `shipping_plan_datetime` ; 0).
    - `payment_amount` — сумма платежа пользователя
    - `vat` — итоговый налог на доставку. Высчитывается как: `payment_amount` ∗ ( `shipping_country_base_rate` + `agreement_rate` + `shipping_transfer_rate`) .
    - `profit` — итоговый доход компании с доставки. Высчитывается как: `payment_amount`∗ `agreement_commission`.
## Итоговый вид таблицы

В результате получили следующую схему:

<img width="1475" alt="Screenshot_2022-05-16_at_15 13 37_1652802660" src="https://github.com/ermakoov/Revising-the-online-stores-data-model./assets/159540686/25916101-77d3-4f4a-9a04-52ddabdb3da6">
