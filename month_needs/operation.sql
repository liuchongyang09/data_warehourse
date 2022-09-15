/*
 邀请1-2，3-4，5-6，7人以上的用户数
 */
select
    count(case when ct <=2 then 1 end ) '1-2'
     ,count(case when  ct >= 3 and ct <= 4 then 1 end ) '3-4'
     ,count(case when  ct >= 5 and ct <= 6 then 1 end) '5-6'
     ,count(case when  ct >=7 then 1 end) '7以上'
from (
         select a.user_id
              , invite_code
              , count(a.user_id) ct
         from (
                  select t.user_id   -- 所有用户
                       , invite_code -- 个人邀请码
                  FROM studyx_briliansolution6.p_student t
                           LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
                  WHERE t.platform != 'robot'
              ) a
                  right join
              (
                  select u.CreateDatetime
                       , t.user_id -- 被邀请注册
                       , channel_code
                       , substring(date_add(u.CreateDatetime, interval 8 hour), 1, 10) as dt
                  FROM studyx_briliansolution6.p_student t
                           LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
                  WHERE t.platform != 'robot'
                    and channel_code is not null
                    and channel_code != ''
                    and channel_code not in (select invite_code from studyx_briliansolution6.channel_config)
                    and (dc_code is null or dc_code = '') -- 用户邀请注册
                    and u.CreateDatetime between ${start_time} and ${end_time}
              ) b
              on a.invite_code = b.channel_code
         where a.user_id is not null and b.user_id is not null
         group by invite_code
                , a.user_id
     )a
;
/*
 首次邀请注册间隔时间
 */
SELECT
    sum(reg_user_id)
     ,count(reg_user_id)
     ,count(1)
     ,SUM(diff)/count(reg_user_id)/60/24 -- 首次邀请间隔时间
FROM (
         select b.user_id as reg_user_id
              , b.invite_code
              , a.user_id
              , a.channel_code
              , b.CreateDatetime                                             '用户注册时间'
              , a.CreateDatetime                                             '被邀人注册时间'
              , TIMESTAMPDIFF(MINUTE, b.CreateDatetime, a.CreateDatetime) as diff
         from (
                  select u.CreateDatetime
                       , t.user_id -- 被邀请注册
                       , channel_code
                       , substring(date_add(u.CreateDatetime, interval 8 hour), 1, 10) as dt
                  FROM studyx_briliansolution6.p_student t
                           LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
                  WHERE t.platform != 'robot'
                    and channel_code is not null
                    and channel_code != ''
                    and channel_code not in (select invite_code from studyx_briliansolution6.channel_config)
                    and (dc_code is null or dc_code = '') -- 用户邀请注册
                    and u.CreateDatetime between ${start_time} and ${end_time}
              ) a
                  left join
              (
                  select t.user_id, -- 新注册用户
                         t.invite_code,
                         channel_code,
                         u.CreateDatetime
                  from studyx_briliansolution6.p_student t
                           LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
                  where u.CreateDatetime between ${start_time} and ${end_time}
              ) b
              on a.channel_code = b.invite_code
         where a.user_id is not null
           and b.user_id is not null
         group by b.user_id
     )A
;
/*
 发生邀请的总人数、个人合计邀请
 */

select
    count(1)                   -- 发生邀请的总人数
   ,count(distinct a.user_id)  -- 个人合计邀请
from (
         select t.user_id   -- 所有用户
              , invite_code -- 个人邀请码
         FROM studyx_briliansolution6.p_student t
                  LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
         WHERE t.platform != 'robot'
     ) a
         right join
     (
         select u.CreateDatetime
              , t.user_id -- 被邀请注册
              , channel_code
              , substring(date_add(u.CreateDatetime, interval 8 hour), 1, 10) as dt
         FROM studyx_briliansolution6.p_student t
                  LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
         WHERE t.platform != 'robot'
           and channel_code is not null
           and channel_code != ''
           and channel_code not in (select invite_code from studyx_briliansolution6.channel_config)
           and (dc_code is null or dc_code = '') -- 用户邀请注册
           and u.CreateDatetime between ${start_time} and ${end_time}
     ) b
     on a.invite_code = b.channel_code
where a.user_id is not null
  and b.user_id is not null
;
/*
 成功解锁用户,解锁次数
 */
select
    count(1)   -- 解锁次数
     ,user_id  -- 成功解锁用户
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'click'
  AND pageId1 LIKE '%matching_details%'
  and actionId = 'Confirm2-1'
  and user_id != '0'
  and user_id != ''
  and user_id is not null
  AND server_time_fmt between ${start_date} and ${end_date}
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
         ,user_id
;

/*
 新增用户
 */
SELECT
    t.user_id
   ,substring(date_add(u.CreateDatetime,interval 8 hour),1,10) dt
FROM
    studyx_briliansolution6.p_student t
        LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
WHERE

    u.CreateDatetime between ${start_time} and ${end_time}
and t.platform != 'robot'
group by t.user_id
       ,substring(date_add(u.CreateDatetime,interval 8 hour),1,10)
;
/*
dc_bot 相关需求
 */
select
    chegg_num
     ,bartleby_num
     ,dt
     ,service_type
