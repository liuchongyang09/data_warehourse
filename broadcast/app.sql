/*
 客户端注册数据
 */

select
    count(distinct case when b.CreateDatetime >= '2022-4-26 6:00:00' and b.CreateDatetime <= ${end_time} then b.UserGuid end) app_usr_cnt  -- 客户端总注册人数
   ,count(case when edu_id is not null and b.CreateDatetime >= '2022-4-26 6:00:00' and b.CreateDatetime <= ${end_time} then b.UserGuid end) app_liuzi_cnt  -- 客户端总留资人数
   ,count(case when b.CreateDatetime >= ${start_time} and b.CreateDatetime <= ${end_time} then a.user_id end) app_add_usr_cnt  -- 客户端新增用户数
   ,count(case when edu_id is not null and b.CreateDatetime >= ${start_time} and b.CreateDatetime <= ${end_time} then a.user_id end) as app_add_liuzi_cnt  -- 客户端新增留资人数
   ,platform   -- ios 、Android
from studyx_briliansolution6.p_student a
         left join studyx_briliansolution6.p_user b
                   on a.UserGuid = b.UserGuid
where   a.platform != 'robot'
and platform in ('android','ios')
group by platform
;
select
count(1)  -- 客户端总注销人数
,platform
from studyx_briliansolution6.p_user_auth a
left join studyx_briliansolution6.p_student b
on a.p_user_id = b.UserGuid
where is_delete = 1
group by platform
;
select
    count(distinct user_id) app_active_usr_cnt    -- 客户端活跃用户数
     ,platform    -- 2:ios 3:android
from studyx_big_log.user_buried_point_log
where client_type = '2'
  and user_id > 0
  and platform in ('2','3')
  and server_time_fmt between ${start_time} and ${end_time}
group by platform
;
/*
 app详细点击数据
 */
select
    search_text_cnt  -- 客户端文本搜题次数(搜索页面曝光次数)
     ,search_pic_cnt  -- 客户端图片搜索次数
     ,search_total_cnt -- 客户端搜题总次数
     ,search_text_cnt/search_total_cnt as rate   -- App端搜索按钮点击率
     ,PV_cnt            -- 客户端搜索列表界面访问次数
     ,click_detail_cnt  -- 客户端搜索列表点击匹配结果次数
     ,click_answers_cnt -- 点击解锁按钮次数(unlock the answer)
     ,succ_cnt          -- 成功解锁次数
     ,click_answers_cnt - succ_cnt    -- 解锁失败次数
     ,succ_cnt / succ_usr_cnt        -- 人均解锁次数
     ,succ_cnt / search_total_cnt     -- 搜索结果解题成功率
from (
         select

             count(case when  actionId = 'Snap_Question_Text'  then 1 end) as search_text_cnt   -- 客户端文本搜题次数(搜索页面曝光次数)
              ,count(case when (actionId = 'crop' and  data1 = 'Snap_Question') then 1 end) as search_pic_cnt  -- 客户端图片搜索次数
              ,count(case when actionId = 'Snap_Question_Text' or (actionId = 'crop' and  data1 = 'Snap_Question') then 1 end ) search_total_cnt  -- 客户端搜题总次数
              ,count(case when pageId1 = '/' and event = 'PV' then 1 end) as PV_cnt   -- 客户端搜索列表界面访问次数
              ,count(case when pageId1 = '/ai_solutions_details' and event = 'Click' and actionId like 'questionId%' then 1 end) click_detail_cnt -- 客户端搜索列表点击匹配结果次数
              ,count(case when actionId = 'Unlock the answers' and event = 'Click' then 1 end) as click_answers_cnt   -- 点击解锁按钮次数(unlock the answer)
              ,count(case when actionId = 'Confirm' and event = 'Click' then 1 end) as succ_cnt  -- 成功解锁次数
              ,count(distinct case when actionId = 'Confirm' and event = 'Click' then user_id end) as succ_usr_cnt  -- 成功解锁人数
         from studyx_big_log.user_buried_point_log
         where server_time_fmt between ${start_time} and ${end_time}
           and client_type = '2'
           and platform in ('2','3')
     )tab1
;
-- -----------------------------------------------
/*
-- 意向付费用户数

 */

select
    count(distinct case when (actionId = 'Points pay' and event = 'Click' ) or (actionId = 'Subscription pay' and event = 'Click' ) then user_id end) as want_pay_usr_cnt   -- 意向付费用户数
     ,platform    -- 2:ios 3:android
from studyx_big_log.user_buried_point_log
where server_time_fmt between ${start_time} and ${end_time}
  and client_type = '2'
  and platform in ('2','3')
group by platform
;

select
count(distinct case when recharge_amount = '0.00' and period is not null then p_user_id end) as free_follow_cnt                       -- 免费订阅人数
,count(distinct  case when recharge_amount != '0.00' and period is not null then p_user_id end) as pay_usr_cnt                         -- 付费订阅人数
,count(distinct p_user_id) as succ_usr_cnt     -- 成功付费人数（包括免费订阅）
,count(1)  as  pay_cnt                         -- 成功付费次数（包括免费订阅）
,sum(recharge_amount)          -- 付费金额
,pay_type                      -- 1：iOS，3：Android
from studyx_briliansolution6.p_recharge_log
where status = 'COMPLETE'
and pay_type in (1,3)
and create_time between ${start_date} and ${end_date}
group by pay_type
;