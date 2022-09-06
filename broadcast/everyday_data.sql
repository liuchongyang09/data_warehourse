-------------------------
select
    count(1) -- web搜题曝光次数
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
     ,data9
from studyx_big_log.user_buried_point_log ubpl
where
    server_time_fmt between '${start_date}' and '${end_date}'
  and  event = 'Exposure'
  and pageId1 like '%matching_results?%'
  and actionId = 'search'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;
----------------------------------

SELECT
    count(DISTINCT data5 ) -- CTR次数
--    ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
--    ,data9
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'pv'
  AND pageId1 LIKE '%#posId%'
  AND pageId1 LIKE '%matching_details%'
  AND server_time_fmt between '${start_date}' and '${end_date}'
-- group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
--    ,data9
;



------------------------------------------------
-- Web端搜索列表点击率 = CTR次数/曝光次数
select
    count(distinct case when event = 'pv' and pageId1 like '%matching_details%'  AND pageId1 LIKE '%#posId%' then data5 end ) as pv_cnt-- ctr次数
     ,count(case when event = 'Exposure' and pageId1 like '%matching_results?%' and actionId = 'search' then 1 end ) as exposure_cnt -- 曝光次数
     , concat( count(distinct case when event = 'pv' and pageId1 like '%matching_details%'  AND pageId1 LIKE '%#posId%' then data5 end )
                   /count(case when event = 'Exposure' and pageId1 like '%matching_results?%' and actionId = 'search' then 1 end )*100,'%') as a
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
--    ,data9
FROM
    studyx_big_log.user_buried_point_log
where server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
--    ,data9
;
--------------------
SELECT
    count(1 ) -- 搜索列表点击view answer次数
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
--    ,data9
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'click'
  AND pageId1 LIKE '%matching_results%'
  and actionId like '%View Answer%'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- , data9
;

-----------------------------------------
-- Web端搜索详情页解锁按钮点击率 = （登录用户解锁 + 未登录用户解锁）/ Web端搜索列表点击view answer次数（Click事件）
select
    dis_log_in_cnt '今日登录用户点击解锁按钮次数(去重)'
     ,log_in '今日登录用户点击解锁按钮的人数'
     ,log_in_cnt '今日登录用户点击解锁按钮次数'
     ,dis_un_log_in_cnt '今日未登录用户点击解锁按钮次数(去重)'
     ,un_log_in '今日未登录用户点击解锁按钮的人数'
     ,un_log_in_cnt '今日未登录用户点击解锁按钮次数'
     ,(dis_log_in_cnt + dis_un_log_in_cnt)  '点击Unlock the answer总次数(去重)'
     ,(dis_log_in_cnt + dis_un_log_in_cnt)/cnt*100 as rate
     ,cnt
-- ,data9
     ,dt
from(
        SELECT
            count(distinct case when user_id > '0' and pageId1 LIKE '%matching_details%' and  actionId = 'unlock the answer' and platform  = '6' then concat( pageId1,user_id) end)  as `dis_log_in_cnt`-- 今日登录用户点击解锁按钮次数(去重)
             ,count(distinct case when user_id !='0' and user_id !='' and user_id is not null and pageId1 LIKE '%matching_details%' and  ( actionId like '%Confirm2-%' or actionId like '%unlock the answer-%' )  then user_id end)  as `log_in`-- 今日登录用户点击解锁按钮的人数
             ,count( case when user_id > '0' and pageId1 LIKE '%matching_details%' and  actionId = 'unlock the answer' and platform  = '6' then 1 end)  as `log_in_cnt`-- 今日登录用户点击解锁按钮次数
             ,count(distinct case when (user_id = '0' or user_id is null) and pageId1 LIKE '%matching_details%' and  actionId = 'unlock the answer' and platform  = '6' then concat (pageId1,ip)  end) as `dis_un_log_in_cnt` -- 今日未登录用户点击解锁按钮次数(去重)
             ,count(distinct case when (user_id = '0' or user_id is null) and pageId1 LIKE '%matching_details%' and  actionId = 'unlock the answer' and platform  = '6' then ip  end) as `un_log_in` -- 今日未登录用户点击解锁按钮的人数
             ,count( case when (user_id = '0' or user_id is null) and pageId1 LIKE '%matching_details%' and  actionId = 'unlock the answer' and platform  = '6' then 1  end) as `un_log_in_cnt` -- 今日未登录用户点击解锁按钮次数
             ,count(case when pageId1 LIKE '%matching_results%' and actionId like '%View Answer%' then 1 end) as cnt -- 搜索列表点击view answer次数
             ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
--     ,data9
        FROM
            studyx_big_log.user_buried_point_log
        WHERE
                `event` = 'click'
          AND server_time_fmt between '${start_date}' and '${end_date}'
        group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- , data9
    )a
