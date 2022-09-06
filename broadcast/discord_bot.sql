
/*
 dc播报数据 时间周期 按北京时间计算
 */
SELECT
    count(case when create_time BETWEEN ${start_date} and ${end_date}
        and dc_type= '9'
                   then 1 end ) AS study_homework_add_num
     ,count(case when out_time BETWEEN ${start_date} and ${end_date}
    and discord_user_state = 'offline'
    and dc_type= '9'
                     then 1 end) as  study_homework_levae_num
     ,count(case when create_time BETWEEN ${start_date} and ${end_date}
    and dc_type= '1'
                     then 1 end ) AS study_space_add_num
     ,count(case when out_time BETWEEN ${start_date} and ${end_date}
    and discord_user_state = 'offline'
    and dc_type= '1'
                     then 1 end) as  study_space_levae_num
     ,count(case when create_time BETWEEN ${start_date} and ${end_date}
    and dc_type= '4'
                     then 1 end ) AS homework_add_num
     ,count(case when out_time BETWEEN ${start_date} and ${end_date}
    and discord_user_state = 'offline'
    and dc_type= '4'
                     then 1 end) as  homework_levae_num
     ,count(case when create_time BETWEEN ${start_date} and ${end_date}
    and dc_type= '8'
                     then 1 end ) AS studyspace2_add_num
     ,count(case when out_time BETWEEN ${start_date} and ${end_date}
    and discord_user_state = 'offline'
    and dc_type= '8'
                     then 1 end) as  studyspace2_levae_num
FROM studyx_discord_db.`t_dis_user`
;
/*
 总人数
 */
SELECT
    count(DISTINCT case when dc_type='9' then dis_user_id end) as study_homework_total_num
     ,count(DISTINCT case when dc_type='1' then dis_user_id end) as study_space_total_num
     ,count(DISTINCT case when dc_type='4' then dis_user_id end) as homework_total_num
     ,count(DISTINCT case when dc_type='8' then dis_user_id end) as studyspace2_total_num
FROM studyx_discord_db.`t_dis_user`
where discord_user_state='online'
;
SELECT
    count(case when ( reply_status = '1' OR msg = '第三方chegg答案为空' )
        and dc_type = '1'
                   then reply_status end) AS suc_cnt  -- study_space 今日成功解题数
     ,count(case when reply_status = '2'
    and msg is null
    and dc_type = '1'
                     then reply_status end) as fail_cnt -- study_space 今日失败解题数
     ,count(case when ( reply_status = '1' OR msg = '第三方chegg答案为空' )
    and dc_type = '4'
                     then reply_status end) AS suc_cnt1  -- homework 今日成功解题数
     ,count(case when reply_status = '2'
    and msg is null
    and dc_type = '4'
                     then reply_status end) as fail_cnt1 -- homework 今日失败解题数
     ,count(case when ( reply_status = '1' OR msg = '第三方chegg答案为空' )
    and dc_type = '8'
                     then reply_status end) AS suc_cnt2  -- studyspace2 今日成功解题数
     ,count(case when reply_status = '2'
    and msg is null
    and dc_type = '8'
                     then reply_status end) as fail_cnt2 -- studyspace2 今日失败解题数
FROM studyx_discord_db.`t_dis_question_record`
WHERE  create_time BETWEEN  ${start_date} and ${end_date}
;
/*

 */
select
    count(1) cn   -- StudyX_Homework 今日成功解题数
from studyx_big_log.user_buried_point_log
where client_type='6'
  and actionId='confirm2-1'
  and server_time_fmt BETWEEN '${start_date}' and '${end_date}'
UNION
select count(1) cn -- StudyX_Homework 今日失败解题数
from studyx_big_log.user_buried_point_log
where `event` = 'click'
  and locate('unlock the answer-',actionId)>0
  and client_type='6'
  and user_id>0
  and server_time_fmt between '${start_date}' and '${end_date}'
;