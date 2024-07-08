-- Task 1

SELECT t1.user_id as user_id_left,
       t2.user_id as user_id_right,
       t1.order_id,
       t1.time,
       t1.action,
       t2.sex,
       t2.birth_date
FROM   user_actions as t1 join users as t2
        ON t1.user_id = t2.user_id
ORDER BY t1.user_id

-- Task 2

SELECT count(distinct a.user_id) as users_count
FROM   user_actions a join users b using (user_id)

-- Task 3

SELECT t1.user_id as user_id_left,
       t2.user_id as user_id_right,
       t1.order_id as order_id,
       t1.time,
       t1.action,
       t2.sex,
       t2.birth_date 
FROM   user_actions as t1
    LEFT JOIN users as t2 using(user_id)
ORDER BY t1.user_id

-- Task 4

SELECT count(distinct a.user_id) as users_count
FROM   user_actions a
    LEFT JOIN users b using (user_id)

-- Task 5

SELECT t1.user_id as user_id_left,
       t2.user_id as user_id_right,
       t1.order_id,
       t1.time,
       t1.action,
       t2.sex,
       t2.birth_date as birth_date
FROM   user_actions as t1
    LEFT JOIN users as t2 using(user_id)
WHERE  t2.user_id is not null
ORDER BY t1.user_id

-- Task 6

with t1 as(SELECT birth_date,
                  count(user_id) as users_count
           FROM   users
           WHERE  birth_date is not null
           GROUP BY birth_date), t2 as(SELECT birth_date,
                                   count(courier_id) as couriers_count
                            FROM   couriers
                            WHERE  birth_date is not null
                            GROUP BY birth_date)
  
SELECT t1.birth_date as users_birth_date,
       t1.users_count,
       t2.birth_date as couriers_birth_date,
       t2.couriers_count
FROM   t1 full join t2 using(birth_date)
ORDER BY t1.birth_date, t2.birth_date


-- Task 7

with t1 as(SELECT birth_date
           FROM   users
           WHERE  birth_date is not null
           UNION
SELECT birth_date
           FROM   couriers
           WHERE  birth_date is not null)
SELECT count(distinct birth_date) as dates_count
FROM   t1

-- Task 8

with t1 as(SELECT user_id
           FROM   users limit 100)
  
SELECT t1.user_id,
       t2.name
FROM   t1 cross join products as t2
ORDER BY t1.user_id, t2.name

-- Task 9

SELECT t1.user_id,
       t1.order_id,
       t2.product_ids
FROM   user_actions as t1 full join orders as t2 using(order_id)
ORDER BY user_id, order_id limit 1000

-- Task 10

