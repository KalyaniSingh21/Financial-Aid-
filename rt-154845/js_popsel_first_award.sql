/*
js_popsel_first_award.sql

AUTHOR:         Jeremy Bristol (JWB)

DATE:           2016-03-08

DESCRIPTION:    RT:142597
                This script creates a population selection of students to
                use in the Award Letter jobs.
                This script runs the query for the FIRST_AWARD
                population.

                It also creates an output file that lists the students
                in the population selection.

                RT:147169
                Exclude students with an established SARPRB code.

PARAMETERS:     Aid Year
                Term Code
                Popsel Selection ID
                Popsel Application
                Possel Creator ID
                Popsel User ID
                Output file path
*/
set serveroutput on
set feedback off
set pagesize 0
set verify off
set heading on
set echo off
set linesize 100
set timing off

define aid_year = &1
define term_code = &2
define popsel_selection = &3
define popsel_application = &4
define popsel_creator_id = &5
define popsel_user_id = &6

/* The last parameter is the output file path. */
spool &7

declare
delim       constant char := ','; 
first_name  spriden.spriden_first_name%type;
last_name   spriden.spriden_last_name%type;
p_number    spriden.spriden_id%type;
v_count     integer;

cursor report is
    select
        spriden_first_name,
        spriden_last_name,
        f_potsdam_id2(spriden_pidm)
    from glbextr, spriden
    where 1=1
        and spriden_pidm = to_number(glbextr_key)
        and spriden_change_ind is null
        and glbextr_selection = '&popsel_selection'
        and glbextr_application = '&popsel_application'
        and glbextr_creator_id = '&popsel_creator_id'
        and glbextr_user_id = '&popsel_user_id'
    order by spriden_last_name, spriden_first_name, f_potsdam_id2(spriden_pidm)
;

cursor report_count is
    select count(*)
    from glbextr
    where 1=1
        and glbextr_selection = '&popsel_selection'
        and glbextr_application = '&popsel_application'
        and glbextr_creator_id = '&popsel_creator_id'
        and glbextr_user_id = '&popsel_user_id'
;

begin

    /* Delete the existing population selection. */
    delete 
    from glbextr
    where 1=1
        and glbextr_selection = '&popsel_selection'
        and glbextr_application = '&popsel_application'
        and glbextr_creator_id = '&popsel_creator_id'
        and glbextr_user_id = '&popsel_user_id'
    ;

    /*  
        If necessary, insert a record into GLBSLCT. 
        If the GLBSLCT recrod already exists, it will throw the
        DUP_VAL_ON_INDEX exception. So, we will catch that exception
        and do nothing, hence the "null" in the exception code.
    */
    insert
    into glbslct (
        glbslct_application,
        glbslct_selection,
        glbslct_creator_id,
        glbslct_desc,
        glbslct_lock_ind,
        glbslct_activity_date,
        glbslct_data_origin
    )
    values (
        '&popsel_application',
        '&popsel_selection',
        '&popsel_creator_id',
        'JS_POPSEL',
        'N',
        sysdate,
        'JS_POPSEL'
    )
    ;
    exception
        when DUP_VAL_ON_INDEX then
            null
    ;
         

    /* Insert the new population selection. */
    insert
    into glbextr (
        glbextr_application,
        glbextr_selection,
        glbextr_creator_id,
        glbextr_user_id,
        glbextr_key,
        glbextr_activity_date,
        glbextr_sys_ind,
        glbextr_slct_ind,
        glbextr_data_origin
    )
    select
        '&popsel_application',
        '&popsel_selection',
        '&popsel_creator_id',
        '&popsel_user_id',
        to_char(rorstat_pidm),
        sysdate,
        'M',
        'M',
        'JS_POPSEL'
    from rorstat
    where 1=1 
        and rorstat_aidy_code = '&aid_year'
        and rorstat_pckg_comp_date is not null
        and nvl(rorstat_awd_ltr_ind, 'N') <> 'Y'
        and rorstat_pgrp_code in ('NEWF', 'NEWT', 'EOPF', 'EOPT', 'NEWG', 'CONTR')
        and exists (
            select 'has awards' from rprawrd
            where 1=1 
                and rprawrd_pidm = rorstat_pidm
                and rprawrd_aidy_code = '&aid_year'
                and rprawrd_awst_code not in ('DECL','CNCL')
        )
        and not exists (
            select 'x' from rorsapr
            where 1=1
                and rorsapr_pidm = rorstat_pidm
                and rorsapr_sapr_code in ('N','O')
                and rorsapr_term_code = '&term_code'
        )
        and not exists (
            select 'Codes to Exclude' from rtvtreq, rrrareq
            where 1=1 
                and rrrareq_pidm = rorstat_pidm
                and rrrareq_treq_code = rtvtreq_code
                and rtvtreq_ltr_exclude_ind = 'Y'
                and rrrareq_aidy_code = '&aid_year'
                and rrrareq_trst_code = 'E'
        )
        /* Check for FA_[aid_year]_AWARD or FA_CONT_AWARD entry in GURMAIL */
        and (
            1=1
            and not exists (
                select 'FA_[aid_year]_AWARD'
                from gurmail
                where 1=1
                    and gurmail_pidm = rorstat_pidm
                    and gurmail_aidy_code = '&aid_year'
                    and gurmail_letr_code = 'FA_' || '&aid_year' || '_AWARD' 
            )
            and not exists (
                select 'FA_CONT_AWARD'
                from gurmail
                where 1=1
                    and gurmail_pidm = rorstat_pidm
                    and gurmail_aidy_code = '&aid_year'
                    and gurmail_letr_code = 'FA_CONT_AWARD'
            )
        )
    ;

    /* Write the report */

    dbms_output.enable(1000000);

    dbms_output.put_line('Parameters:');
    dbms_output.put_line('Aid Year: ' || '&aid_year');
    dbms_output.put_line('Term Code: ' || '&term_code');
    dbms_output.put_line('Popsel Selection ID: ' || '&popsel_selection');
    dbms_output.put_line('Popsel Application: ' || '&popsel_application');
    dbms_output.put_line('Popsel Creator ID: ' || '&popsel_creator_id');
    dbms_output.put_line('Popsel User ID: ' || '&popsel_user_id');
    dbms_output.put_line('-');

    open report_count;
    fetch report_count into v_count;
    close report_count;

    open report;
    dbms_output.put_line('Students in Population Selection: ' || v_count);
    loop
        fetch report into first_name, last_name, p_number;
        exit when report%notfound;
        dbms_output.put_line(
            p_number || delim ||
            last_name || delim ||
            first_name
        );
    end loop;
    dbms_output.put_line('-');

end;
/
spool off
exit
