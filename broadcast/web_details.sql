/*
   web端搜索列表点击率（去重）= ctr次数/曝光
   web详情页面点击解锁按钮率  = （今日登录用户点击解锁按钮去重次数+今日未登录用户点击解锁按钮去重次数）/搜索列表点击view answer次数
   搜索结果解锁点击率 = web端搜索列表点击率 * web详情页面点击解锁按钮率
   人均解锁次数= web端成功解锁次数/登录用户解锁人数
   人均解题率= web端成功解锁次数/web端曝光次数
 */
select
      log_in                                                                            -- 今日登录用户点击解锁人数
     ,log_in_cnt                                                                        -- 今日登录用户点击解锁按钮次数
     ,exposure_cnt                                                                      -- web端搜索列表曝光次数
     ,web_suc_lock_cnt                                                                  -- web端解锁成功次数
     ,web_suc_lock_cnt/log_in                                                           -- 人均解锁次数
     ,web_suc_lock_cnt/exposure_cnt*100                                                 -- 人均解题率
     ,(dis_log_in_cnt + dis_un_log_in_cnt)/click_view_answer_cnt*100 as web_detail_rate -- web详情页面点击解锁按钮率
     ,ctr_cnt  --
     ,exposure_cnt
     ,ctr_cnt/exposure_cnt*100 as web_search_rate  -- web端搜索列表点击率（去重）
     ,((dis_log_in_cnt + dis_un_log_in_cnt)/click_view_answer_cnt)*(ctr_cnt/exposure_cnt)*100 as search_result_rate  -- 搜索结果解锁点击率
#      ,data9
     ,dt
from(
        SELECT
            count(distinct case when user_id > '0'
                and `event` = 'click'
                and pageId1 LIKE '%matching_details%'
                and  actionId = 'unlock the answer'
                and platform  = '6' then concat( pageId1,user_id) end)  as `dis_log_in_cnt`-- 今日登录用户点击解锁按钮次数(去重)
             ,count( case when user_id > '0'
                                      and `event` = 'click'
                                      and pageId1 LIKE '%matching_details%'
                                      and  actionId = 'unlock the answer'
                                      and platform  = '6' then 1 end)  as `log_in_cnt`-- 今日登录用户点击解锁按钮次数
             ,count(distinct case when (user_id = '0' or user_id is null)
                                                and `event` = 'click'
                                                and pageId1 LIKE '%matching_details%'
                                                and  actionId = 'unlock the answer' and platform  = '6' then concat (pageId1,ip)  end) as `dis_un_log_in_cnt` -- 今日未登录用户点击解锁按钮次数(去重)
             ,count(distinct case when (user_id = '0' or user_id is null)
                                                  and pageId1 LIKE '%matching_details%'
                                                  and `event` = 'click'
                                                  and  actionId = 'unlock the answer' and platform  = '6' then ip  end) as `un_log_in` -- 今日未登录用户点击解锁按钮的人数
             ,count( case when (user_id = '0' or user_id is null)
                                            and pageId1 LIKE '%matching_details%'
                                            and `event` = 'click'
                                            and  actionId = 'unlock the answer' and platform  = '6' then 1  end) as `un_log_in_cnt` -- 今日未登录用户点击解锁按钮次数
             ,count(case when pageId1 LIKE '%matching_results%'
                                       and `event` = 'click'
                                       and actionId like '%View Answer%' then 1 end) as click_view_answer_cnt -- 搜索列表点击view answer次数
             ,count(distinct case when event = 'pv'
                                       and pageId1 like '%matching_details%'
                                       AND pageId1 LIKE '%#posId%' then data5 end ) as ctr_cnt-- ctr次数
             ,count(case when event = 'Exposure'
                                       and pageId1 like '%matching_results?%'
                                       and actionId = 'search' then 1 end ) as exposure_cnt -- 曝光次数
             ,count(distinct case when user_id !='0' and user_id !=''
                                                and `event` = 'click'
                                                and user_id is not null and pageId1 LIKE '%matching_details%'
                                                and  ( actionId like '%Confirm2-%' or actionId like '%unlock the answer-%' )
                                      then user_id end)  as `log_in`-- 今日登录用户点击解锁人数
             ,count(case when user_id > '0'
                                  and pageId1 LIKE '%matching_details%'
                                  and actionId like 'Confirm2-1' then 1 end) as web_suc_lock_cnt -- web端成功解锁次数
             ,substring(date_add(server_time_fmt,interval 8 hour),1,10) as dt
#              ,data9
        FROM
            studyx_big_log.user_buried_point_log
        WHERE
            server_time_fmt between ${start_date} and ${end_date}
        group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
#                , data9
    )a
