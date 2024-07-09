-- Task 1

SELECT product_id,
       name,
       price,
       row_number() OVER (ORDER BY price desc) as product_number,
       rank() OVER (ORDER BY price desc) as product_rank,
       dense_rank() OVER(ORDER BY price desc) as product_dense_rank
FROM   products

-- Task 2

SELECT product_id,
       name,
       price,
       max(price) OVER () as max_price,
       round(price::decimal/max(price) OVER(), 2) as share_of_max
FROM   products
ORDER BY price desc, product_id

-- Task 3

SELECT product_id,
       name,
       price,
       max(price) OVER (ORDER BY price desc) as max_price,
       min(price) OVER (ORDER BY price desc) as min_price
FROM   products
ORDER BY price desc, product_id

-- Task 4

with daily_orders as(SELECT date(creation_time) as date,
                            count(distinct order_id) as orders_count
                     FROM   orders
                     WHERE  order_id not in (SELECT order_id
                                             FROM   user_actions
                                             WHERE  action = 'cancel_order')
                     GROUP BY date)
SELECT date,
       orders_count,
       (sum(orders_count) OVER(ORDER BY date))::int as orders_cum_count
FROM   daily_orders

-- Task 5

SELECT user_id,
       order_id,
       time,
       row_number() OVER(PARTITION BY user_id
                         ORDER BY time) as order_number
FROM   user_actions
WHERE  order_id not in(SELECT order_id
                       FROM   user_actions
                       WHERE  action = 'cancel_order')
ORDER BY user_id, order_id limit 1000

-- Task 6

SELECT user_id,
       order_id,
       time,
       row_number() OVER(PARTITION BY user_id
                         ORDER BY time) as order_number,
       lag(time, 1) OVER (PARTITION BY user_id) as time_lag,
       time - lag(time, 1) OVER (PARTITION BY user_id) as time_diff
FROM   user_actions
WHERE  order_id not in(SELECT order_id
                       FROM   user_actions
                       WHERE  action = 'cancel_order')
ORDER BY user_id, order_id limit 1000

-- Task 7
  
with t1 as(SELECT user_id,
                  time,
                  extract(epoch
           FROM   (time - lag(time, 1)
           OVER (
           PARTITION BY user_id
           ORDER BY time)) / 3600) as time_diff
           FROM   user_actions
           WHERE  order_id not in(SELECT order_id
                                  FROM   user_actions
                                  WHERE  action = 'cancel_order')
           ORDER BY user_id)
SELECT user_id,
       avg(time_diff)::integer as hours_between_orders
FROM   t1
WHERE  time_diff is not null
GROUP BY user_id limit 1000

-- Task 8

with daily_orders as(SELECT date(creation_time) as date,
                            count(distinct order_id) as orders_count
                     FROM   orders
                     WHERE  order_id not in (SELECT order_id
                                             FROM   user_actions
                                             WHERE  action = 'cancel_order')
                     GROUP BY date)
SELECT date,
       orders_count,
       round(avg(orders_count) OVER(rows between 3 preceding and 1 preceding),
             2) as moving_avg
FROM   daily_orders

-- Task 9

SELECT courier_id,
       count(courier_id) as delivered_orders,
       round(avg(count(courier_id)) OVER(), 2) as avg_delivered_orders,
       case when count(courier_id) > avg(count(courier_id)) OVER() then 1
            else 0 end as is_above_avg
FROM   courier_actions
WHERE  action = 'deliver_order'
   and date_part('year', time) = 2022
   and date_part('month', time) = 9
GROUP BY courier_id
ORDER BY courier_id

-- Task 10

with t1 as(SELECT user_id,
                  order_id,
                  date(time) as date,
                  row_number() OVER(PARTITION BY user_id
                                    ORDER BY time) as order_number,
                  case when row_number() OVER(PARTITION BY user_id
                                              ORDER BY time) = 1 then 'Первый'
                       else 'Повторный' end as order_type
           FROM   user_actions
           WHERE  order_id not in(SELECT order_id
                                  FROM   user_actions
                                  WHERE  action = 'cancel_order'))
SELECT date,
       order_type,
       count(order_type) as orders_count
FROM   t1
GROUP BY date, order_type
ORDER BY date, order_type

-- Task 11

