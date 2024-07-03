-- Task 1

SELECT product_id,
       name,
       price
FROM   products

-- Task 2

SELECT *
FROM   products
ORDER BY name

-- Task 3

SELECT *
FROM   courier_actions
ORDER BY courier_id, action, time desc limit 1000

-- Task 4

SELECT name,
       price
FROM   products
ORDER BY price desc limit 5

-- Task 5

SELECT name as product_name,
       price as product_price
FROM   products
ORDER BY price desc limit 5

-- Task 6

SELECT name,
       length(name) as name_length,
       price
FROM   products
ORDER BY name_length desc limit 1

-- Task 7

SELECT name,
       upper(split_part(name, ' ', 1)) as first_word,
       price
FROM   products
ORDER BY name

-- Task 8

SELECT name,
       price,
       cast(price as varchar) as price_char
FROM   products
ORDER BY name

-- Task 9

SELECT concat('Заказ № ', order_id, ' создан ', date(creation_time)) as order_info
FROM   orders limit 200

-- Task 10

SELECT courier_id,
       date_part('year', birth_date) as birth_year
FROM   couriers
ORDER BY birth_year desc, courier_id

-- Task 11

SELECT courier_id,
       coalesce(cast(date_part('year', birth_date) as varchar), 'unknown') as birth_year
FROM   couriers
ORDER BY birth_year desc, courier_id

-- Task 12

SELECT product_id,
       name,
       price as old_price,
       price + price * 0.05 as new_price
FROM   products
ORDER BY new_price desc, product_id

-- Task 13

SELECT product_id,
       name,
       price as old_price,
       round(price + price * 0.05, 1) as new_price
FROM   products
ORDER BY new_price desc, product_id

-- Task 14

SELECT product_id,
       name,
       price as old_price,
       case when price <= 100 or
                 name = 'икра' then price
            when price > 100 then price*1.05
            else 0 end new_price
FROM   products
ORDER BY new_price desc, product_id

-- Task 15

SELECT product_id,
       name,
       price,
       round(price / 1.2 * 0.2, 2) as tax,
       round(price - price / 1.2 * 0.2, 2) as price_before_tax
FROM   products
ORDER BY price_before_tax desc, product_id

