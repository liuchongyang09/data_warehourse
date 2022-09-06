## 今日搜题次数

SELECT
    count(distinct  case when search_source = 'web' then concat( search_text ,create_time) end) as web_cnt  -- web端
     ,count(distinct  case when search_source = 'ios' or search_source = 'android' then concat( search_text ,create_time) end) as app_cnt -- 客户端
     ,count(distinct  case when search_source = 'discord'  then concat( search_text ,create_time) end) as suite_cnt  -- StudyX Suite
FROM
    studyx_briliansolution6.t_que_sea_record
WHERE
    create_time BETWEEN ${start_time} and ${end_time}
;
##直接通过链接进入搜索列表页搜索= 今日搜题次数(web端) - web端通过点击搜索按钮搜索
## web端通过点击搜索按钮搜索
##客户端图片搜题
##StudyX Suite 无效搜题次数
##StudyX Suite 有效搜题次数
SELECT
      count(case when `event` = 'click'
                           and actionId='search'
                           and (locate('index',pageId1)>0 or locate('matching_results',pageId1)>0)
                 then 1 end)                                                  as web_click_search_cnt   -- web端通过点击搜索按钮搜索
     ,COUNT(case when actionId = 'crop'AND data1='Snap_Question' then 1 end ) as app_poto_cnt -- 客户端图片搜题
     ,count(case when data1 = '0' and client_type='6' then 1 end)             as valid_cnt -- StudyX Suite 无效搜题
     ,count(case when data1 = '1' and client_type='6' then 1 end)             as eff_cnt     -- StudyX Suite 有效搜题
FROM
    studyx_big_log.`user_buried_point_log`
WHERE
    server_time_fmt between ${start_date} and ${end_date}
;