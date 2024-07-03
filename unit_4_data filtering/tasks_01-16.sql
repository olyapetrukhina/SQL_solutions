-- Task 1

SELECT product_id,
       name,
       price
FROM   products
WHERE  price <= 100
ORDER BY product_id

-- Task 2

SELECT user_id
FROM   users
WHERE  sex = 'female'
ORDER BY user_id limit 1000

-- Task 3

SELECT user_id,
       order_id,
       time
FROM   user_actions
WHERE  action = 'create_order'
   and time > '2022-09-06'
ORDER BY order_id

-- Task 4

SELECT product_id,
       name,
       price as old_price,
       price * 0.8 as new_price
FROM   products
WHERE  price * 0.8 > 100
ORDER BY product_id

-- Task 5

SELECT product_id,
       name
FROM   products
WHERE  split_part(name, ' ', 1) = 'чай'
    or length(name) = 5
ORDER BY product_id

-- Task 6

SELECT product_id,
       name
FROM   products
WHERE  name like '%чай%'
ORDER BY product_id

-- Task 7

SELECT product_id,
       name
FROM   products
WHERE  name like 'с%'
   and name not like '% %'
ORDER BY product_id

-- Task 8

SELECT product_id,
       name,
       price,
       '25%' as discount,
       price * 0.75 as new_price
FROM   products
WHERE  price > 60
   and name like '%чай%'
   and name not like '%гриб%'
ORDER BY product_id

-- Task 9

SELECT user_id,
       order_id,
       action,
       time
FROM   user_actions
WHERE  user_id in (170, 200, 230)
   and time >= '2022-08-25'
   and time < '2022-09-05'
ORDER BY order_id desc

-- Task 10

SELECT birth_date,
       courier_id,
       sex
FROM   couriers
WHERE  birth_date is null
ORDER BY courier_id

-- Task 11

SELECT user_id,
       birth_date
FROM   users
WHERE  sex = 'male'
   and birth_date is not null
ORDER BY birth_date desc limit 50

-- Task 12

SELECT order_id,
       time
FROM   courier_actions
WHERE  courier_id = 100
   and action = 'deliver_order'
ORDER BY time desc limit 10

-- Task 13

SELECT order_id
FROM   user_actions
WHERE  action = 'create_order'
   and date_part('year', time) = 2022
   and date_part('month', time) = 08
ORDER BY order_id

-- Task 14

SELECT courier_id
FROM   couriers
WHERE  date_part('year', birth_date) between 1990
   and 1995
ORDER BY courier_id

-- Task 15

SELECT user_id,
       order_id,
       action,
       time
FROM   user_actions
WHERE  action = 'cancel_order'
   and date_part('dow', time) = 3
   and date_part('month', time) = 8
   and date_part('year', time) = 2022 
   and date_part('hour', time) >= 12
   and date_part('hour', time) < 16
ORDER BY order_id desc

-- Task 16

SELECT product_id,
       name,
       price,
       case when name in ('сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное', 'виноград', 'масло оливковое', 'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 'овсянка', 'макароны', 'баранина', 'апельсины', 'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины') then round(price / 1.1 * 0.1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         2)
            else round(price / 1.2 * 0.2, 2) end as tax,
       case when name in ('сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное', 'виноград', 'масло оливковое', 'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 'овсянка', 'макароны', 'баранина', 'апельсины', 'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины') then round(price - price / 1.1 * 0.1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         2)
            else round(price - price / 1.2 * 0.2, 2) end as price_before_tax
FROM   products
ORDER BY price_before_tax desc, product_id
