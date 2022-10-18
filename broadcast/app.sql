/*
 客户端注册数据
 */

select
    count(distinct case when b.CreateDatetime >= '2022-4-26 6:00:00' and b.CreateDatetime <= ${end_time} then b.UserGuid end) app_usr_cnt  -- 客户端总注册人数
   ,count(case when edu_id is not null and b.CreateDatetime >= '2022-4-26 6:00:00' and b.CreateDatetime <= ${end_time} then b.UserGuid end) app_liuzi_cnt  -- 客户端总留资人数
   ,count(case when b.CreateDatetime >= ${start_time} and b.CreateDatetime <= ${end_time} then b.UserGuid end) app_add_usr_cnt  -- 客户端新增用户数
   ,count(case when edu_id is not null and b.CreateDatetime >= ${start_time} and b.CreateDatetime <= ${end_time} then b.UserGuid end) as app_add_liuzi_cnt  -- 客户端新增留资人数
   ,platform   -- ios 、Android
   ,ifnull(server_type,0) server_type -- 服务器
from studyx_briliansolution6.p_student a
         left join studyx_briliansolution6.p_user b
                   on a.UserGuid = b.UserGuid
where   a.platform != 'robot'
and platform in ('android','ios')
group by platform,ifnull(server_type,0)
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
     ,platform
from studyx_big_log.user_buried_point_log
where client_type = '2'
  and user_id > 0
  and server_time_fmt between ${start_time} and ${end_time}
group by platform
;