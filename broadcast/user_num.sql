
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

/*
 今日活跃用户
 */
select
    count(distinct user_id) -- 今日活跃用户
     , client_type
from studyx_big_log.user_buried_point_log
where
    user_id IS NOT NULL
  AND user_id != ''
  AND user_id != '0'
  AND server_time_fmt between ${start_date} and ${end_date}
group by client_type
;

/*
suite端 see answer次数
        see answer人数
        ctr次数
        解锁成功次数
        解锁失败次数
        搜题次数
        人均解锁次数=解锁成功次数/ 解锁人数
        人均解题率 = 搜索次数/ 解锁成功次数
 */

select
    count(case when actionId='unlock the answer' then 1 end) see_answer_cnt  -- see answer的次数
     ,count(distinct case when actionId='unlock the answer' then user_id end) see_answer_num  -- see answer的人数
     ,count(distinct case when  actionId='unlock the answer' then data5 end) ctr_cnt
     ,count(case when actionId='Confirm2-1' then 1 end) as suite_suc_cnt
     ,count(case when event = 'click'
    and actionId in ('unlock the answer-a','unlock the answer-b') then 1 end) suite_fail_cnt
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     , data9
from studyx_big_log.user_buried_point_log
where client_type = '6'

  and user_id != '0'
  and user_id != ''
  and user_id is not null
  and server_time_fmt between ${start_date} and ${end_date}
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9

;
SELECT
    count(distinct search_text,create_time ) suite_search_cnt  -- suite端搜题次数
     ,substring(date_add(create_time,interval 8 hour),1,10) dt
FROM
    studyx_briliansolution6.t_que_sea_record
WHERE
        search_source = 'discord'
  and create_time between ${start_date} and ${end_date}
group by
    substring(date_add(create_time,interval 8 hour),1,10)
;
############################################################
/*
 注册人数相关指标
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