;

----------------------------------
-- Web端搜索列表界面访问次数（PV事件）

SELECT
    count(1) --
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
     ,data9
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'pv'
  AND pageId1 LIKE '%matching_result%'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;
-------------------------------------------------------------
-- 搜索详情界面列表点击Unlock the answer总次数
select
    count(1)
--    ,data9
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'click'
  AND pageId1 LIKE '%matching_details%'
  and actionId = 'unlock the answer'
  and platform  = 6
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- , data9
;
-------------
-- 成功解锁
select
    count(1)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     ,data9
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'click'
  AND pageId1 LIKE '%matching_details%'
  and actionId = 'Confirm2-1'
-- and platform  = 6
  and user_id != '0'
  and user_id != ''
  and user_id is not null
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;
------------------
-- 解锁失败
select
    count(1)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     ,data9
from studyx_big_log.user_buried_point_log
where `event` = 'click'
  and pageId1 like '%matching_details%'
  and actionid like 'Unlock the answer-%'
  and client_type=3
  and user_id != '0'
  and user_id != ''
  and user_id is not null
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;
-------------------
-- 积分不足
select
    count(1) -- 出现积分不足次数
     ,count(distinct user_id) -- 积分不足的用户数
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
-- , data9
from studyx_big_log.user_buried_point_log
where `event` = 'click'
  and pageId1 like '%matching_details%'
  and actionid ='unlock the answer-a'
  and client_type=3
  and user_id != '0'
  and user_id != ''
  and user_id is not null
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- , data9
;
----------------------------
-- suite平台 涉及用户数
select
    count(distinct user_id)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     , data9
from studyx_big_log.user_buried_point_log
where client_type=6
  and actionId='unlock the answer'
  and user_id != '0'
  and user_id != ''
  and user_id is not null
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;

----------------------
-- suite平台 ctr次数
select
    count(distinct data5)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     , data9
from studyx_big_log.user_buried_point_log
where client_type=6
  and actionId='unlock the answer'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;
---------------------
-- suite点击 see answers 次数
select
    count(1)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     , data9
from studyx_big_log.user_buried_point_log
where client_type=6
  and actionId='unlock the answer'
  and user_id != '0'
  and user_id != ''
  and user_id is not null
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;
-------------------
-- suite成功解锁
select
    count(1)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     , data9
from studyx_big_log.user_buried_point_log
where client_type=6
  and actionId='confirm2-1'
  and user_id != '0'
  and user_id != ''
  and user_id is not null
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
    ---------------------
-- suite解锁失败
select
    count(1)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
     , data9
from studyx_big_log.user_buried_point_log
where `event` = 'click'
  and locate('unlock the answer-',actionId)>0
  and client_type=6 and user_id>0
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
###########################付费相关#################################################################
-- My Points页面：
    ----------------------------------------
-- 1.支付入口曝光次数
select
    count(1)
     ,count(distinct user_id)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
-- ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'pv'
  and pageId1 like 'my_points%'
  and user_id > '0'
  and platform = '6'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- , data9
;
----------- 唤起结算台的用户id ----------------
select
    user_id
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
     ,data9
     ,ip
-- ,pageId1
from studyx_big_log.user_buried_point_log ubpl
where event = 'click'
  and pageId1 like '%my_points%'
  and actionId like 'points pay%'
  and user_id > '0'
  and platform = '6'
  AND server_time_fmt between '${start_date}' and '${end_date}'
-- and user_id = '1000031279'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
       ,user_id
       ,ip
-- ,pageId1
;

-- 2.支付按钮点击次数（点击Pay $xx.xx的次数）
select
    count(1)
     ,count(distinct user_id)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
-- ,actionId
-- ,pageId1
-- ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'click'
  and pageId1 like '%my_points%'
  and actionId like 'points pay%'
  and user_id > '0'
  and platform = '6'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- ,actionId
