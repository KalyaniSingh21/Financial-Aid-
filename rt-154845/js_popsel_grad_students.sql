/*
js_popsel_grad_students.sql

AUTHOR:         Kalyani Singh (KS)

DATE:           27-JUN-2017

DESCRIPTION:    RT:154845
                This script creates a population selection of active
                grad students.

                It also creates an output file that lists the students
                in the population selection.


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





/
spool off
exit