;

/*
 订阅相关指标
 */
select
    count(case when status = 1 then 1 end) -- 订阅后已更新的内容数量
     ,count(distinct case when status = 1 then p_user_id end) -- 订阅后已更新的内容数量涉及用户
     ,count(case when status = 0 then 1 end) -- 订阅后待获得答案的问题数量
     ,count(distinct case when status = 0 then p_user_id end) -- 订阅后待获得答案的问题涉及用户
from studyx_briliansolution6.t_question_answer_notice
where create_time >= '2022-06-13 16:00:00'
  and create_time <= ${end_time}
;

#################################################################################################
/*
运营分析统计相关指标

 */
-- -----------------------
select
    count(1) -- web搜题曝光次数
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
--    ,data9
from studyx_big_log.user_buried_point_log ubpl
where
    server_time_fmt between '${start_date}' and '${end_date}'
  and  event = 'Exposure'
  and pageId1 like '%matching_results?%'
  and actionId = 'search'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- , data9
;
-- --------------------------------

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



-- ----------------------------------------------
-- Web端搜索列表点击率 = CTR次数/曝光次数
select
    count(distinct case when event = 'pv' and pageId1 like '%matching_details%'  AND pageId1 LIKE '%#posId%' then data5 end ) as pv_cnt-- ctr次数
     ,count(case when event = 'Exposure' and pageId1 like '%matching_results?%' and actionId = 'search' then 1 end ) as exposure_cnt -- 曝光次数
     , concat( count(distinct case when event = 'pv' and pageId1 like '%matching_details%'  AND pageId1 LIKE '%#posId%' then data5 end )
                   /count(case when event = 'Exposure' and pageId1 like '%matching_results?%' and actionId = 'search' then 1 end )*100,'%') as a
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
     ,data9
FROM
    studyx_big_log.user_buried_point_log
where server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       ,data9
;
-- ------------------
SELECT
    count(1 ) -- 搜索列表点击view answer次数
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
     ,data9
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'click'
  AND pageId1 LIKE '%matching_results%'
  and actionId like '%View Answer%'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;

-- ---------------------------------------
-- Web端搜索详情页解锁按钮点击率 = （登录用户解锁 + 未登录用户解锁）/ Web端搜索列表点击view answer次数（Click事件）
select
    dis_log_in_cnt
     ,log_in
     ,log_in_cnt
     ,dis_un_log_in_cnt
     ,un_log_in
     ,un_log_in_cnt
     ,(dis_log_in_cnt + dis_un_log_in_cnt) as dis_un_view
     ,cnt
     ,(dis_log_in_cnt + dis_un_log_in_cnt)/cnt*100 as rate
     ,data9
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
             ,data9
        FROM
            studyx_big_log.user_buried_point_log
        WHERE
                `event` = 'click'
          AND server_time_fmt between '${start_date}' and '${end_date}'
        group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
               , data9
    )a
;

-- --------------------------------
-- Web端搜索列表界面访问次数（PV事件）

SELECT
    count(1) --
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10)
--    ,data9
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'pv'
  AND pageId1 LIKE '%matching_result%'
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- , data9
;
-- -----------------------------------------------------------
-- 搜索详情界面列表点击Unlock the answer总次数
select
    count(1)
     ,data9
FROM
    studyx_big_log.user_buried_point_log
WHERE
        `event` = 'click'
  AND pageId1 LIKE '%matching_details%'
  and actionId = 'unlock the answer'
  and platform  = 6
  AND server_time_fmt between '${start_date}' and '${end_date}'
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
       , data9
;
-- -----------
-- 成功解锁
select
    count(1)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
--    ,data9
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
  AND server_time_fmt between ${start_date} and ${end_date}
group by substring(date_add(server_time_fmt,interval 8 hour),1,10)
-- , data9
;
-- ----------------
-- 解锁失败
select
    count(1)
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
--    ,data9
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
-- , data9
;
-- -----------------
-- 积分不足
select
    count(1) -- 出现积分不足次数
     ,count(distinct user_id) -- 积分不足的用户数
     ,substring(date_add(server_time_fmt,interval 8 hour),1,10) dt
     , data9
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
       , data9
;
-- --------------------------
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

-- --------------------
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
-- -------------------
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
-- -----------------
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
;
    -- -------------------
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
