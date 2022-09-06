#--------------------------------------------------
-- 社区新增题目
#用户自主发布
SELECT
    count(1)
FROM studyx_briliansolution6.`q_community_question`
where push_type=0  -- 1：机器人，0：真实用户,2:用户搜索机器人发布
-- and subject_id=2000 -- 学科id
  and  create_time between  ${start_date} and ${end_date}

;
#飞轮发布
SELECT count(1)
FROM studyx_briliansolution6.`q_community_question`
where (push_type=1 or push_type=2)
-- and subject_id=2000
  and create_time between ${start_date} and ${end_date}
;
#-----------------------------------------------------
-- 社区题目搬运情况
#飞轮采集
select count(1)
from studyx_briliansolution6.t_submit_answer_history
where answer_type=1
-- and subject_id=2000
  and  create_time between ${start_date} and ${end_date}
;
#用户自主答题
select count(1)
from studyx_briliansolution6.t_submit_answer_history
where  answer_type=0
-- and subject_id=2003
  and  create_time between ${start_date} and ${end_date}
;
#学科团队搬运
select count(1)
from studyx_briliansolution6.t_submit_answer_history
where  answer_type=2
-- and subject_id=2000
  and  create_time between ${start_date} and ${end_date}
;
#--------------------------------------------------------

#学科团队再前端操作回答
select count(1)
from studyx_briliansolution6.t_submit_answer_history
where (p_user_id='83baad17-49f7-481b-91a8-2584c2b07d4f' or p_user_id='1517080938348154880' or p_user_id='1517099048216170496' or p_user_id='dee4001a-1aa8-4971-9992-083e84f61a84')
  and answer_type=0
-- and subject_id=2000
  and  create_time between ${start_date} and ${end_date}
;
#----------------------------------------
-- 下架题目
#学科团队下架
SELECT count(1)
FROM studyx_briliansolution6.`q_community_question`
where answer_status=2
  and subject_id=2002
  and create_time between ${start_date} and ${end_date}
;
