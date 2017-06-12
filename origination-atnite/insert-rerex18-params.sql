-- insert-rerex18-params.sql

/* MODIFICATION HISTORY : 12-JUN-2017 KS
                          Changes made to conform to REREX18 parameters according to
                          Release Notes. Unsure about the last parameter - 99
*/

define aidy_code = &1
define one_up_no = &2

delete from general.gjbprun where gjbprun_one_up_no = to_number('&one_up_no');
delete from general.gjbrslt where gjbrslt_one_up_no = to_number('&one_up_no');

insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'01',sysdate,'&aidy_code')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'02',sysdate,'DIRCTS')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'02',sysdate,'DIRCTU')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'02',sysdate,'DIRCTP')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'02',sysdate,'DIRCTG')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'03',sysdate,'N')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'04',sysdate,'B')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'08',sysdate,'51336149')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'09',sysdate,'F')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'15',sysdate,'Y')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'16',sysdate,'Y')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'17',sysdate,'N')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'18',sysdate,'B')
/
insert into general.gjbprun
(gjbprun_job,gjbprun_one_up_no,gjbprun_number,gjbprun_activity_date,gjbprun_value)
values ('REREX18',to_number('&one_up_no'),'99',sysdate,'55')
/
commit;
exit;
