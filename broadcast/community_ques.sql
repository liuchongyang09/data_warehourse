SELECT
    count(case when push_type in (0,3) then 1 end) as use_num          -- 用户自主发布
     ,count(case when push_type in (1,2)   then 1 end) as feilun_num   -- 飞轮未实时抓取发布
     ,count(case when answer_status = 2 then 1 end)    as out_num   -- 学科团队下架数量
     ,count(case when answer_status = 1 and answer_type = 4 then 1 end) as expert_num   -- expert答题
     ,count(case when push_type in (0,3) and answer_status = 1 and answer_type = 2 then 1 end) as consol_num  -- 控台答题
     ,count(case when push_type in (1,2) and answer_status = 1 and answer_type = 2 then 1 end) as consol_carry_num  -- 控台搬运
     ,count(case when push_type in (1,2) and answer_status = 0 then 1 end) as unsolved_feilun_num     -- 计算累计飞轮发布未解答
     ,subject_id
     ,CategoryName
FROM studyx_briliansolution6.`q_community_question` a
         left join studyx_briliansolution6.q_category b
                   on a.subject_id = b.CategoryId
where -- push_type=0  -- 1：机器人，0：真实用户,2:用户搜索机器人发布
      create_time between  ${start_date} and ${end_date}
group by subject_id,CategoryName
;
SELECT
        count(case when push_type in (0,3) and answer_status = 0 then 1 end) as unsolved_use_num        -- 计算累计用户发布未解答
        ,count(case when push_type in (1,2) and answer_status = 0 then 1 end) as unsolved_feilun_num     -- 计算累计飞轮发布未解答
     ,subject_id
     ,CategoryName
FROM studyx_briliansolution6.`q_community_history` a
         left join studyx_briliansolution6.q_category b
                   on a.subject_id = b.CategoryId
     -- push_type=0  -- 1：机器人，0：真实用户,2:用户搜索机器人发布
#          where   create_time <= ${end_date}
group by subject_id,CategoryName
;
select
    count(distinct case when push_type in (0,3) then   p_user_id end) as cnt -- 有提问行为用户数
from studyx_briliansolution6.`q_community_question`
where  create_time between  ${start_date} and ${end_date}
;

select
    count(distinct p_user_id)   -- 有答题行为导师数
from studyx_briliansolution6.q_community_answer
where role = 20
  and create_time between  ${start_date} and ${end_date}
;



select
    count(distinct a.p_user_id)  -- 用户主动答题
     ,b.subject_id
     ,c.CategoryName
from studyx_briliansolution6.q_community_answer a
         left join studyx_briliansolution6.q_community_question b
                   on a.community_id = b.id
         left join studyx_briliansolution6.q_category c
                   on b.subject_id = c.CategoryId
where
    a.create_time between  ${start_date} and ${end_date}
  and role !=''
  and role != 10
group by
    b.subject_id
       ,c.CategoryName
;
select
    count(case when m_evaluation_num is not null then 1 end) as  check_num-- 已审核数
     ,count(case when m_evaluation_num is null and ifnull(evaluation_num,0) < 4 then 1 end)        un_check_num-- 待审核数
     ,count(case when m_evaluation_num is not null and evaluation_num = m_evaluation_num then 1 end)   eff_check_num-- 有效审核
     ,count(case when m_evaluation_num is not null and ifnull(evaluation_num,0) != m_evaluation_num then 1 end) invalid_check_num-- 无效审核
from studyx_briliansolution6.q_community_answer
where create_time between  ${start_date} and ${end_date}
;

SELECT
    COUNT(distinct question_id)  -- 累计含答案的学习内容数
FROM
    studyx_briliansolution6.t_question_to_solution
WHERE
    question_id IS NOT NULL
;
#------------------------------
/*
 1.用户发布题目到社区记录：q_community_question
 2.用户回答社区题目记录 ： q_community_answer
 */