--select * from GENERAL.GURMAIL t

    insert into general.gurmail
                  (gurmail_pidm,
                   gurmail_system_ind,
                   gurmail_term_code,
                   gurmail_letr_code,
                   gurmail_module_code,
                   gurmail_admin_identifier,
                   gurmail_matl_code_mod,
                   gurmail_date_init,
                   gurmail_date_printed,
                   gurmail_user,
                   gurmail_wait_days,
                   gurmail_pub_gen,
                   gurmail_init_code,
                   gurmail_orig_ind,
                   gurmail_activity_date,
                   gurmail_aidy_code )
         select  F_SPRIDEN_PIDM('P00543818'),
                  'R',
                  '999999',
                  'FA_SAP_EMAIL',
                   null,
                   null,
                   null,
                   null,
                   sysdate,
                   user,
                   null,
                   null,
                   null,
                   null,
                   sysdate,
                   '1617'
          from dual
          where not exists(
          select * from gurmail where gurmail_pidm = F_SPRIDEN_PIDM('P00543818'));
          
          
          
insert into general.gurmail
                  (gurmail_pidm,
                   gurmail_system_ind,
                   gurmail_term_code,
                   gurmail_letr_code,
                   gurmail_module_code,
                   gurmail_admin_identifier,
                   gurmail_matl_code_mod,
                   gurmail_date_init,
                   gurmail_date_printed,
                   gurmail_user,
                   gurmail_wait_days,
                   gurmail_pub_gen,
                   gurmail_init_code,
                   gurmail_orig_ind,
                   gurmail_activity_date,
                   gurmail_aidy_code )
         values   (student_pidm,
                  'R',
                  '999999',
                  'FA_SAP_EMAIL',
                   null,
                   null,
                   null,
                   null,
                   sysdate,
                   user,
                   null,
                   null,
                   null,
                   null,
                   sysdate,
                   '&aid_year');          
          
select * from gurmail where gurmail_pidm = F_SPRIDEN_PIDM('P00543818')
AND GURMAIL_LETR_CODE = 'FA_SAP_EMAIL';

select * from SPRIDEN where spriden_pidm = F_SPRIDEN_PIDM('P00543818');

set serveroutput on
set feedback off
set pagesize 0
set verify off
set heading on
set echo off
set linesize 100
set timing off

DECLARE

updation_completed BOOLEAN;

BEGIN
  
updation_completed := FALSE;
dbms_output.enable; 
IF NOT updation_completed THEN
  --select rrrareq_trst_code from RRRAREQ Y
   UPDATE RRRAREQ y
            SET y.rrrareq_trst_code = 'R'
            WHERE y.rrrareq_aidy_code = '1617'
            and   y.rrrareq_treq_code = 'SAP'
            and   y.rrrareq_pidm =  '16608'--F_SPRIDEN_PIDM('P00315912')
            and  exists (select 'RORSAPR_SAPR_CODE is U, W, R, P or B'
                                from RORSAPR z
                                where 1=1
                                      and z.rorsapr_pidm = y.rrrareq_pidm
                                      and z.rorsapr_term_code ='201602'
                                      and z.rorsapr_sapr_code in ('U','W','R','P','B'));
                                      
    updation_completed := FALSE;
END IF;

dbms_output.PUT_LINE(sys.diutil.bool_to_int(updation_completed));

END;


select rrrareq_trst_code from RRRAREQ Y
   UPDATE RRRAREQ y
            SET y.rrrareq_trst_code = 'R'
            WHERE y.rrrareq_aidy_code = '1617'
            and   y.rrrareq_treq_code = 'SAP'
            and   y.rrrareq_pidm =  F_SPRIDEN_PIDM('P00315912')
            and  exists (select 'RORSAPR_SAPR_CODE is U, W, R, P or B'
                                from RORSAPR z
                                where 1=1
                                      and z.rorsapr_pidm = y.rrrareq_pidm
                                      and z.rorsapr_term_code ='201602'
                                      and z.rorsapr_sapr_code in ('U','W','R','P','B'));
                                      
                                      
select spriden_pidm
                                from RORSAPR z, spriden s, rrrareq y
                                where y.rrrareq_pidm = s.spriden_pidm
                                      and z.rorsapr_pidm = y.rrrareq_pidm
                                      and z.rorsapr_term_code ='201602'
                                      and z.rorsapr_sapr_code not in ('U','W','R','P','B');


           