with t1 as(SELECT DISTINCT user_id,
                           order_id
           FROM   user_actions
           WHERE  order_id not in (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order'))
SELECT t1.user_id,
       t1.order_id,
       t2.product_ids
FROM   t1
    LEFT JOIN orders as t2 using(order_id)
ORDER BY user_id, order_id limit 1000

-- Task 11

with t1 as (SELECT DISTINCT ua.user_id,
                            ua.order_id,
                            o.product_ids
            FROM   user_actions as ua
                LEFT JOIN orders as o using(order_id)
            WHERE  ua.order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order'))
SELECT user_id,
       round(sum(array_length(product_ids, 1))::decimal / count(order_id),
             2) as avg_order_size
FROM   t1
GROUP BY user_id
ORDER BY user_id limit 1000

-- Task 12

with t1 as(SELECT order_id,
                  unnest(product_ids) as product_id
           FROM   orders)
SELECT t1.order_id,
       t1.product_id,
       t2.price
FROM   t1
    LEFT JOIN products as t2 using(product_id)
ORDER BY order_id, product_id limit 1000

-- Task 13

SELECT order_id,
       sum(price) as order_price
FROM   (SELECT order_id,
               product_ids,
               unnest(product_ids) as product_id
        FROM   orders) t1
    LEFT JOIN products using(product_id)
GROUP BY order_id
ORDER BY order_id limit 1000

-- Task 14

SELECT user_id,
       count(order_price) as orders_count,
       round(avg(order_size), 2) as avg_order_size,
       sum(order_price) as sum_order_value,
       round(avg(order_price), 2) as avg_order_value,
       min(order_price) as min_order_value,
       max(order_price) as max_order_value
FROM   (SELECT user_id,
               order_id,
               array_length(product_ids, 1) as order_size
        FROM   (SELECT user_id,
                       order_id
                FROM   user_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN orders using(order_id)) t2
    LEFT JOIN (SELECT order_id,
                      sum(price) as order_price
               FROM   (SELECT order_id,
                              product_ids,
                              unnest(product_ids) as product_id
                       FROM   orders
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')) t3
                   LEFT JOIN products using(product_id)
               GROUP BY order_id) t4 using (order_id)
GROUP BY user_id
ORDER BY user_id limit 1000

-- Task 15

SELECT date(creation_time) as date,
       sum(price) as revenue
FROM   (SELECT order_id,
        creation_time,
        unnest(product_ids) as product_id
FROM   orders
WHERE  order_id not in (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')) as t
left join products using(product_id)                                   
GROUP BY date
ORDER BY date


-- Task 16

WITH orders_delivered_sep2022 AS (
    SELECT DISTINCT order_id
    FROM courier_actions
    WHERE date_part('month', time) = 9
      AND date_part('year', time) = 2022
      AND action = 'deliver_order'
),
items_delivered_sep2022 AS (
    SELECT t1.order_id, unnest(t2.product_ids) AS product_id
    FROM orders_delivered_sep2022 t1
    JOIN orders t2 USING (order_id)
),
distinct_items AS (
    SELECT t1.order_id, t1.product_id, t2.name
    FROM items_delivered_sep2022 t1
    JOIN products t2 USING (product_id)
)
SELECT name, COUNT(name) AS times_purchased
FROM distinct_items
GROUP BY name
ORDER BY times_purchased DESC
LIMIT 10

-- Task 17

SELECT coalesce(sex, 'unknown') as sex,
       round(avg(cancel_rate), 3) as avg_cancel_rate
FROM   (SELECT user_id,
               sex,
               count(distinct order_id) filter (WHERE action = 'cancel_order')::decimal / count(distinct order_id) as cancel_rate
        FROM   user_actions
            LEFT JOIN users using(user_id)
        GROUP BY user_id, sex
        ORDER BY cancel_rate desc) t
GROUP BY sex
ORDER BY sex

-- Task 18

SELECT order_id
FROM   (SELECT order_id,
               time as delivery_time
        FROM   courier_actions
        WHERE  action = 'deliver_order') as t
    LEFT JOIN orders using (order_id)
ORDER BY delivery_time - creation_time desc limit 10

-- Task 19

SELECT order_id,
       array_agg(name) as product_names
FROM   (SELECT order_id, unnest(product_ids) as product_id FROM   orders) t
left join products using(product_id)
GROUP BY order_id limit 1000

-- Task 20

with couriers_age as (SELECT courier_id,
                             extract(year
                      FROM   age((SELECT max(time)
                                  FROM   user_actions), birth_date)) as courier_age
                      FROM   couriers), users_age as (SELECT user_id,
                                       extract(year
                                FROM   age((SELECT max(time)
                                            FROM   user_actions), birth_date)) as user_age
                                FROM   users), top_orders as (SELECT c.courier_id,
                                     c.order_id,
                                     u.user_id,
                                     o.product_ids
                              FROM   courier_actions c
                                  LEFT JOIN user_actions u using(order_id)
                                  LEFT JOIN orders o using(order_id)
                              WHERE  c.action = 'deliver_order'
                                 and u.action = 'create_order'
                              ORDER BY array_length(o.product_ids, 1) desc limit 5)
SELECT t.order_id,
       t.user_id,
       ua.user_age::int,
       t.courier_id,
       ca.courier_age::int
FROM   top_orders t
    LEFT JOIN couriers_age ca using(courier_id)
    LEFT JOIN users_age ua using(user_id)
ORDER BY t.order_id
