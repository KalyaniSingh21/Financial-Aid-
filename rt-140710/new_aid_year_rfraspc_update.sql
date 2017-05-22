/*
new_aid_year_rfraspc_update.sql

AUTHOR:        Kalyani Singh (KS)

DATE:          2017-19-05

DESCRIPTION:   JWB - Sue wants me to update the below fields on RFRMGMT
               from the previous aid year
               for all funds and she will correct any that need it.

               RT:140710
               This SQL script cannot be run until the job ROPROLL is run.
               ROPROLL is a baseline job that copies the funds in the RFRASPC table
               from one aid year to another aid year.

               Once ROPROLL is run, then this SQL script can be run,
               it will update the amounts for these funds.

PARAMETERS:    Previous Aid Year
               Next Aid Year
*/


declare
v_fund                           RFRASPC.RFRASPC_FUND_CODE%TYPE;
v_aidy                           RFRASPC.RFRASPC_AIDY_CODE%TYPE;
v_RFRASPC_PRIOR_BAL_AMT          RFRASPC.RFRASPC_PRIOR_BAL_AMT%TYPE;
v_RFRASPC_PRIOR_BAL_AMT_curr     RFRASPC.RFRASPC_PRIOR_BAL_AMT%TYPE;
v_RFRASPC_TRANSFER_AMT           RFRASPC.RFRASPC_TRANSFER_AMT%TYPE;
v_RFRASPC_TRANSFER_AMT_curr      RFRASPC.RFRASPC_TRANSFER_AMT%TYPE;
v_RFRASPC_BUDG_ALLOC_AMT         RFRASPC.RFRASPC_BUDG_ALLOC_AMT%TYPE;
v_RFRASPC_BUDG_ALLOC_AMT_curr    RFRASPC.RFRASPC_BUDG_ALLOC_AMT%TYPE;
v_RFRASPC_TOTAL_ALLOC_AMT        RFRASPC.RFRASPC_TOTAL_ALLOC_AMT%TYPE;
v_RFRASPC_TOTAL_ALLOC_AMT_curr   RFRASPC.RFRASPC_TOTAL_ALLOC_AMT%TYPE;
v_RFRASPC_AVAIL_OFFER_AMT        RFRASPC.RFRASPC_AVAIL_OFFER_AMT%TYPE;
v_RFRASPC_AVAIL_OFFER_AMT_curr   RFRASPC.RFRASPC_AVAIL_OFFER_AMT%TYPE;
v_RFRASPC_AVAIL_OFFER_PCT        RFRASPC.RFRASPC_AVAIL_OFFER_PCT%TYPE;
v_RFRASPC_AVAIL_OFFER_PCT_curr   RFRASPC.RFRASPC_AVAIL_OFFER_PCT%TYPE;
v_count                          PLS_INTEGER := 0;

cursor driving_cur is
select rfraspc_fund_code from rfraspc
where /*rfraspc_fund_code like 'I%'
and */rfraspc_aidy_code = '&working_aidy'
order by rfraspc_fund_code;

cursor get_current_amts is
select RFRASPC_PRIOR_BAL_AMT,RFRASPC_TRANSFER_AMT,RFRASPC_BUDG_ALLOC_AMT,RFRASPC_TOTAL_ALLOC_AMT,
       RFRASPC_AVAIL_OFFER_AMT,RFRASPC_AVAIL_OFFER_PCT
from rfraspc
where rfraspc_fund_code = v_fund
and rfraspc_aidy_code = '&working_aidy';


cursor get_update_amts is
select RFRASPC_PRIOR_BAL_AMT,RFRASPC_TRANSFER_AMT,RFRASPC_BUDG_ALLOC_AMT,RFRASPC_TOTAL_ALLOC_AMT,
       RFRASPC_AVAIL_OFFER_AMT,RFRASPC_AVAIL_OFFER_PCT
from rfraspc
where rfraspc_fund_code = v_fund
and rfraspc_aidy_code = '&prev_aidy';


