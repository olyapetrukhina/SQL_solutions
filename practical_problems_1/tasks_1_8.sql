-- Task 1

with new_users as(SELECT date,
                         count(distinct user_id) as new_users
                  FROM   (SELECT user_id,
                                 min(date(time)) as date
                          FROM   user_actions
                          GROUP BY user_id
                          ORDER BY user_id) as t
                  GROUP BY date), new_couriers as (SELECT date,
                                        count(distinct courier_id) as new_couriers
                                 FROM   (SELECT courier_id,
                                                min(date(time)) as date
                                         FROM   courier_actions
                                         GROUP BY courier_id
                                         ORDER BY courier_id) as t
                                 GROUP BY date)
SELECT n.date,
       n.new_users,
       c.new_couriers,
       (sum(n.new_users) OVER(ORDER BY n.date))::int as total_users,
       (sum(c.new_couriers) OVER(ORDER BY n.date))::int as total_couriers
FROM   new_users as n
    LEFT JOIN new_couriers as c using(date)
ORDER BY date

-- Task 2

with new_users as(SELECT date,
                         count(distinct user_id) as new_users
                  FROM   (SELECT user_id,
                                 min(date(time)) as date
                          FROM   user_actions
                          GROUP BY user_id
                          ORDER BY user_id) as t
                  GROUP BY date), new_couriers as (SELECT date,
                                        count(distinct courier_id) as new_couriers
                                 FROM   (SELECT courier_id,
                                                min(date(time)) as date
                                         FROM   courier_actions
                                         GROUP BY courier_id
                                         ORDER BY courier_id) as t
                                 GROUP BY date), semi_result as (SELECT n.date,
                                       n.new_users,
                                       c.new_couriers,
                                       (sum(n.new_users) OVER(ORDER BY n.date))::int as total_users,
                                       (sum(c.new_couriers) OVER(ORDER BY n.date))::int as total_couriers
                                FROM   new_users as n
                                    LEFT JOIN new_couriers as c using(date)
                                ORDER BY date)
SELECT date,
       new_users,
       new_couriers,
       total_users,
       total_couriers,
       round((new_users::decimal - lag(new_users) OVER (ORDER BY date)) / lag(new_users) OVER (ORDER BY date) * 100,
             2) as new_users_change,
       round((new_couriers::decimal - lag(new_couriers) OVER (ORDER BY date)) / lag(new_couriers) OVER (ORDER BY date) * 100,
             2) as new_couriers_change,
       round((total_users::decimal - lag(total_users) OVER (ORDER BY date)) / lag(total_users) OVER (ORDER BY date) * 100,
             2) as total_users_growth,
       round((total_couriers::decimal - lag(total_couriers) OVER (ORDER BY date)) / lag(total_couriers) OVER (ORDER BY date) * 100,
             2) as total_couriers_growth
FROM   semi_result
ORDER BY date


-- Task 3

with active_and_paying as(SELECT t1.date,
                                 t1.paying_users,
                                 t2.active_couriers
                          FROM   (SELECT date(time) as date,
                                         count(distinct user_id) as paying_users
                                  FROM   user_actions
                                  WHERE  action = 'create_order'
                                     and order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')
                                  GROUP BY date
                                  ORDER BY date) as t1 full join (SELECT date(time) as date,
                                                                 count(distinct courier_id) as active_couriers
                                                          FROM   courier_actions
                                                          WHERE  (action = 'accept_order'
                                                             and order_id in (SELECT order_id
                                                                           FROM   courier_actions
                                                                           WHERE  action = 'deliver_order'))
                                                              or action = 'deliver_order'
                                                          GROUP BY date) as t2 using(date)), new_users as(SELECT date,
                                                       count(distinct user_id) as new_users
                                                FROM   (SELECT user_id,
                                                               min(date(time)) as date
                                                        FROM   user_actions
                                                        GROUP BY user_id
                                                        ORDER BY user_id) as t
                                                GROUP BY date), new_couriers as (SELECT date,
                                        count(distinct courier_id) as new_couriers
                                 FROM   (SELECT courier_id,
                                                min(date(time)) as date
                                         FROM   courier_actions
                                         GROUP BY courier_id
                                         ORDER BY courier_id) as t
                                 GROUP BY date)
SELECT ap.date,
       ap.paying_users,
       ap.active_couriers,
       round(ap.paying_users::decimal / sum(u.new_users) OVER(ORDER BY u.date) * 100,
             2) as paying_users_share,
       round(ap.active_couriers::decimal / sum(c.new_couriers) OVER(ORDER BY c.date) * 100,
             2) as active_couriers_share
