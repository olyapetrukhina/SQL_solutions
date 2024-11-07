-- Task 2

SELECT round(avg(number_), 2) as orders_avg
FROM   (SELECT count(user_id) as number_
        FROM   user_actions
        WHERE  action = 'create_order'
        GROUP BY user_id) as sub_1

-- Task 3

with sub_1 as (SELECT count(user_id) as number_
               FROM   user_actions
               WHERE  action = 'create_order'
               GROUP BY user_id)
SELECT round(avg(number_), 2) as orders_avg
FROM   sub_1

-- Task 4

SELECT product_id,
       name,
       price
FROM   products
WHERE  price != (SELECT min(price)
                 FROM   products)
ORDER BY product_id desc

-- Task 5

SELECT product_id,
       name,
       price
FROM   products
WHERE  price >= (SELECT avg(price)
                 FROM   products) + 20
ORDER BY product_id desc

-- Task 6

SELECT count(distinct user_id) as users_count
FROM   user_actions
WHERE  time >= (SELECT max(time)
                FROM   user_actions) - interval '1 week'

-- Task 7

SELECT min(age(((SELECT max(time :: date)
                 FROM   courier_actions)), birth_date)):: varchar as min_age
FROM   couriers
WHERE  sex = 'male'

-- Task 8

with cancelled_orders as (SELECT order_id
                          FROM   user_actions
                          WHERE  action = 'cancel_order')
SELECT order_id
FROM   user_actions
WHERE  order_id not in (SELECT *
                        FROM   cancelled_orders)
ORDER BY order_id limit 1000

-- Task 9

with counts as (SELECT user_id,
                   count(order_id) as orders_count
            FROM   user_actions
            WHERE  action = 'create_order'
            GROUP BY user_id)
SELECT user_id,
       orders_count,
       round((SELECT avg(orders_count)
       FROM   counts), 2) as orders_avg, orders_count - round((SELECT avg(orders_count)
                                                    FROM   counts), 2) as orders_diff
FROM   counts
ORDER BY user_id limit 1000

-- Task 10

with average_price as (SELECT round(avg(price), 2) as avg_price
                       FROM   products)
SELECT product_id,
       name,
       price,
       case when price >= (SELECT avg_price
                    FROM   average_price) + 50 then price * 0.85 when price <= (SELECT avg_price
                                                            FROM   average_price) - 50 then price * 0.90 else price end as new_price
FROM   products
ORDER BY price desc, product_id

-- Task 11

select count(order_id) as orders_count
from courier_actions
where action = 'accept_order' and order_id not in (select order_id from courier_actions where action = 'deliver_order')

-- Task 12

SELECT count(order_id) as orders_canceled,
       count(order_id) filter (WHERE action = 'deliver_order') as orders_canceled_and_delivered
FROM   courier_actions
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order')

-- Task 13

SELECT count(distinct order_id) as orders_canceled,
       count(order_id) filter (WHERE action = 'deliver_order') as orders_canceled_and_delivered
FROM   courier_actions
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order')

-- Task 14

SELECT count(distinct order_id) as orders_undelivered,
       count(order_id) filter (WHERE action = 'cancel_order') as orders_canceled,
       count(distinct order_id) - count(order_id) filter (WHERE action = 'cancel_order') as orders_in_process
FROM   user_actions
WHERE  order_id not in (SELECT order_id
                        FROM   courier_actions
                        WHERE  action = 'deliver_order')

-- Task 15

SELECT user_id,
       birth_date
FROM   users
WHERE  sex = 'male'
   and birth_date < (SELECT min(birth_date)
                  FROM   users
                  WHERE  sex = 'female')
ORDER BY user_id

-- Task 16

SELECT order_id,
       product_ids
FROM   orders
WHERE  order_id in (SELECT order_id
                    FROM   courier_actions
                    WHERE  action = 'deliver_order'
                    ORDER BY time desc limit 100)
ORDER BY order_id

-- Task 17

SELECT courier_id,
       birth_date,
       sex
FROM   couriers
WHERE  courier_id in (SELECT courier_id
                      FROM   courier_actions
                      WHERE  action = 'deliver_order'
                         and date_part('year', time) = 2022
                         and date_part('month', time) = 09
                      GROUP BY courier_id having count(distinct order_id) >= 30)
ORDER BY courier_id

-- Task 18

with male_orders as (SELECT user_id as var_1
                     FROM   users
                     WHERE  sex = 'male'), cancelled_orders as (SELECT order_id as var_2
                                           FROM   user_actions
                                           WHERE  user_id in (SELECT var_1
                                                              FROM   male_orders) and action = 'cancel_order')
SELECT round(avg(array_length(product_ids, 1)), 3) as avg_order_size
FROM   orders
WHERE  order_id in (SELECT var_2
                    FROM   cancelled_orders)

-- Task 19

with user_ages as(SELECT user_id,
                         date_part('year', age((SELECT max(time)
                                         FROM   user_actions), birth_date))::integer as age
                  FROM   users)
SELECT user_id,
       coalesce(age, (SELECT avg(age)
               FROM   user_ages))::integer as age
FROM   user_ages
ORDER BY user_id

-- Task 20

SELECT DISTINCT order_id,
                min(time) as time_accepted,
                max(time) as time_delivered,
                extract(epoch
FROM   (max(time) - min(time))/60)::integer as delivery_time
FROM   courier_actions
WHERE  order_id in (SELECT order_id
                    FROM   orders
                    WHERE  array_length(product_ids, 1) > 5)
   and order_id not in (SELECT order_id
                     FROM   user_actions
                     WHERE  action = 'cancel_order')
GROUP BY order_id
ORDER BY order_id

-- Task 21

select first_date as date, count(user_id) as first_orders
from (select user_id, min(time)::date as first_date
    from user_actions 
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by user_id) as t1
group by date
order by date

-- Task 22
  
 SELECT creation_time,
       order_id,
       product_ids,
       unnest(product_ids) as product_id
FROM   orders limit 100

-- Task 23

SELECT product_id,
       times_purchased
FROM   (SELECT unnest(product_ids) as product_id,
               count(*) as times_purchased
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY product_id
        ORDER BY times_purchased desc limit 10) t
ORDER BY product_id

-- Task 24

with most_exp as(SELECT product_id
                 FROM   products
                 ORDER BY price desc limit 5), unnested as (SELECT order_id,
                                                  product_ids,
                                                  unnest(product_ids) as product_id
                                           FROM   orders)
SELECT DISTINCT order_id,
                product_ids
FROM   unnested
WHERE  product_id in (SELECT *
                      FROM   most_exp)
ORDER BY order_id

