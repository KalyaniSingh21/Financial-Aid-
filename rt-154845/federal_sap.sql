
select
  spriden_id "P Number",
  spriden_last_name "Last Name",
  spriden_first_name "First Name",
  sgbstdn_levl_code,
  fp_credit_hrs(spriden_pidm, &term_code) "&term_code Registered Hours",
  fp_get_earned_hours(spriden_pidm, sgbstdn_levl_code) "Earned Hours",
  (
    select nvl(sum(shrlgpa_hours_attempted), 0)
    from shrlgpa
    where 1=1
          and shrlgpa_pidm = spriden_pidm
          and shrlgpa_levl_code = sgbstdn_levl_code
          and shrlgpa_gpa_type_ind = 'O'
  ) "Attempted Hours",
  (
    potsdam_finaid_shared.get_sap_percentage(spriden_pidm, sgbstdn_levl_code)
  ) "SAP Percentage",
  ( 183 -
      (
          select nvl(sum(shrlgpa_hours_attempted), 0)
          from shrlgpa
          where 1=1
                and shrlgpa_pidm = spriden_pidm
                and shrlgpa_levl_code = sgbstdn_levl_code
                and shrlgpa_gpa_type_ind = 'O'
      )
  ) "183 - Attempted Hours",
  (
        122 - fp_get_earned_hours(spriden_pidm, sgbstdn_levl_code)
  ) "122 - Earned Hours",
  (
      case
      when fp_credit_hrs(spriden_pidm, &term_code) is null then 'X'
      when exists (
        select null
        from rrrareq
        where 1=1
              and rrrareq_pidm = spriden_pidm
              and rrrareq_treq_code = 'BACH'
              and rrrareq_trst_code in ('S', 'R')
              and rrrareq_aidy_code = (select stvterm_fa_proc_yr from stvterm where stvterm_code = &term_code)
        ) then 'BACH2'
      when
      ( 183 -
          (
              select nvl(shrlgpa_hours_attempted, 0)
              from shrlgpa
              where 1=1
                    and shrlgpa_pidm = spriden_pidm
                    and shrlgpa_levl_code = sgbstdn_levl_code
                    and shrlgpa_gpa_type_ind = 'O'
          ) <
          (
            122 - fp_get_earned_hours(spriden_pidm, sgbstdn_levl_code)
          )
      ) then 'M'
      when (
        potsdam_finaid_shared.get_sap_percentage(spriden_pidm, sgbstdn_levl_code) < 67
        and
        (
          select rorsapr_sapr_code
          from rorsapr
          where 1=1
                and rorsapr_pidm = spriden_pidm
                and rorsapr_term_code < &term_code
                and rorsapr_sapr_code <> 'X'
          order by rorsapr_term_code desc
          fetch next 1 row only
        ) = 'R'
      ) then 'W'
      when potsdam_finaid_shared.get_sap_percentage(spriden_pidm, sgbstdn_levl_code) < 67 then 'N'
      when
      (
          select nvl(shrlgpa_hours_attempted, 0)
          from shrlgpa
          where 1=1
                and shrlgpa_pidm = spriden_pidm
                and shrlgpa_levl_code = sgbstdn_levl_code
                and shrlgpa_gpa_type_ind = 'O'
      ) >= 153 then 'U'
      when
      (
          select nvl(shrlgpa_hours_attempted, 0)
          from shrlgpa
          where 1=1
                and shrlgpa_pidm = spriden_pidm
                and shrlgpa_levl_code = sgbstdn_levl_code
                and shrlgpa_gpa_type_ind = 'O'
      ) > 183 then 'O'
      else 'R' end
  ) "&term_code SAP Code",
    (
     select listagg(rorsapr_term_code || ':' || rorsapr_sapr_code, ', ')
     within group (order by rorsapr_term_code desc)
     from rorsapr
     where 1=1
           and rorsapr_pidm = spriden_pidm
           and rorsapr_term_code < &term_code
  ) "Previous SAP Codes"
from sgbstdn, spriden
where 1=1
      and spriden_change_ind is null
      and sgbstdn_pidm = spriden_pidm
      and sgbstdn_term_code_eff = (
          select max(s2.sgbstdn_term_code_eff)
          from sgbstdn s2
          where s2.sgbstdn_pidm = spriden_pidm
      )
      and sgbstdn_term_code_eff <= &term_code
      and sgbstdn_stst_code = 'AS'
      --and sgbstdn_levl_code in ('01', '05')
      and sgbstdn_levl_code = '01'
order by spriden_last_name, spriden_first_name