FROM   active_and_paying as ap full join new_users as u using(date) full join new_couriers as c using(date)
ORDER BY date


-- Task 4

with t1 as(SELECT user_id,
                  date(time) as date,
                  case when count(user_id) = 1 then '1'
                       else '> 1' end as number_of_orders
           FROM   user_actions
           WHERE  order_id not in (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')
           GROUP BY user_id, date
           ORDER BY user_id)
SELECT date,
       round(count(distinct user_id) filter(WHERE number_of_orders = '1')::decimal / count(user_id) * 100,
             2) as single_order_users_share,
       round(count(distinct user_id) filter(WHERE number_of_orders = '> 1')::decimal / count(user_id) * 100,
             2) as several_orders_users_share
FROM   t1
GROUP BY date
ORDER BY date

-- Task 5

SELECT date,
       orders,
       first_orders,
       new_users_orders::int,
       round(100 * first_orders::decimal / orders, 2) as first_orders_share,
       round(100 * new_users_orders::decimal / orders, 2) as new_users_orders_share
FROM   (SELECT creation_time::date as date,
               count(distinct order_id) as orders
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
           and order_id in (SELECT order_id
                         FROM   courier_actions
                         WHERE  action = 'deliver_order')
        GROUP BY date) t5
    LEFT JOIN (SELECT first_order_date as date,
                      count(user_id) as first_orders
               FROM   (SELECT user_id,
                              min(time::date) as first_order_date
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')
                       GROUP BY user_id) t4
               GROUP BY first_order_date) t7 using (date)
    LEFT JOIN (SELECT start_date as date,
                      sum(orders) as new_users_orders
               FROM   (SELECT t1.user_id,
                              t1.start_date,
                              coalesce(t2.orders, 0) as orders
                       FROM   (SELECT user_id,
                                      min(time::date) as start_date
                               FROM   user_actions
                               GROUP BY user_id) t1
                           LEFT JOIN (SELECT user_id,
                                             time::date as date,
                                             count(distinct order_id) as orders
                                      FROM   user_actions
                                      WHERE  order_id not in (SELECT order_id
                                                              FROM   user_actions
                                                              WHERE  action = 'cancel_order')
                                      GROUP BY user_id, date) t2
                               ON t1.user_id = t2.user_id and
                                  t1.start_date = t2.date) t3
               GROUP BY start_date) t6 using (date)
ORDER BY date

-- Task 6

SELECT t1.date,
       round(t1.paying_users::decimal/t2.active_couriers, 2) as users_per_courier,
       round(t3.delivered_orders::decimal/t2.active_couriers, 2) as orders_per_courier
FROM   (SELECT date(time) as date,
               count(distinct user_id) as paying_users
        FROM   user_actions
        WHERE  action = 'create_order'
           and order_id not in (SELECT order_id
                             FROM   user_actions
                             WHERE  action = 'cancel_order')
        GROUP BY date
        ORDER BY date) as t1 full join (SELECT date(time) as date,
                                       count(distinct courier_id) as active_couriers
                                FROM   courier_actions
                                WHERE  (action = 'accept_order'
                                   and order_id in (SELECT order_id
                                                 FROM   courier_actions
                                                 WHERE  action = 'deliver_order'))
                                    or action = 'deliver_order'
                                GROUP BY date) as t2 using(date)
    LEFT JOIN (SELECT creation_time::date as date,
                      count (order_id) as delivered_orders
               FROM   orders
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date) as t3 using(date)

-- Task 7

SELECT date,
       round(avg(extract(epoch
FROM   (delivered-accepted)/60)))::integer as minutes_to_deliver
FROM   (SELECT max(time::date) as date,
               order_id,
               max(time) filter (WHERE action = 'accept_order') as accepted,
               max(time) filter (WHERE action = 'deliver_order') as delivered
        FROM   courier_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY order_id, date(time)) t
GROUP BY date
ORDER BY date  
  
-- Task 8

SELECT hour,
       successful_orders,
       canceled_orders,
       round(canceled_orders::decimal / nullif((canceled_orders + successful_orders), 0),
             3) as cancel_rate
FROM   (SELECT date_part('hour', creation_time)::integer as hour,
               count(order_id) filter (WHERE order_id in (SELECT order_id
                                                   FROM   courier_actions
                                                   WHERE  action = 'deliver_order')) as successful_orders, count(order_id) filter (
        WHERE  order_id in (SELECT order_id
                            FROM   user_actions
                            WHERE  action = 'cancel_order')) as canceled_orders
        FROM   orders
        GROUP BY hour
        ORDER BY hour) as t1
