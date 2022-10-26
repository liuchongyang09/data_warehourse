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
  AND (pageId1 LIKE '%matching_details%' or pageId1 like 'search_result%')
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
 StudyX homework help 活跃人数 -- 目前有点问题
 */
select
    count(distinct user_id)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
from studyx_big_log.user_buried_point_log
where  user_id > '0'
  and user_id is not null
  and user_id != 0
  and client_type = '6'
  AND server_time_fmt between ${start_date} and ${end_date}
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
;
/*
 运营所需数据
 */

select
    tab1.user_id        -- 消耗points用户id
     ,tab2.user_id       -- 注册用户id
     ,tab4.user_id       -- 支付用户id
     ,tab5.user_id       -- 答题用户id
     ,tab2.reg_type
     ,tab2.CreateDatetime
     ,tab1.create_time as use_first_time
     ,tab1.left_points
     ,tab1.use_points
     ,tab3.ct         -- 邀请人数
     ,tab5.cnt        -- 答题次数
     ,tab4.create_time as pay_first_time
     ,tab4.points_type
     ,tab4.points_cnt
     ,tab4.member_type
     ,tab4.member_cnt
from
    (
        select b.user_id
             ,a.create_time
             , sum(a.points_num) as use_points-- 消耗points数
             , sum(a.num)        as left_points-- 可用points数
        from studyx_briliansolution6.p_points_detatiled a
                 left join studyx_briliansolution6.p_student b
                           on a.p_user_id = b.UserGuid
                 left join studyx_briliansolution6.p_user c
                           on a.p_user_id = c.UserGuid
        where info_status = 0
          and a.create_time between ${start_time} and ${end_time}
        group by b.user_id
    )tab1
        left join
    (
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
    )tab3
    on tab1.user_id = tab3.user_id
        left join
    (
        select count(case when a.type = 1 then recharge_amount end)    as points_cnt  -- points支付次数
             , count(case when a.type = 2 then recharge_amount end)    as member_cnt  -- 会员支付次数
             , b.user_id
             ,a.create_time
             , sum(case when a.type = 1 then recharge_amount end) as points_type
             , sum(case when a.type = 2 then recharge_amount end) as member_type
        from studyx_briliansolution6.p_recharge_log a
                 left join studyx_briliansolution6.p_student b
                           on a.p_user_id = b.UserGuid
        where a.create_time between ${start_time} and ${end_time}
          and status = 'COMPLETE'
        group by b.user_id
    )tab4
    on tab1.user_id = tab4.user_id
        left join
    (
        select
            count(1) cnt
             , b.user_id
        from studyx_briliansolution6.t_submit_answer_history a
                 left join studyx_briliansolution6.p_student b
                           on a.p_user_id = b.UserGuid
        where answer_type = 0
          and a.create_time between ${start_time} and ${end_time}
        group by b.user_id
    )tab5
    on tab1.user_id = tab5.user_id
        left join
    (
        select case
                   when t.platform != 'robot' and t.channel_code IN
                                                  (SELECT DISTINCT invite_code
                                                   FROM studyx_briliansolution6.channel_config)
                       AND (t.dc_code is null or t.dc_code = '')
                       then 'dc注册'
                   when t.platform != 'robot' and channel_code is not null
                       and channel_code != ''
                       and
                        channel_code not in (select invite_code from studyx_briliansolution6.channel_config)
                       and (dc_code is null or dc_code = '')
                       then '用户邀请注册'
                   when t.platform != 'robot' and (t.channel_code is null or t.channel_code = '') and
                        dc_code is null
                       then '用户自行注册'
                   when dc_code is not null AND t.platform != 'robot'
                       then 'suite注册' end as reg_type
             , t.user_id
             , u.CreateDatetime
        FROM studyx_briliansolution6.p_student t
                 LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
    )tab2
    on ifnull(tab1.user_id,tab5.user_id) = tab2.user_id
union
select
    tab1.user_id        -- 消耗points用户id
     ,tab2.user_id       -- 注册用户id
     ,tab4.user_id       -- 支付用户id
     ,tab5.user_id       -- 答题用户id
     ,tab2.reg_type
     ,tab2.CreateDatetime
     ,tab1.create_time as use_first_time
     ,tab1.left_points
     ,tab1.use_points
     ,tab3.ct
     ,tab5.cnt
     ,tab4.create_time as pay_first_time
     ,tab4.points_type
     ,tab4.points_cnt
     ,tab4.member_type
     ,tab4.member_cnt
