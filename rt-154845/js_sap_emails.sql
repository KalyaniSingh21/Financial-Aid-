/*
 js_sap_emails.pl

 AUTHOR:   Jeremy Bristol (JWB)

 CREATED:  2016-01-13

 DESCRIPTION:     RT:140965
                  This script is used by js_sap_emails.pl to generate
                  a CSV file of students who have a locked Eligibility
                  Status record for the given term code.
*/

set serveroutput on
set feedback off
set pagesize 0
set verify off
set heading on
set echo off
set linesize 100
set timing off

-- Command Line parameters:
-- &1 == Term Code
-- &2 == CSV File Path
define term_code = &1
define aid_year = &2
spool &3

declare
delim       constant char := ',';
last_name   spriden.spriden_last_name%type;
first_name  spriden.spriden_first_name%type;
p_number    spriden.spriden_id%type;
email       goremal.goremal_email_address%type;
sap_code    rorsapr.rorsapr_sapr_code%type;
student_pidm spriden.spriden_pidm%type;

cursor driving_cursor is

    select
        spriden_last_name,
        spriden_first_name,
        fp_spriden_id(rorsapr_pidm),
        fp_get_email_addr(rorsapr_pidm, 'ON', 'A', 'Y'),
        rorsapr_sapr_code,
        spriden_pidm
    from
        rorsapr, spriden
    where 1=1
        and spriden_pidm = rorsapr_pidm
        and spriden_change_ind is null
        and rorsapr_term_code = '&term_code'
        and rorsapr_lock_ind = 'Y'
    order by
        spriden_last_name,
        spriden_first_name
;

begin

    dbms_output.enable(1000000);

    open driving_cursor;

        --Print the header:
        dbms_output.put_line (
            'Last Name' || delim ||
            'First Name' || delim ||
            'P Number' || delim ||
            'Email' || delim ||
            'SAP Code'
        );

    loop
        fetch driving_cursor into
            last_name, first_name, p_number, email, sap_code, student_pidm;
        --Stop the loop when there is no more data:
        exit when driving_cursor%notfound;

        dbms_output.put_line (student_pidm);


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
                                  
          dbms_output.put_line ('Updated Value');

          --Print the data:
          dbms_output.put_line (
              last_name || delim ||
              first_name || delim ||
              p_number || delim ||
              email || delim ||
              sap_code
          );


    end loop;

end;
/
spool off
exit