from (
         select count(distinct case when che_url like '%www.chegg.com%' then dis_user_id end)    as chegg_num
              , count(distinct case when che_url like '%www.bartleby.com%' then dis_user_id end) as bartleby_num
              , substring(create_time, 1, 10)                                                    as dt
              , case
                    when service_id = '1000940347087659120' then 'StudyX Homework Help'
                    when service_id = '924598255969501194' then 'Study Space 7'
                    when service_id = '1007463428031516813' then 'Study Space 8'
                    when service_id = '989051320335998976' then 'Study Space II'
                    when service_id = '951370203940401162' then 'Homework Q&A' end                  service_type
         from studyx_discord_db.t_dis_question_record
         where create_time between ${start_time} and ${end_time}
         group by substring(create_time, 1, 10)
                , case
                    when service_id = '1000940347087659120' then 'StudyX Homework Help'
                    when service_id = '924598255969501194' then 'Study Space 7'
                    when service_id = '1007463428031516813' then 'Study Space 8'
                    when service_id = '989051320335998976' then 'Study Space II'
                    when service_id = '951370203940401162' then 'Homework Q&A' end
     )a
where a.service_type is not null
;

select
    count(distinct dis_user_id) as search_num
     ,substring(create_time, 1, 10) as dt
     ,case
                    when service_id = '1000940347087659120' then 'StudyX Homework Help'
                    when service_id = '924598255969501194' then 'Study Space 7'
                    when service_id = '1007463428031516813' then 'Study Space 8'
                    when service_id = '989051320335998976' then 'Study Space II'
                    when service_id = '951370203940401162' then 'Homework Q&A' end
from studyx_discord_db.t_search_bot_re_an
where create_time between ${start_time} and ${end_time}
group by
    substring(create_time, 1, 10)
       ,case
                    when service_id = '1000940347087659120' then 'StudyX Homework Help'
                    when service_id = '924598255969501194' then 'Study Space 7'
                    when service_id = '1007463428031516813' then 'Study Space 8'
                    when service_id = '989051320335998976' then 'Study Space II'
                    when service_id = '951370203940401162' then 'Homework Q&A' end
;
/*
 运营所需数据
 */

select
user_id_anwser  -- 答题用户
,user_id_pay    -- 付费用户
,cnt            -- 答题次数
,pay_cnt        -- 支付次数
,points_type    -- points充值
,member_type    -- 会员订阅充值
,tab2.CreateDatetime -- 注册时间
,reg_type            -- 注册来源
from (
         select a.user_id as user_id_anwser-- 答题用户
              , b.user_id as user_id_pay -- 付费用户
              , cnt
              , pay_cnt
              , points_type
              , member_type
         from (
                  select
#        count(1) -- 答题成功
                      count(1) cnt
                       , b.user_id
                       , a.p_user_id
                  from studyx_briliansolution6.t_submit_answer_history a
                           left join studyx_briliansolution6.p_student b
                                     on a.p_user_id = b.UserGuid
                  where answer_type = 0
                    and a.create_time between ${start_date} and ${end_date}
                  group by b.user_id
                         , a.p_user_id
              ) a
                  left join
              (
                  select count(1)             as pay_cnt -- 支付次数
                       , b.user_id
                       , sum(case when a.type = 1 then recharge_amount end) as points_type
                       ,sum(case  when a.type = 2 then recharge_amount end) as  member_type

                  from studyx_briliansolution6.p_recharge_log a
                           left join studyx_briliansolution6.p_student b
                                     on a.p_user_id = b.UserGuid
                  where a.create_time between ${start_time} and ${end_time}
                  group by b.user_id
              ) b
              on a.user_id = b.user_id
         union
         select a.user_id
              , b.user_id
              , cnt
              , pay_cnt
              , points_type
              , member_type
         from (
                  select
#        count(1) -- 答题成功
                      count(1) cnt
                       , b.user_id
                       , a.p_user_id
                  from studyx_briliansolution6.t_submit_answer_history a
                           left join studyx_briliansolution6.p_student b
                                     on a.p_user_id = b.UserGuid
                  where answer_type = 0
                    and a.create_time between ${start_date} and ${end_date}
                  group by b.user_id
                         , a.p_user_id
              ) a
                  right join
              (
                  select count(1)             as pay_cnt -- 支付次数
                       , b.user_id
                       , sum(case when a.type = 1 then recharge_amount end) as points_type
                       ,sum(case  when a.type = 2 then recharge_amount end) as  member_type

                  from studyx_briliansolution6.p_recharge_log a
                           left join studyx_briliansolution6.p_student b
                                     on a.p_user_id = b.UserGuid
                  where a.create_time between ${start_time} and ${end_time}
                  group by b.user_id
              ) b
              on a.user_id = b.user_id
     )tab1
left join
     (
         select case
                          when t.platform != 'robot' and t.channel_code IN
                                          (SELECT DISTINCT invite_code FROM studyx_briliansolution6.channel_config)
                                          AND (t.dc_code is null or t.dc_code = '')
                              then 'dc注册'
                          when t.platform != 'robot' and channel_code is not null
                                          and channel_code != ''
                                          and channel_code not in (select invite_code from studyx_briliansolution6.channel_config)
                                          and (dc_code is null or dc_code = '')
                              then '用户邀请注册'
                          when t.platform != 'robot' and (t.channel_code is null or t.channel_code = '') and dc_code is null
                              then '用户自行注册'
                          when dc_code is not null AND t.platform != 'robot'
                              then 'suite注册' end as reg_type
              , t.user_id
              , u.CreateDatetime
         FROM studyx_briliansolution6.p_student t
                  LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
     )tab2
on ifnull(tab1.user_id_pay,tab1.user_id_anwser) = tab2.user_id
and tab2.reg_type is not null
;