-- ,pageId1
-- , data9
;
-- 3.点击Pay $xx.xx按钮后出现Stripe信用卡信息填写框的等待时间；(平均时长)
select
    `date`
     ,data9
     ,sum(TIMESTAMPDIFF(second ,dt , t.server_time_fmt))*1000 as sum_time
     ,sum(TIMESTAMPDIFF(second ,dt , t.server_time_fmt))*1000/count(user_id) as avg_time
from (
         select
             user_id
              ,server_time_fmt
              ,actionId
              ,substring(date_add(server_time_fmt,interval 8 hour),1,10) `date`
              ,data9
              ,@test as dt
              ,@test:= server_time_fmt
         from studyx_big_log.user_buried_point_log a ,(select @test:=0) b
         where (event = 'click' or event = 'Exposure')
           and pageId1 like '%my_points%'
           and (actionId like 'points pay%' or actionId like 'payDom%')
           and user_id > '0'
           and platform = '6'
           AND server_time_fmt between '${start_date}' and '${end_date}'
         group by
             user_id
                ,actionId
                ,server_time_fmt
                ,actionId
                ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
                ,data9
         order by server_time_fmt desc
     )t
where t.dt !=0 and actionId = 'payDom'
group by
    `date`
       ,data9
;
-- 4. 点击Pay Now按钮的次数。
select
    count(1)
     ,user_id
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
     ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'pv'
  and pageId1 like '%my_points%'
  and actionId = 'pay'
  and actionData = 'succeeded'
  and user_id > '0'
  and platform = '6'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by
    substring(date_add(server_time_fmt,interval 8 hour),1,10)
       ,data9
       ,user_id
;
-------------------------------------------
----- 详情页解锁时--------------------------
-- 1.支付入口曝光次数（出现积分不足的次数）
select
    count(1)
     ,count(distinct user_id)
     ,user_id
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
     ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'click'
  and pageId1 like 'matching_details%'
  and actionId in ('Unlock the answer-a' ,'Confirm2-2')
-- and user_id > '0'
  and platform = '6'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
       ,user_id
;
----------- 唤起结算台的用户id-------------
select
    user_id
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
     ,data9
     ,ip
     ,actionId
from studyx_big_log.user_buried_point_log ubpl
where event = 'click'
  and pageId1 like 'matching_details%'
  and actionId in ('Unlock the answer-a' ,'Confirm2-2')
-- and user_id > '0'
  and platform = '6'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
       ,user_id
       ,ip
       ,actionId
;
-- 2.支付按钮点击次数（点击Pay $xx.xx的次数）
select
    count(1)
     ,count(distinct user_id)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
-- ,actionId
-- ,pageId1
     ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'click'
  and pageId1 like 'matching_details%'
  and actionId like 'points pay%'
  and user_id > '0'
  and platform = '6'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- ,actionId
-- ,pageId1
       , data9
;
-- 3.点击Pay $xx.xx按钮后出现Stripe信用卡信息填写框的等待时间；(平均时长)
select
    `date`
     ,data9
     ,sum(TIMESTAMPDIFF(second ,dt , t.server_time_fmt)) as sum_time
     ,sum(TIMESTAMPDIFF(second ,dt , t.server_time_fmt))/count(user_id)*1000 as avg_time
from (
         select
             user_id
              ,server_time_fmt
              ,actionId
              ,substring(date_add(server_time_fmt,interval 8 hour),1,10) `date`
              ,data9
              ,@test as dt
              ,@test:= server_time_fmt
         from studyx_big_log.user_buried_point_log a ,(select @test:=0) b
         where (event = 'click' or event = 'Exposure')
           and pageId1 like 'matching_details%'
           and (actionId like 'points pay%' or actionId like 'payDom%')
           and user_id > '0'
           and platform = '6'
           AND server_time_fmt between '${start_date}' and '${end_date}'
         group by
             user_id
                ,actionId
                ,server_time_fmt
                ,actionId
                ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
                ,data9
         order by server_time_fmt desc
     )t
where t.dt !=0 and actionId = 'payDom'
group by
    `date`
       ,data9
;

-- 4. 点击Pay Now按钮的次数。
select
    count(1)
     ,user_id
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
     ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'pv'
  and pageId1 like 'matching_details%'
  and actionId = 'pay'
  and actionData = 'succeeded'
  and user_id > '0'
  and platform = '6'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by
    substring(date_add(server_time_fmt,interval 8 hour),1,10)
       ,data9
       ,user_id
;