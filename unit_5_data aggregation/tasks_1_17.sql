-- Task 1

SELECT DISTINCT user_id
FROM   user_actions
ORDER BY user_id

-- Task 2

SELECT DISTINCT courier_id,
                order_id
FROM   courier_actions
ORDER BY courier_id, order_id

-- Task 3

SELECT max(price) as max_price,
       min(price) as min_price
FROM   products

-- Task 4

SELECT count(*) as dates,
       count(birth_date) as dates_not_null
FROM   users

-- Task 5

SELECT count(user_id) as users,
       count(distinct user_id) as unique_users
FROM   user_actions

-- Task 6

SELECT count(distinct courier_id) as couriers
FROM   couriers
WHERE  sex = 'female'

-- Task 7

SELECT count(distinct courier_id) as couriers
FROM   couriers
WHERE  sex = 'female'

-- Task 8

SELECT sum(price) as order_price
FROM   products
WHERE  name = 'сухарики'
    or name = 'чипсы'
    or name = 'энергетический напиток'

-- Task 9

SELECT count(order_id) as orders
FROM   orders
WHERE  array_length(product_ids, 1) >= 9

-- Task 10

SELECT age(max(birth_date))::varchar as min_age
FROM   couriers
WHERE  sex = 'male'

-- Task 11

SELECT sum(case when name = 'сухарики' then price * 3
                when name = 'чипсы' then price * 2
                when name = 'энергетический напиток' then price
                else 0 end) as order_price
FROM   products

-- Task 12

SELECT round(avg(price), 2) as avg_price
FROM   products
WHERE  (name like '%чай%'
    or name like '%кофе%')
   and (name not like '%гриб%'
   and name not like '%иван-чай%')

-- Task 13

SELECT age(max(birth_date), min(birth_date))::varchar as age_diff
FROM   users
WHERE  sex = 'male'

-- Task 14

SELECT round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM   orders
WHERE  date_part('dow', creation_time) = 6
    or date_part('dow', creation_time) = 0

-- Task 15

SELECT count(distinct user_id) as unique_users,
       count(distinct order_id) as unique_orders,
       round(count(distinct order_id)::decimal /count(distinct user_id)::decimal,
             2) as orders_per_user
FROM   user_actions

-- Task 16

SELECT count(distinct user_id) - (count(distinct user_id) filter (WHERE action = 'cancel_order')) as users_count
FROM   user_actions

-- Task 17

SELECT count(order_id) as orders,
       count(case when array_length(product_ids, 1) >= 5 then order_id end) as large_orders,
       round(count(case when array_length(product_ids, 1) >= 5 then order_id end)::decimal / count(order_id)::decimal,
             2) as large_orders_share
FROM   orders;