from
    (
        select b.user_id
             ,a.create_time
             , sum(a.points_num) as use_points-- 消耗points数
             , sum(a.num)        as left_points-- 可用points数
        from studyx_briliansolution6.p_points_detatiled a
                 left join studyx_briliansolution6.p_student b
                           on a.p_user_id = b.UserGuid
                 left join studyx_briliansolution6.p_user c
                           on a.p_user_id = c.UserGuid
        where info_status = 0
          and a.create_time between ${start_time} and ${end_time}
        group by b.user_id
    )tab1
        left join
    (
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
    )tab3
    on tab1.user_id = tab3.user_id
        left join
    (
        select count(case when a.type = 1 then recharge_amount end)    as points_cnt  -- points支付次数
             , count(case when a.type = 2 then recharge_amount end)    as member_cnt  -- 会员支付次数
             , b.user_id
             ,a.create_time
             , sum(case when a.type = 1 then recharge_amount end) as points_type
             , sum(case when a.type = 2 then recharge_amount end) as member_type
        from studyx_briliansolution6.p_recharge_log a
                 left join studyx_briliansolution6.p_student b
                           on a.p_user_id = b.UserGuid
        where a.create_time between ${start_time} and ${end_time}
          and status = 'COMPLETE'
        group by b.user_id
    )tab4
    on tab1.user_id = tab4.user_id
        right join
    (
        select
            count(1) cnt
             , b.user_id
        from studyx_briliansolution6.t_submit_answer_history a
                 left join studyx_briliansolution6.p_student b
                           on a.p_user_id = b.UserGuid
        where answer_type = 0
          and a.create_time between ${start_time} and ${end_time}
        group by b.user_id
    )tab5
    on tab1.user_id = tab5.user_id
        and tab1.user_id is null
        left join
    (
        select case
                   when t.platform != 'robot' and t.channel_code IN
                                                  (SELECT DISTINCT invite_code
                                                   FROM studyx_briliansolution6.channel_config)
                       AND (t.dc_code is null or t.dc_code = '')
                       then 'dc注册'
                   when t.platform != 'robot' and channel_code is not null
                       and channel_code != ''
                       and
                        channel_code not in (select invite_code from studyx_briliansolution6.channel_config)
                       and (dc_code is null or dc_code = '')
                       then '用户邀请注册'
                   when t.platform != 'robot' and (t.channel_code is null or t.channel_code = '') and
                        dc_code is null
                       then '用户自行注册'
                   when dc_code is not null AND t.platform != 'robot'
                       then 'suite注册' end as reg_type
             , t.user_id
             , u.CreateDatetime
        FROM studyx_briliansolution6.p_student t
                 LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
    )tab2
    on ifnull(tab1.user_id,tab5.user_id) = tab2.user_id
;
/*
 解锁成功用户、首次解锁成功时间、最后一次点击行为所属服务器
 */

select
    a.user_id           -- 解锁成功用户
     ,a.server_time_fmt  -- 首次解锁时间
     ,b.data9            -- 用户最后一次点击行为所属的服务器
from (
         select user_id   -- 解锁成功用户
              , server_time_fmt
         FROM studyx_big_log.user_buried_point_log
         WHERE `event` = 'click'
           AND (pageId1 like 'matching_details%' or pageId1 like 'search_result%')
           and actionId = 'Confirm2-1'
-- and platform  = 6
           and user_id != '0'
           and user_id != ''
           and user_id is not null
           AND server_time_fmt between ${start_date} and ${end_date}
         group by user_id
     )a
         left join
     (
         select
             user_id,server_time_fmt,data9  -- 用户最后一次点击行为所属的服务器
         from (
                  select user_id,
                         server_time_fmt,
                         data9
                  from studyx_big_log.user_buried_point_log
                  where server_time_fmt between ${start_date} and ${end_date}
                    and user_id != '0'
                    and user_id != ''
                    and user_id is not null
                  group by user_id, server_time_fmt
                  order by server_time_fmt desc
              ) A
         group by user_id
     )b
     on a.user_id = b.user_id
;

/*
 PC端
 */
