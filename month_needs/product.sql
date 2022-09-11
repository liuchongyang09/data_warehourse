/*
 用户支付明细数据
 */
select
    b.user_id
     ,a.create_time
     ,substring(date_add(a.create_time,interval 8 hour),1,10) dt
     ,case when a.type = 1 then 'points充值'
           when a.type = 2 then '会员订阅充值'
           else a.type end as type
     ,case when a.pay_type = 0 then 'PayPal'
           when a.pay_type = 1 then 'apple'
           when a.pay_type = 3 then 'google'
           when a.pay_type = 4 then 'stripe'
           when a.pay_type = 2 then 'stripe会员订阅充值'
           else pay_type end as pay_type
     ,recharge_amount
     ,points
from studyx_briliansolution6.p_recharge_log a
         left join studyx_briliansolution6.p_student b
                   on a.p_user_id = b.UserGuid
where a.create_time between ${start_time} and ${end_time}
  and status = 'COMPLETE'
;
/*
用户消耗points明细记录
 */

select
    b.user_id
     ,a.create_time
     ,a.points_num
     ,num
     ,a.charge_money
     ,c.CreateDatetime
from studyx_briliansolution6.p_points_detatiled a
         left join studyx_briliansolution6.p_student b
                   on a.p_user_id = b.UserGuid
         left join studyx_briliansolution6.p_user c
                   on a.p_user_id = c.UserGuid
where info_status = 0
  and a.create_time between ${start_time} and ${end_time}
;
/*
 用户消耗points汇总表
 */
select
    b.user_id
     ,sum(a.points_num) -- 消耗points数
     ,count(a.points_num) ct -- 消耗points次数
from studyx_briliansolution6.p_points_detatiled a
         left join studyx_briliansolution6.p_student b
                   on a.p_user_id = b.UserGuid
         left join studyx_briliansolution6.p_user c
                   on a.p_user_id = c.UserGuid
where info_status = 0
  and a.create_time between ${start_time} and ${end_time}
group by
    b.user_id
;
/*
 1.支付入口曝光次数（出现积分不足的次数）
 */

select
    count(1)
     ,count(distinct user_id)
     ,user_id
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
    #      ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'click'
  and pageId1 like 'matching_details%'
  and actionId in ('Unlock the answer-a' ,'Confirm2-2')
-- and user_id > '0'
  and platform = '6'
  AND server_time_fmt between ${start_date} and ${end_date}
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
    #        , data9
       ,user_id
;

-- 4. 点击Pay Now按钮的次数。
select
    count(1)
     ,user_id
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
    #      ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'pv'
  and pageId1 like 'matching_details%'
  and actionId = 'pay'
  and actionData = 'succeeded'
  and user_id > '0'
  and platform = '6'
  AND server_time_fmt between ${start_date} and ${end_date}
group by
    substring(date_add(server_time_fmt,interval 8 hour),1,10)
    #        ,data9
       ,user_id
;
/*
 用户注册相关
 */

select
    count(case when t.platform != 'robot'
              and  t.channel_code IN (SELECT DISTINCT invite_code FROM studyx_briliansolution6.channel_config)
              AND (t.dc_code is null or t.dc_code='')
          then 1 end)                                     as dc_reg_num             -- dc注册
     ,count(case when  t.platform != 'robot'
    and channel_code is not null
    and channel_code!=''
    and channel_code not  in(select invite_code from studyx_briliansolution6.channel_config)
    and (dc_code is null or dc_code = '')
                     then 1 end)                                    as usr_inv_reg_num       -- 用户邀请注册
     ,count(case when  t.platform != 'robot'
                and ( t.channel_code is null or t.channel_code='')
                and dc_code is null
            then 1 end)                                    as usr_person_reg_num  -- 用户自行注册
     ,count(case when dc_code is not null
    AND t.platform != 'robot'
                     then 1 end)                                    as suite_reg_num         -- suite端注册人数

FROM
    studyx_briliansolution6.p_student t
        LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
WHERE
        u.CreateDatetime >= '2022-4-26 6:00:00'
  and u.CreateDatetime <= ${end_time}
;
-------------------------------------------------
SELECT
    count(case when t.platform != 'robot' then 1 end) as add_usr_num -- 新增用户数
     ,count(case when edu_id IS NOT NULL then 1 end ) as add_liuzi_num -- 新增留资人数
FROM
    studyx_briliansolution6.p_student t
        LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
WHERE

    u.CreateDatetime between ${start_time} and ${end_time}
;
/*
 新用户邀请明细
 */

select
    a.user_id '新注册用户',b.user_id '被邀请注册用户', a.invite_code '个人邀请码',b.channel_code ,a.CreateDatetime,b.CreateDatetime
from (
         select
             u.CreateDatetime
              , t.user_id   -- 新注册用户
              , channel_code
              , dc_code
              , invite_code -- 个人邀请码
              , substring(date_add(u.CreateDatetime, interval 8 hour), 1, 10) as dt
         FROM studyx_briliansolution6.p_student t
                  LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
         WHERE u.CreateDatetime between ${start_time} and ${end_time}
           and t.platform != 'robot'
     ) a
         right join
     (
         select
             t.user_id
              , channel_code
              , u.CreateDatetime
              , substring(date_add(u.CreateDatetime, interval 8 hour), 1, 10) as dt
         FROM studyx_briliansolution6.p_student t
                  LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
         WHERE t.platform != 'robot'
           and channel_code is not null
           and channel_code != ''
           and channel_code not in (select invite_code from studyx_briliansolution6.channel_config)
           and (dc_code is null or dc_code = '') -- 用户邀请注册
           and  u.CreateDatetime between ${start_time} and ${end_time}
     )b
     on a.invite_code = b.channel_code
where b.user_id is not null and  a.user_id is not null