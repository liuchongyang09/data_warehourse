/*
总留资人数
*/
SELECT
    count(1)  -- 总留资人数
FROM
    studyx_briliansolution6.p_student t
        LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
WHERE
        platform != 'robot'
  and edu_id IS NOT NULL
  and u.CreateDatetime <= ${end_time}
;
-- ------------------------------------------------------
/*
 统计用户所属服务器人数
 */
select
    count(1)
     ,data9
from (
         select user_id,
                server_time_fmt,
                data9 -- 用户最后一次点击行为所属的服务器
         from (
                  select user_id,
                         server_time_fmt,
                         data9
                  from studyx_big_log.user_buried_point_log
                  where user_id > 0
                  group by user_id, server_time_fmt
                  order by server_time_fmt desc
              ) A
         group by user_id
     )B
group by data9
;
-- ----------------------------------------------------------
/*
 注销人数
 */
SELECT
    count(1) -- 已注销的用户id
FROM
    studyx_briliansolution6.p_user_auth
WHERE
        is_delete = 1
  and create_time between ${start_date} and ${end_date}
;
SELECT
    count(1) -- 注销人邀请总人数
FROM
    studyx_briliansolution6.p_invite_record
WHERE
        p_invite_id IN (
        SELECT
            p_user_id -- 已注销的用户id
        FROM
            studyx_briliansolution6.p_user_auth
        WHERE
                is_delete = 1
    )
;
-- ----------------------------------------------
/*
 注册人数
 */
select
    count(case when t.platform != 'robot'
        and  t.channel_code IN (SELECT DISTINCT invite_code FROM studyx_briliansolution6.channel_config)
        AND (t.dc_code is null or t.dc_code='')
                   then 1 end)                                     as dc_reg_num   -- dc注册
     ,count(case when  t.platform != 'robot'
    and channel_code is not null
    and channel_code!=''
    and channel_code not  in(select invite_code from studyx_briliansolution6.channel_config)
    and (dc_code is null or dc_code = '')
                     then 1 end)                                    as usr_inv_reg_num  -- 用户邀请注册
     ,count(case when  t.platform != 'robot'
    and ( t.channel_code is null or t.channel_code='')
    and dc_code is null
                     then 1 end)                                    as usr_person_reg_num  -- 用户自行注册
     ,count(case when dc_code is not null
    AND t.platform != 'robot'
                     then 1 end) as suite_reg_num   -- suite端注册人数
     ,count(case when dc_code is not null
    and platform='discord'
    and (channel_code is not null and channel_code!='')
                     then 1 end)                                    as  entry_server_reg_num -- (suite端)通过用户服务器邀请链接进入服务器注册
     ,count(case when t.dc_code IS NOT NULL
    AND t.dc_code != ' '
    AND platform != 'discord'
    AND t.channel_code IS NOT NULL
    AND t.channel_code != ' '
                     then 1 end)                                     as usr_studyx_reg_num   -- (suite端)通过服务器内用户StudyX邀请链接注册
     ,count(case when dc_code is not null
    and dc_code != ''
    and (channel_code is null or channel_code = '')
                     then 1 end)                                     as suite_person_reg_num  -- (suite端)自行注册
FROM
    studyx_briliansolution6.p_student t
        LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
WHERE
        u.CreateDatetime >= '2022-4-26 6:00:00'
  and u.CreateDatetime <= ${end_time}
;
-- -------------------------------------------------
/*
  1.新增用户数
  2.新增留资人数
 */
SELECT
    count(case when t.platform != 'robot' then 1 end) as add_usr_num -- 新增用户数
     ,count(case when edu_id IS NOT NULL then 1 end ) as add_liuzi_num -- 新增留资人数
FROM
    studyx_briliansolution6.p_student t
        LEFT JOIN studyx_briliansolution6.p_user u ON t.UserGuid = u.UserGuid
WHERE

    u.CreateDatetime between ${start_time} and ${end_time}
;

-- --------------------------------------------
/*
 今日活跃用户
 */
select
    count(distinct user_id) -- 今日活跃用户
     , data9                -- 服务器
from studyx_big_log.user_buried_point_log
where
        user_id > 0
  AND server_time_fmt between ${start_date} and ${end_date}
group by data9
;
-- -----------------------------------------------------------
/*
 dc搜题次数  统计时间：北京时间
 */
select
    total_cnt    -- 搜题次数
     ,total_cnt - invaild_cnt -- 有效搜题
     ,invaild_cnt -- 无效搜题
     ,suc_cnt -- 成功发送私信次数
from (
         select count(1)                               as total_cnt
              , count(case when type = '0' then 1 end) as invaild_cnt -- 无效搜题次数
              , count(case when type = '1' then 1 end) as suc_cnt
         from studyx_discord_db.t_search_bot_re_an
         where create_time between ${start_date} and ${end_date}
     )a
;

/*
链接打开次数 统计时间：utc
 */
select create_time,
       search_text
from (
         select question_id,
                search_text,
                create_time
         from studyx_briliansolution6.t_que_sea_record tqsr
         where code in (select invite_code from studyx_briliansolution6.channel_config cc)
           and create_time between ${start_date} and ${end_date}
           and search_text != ''
         group by question_id, search_text, create_time
     ) b
group by create_time, search_text
;
/*
成功打开次数 （用户打开同一个链接三次，但是只有两次在web抓取到了访问的信息）,则这两次表示成功打开
 */