with t1 as(SELECT user_id,
                  order_id,
                  date(time) as date,
                  row_number() OVER(PARTITION BY user_id
                                    ORDER BY time) as order_number,
                  case when row_number() OVER(PARTITION BY user_id
                                              ORDER BY time) = 1 then 'Первый'
                       else 'Повторный' end as order_type
           FROM   user_actions
           WHERE  order_id not in(SELECT order_id
                                  FROM   user_actions
                                  WHERE  action = 'cancel_order'))
SELECT date,
       order_type,
       orders_count,
       round(orders_count/sum(orders_count) OVER (PARTITION BY date), 2) as orders_share
FROM   (SELECT date,
               order_type,
               count(order_type) as orders_count
        FROM   t1
        GROUP BY date, order_type
        ORDER BY date, order_type) as t

-- Task 12

SELECT product_id,
       name,
       price,
       round(avg(price) OVER (), 2) as avg_price,
       round(avg(price) filter (WHERE price != (SELECT max(price)
                                         FROM   products))
OVER (), 2) as avg_price_filtered
FROM   products
ORDER BY price desc, product_id

-- Task 13

SELECT user_id,
       order_id,
       action,
       time,
       count(order_id) filter (WHERE action != 'cancel_order') OVER (PARTITION BY user_id
                                                                     ORDER BY time) as created_orders,
       count(order_id) filter (WHERE action = 'cancel_order') OVER (PARTITION BY user_id
                                                                    ORDER BY time) as canceled_orders,
       round((count(order_id) filter (WHERE action = 'cancel_order') OVER (PARTITION BY user_id
                                                                           ORDER BY time))::decimal / (count(order_id) filter (WHERE action != 'cancel_order') OVER (PARTITION BY user_id ORDER BY time)), 2) as cancel_rate
FROM   user_actions
ORDER BY user_id, order_id, time limit 1000


-- Task 14

SELECT courier_id,
       orders_count,
       courier_rank FROM(SELECT courier_id,
                         count(courier_id) as orders_count,
                         row_number() OVER (ORDER BY count(courier_id) desc, courier_id) as courier_rank
                  FROM   courier_actions
                  WHERE  action = 'deliver_order'
                  GROUP BY courier_id
                  ORDER BY orders_count desc) as t
WHERE  courier_rank <= round((SELECT count(distinct courier_id)
                              FROM   courier_actions)*0.1)

-- Task 15

with courier_days as (SELECT courier_id,
                              min(date(time)) OVER (PARTITION BY courier_id) as first_date,
                              max(date(time)) OVER () as last_date,
                              count(*) filter (WHERE action = 'deliver_order') OVER (PARTITION BY courier_id) as delivered_orders
                       FROM   courier_actions)
SELECT courier_id,
       (last_date - first_date) as days_employed,
       delivered_orders
FROM   courier_days
WHERE  last_date - interval '10 days' >= first_date
GROUP BY courier_id, days_employed, delivered_orders
ORDER BY days_employed desc, courier_id

-- Task 16

with t1 as(SELECT order_id,
                  creation_time,
                  sum(price) as order_price
           FROM   (SELECT order_id,
                          creation_time,
                          product_ids,
                          unnest(product_ids) as product_id
                   FROM   orders
                   WHERE  order_id not in (SELECT order_id
                                           FROM   user_actions
                                           WHERE  action = 'cancel_order')) t3
               LEFT JOIN products using(product_id)
           GROUP BY order_id, creation_time)
SELECT order_id,
       creation_time,
       order_price,
       sum(order_price) OVER(PARTITION BY date(creation_time)) as daily_revenue,
       round(order_price::decimal/sum(order_price) OVER(PARTITION BY date(creation_time)) * 100,
             3) as percentage_of_daily_revenue
FROM   t1
ORDER BY date(creation_time) desc, percentage_of_daily_revenue desc, order_id

-- Task 17

SELECT date,
       round(daily_revenue, 1) as daily_revenue,
       round(coalesce(daily_revenue - lag(daily_revenue, 1) OVER (ORDER BY date), 0),
             1) as revenue_growth_abs,
       round(coalesce(round((daily_revenue - lag(daily_revenue, 1) OVER (ORDER BY date))::decimal / lag(daily_revenue, 1) OVER (ORDER BY date) * 100, 2), 0),
             1) as revenue_growth_percentage
FROM   (SELECT date(creation_time) as date,
               sum(price) as daily_revenue
        FROM   (SELECT order_id,
                       creation_time,
                       product_ids,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN products using(product_id)
        GROUP BY date) t2
ORDER BY date