select rorsapr_sapr_code 
       from RORSAPR 
       WHERE rorsapr_pidm =  F_SPRIDEN_PIDM('P00315912') 
             and rorsapr_term_code ='201609';
            

select
        spriden_last_name,
        spriden_first_name,
        fp_spriden_id(rorsapr_pidm),
        fp_get_email_addr(rorsapr_pidm, 'ON', 'A'),
        rorsapr_sapr_code,
        spriden_pidm
    from
        rorsapr, spriden
    where 1=1
        and spriden_pidm = rorsapr_pidm
        and spriden_change_ind is null
        and rorsapr_term_code = '201609'
        and rorsapr_lock_ind = 'Y'
    order by
        spriden_last_name,
        spriden_first_name;
        
        
select * from GURMAIL WHERE GURMAIL_LETR_CODE = 'FA_SAP_EMAIL';     
        

IF EXISTS (select 'RORSAPR_SAPR_CODE is U, W, R, P or B'
                            from RORSAPR z
                            where z.rorsapr_pidm = y.rrrareq_pidm
                                  and z.rorsapr_term_code ='&term_code'
                                  and z.rorsapr_sapr_code in ('U','W','R','P','B')) 
BEGIN   
        UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'R'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm;
END    

    ELSE IF (select 'RORSAPR_SAPR_CODE is X'
                                from RORSAPR z
                                where z.rorsapr_pidm = y.rrrareq_pidm
                                      and z.rorsapr_term_code ='&term_code'
                                      and z.rorsapr_sapr_code is 'X') THEN
        (UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'D'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm);
                                  
    ELSE IF (select 'RORSAPR_SAPR_CODE not in X, U, W, R, P or B'
                                from RORSAPR z
                                where z.rorsapr_pidm = y.rrrareq_pidm
                                      and z.rorsapr_term_code ='&term_code'
                                      and z.rorsapr_sapr_code not in ('U','W','R','P','B', 'X')) THEN
       (UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'E'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm);
        
END IF;     



  UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'R'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm
        and  exists (select 'RORSAPR_SAPR_CODE is U, W, R, P or B'
                            from RORSAPR z
                            where 1=1
                                  and z.rorsapr_pidm = y.rrrareq_pidm
                                  and z.rorsapr_term_code ='&term_code'
                                  and z.rorsapr_sapr_code in ('U','W','R','P','B'));

        UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'D'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm
        and  exists (select 'RORSAPR_SAPR_CODE is U, W, R, P or B'
                             from RORSAPR z
                             where z.rorsapr_pidm = y.rrrareq_pidm
                                   and z.rorsapr_term_code ='&term_code'
                                   and z.rorsapr_sapr_code = 'X');

        UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'E'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm
        and  exists (select 'RORSAPR_SAPR_CODE is U, W, R, P or B'
                            from RORSAPR z
                            where z.rorsapr_pidm = y.rrrareq_pidm
                                  and z.rorsapr_term_code ='&term_code'
                                  and z.rorsapr_sapr_code not in ('U','W','R','P','B'));
                                                                 
                                  
select rorsapr_sapr_code as rorsapr_code
                            from RORSAPR z, RRRAREQ y
                            where z.rorsapr_pidm = y.rrrareq_pidm
                                  and z.rorsapr_term_code ='201602'

IF rorsapr_code in ('U','W','R','P','B') 
  UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'R'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm;
END IF;       
ELSE IF rorsapr_code not in ('U','W','R','P','B') THEN
  UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'E'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm;
        
ELSE IF rorsapr_code = 'X' THEN
  UPDATE RRRAREQ y
        SET y.rrrareq_trst_code = 'D'
        WHERE y.rrrareq_aidy_code = '&aid_year'
        and   y.rrrareq_treq_code = 'SAP'
        and   y.rrrareq_pidm = student_pidm;
END IF;



  UPDATE RRRAREQ y
          SET y.rrrareq_trst_code = 'R', updation_completed := TRUE
          WHERE y.rrrareq_aidy_code = '&aid_year'
          and   y.rrrareq_treq_code = 'SAP'
          and   y.rrrareq_pidm = student_pidm
          and  exists (select 'RORSAPR_SAPR_CODE is U, W, R, P or B'
                              from RORSAPR z
                              where 1=1
                                    and z.rorsapr_pidm = y.rrrareq_pidm
                                    and z.rorsapr_term_code ='&term_code'
                                    and z.rorsapr_sapr_code in ('U','W','R','P','B'));
                                    
                                    
select * from RRRAREQ;