BEGIN
  DBMS_OUTPUT.enable(10000000);
  open driving_cur;
    LOOP
      FETCH driving_cur INTO v_fund;  --get the driving pidm and basic info
       EXIT WHEN driving_cur%NOTFOUND;

      --show what is in there now
      open get_current_amts;
       fetch get_current_amts into v_RFRASPC_PRIOR_BAL_AMT_curr,v_RFRASPC_TRANSFER_AMT_curr,
                                   v_RFRASPC_BUDG_ALLOC_AMT_curr,v_RFRASPC_TOTAL_ALLOC_AMT_curr,
                                   v_RFRASPC_AVAIL_OFFER_AMT_curr,v_RFRASPC_AVAIL_OFFER_PCT_curr;
      close get_current_amts;
      --get the prior year info for the fund
      open get_update_amts;
       fetch get_update_amts into v_RFRASPC_PRIOR_BAL_AMT,v_RFRASPC_TRANSFER_AMT,
                                  v_RFRASPC_BUDG_ALLOC_AMT,v_RFRASPC_TOTAL_ALLOC_AMT,
                                  v_RFRASPC_AVAIL_OFFER_AMT,v_RFRASPC_AVAIL_OFFER_PCT;  -- The offer pct will never be null --KDE
      close get_update_amts;

      --do the update
       update RFRASPC
         set RFRASPC_PRIOR_BAL_AMT = v_RFRASPC_PRIOR_BAL_AMT,
             RFRASPC_TRANSFER_AMT =v_RFRASPC_TRANSFER_AMT,
             RFRASPC_BUDG_ALLOC_AMT = v_RFRASPC_BUDG_ALLOC_AMT,
             RFRASPC_TOTAL_ALLOC_AMT = v_RFRASPC_TOTAL_ALLOC_AMT,
             RFRASPC_AVAIL_OFFER_AMT = v_RFRASPC_AVAIL_OFFER_AMT,
             RFRASPC_AVAIL_OFFER_PCT = v_RFRASPC_AVAIL_OFFER_PCT
         where rfraspc_fund_code = v_fund
           and rfraspc_aidy_code = '&working_aidy';
        --update the count
        v_count := v_count + 1;
        --output the update info
        DBMS_OUTPUT.put_line('*-----------------------------------------------------------------*');
        DBMS_OUTPUT.put_line('                  Fund => '|| v_fund);
        DBMS_OUTPUT.put_line('Updated PRIOR_BAL_AMT   =>'||v_RFRASPC_PRIOR_BAL_AMT_curr  ||' to => '||v_RFRASPC_PRIOR_BAL_AMT);
        DBMS_OUTPUT.put_line('Updated TRANSFER_AMT    =>'||v_RFRASPC_TRANSFER_AMT_curr   ||' to => '||v_RFRASPC_TRANSFER_AMT);
        DBMS_OUTPUT.put_line('Updated BUDG_ALLOC_AMT  =>'||v_RFRASPC_BUDG_ALLOC_AMT_curr ||' to => '|| v_RFRASPC_BUDG_ALLOC_AMT);
        DBMS_OUTPUT.put_line('Updated TOTAL_ALLOC_AMT =>'||v_RFRASPC_TOTAL_ALLOC_AMT_curr||' to => '||v_RFRASPC_TOTAL_ALLOC_AMT);
        DBMS_OUTPUT.put_line('Updated AVAIL_OFFER_AMT =>'||v_RFRASPC_AVAIL_OFFER_AMT_curr||' to => '||v_RFRASPC_AVAIL_OFFER_AMT);
        DBMS_OUTPUT.put_line('Updated AVAIL_OFFER_PCT =>'||v_RFRASPC_AVAIL_OFFER_PCT_curr||' to => '||v_RFRASPC_AVAIL_OFFER_PCT);
        DBMS_OUTPUT.put_line('*-----------------------------------------------------------------*');
    END LOOP;
    DBMS_OUTPUT.put_line(v_count || ' records updated.');
  close driving_cur;
  if driving_cur%ISOPEN = FALSE
    then
      DBMS_OUTPUT.put_line('Driving cursor closed');
  else
    DBMS_OUTPUT.put_line('Driving cursor still open');
  end if;
exception
  when others
    then
      DBMS_OUTPUT.put_line(SQLERRM);

END;
