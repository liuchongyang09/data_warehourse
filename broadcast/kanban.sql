
-- data_pay_num
select
    count(1) as pay_num
     ,count(case when a.type = 1 then 1 end) as point_pay_num
     ,count(case when a.type = 2 then 1 end) as sub_num
     ,ifnull(sum(recharge_amount),0) as total_money
     ,sum(case when a.type = 1 then recharge_amount else 0 end) as point_money
     ,sum(case when a.type = 2 then recharge_amount else 0 end) as sub_money
     ,pay_type
     ,ifnull(b.server_type,'') as server_type
     ,substring(date_add(a.create_time,interval 8 hour),1,10) data_time
     ,from_unixtime(unix_timestamp(now())) as create_time
from studyx_briliansolution6.p_recharge_log a
         left join studyx_briliansolution6.p_user b
                   on a.p_user_id = b.UserGuid
where status = 'COMPLETE'
group by
    ifnull(b.server_type,'')
       ,substring(date_add(a.create_time,interval 8 hour),1,10)
       ,pay_type
;
/*
 data_num
 */
select
    0
     ,count(case when a.CreateDatetime >= '2022-4-26 6:00:00'
    and a.CreateDatetime < ${end_date} and platform != 'root' then 1 end) as total_num
     ,count(case when a.CreateDatetime < ${end_date} and platform != 'root' and edu_id is not null then 1 end) as leaf
     ,count(case when b.p_user_id is  null and a.CreateDatetime >= '2022-4-26 6:00:00' then 1 end)   as eff_num  -- 有效用户数
     ,count(case when b.p_user_id is not null then 1 end)  as core_num -- 核心用户
     ,count(d.p_user_id) --  发题用户数
     ,count(c.p_user_id)  -- 答题用户数
     ,count(case when points_pay!=0 then b.points_pay end)  as points_pay_num    -- 充值购买point用户数
     ,count(case when order_pay !=0 then b.order_pay end)   as order_pay_num -- 订阅付费用户数
     ,sum(points_money)
     ,sum(order_money)
     ,ifnull(server_type,0)
     ,substring(${end_date},1,10) as date_time
     ,from_unixtime(unix_timestamp(now())) as create_date
from studyx_briliansolution6.p_student t
         left join studyx_briliansolution6.p_user a
                   on t.UserGuid = a.UserGuid
         left join (
    select
        p_user_id -- 付费用户
         ,sum(recharge_amount) sum_amount -- 总金额
         , count(case when a.type = 1 then 1 end) as points_pay -- points
         ,count(case when a.type = 2 then 1 end) as order_pay  -- 订阅付费
         ,sum(case when a.type = 1 then recharge_amount else 0 end) as points_money
         ,sum(case when a.type = 2 then recharge_amount else 0 end) as order_money
    from studyx_briliansolution6.p_recharge_log a
             left join studyx_briliansolution6.p_user b
                       on a.p_user_id = b.UserGuid
    where status = 'COMPLETE'
      and a.create_time <  ${end_date}
    group by p_user_id
) b
                   on t.UserGuid = b.p_user_id
         left join (
    select
        p_user_id -- 主动答题用户数 截至29号 151人，其中138人有注册信息，13人没有注册信息，暂时只统计有注册信息的人数
    from studyx_briliansolution6.q_community_answer a
    where
            a.create_time < ${end_date}
      and role !=''
      and role != 10
    group by p_user_id
) c
                   on c.p_user_id = t.UserGuid
         left join (
    SELECT
        p_user_id   -- 发题用户数 750
    FROM studyx_briliansolution6.`q_community_question` a
    where
            create_time   < ${end_date}
      and push_type in (0,3)
    group by p_user_id
)d
                   on t.UserGuid = d.p_user_id
group by ifnull(server_type,0)
;
/*

 */
select
    0
     ,count(distinct user_id)
     ,''
     ,count(distinct case when pageId1 like 'matching_results%'
    and event = 'Exposure'
    and actionId = 'search' then user_id end) as search_num -- 每日搜题行为账号数
     ,count(distinct case when `event` = 'click'
    and pageId1 LIKE '%matching_details%'
    and (actionId like '%Confirm2-%' or actionId like '%unlock the answer-%') then user_id end)  as unlock_num  -- 每日解锁行为账号数
     ,''
     ,count(case when pageId1 like 'matching_results%'
    and event = 'Exposure'
    and actionId = 'search' then 1 end) as search_cnt  -- 每日搜索次数
     ,count( case when `event` = 'click'
    and pageId1 LIKE '%matching_details%'
    and (actionId like '%Confirm2-%' or actionId like '%unlock the answer-%') then 1 end)  as unlock_cnt  -- 每日解锁按钮点击次数
     ,count(case when `event` = 'click'
    AND pageId1 LIKE '%matching_details%'
    and actionId = 'Confirm2-1' then 1 end) as succ_unlock_cnt -- 每日成功解锁次数
     ,''
     ,''
     ,''
     ,''
     ,''
     ,count(distinct case when event = 'click'
    and actionId = 'Unlock the answer'
    and platform = '6'
    and pageId1 like '%es=%' then substring_index(substring_index(pageId1,'es=',-1),'#',1) end)/
      count(case when pageId1 like 'matching_results%' and event = 'Exposure' and actionId = 'search' then 1 end) as search_rate   -- 搜题解锁率
     ,count(case when `event` = 'click'
    AND pageId1 LIKE '%matching_details%'
    and actionId = 'Confirm2-1' then 1 end)/
      count(case when pageId1 like 'matching_results%'and event = 'Exposure'and actionId = 'search' then 1 end) as unlock_succ_rate -- 搜题解锁成功率
     ,ifnull(data9,0)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) data_time
     ,from_unixtime(unix_timestamp(now())) create_time
from studyx_big_log.user_buried_point_log
where  server_time_fmt < ${end_time}
  and server_time_fmt >= ${start_time}
group by
    ifnull(data9,0)
       ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
;