select
    count(distinct case when user_id = '0' and event = 'PV'
        and pageId1 like 'homework_help_%'  then concat(pageId1,ip) end)  un_login_cnt   -- 页面未登录用户访问次数
     ,count(distinct case when user_id > '0' and event = 'PV'
    and pageId1 like 'homework_help_%'  then concat(pageId1,ip) end)  login_cnt     -- 页面登录用户访问次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionId = 'Unlock the answer'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) un_login_unlock_cnt     -- 页面未登录用户unlock点击次数
     ,count(distinct case when user_id > '0' and event = 'Click'
    and actionId = 'Unlock the answer'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) login_unlock_cnt        -- 页面登录用户unlock点击次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionId = 'Submit' and actionData like '%succeeded%'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end)  click_unlock_login_cnt -- 未登录用户点击unlock成功登录次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionId = 'Sign up' and actionData like '%code%'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) click_unlock_sign_up_cnt  -- 未登录用户点击unlock成功注册次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionId = 'Submit' and actionData like '%succeeded%'
    and pageId1 = 'login_' then concat(pageId1,ip) end) click_login_cnt                       -- 页面顶部导航Log in 成功登录次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionData like '%successfully%'
    and pageId1 = 'register' then concat(pageId1,ip) end) click_reg_cnt                       -- 页面顶部导航Log in 成功注册次数
     ,count(distinct case when user_id = '0' and event = 'click' and actionId = 'Search searchPopInput'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) click_search_unlogin_cnt  -- 页面搜索框未登陆用户首次点击总次数
     ,count(distinct case when user_id > '0' and event = 'click' and actionId = 'Search searchPopInput'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) click_search_login_cnt    -- 页面搜索框登陆用户首次点击总次数
     , substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
from user_buried_point_log
where platform = '6'
  and os_ver not in ('IOS','Android')
  and server_time_fmt between ${start_date} and ${end_date}
group by  substring(date_add(server_time_fmt,interval 8 hour),1,10)
;

/*
 IOS OR Android
 */
select
    count(distinct case when user_id = '0' and event = 'PV'
        and pageId1 like 'homework_help_%'  then concat(pageId1,ip) end)  un_login_cnt   -- 页面未登录用户访问次数
     ,count(distinct case when user_id > '0' and event = 'PV'
    and pageId1 like 'homework_help_%'  then concat(pageId1,ip) end)  login_cnt     -- 页面登录用户访问次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionId = 'Unlock the answer'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) un_login_unlock_cnt     -- 页面未登录用户unlock点击次数
     ,count(distinct case when user_id > '0' and event = 'Click'
    and actionId = 'Unlock the answer'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) login_unlock_cnt        -- 页面登录用户unlock点击次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionId = 'Submit' and actionData like '%succeeded%'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end)  click_unlock_login_cnt -- 未登录用户点击unlock成功登录次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionId = 'Sign up' and actionData like '%code%'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) click_unlock_sign_up_cnt  -- 未登录用户点击unlock成功注册次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionId = 'Submit' and actionData like '%succeeded%'
    and pageId1 = 'login_' then concat(pageId1,ip) end) click_login_cnt                       -- 页面顶部导航Log in 成功登录次数
     ,count(distinct case when user_id = '0' and event = 'Click'
    and actionData like '%successfully%'
    and pageId1 = 'register' then concat(pageId1,ip) end) click_reg_cnt                       -- 页面顶部导航Log in 成功注册次数
     ,count(case when event = 'PV' and pageId1 = 'download'then 1 end) download_cnt                                   -- download点击次数
     ,count(distinct case when user_id = '0' and event = 'click' and actionId = 'Search searchPopInput'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) click_search_unlogin_cnt  -- 页面搜索框未登陆用户首次点击总次数
     ,count(distinct case when user_id > '0' and event = 'click' and actionId = 'Search searchPopInput'
    and pageId1 like 'homework_help_%' then concat(pageId1,ip) end) click_search_login_cnt    -- 页面搜索框登陆用户首次点击总次数
     , substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     ,os_ver
from user_buried_point_log
where platform = '6'
  and os_ver in ('IOS','Android')
  and server_time_fmt between ${start_date} and ${end_date}
group by  substring(date_add(server_time_fmt,interval 8 hour),1,10)
       ,os_ver
;