select
    count(1)
from studyx_big_log.user_buried_point_log
where pageId1 like '%code=%'
  and pageId1 like '%&r%'
  and `event` ='exposure'
  and server_time_fmt between ${start_date} and ${end_date}
;
/*
 搜索结果解锁按钮点击次数
 */
select
    count(distinct substring_index(substring_index(pageId1,'es=',-1),'#',1))  -- 搜索结果解锁按钮点击次数
from studyx_big_log.user_buried_point_log
where event = 'click'
  and actionId = 'Unlock the answer'
  and platform = '6'
  and pageId1 like '%es=%'
  and server_time_fmt between ${start_date} and ${end_date}
;

/*
 web付费
 */
select
    count(distinct user_id)  -- 意向付费用户数
from studyx_big_log.user_buried_point_log ubpl
where event = 'click'
  and (pageId1 like '%my_points%' or pageId1 like 'matching_details%')
  and (actionId like 'points pay%' or actionId  in ('Unlock the answer-a' ,'Confirm2-2'))
  and user_id > '0'
  and platform = '6'
  AND server_time_fmt between ${start_date} and ${end_date}
;

select
    count(1)                -- 成功付费次数
     ,count(distinct user_id) -- 成功付费用户数
     ,data9
from studyx_big_log.user_buried_point_log ubpl
where event = 'pv'
  and (pageId1 like 'my_points%' or pageId1 like 'matching_details%')
  and actionId = 'pay_succeeded'
  and platform = '6'
  AND server_time_fmt between ${start_date} and ${end_date}
group by
    data9
;
-- ---------------------------------------------------------------
/*
 客户端付费情况
 */
select
    count(1)  -- 支付次数
     ,count(distinct b.user_id) -- 支付人数
     ,sum(recharge_amount)      -- 支付金额
     ,pay_type                  -- 支付类型（1：ios，3：Android，4：web）
from studyx_briliansolution6.p_recharge_log a
         left join studyx_briliansolution6.p_student b
                   on a.p_user_id = b.UserGuid
where status = 'COMPLETE'
  AND a.create_time between ${start_date} and ${end_date}
group by pay_type
;
-- -------------------------------------------------------
/*
 统计通过点击搜索按钮后的行为
 */
select
    count(1)  -- 点击搜索按钮的次数  1247
from studyx_big_log.user_buried_point_log ubpl
where
        event = 'Exposure'
  and pageId1 like '%matching_results?%'
  and pageId1 not like '%&r%'
  and actionId = 'search'
  and platform = '6'
  and server_time_fmt between ${start_time} and ${end_time}
;
select
    count(distinct data5)   -- CTR次数  750
from (SELECT
          substring_index(substring_index(pageId1,'es=',-1),'#',1) as xxx
           ,actionId,actionData,event,user_id,data5,ip
      FROM
          studyx_big_log.user_buried_point_log
      WHERE
              `event` = 'pv'
        AND pageId1 LIKE '%#posId%'
        AND pageId1 LIKE '%matching_details%'
        and platform  = 6
        AND server_time_fmt between ${start_time} and ${end_time}
     )tab1
         left join (
    select
        distinct  replace(data7,'-','_') as data7
    from studyx_big_log.user_buried_point_log ubpl
    where
            event = 'Exposure'
      and pageId1 like '%matching_results?%'
      and pageId1 not like '%&r%'
      and actionId = 'search'
      and platform = '6'
      and server_time_fmt between ${start_time} and ${end_time}
)tab2
                   on tab1.xxx = tab2.data7
where tab2.data7 is not null
;

select
    count(1)  -- 点击see full answer次数    1082
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'click'
  AND pageId1 LIKE '%matching_results%'
  and actionId like '%View Answer%'
  and pageId1 not like '%&r%'
  and platform  = 6
  AND server_time_fmt between ${start_time} and ${end_time}
;
select
    count(1)  -- 点击unlock the answer次数       664
     ,count(distinct xxx) -- 搜索结果解锁按钮点击次数 505
from (
         SELECT
             substring_index(substring_index(pageId1,'es=',-1),'#',1) as xxx
              ,actionId,actionData,event,user_id,data5,ip
         FROM
             studyx_big_log.user_buried_point_log
         WHERE
                 `event` = 'click'
           AND pageId1 LIKE '%matching_details%'
           and pageId1 like '%es=%'
           and actionId = 'unlock the answer'
           and platform  = 6
           AND server_time_fmt between ${start_time} and ${end_time}
     )tab1
         left join (
    select
        distinct  replace(data7,'-','_') as data7
    from studyx_big_log.user_buried_point_log ubpl
    where
            event = 'Exposure'
      and pageId1 like '%matching_results?%'
      and pageId1 not like '%&r%'
      and actionId = 'search'
      and platform = '6'
      and server_time_fmt between ${start_time} and ${end_time}
)tab2
                   on tab1.xxx = tab2.data7
where tab2.data7 is not null
;
/*
 * 通过点击搜索按钮搜索的搜索列表点击率 = CTR次数/点击搜索按钮的次数
   通过点击搜索按钮搜索的搜索详情页解锁按钮点击率 = 点击unlock the answer次数/点击see full answer次数
   通过点击搜索按钮搜索的解锁按钮点击率 = 搜索结果解锁按钮点击次数/点击搜索按钮的次数
/