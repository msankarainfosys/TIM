--------------------------------------------------------
--  File created - Tuesday-January-26-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body XX_JOB_STATUS_MAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEMANTRA12251"."XX_JOB_STATUS_MAIL_PKG" AS

/******************************************************************************
   NAME:         xx_job_status_mail_pkg BODY
   PURPOSE:      Package to send mail
   REVISIONS:
   Ver        Date        Author
   ---------  ----------  ---------------------------------------------------
   1.0        11/21/2010  Rajavikraman S R / Infosys - Initial Version

   ******************************************************************************/


    PROCEDURE  send_mail_prc (p_to VARCHAR2,
              p_cc VARCHAR2,
							p_subject VARCHAR2,
              p_priority NUMBER,
							p_mesg clob)
IS

  l_connection   UTL_SMTP.connection;
  l_boundary    VARCHAR2(50) := '----=*#abc1234321cba#*=';
  l_step        PLS_INTEGER  := 12000; -- make sure you set a multiple of 3 not higher than 24573
  l_from       varchar2(1000):= 'noreply@nbty.com';
  l_subject     VARCHAR2(200);
  l_to         varchar2(1000);
  l_cc         varchar2(1000);
  l_pos        number;
  l_to_fi      varchar2(100);
  l_cc_fi      varchar2(100);
  l_global_name    varchar2(100);
  l_Priority    NUMBER := 5;  -- 3 = Medium, 5 = Low, 1 = High
  l_smtp_host   VARCHAR2(100) := 'Namail.nbty.net';--'Eumail.nbty.net';
  l_smtp_port   NUMBER := 25;

BEGIN
  l_Priority := p_priority;
  
	SELECT global_name INTO l_global_name FROM global_name;

	l_subject := p_subject||' - '||substr(sys_context ('USERENV','DB_NAME'),4);

	l_connection := UTL_SMTP.open_connection(l_smtp_host, l_smtp_port);
	UTL_SMTP.helo(l_connection, l_smtp_host);
	UTL_SMTP.mail(l_connection, l_from);

	l_to := p_to;
	IF l_to IS NOT NULL THEN
	LOOP
		l_pos := INSTR(l_to,',',1);
		IF l_pos <> 0 THEN
			l_to_fi := SUBSTR(l_to,1,l_pos-1);
			l_to := SUBSTR(l_to,l_pos+1);
			UTL_SMTP.rcpt(l_connection, l_to_fi);
		ELSIF l_pos = 0 then
			UTL_SMTP.rcpt(l_connection, l_to);
		END IF;
	EXIT WHEN L_POS = 0;
	END LOOP;
	END IF;

  l_cc := p_cc;
	IF l_to IS NOT NULL THEN
	LOOP
		l_pos := INSTR(l_cc,',',1);
		IF l_pos <> 0 THEN
			l_cc_fi := SUBSTR(l_cc,1,l_pos-1);
			l_cc := SUBSTR(l_cc,l_pos+1);
			UTL_SMTP.rcpt(l_connection, l_cc_fi);
		ELSIF l_pos = 0 then
			UTL_SMTP.rcpt(l_connection, l_cc);
		END IF;
	EXIT WHEN L_POS = 0;
	END LOOP;
	END IF;

	UTL_SMTP.open_data(l_connection);

	UTL_SMTP.write_data(l_connection, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
	UTL_SMTP.write_data(l_connection, 'To: ' || p_to || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_connection, 'Cc: ' || p_cc || UTL_TCP.crlf);
	UTL_SMTP.write_data(l_connection, 'From: ' || l_from || UTL_TCP.crlf);
	UTL_SMTP.write_data(l_connection, 'Subject: ' || l_subject || UTL_TCP.crlf);
	UTL_SMTP.write_data(l_connection, 'Reply-To: ' || l_from || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_connection, 'X-Priority: ' || l_Priority || UTL_TCP.crlf);
	UTL_SMTP.write_data(l_connection, 'MIME-Version: 1.0' || UTL_TCP.crlf);
	UTL_SMTP.write_data(l_connection, 'Content-Type: multipart/mixed; boundary="' || l_boundary || '"' || UTL_TCP.crlf || UTL_TCP.crlf);

	UTL_SMTP.write_data(l_connection, '--' || l_boundary || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_connection, 'Content-Type: text/html; charset="iso-8859-1"' || UTL_TCP.crlf || UTL_TCP.crlf);

	UTL_SMTP.write_data (l_connection, p_mesg);
	UTL_SMTP.write_data(l_connection, UTL_TCP.crlf || UTL_TCP.crlf);

	UTL_SMTP.close_data (l_connection);
	UTL_SMTP.quit (l_connection);

EXCEPTION
/*
	WHEN utl_smtp.invalid_opereation
	THEN
		dbms_output.put_line ('Invalid Opereation in Mail attempy using UT_SMTP'|| SQLERRM);
	WHEN utl_smtp.transient_error
	THEN
		dbms_output.put_line ('Temporary e-mail issue - try again'|| SQLERRM);

	WHEN utl_smtp.permanent_error
	THEN
		dbms_output.put_line ('Permanent Error Encountered.'|| SQLERRM);
		*/
	WHEN OTHERS
	THEN	dbms_output.put_line ('Error occured in send_mail_prc'|| SQLERRM);
END send_mail_prc;



    PROCEDURE  mail_intrfc_data_prc (p_to VARCHAR2,
              p_cc VARCHAR2,
							p_subject VARCHAR2)
IS

  l_to varchar2(1000);
  l_cc varchar2(1000);
  l_subject varchar2(2000);
	l_stmt varchar2(10000);
	mesg clob;

	cursor interface_data
	is
  select 'Item Load' Load_Type,'NBTY_T_SRC_ITEM' interface_table_name,count(1) count from demantra12251.NBTY_T_SRC_ITEM
  union all
  select 'Location Load','NBTY_T_SRC_LOC',count(1) from demantra12251.NBTY_T_SRC_LOC
  union all
  select 'Sales Load','NBTY_T_SRC_SHIPMENTS',count(1) from demantra12251.NBTY_T_SRC_SHIPMENTS
  union all
  select 'Consumption Load','NBTY_IMP_CONS_UNIT',count(1) from demantra12251.NBTY_IMP_CONS_UNIT
  union all
  select 'Bill To Load','NBTY_DSM_IMPORT_BILLTO',count(1) from demantra12251.NBTY_DSM_IMPORT_BILLTO
  union all
  select 'COGS Load','NBTY_T_SRC_COGS',count(1) from demantra12251.NBTY_T_SRC_COGS
  union all
  select 'Price Load','NBTY_T_SRC_PRICING',count(1) from demantra12251.NBTY_T_SRC_PRICING
  union all
  select 'Acq Price Load','NBTY_IMP_ACQUISITION_PRICE',count(1) from demantra12251.NBTY_IMP_ACQUISITION_PRICE
  union all
  select 'Baseline Load','NBTY_IMP_BASE_UNITS',count(1) from demantra12251.nbty_imp_base_units
  union all
  select 'Check Number Load','NBTY_BIIO_PAYMENT_IMPORT',count(1) from demantra12251.nbty_biio_payment_import;

BEGIN
  l_to := p_to;
  l_cc := p_cc;
  l_subject := p_subject;

	l_stmt := 'stmt 1.0';

	mesg := mesg
			|| '<html>
					<head>
					</head>
					<body bgcolor="#FFFFFF" link="#8B0000">
					Hi Team, <p> Please find Interface data count details of TIM. </p>';

	l_stmt := 'stmt 2.0';

	mesg := mesg
			|| '<table border="2" style="border-collapse:collapse;" cellpadding="5">
				<font color="BLUE">
				<tr>
          <th><font color="BLUE">LOAD_TYPE</font></th>
					<th><font color="BLUE">INTERFACE_TABLE_NAME</font></th>
					<th><font color="BLUE">COUNT</font></th>
				</tr>
				</font>';

	l_stmt := 'stmt 3.0';

	FOR cur_excpt in interface_data
	LOOP
		EXIT WHEN interface_data%NOTFOUND;

		mesg :=  mesg
				|| '<font face = "calibri" size="2" > <tr> <div align="center"> <td>'
				|| cur_excpt.load_type
				|| '</td> <td> <div align="center">'
				|| cur_excpt.interface_table_name
				|| '</td> <td> <div align="center">'
				|| cur_excpt.count
				|| '</td> </tr> </font>';
	END LOOP;

	mesg := mesg || '</table>';

	l_stmt := 'stmt 4.0';

	mesg := mesg
			|| '<P> Thanks,<BR>'
			|| 'TIM Support (Infosys)</BR>'
			|| '</BODY></html>';

  --dbms_output.put_line(mesg);
	xx_job_status_mail_pkg.send_mail_prc (l_to,l_cc,l_subject,3,mesg);

END mail_intrfc_data_prc;

PROCEDURE  mail_intrfc_errdata_prc (p_to VARCHAR2,
              p_cc VARCHAR2,
							p_subject VARCHAR2)
IS

  l_to varchar2(1000);
  l_cc varchar2(1000);
  l_subject varchar2(2000);
	l_stmt varchar2(10000);
	mesg clob;

	cursor interface_data
	is
	select 'Item Load' Load_Type,'T_SRC_ITEM_TMPL_ERR' error_table_name,count(1) count from demantra12251.t_src_item_tmpl_err
	union all
	select 'Location Load','T_SRC_LOC_TMPL_ERR',count(1) from demantra12251.t_src_loc_tmpl_err
	union all
  select 'Sales Load','T_SRC_SALES_TMPL_ERR',count(1) from demantra12251.t_src_sales_tmpl_err
	union all
  select 'Consumption Load','BIIO_IMP_CONS_UNIT_ERR',count(1) from demantra12251.biio_imp_cons_unit_err
	union all
  select 'Bill To Load','T_SRC_BILLTO_ID_ERR',count(1) from demantra12251.t_src_billto_id_err
	union all
	select 'COGS Load','T_SRC_COGS_ERR',count(1) from demantra12251.t_src_cogs_err
	union all
  select 'Pricing Load','T_SRC_PRICING_ERR',count(1) from demantra12251.t_src_pricing_err
	union all
  select 'Acquisition Price Load','T_SRC_ACQUSITION_PRICE_ERR',count(1) from demantra12251.t_src_acqusition_price_err
	union all	
	select 'Baseline Load','BIIO_IMP_BASE_UNITS_ERR',count(1) from demantra12251.biio_imp_base_units_err
	union all
	select 'Check Number Load','BIIO_PAYMENT_IMPORT_1_ERR',count(1) from demantra12251.biio_payment_import_1_err;

BEGIN
  l_to := p_to;
  l_cc := p_cc;
  l_subject := p_subject;

	l_stmt := 'stmt 1.0';

	mesg := mesg
			|| '<html>
					<head>
					</head>
					<body bgcolor="#FFFFFF" link="#8B0000">
					Hi Team, <p> Please find Interface data error count details of TIM. </p>';

	l_stmt := 'stmt 2.0';

	mesg := mesg
			|| '<table border="2" style="border-collapse:collapse;" cellpadding="5">
				<font color="BLUE">
				<tr>
					<th><font color="BLUE">LOAD_TYPE</font></th>
					<th><font color="BLUE">ERROR_TABLE_NAME</font></th>
					<th><font color="BLUE">COUNT</font></th>
				</tr>
				</font>';

	l_stmt := 'stmt 3.0';

	FOR cur_excpt in interface_data
	LOOP
		EXIT WHEN interface_data%NOTFOUND;

		mesg :=  mesg
				|| '<font face = "calibri" size="2" > <tr> <div align="center"> <td>'
				|| cur_excpt.load_type
				|| '</td> <td> <div align="center">'
				|| cur_excpt.error_table_name
				|| '</td> <td> <div align="center">'
				|| cur_excpt.count
				|| '</td> </tr> </font>';
	END LOOP;

	mesg := mesg || '</table>';

	l_stmt := 'stmt 4.0';

	mesg := mesg
			|| '<P> Thanks,<BR>'
			|| 'TIM Support (Infosys)</BR>'
			|| '</BODY></html>';

  --dbms_output.put_line(mesg);
	xx_job_status_mail_pkg.send_mail_prc (l_to,l_cc,l_subject,3,mesg);

END mail_intrfc_errdata_prc;


PROCEDURE  mail_wf_status_prc (p_to VARCHAR2,
        p_cc VARCHAR2,
				p_subject VARCHAR2,
				p_eng_check VARCHAR2,
				p_err_check VARCHAR2,
				p_wf_id NUMBER)
IS

  l_to varchar2(1000);
  l_cc varchar2(1000);
  l_subject varchar2(2000);
	l_stmt varchar2(10000);
	v_count number;
	mesg clob;

	cursor interface_data
	is
	select pl.process_id,pl.parent_process_id,u.user_name initiator,s.schema_name workflow_name,
	case pl.status when 0 then 'Completed' when 1 then 'Running' when -1 then 'Terminated' end Status,
	pl.step_id,pl.num_steps,TO_char(pl.record_created, 'DD-MON-YY hh24:mi:ss') Start_Time
	,TO_char(pl.record_updated, 'DD-MON-YY hh24:mi:ss') End_Time
	,round((pl.record_updated - pl.record_created)* 24 * 60,2) run_time_mins
	from demantra12251.wf_process_log pl,demantra12251.user_id u,demantra12251.wf_schemas s
	where pl.schema_id=p_wf_id
	and trunc(pl.record_updated)=trunc(sysdate)
	and pl.initiator=u.user_id
	and pl.schema_id=s.schema_id
	union all
	select pl.process_id,pl.parent_process_id,u.user_name initiator,s.schema_name workflow_name,
	case pl.status when 0 then 'Completed' when 1 then 'Running' when -1 then 'Terminated' end Status,
	pl.step_id,pl.num_steps,TO_char(pl.record_created, 'DD-MON-YY hh24:mi:ss') Start_Time
	,TO_char(pl.record_updated, 'DD-MON-YY hh24:mi:ss') End_Time
	,round((pl.record_updated - pl.record_created)* 24 * 60,2) run_time_mins
	from demantra12251.wf_process_log pl,demantra12251.user_id u,demantra12251.wf_schemas s
	where trunc(pl.record_updated)=trunc(sysdate)
	and pl.parent_process_id in
	(select pl.process_id from demantra12251.wf_process_log pl where pl.schema_id=p_wf_id
	and trunc(pl.record_updated)=trunc(sysdate))
	and pl.initiator=u.user_id
	and pl.schema_id=s.schema_id;

	cursor engine_data
	is
	select time_sig,case status when -1 then 'Initialization' when 0 then 'Running' when 1 then 'Completed' end status
	,fore_column_name,engine_profiles_id,INIT_PARAMS_TABLE_NAME
	,TO_char(time_sig, 'DD-MON-YY hh24:mi:ss') start_time_est
	,total_run_time
	from demantra12251.forecast_history
	where 1=1--rownum <5
	AND trunc(TIME_SIG) = trunc(SYSDATE)
  --AND trunc(TIME_SIG) = to_date('20-APR-17','DD-MON-YY')
	order by time_sig desc;

	cursor err_data
	is
	select log_id,package_name,procedure_name,trim(message) message,
	error_message,STEP_NUMBER,RECORD_COUNT,START_DATE,END_DATE,ELAPSED_TIME
	from demantra12251.aex_logs
	where trunc(start_date) = trunc(sysdate)
  --and trunc(start_date) = to_date('28-MAR-17','DD-MON-YY')
	and ERROR_MESSAGE is not null
	order by log_id;


BEGIN
  l_to := p_to;
  l_cc := p_cc;
  l_subject := p_subject;

	l_stmt := 'stmt 1.0';

	mesg := mesg
			|| '<html>
					<head>
					</head>
					<body bgcolor="#FFFFFF" link="#8B0000">
					Hi Team, <p> Please find the TIM workflow status. </p>';

	l_stmt := 'stmt 2.0';

	mesg := mesg
			|| '<table border="2" width="1000" style="border-collapse:collapse;" cellpadding="5">
				<font color="BLUE">
				<tr>
					<th><font color="BLUE">PROCESS_ID</font></th>
					<th><font color="BLUE">PARENT_PROCESS_ID</font></th>
					<th><font color="BLUE">INITIATOR</font></th>
					<th><font color="BLUE">WORKFLOW_NAME</font></th>
					<th><font color="BLUE">STATUS</font></th>
					<th><font color="BLUE">STEP_ID</font></th>
					<th><font color="BLUE">NUM_STEPS</font></th>
					<th><font color="BLUE">START_TIME</font></th>
					<th><font color="BLUE">END_TIME</font></th>
					<th><font color="BLUE">RUN_TIME_MINS</font></th>
				</tr>
				</font>';

	l_stmt := 'stmt 3.0';

	FOR cur_excpt in interface_data
	LOOP
		EXIT WHEN interface_data%NOTFOUND;

		mesg :=  mesg
				|| '<font face = "calibri" size="2" > <tr> <div align="center"> <td>'
				|| cur_excpt.PROCESS_ID
				|| '</td> <td> <div align="center">'
				|| cur_excpt.PARENT_PROCESS_ID
				|| '</td> <td> <div align="center">'
				|| cur_excpt.INITIATOR
				|| '</td> <td> <div align="center">'
				|| cur_excpt.WORKFLOW_NAME
				|| '</td> <td> <div align="center">'
				|| cur_excpt.STATUS
				|| '</td> <td> <div align="center">'
				|| cur_excpt.STEP_ID
				|| '</td> <td> <div align="center">'
				|| cur_excpt.NUM_STEPS
				|| '</td> <td> <div align="center">'
				|| cur_excpt.START_TIME
				|| '</td> <td> <div align="center">'
				|| cur_excpt.END_TIME
				|| '</td> <td> <div align="center">'
				|| cur_excpt.RUN_TIME_MINS
				|| '</td> </tr> </font>';
	END LOOP;

	mesg := mesg || '</table>';


	IF upper(p_eng_check)  = 'YES' THEN

		select count(1) INTO v_count
		from demantra12251.forecast_history
		where trunc(TIME_SIG) = trunc(SYSDATE)
		order by time_sig desc;

		IF v_count > 0 THEN

			mesg := mesg
			|| '<p> Please find the Engine status. </p>';

			mesg := mesg
			|| '<table border="2" width="1000" style="border-collapse:collapse;" cellpadding="5">
				<font color="BLUE">
				<tr>
					<th><font color="BLUE">TIME_SIG</font></th>
					<th><font color="BLUE">STATUS</font></th>
					<th><font color="BLUE">FORE_COLUMN_NAME</font></th>
					<th><font color="BLUE">ENGINE_PROFILES_ID</font></th>
					<th><font color="BLUE">INIT_PARAMS_TABLE_NAME</font></th>
					<th><font color="BLUE">START_TIME_EST</font></th>
					<th><font color="BLUE">TOTAL_RUN_TIME</font></th>
				</tr>
				</font>';

			FOR cur_excpt in engine_data
			LOOP
				EXIT WHEN engine_data%NOTFOUND;

				mesg :=  mesg
						|| '<font face = "calibri" size="2" > <tr> <div align="center"> <td>'
						|| cur_excpt.TIME_SIG
						|| '</td> <td> <div align="center">'
						|| cur_excpt.STATUS
						|| '</td> <td> <div align="center">'
						|| cur_excpt.FORE_COLUMN_NAME
						|| '</td> <td> <div align="center">'
						|| cur_excpt.ENGINE_PROFILES_ID
						|| '</td> <td> <div align="center">'
						|| cur_excpt.INIT_PARAMS_TABLE_NAME
						|| '</td> <td> <div align="center">'
						|| cur_excpt.START_TIME_EST
						|| '</td> <td> <div align="center">'
						|| cur_excpt.TOTAL_RUN_TIME
						|| '</td> </tr> </font>';
			END LOOP;

			mesg := mesg || '</table>';

		ELSE
			mesg := mesg
			|| '<p> No engine status have been recorded in forecast_history table. </p>';

		END IF;
	END IF;


	IF upper(p_err_check) = 'YES' THEN

		select count(1) INTO v_count
		from demantra12251.aex_logs
		where trunc(start_date) = trunc(sysdate)
		and ERROR_MESSAGE is not null
		order by log_id;

		IF v_count > 0 THEN

			mesg := mesg
			|| '<p> Seems there are some errors occurred when running the workflow. </p>';

			mesg := mesg
			|| '<table border="2" width="1000" style="border-collapse:collapse;" cellpadding="5">
				<font color="RED">
				<tr>
					<th><font color="RED">LOG_ID</font></th>
					<th><font color="RED">PACKAGE_NAME</font></th>
					<th><font color="RED">PROCEDURE_NAME</font></th>
					<th><font color="RED">MESSAGE</font></th>
					<th><font color="RED">ERROR_MESSAGE</font></th>
					<th><font color="RED">STEP_NUMBER</font></th>
					<th><font color="RED">RECORD_COUNT</font></th>
					<th><font color="RED">START_DATE</font></th>
					<th><font color="RED">END_DATE</font></th>
					<th><font color="RED">ELAPSED_TIME</font></th>
				</tr>
				</font>';

			FOR cur_excpt in err_data
			LOOP
				EXIT WHEN err_data%NOTFOUND;

				mesg :=  mesg
						|| '<font face = "calibri" size="2" > <tr> <div align="center"> <td>'
						|| cur_excpt.LOG_ID
						|| '</td> <td> <div align="center">'
						|| cur_excpt.PACKAGE_NAME
						|| '</td> <td> <div align="center">'
						|| cur_excpt.PROCEDURE_NAME
						|| '</td> <td> <div align="center">'
						|| cur_excpt.MESSAGE
						|| '</td> <td> <div align="center">'
						|| cur_excpt.ERROR_MESSAGE
						|| '</td> <td> <div align="center">'
						|| cur_excpt.STEP_NUMBER
						|| '</td> <td> <div align="center">'
						|| cur_excpt.RECORD_COUNT
						|| '</td> <td> <div align="center">'
						|| cur_excpt.START_DATE
						|| '</td> <td> <div align="center">'
						|| cur_excpt.END_DATE
						|| '</td> <td> <div align="center">'
						|| cur_excpt.ELAPSED_TIME
						|| '</td> </tr> </font>';
			END LOOP;

			mesg := mesg || '</table>';
     -- l_subject := l_subject || ' - Error';

		ELSE
			mesg := mesg
			|| '<p> No errors have been recorded. </p>';

		END IF;

	END IF;


	l_stmt := 'stmt 4.0';

	mesg := mesg
			|| '<P> Thanks,<BR>'
			|| 'TIM Support (Infosys)</BR>'
			|| '</BODY></html>';

  --dbms_output.put_line(mesg);
	xx_job_status_mail_pkg.send_mail_prc (l_to,l_cc,l_subject,3,mesg);

END mail_wf_status_prc;

PROCEDURE  mail_settlement_errdata_prc (p_to VARCHAR2,
              p_cc VARCHAR2,
							p_subject VARCHAR2)
IS

  l_to varchar2(1000);
  l_cc varchar2(1000);
  l_subject varchar2(2000);
	l_stmt varchar2(10000);
  l_count number;
	mesg clob;
  l_mail varchar2(100);
  
  v_message_in varchar2(1000);
  v_procedure_name varchar2(100);
  v_package_name  varchar2(100); 
  v_step_number number:=0;
  v_record_count number:= 0;
  v_log_id INTEGER := aex_seq_log_id.nextval;  

	cursor interface_data
	is
	select s1.settlement_id
		,s1.promotion_id linked_promotion_id
		,to_char(s1.aex_start_date,'DD-MON-YY') claim_start_date
		,to_char(s1.aex_end_date,'DD-MON-YY') claim_end_date
		,to_char(s1.date_posted,'DD-MON-YY HH24:MI:SS') settlement_date_posted
		,ss.settlement_status_desc settlement_status
		,ac.dm_site_desc  settlement_planning_Account
		,case when nvl(br.t_ep_p2_ep_id,0)<>0 then br.ps_desc else '' end settlement_Brand
		,case when nvl(bt.aex_vendor_id,0)<>0 then bt.aex_vendor_desc else '' end Customer_bill_to
		,case when nvl(rc.gl_code_id,0)<>0 then rc.gl_code_desc else '' end reason_code
		,u.first_name||' '||u.last_name settlement_owner
    ,u.e_mail_adress e_mail_address
		,case 
            when (s1.aex_incorr_promo_flag = 1 
                  and (s1.aex_start_date is null
                  or s1.aex_end_date is null 
                  or ac.t_ep_site_ep_id=0
                  or br.t_ep_p2_ep_id=0
                  or bt.aex_vendor_id=0
                  or rc.gl_code_id=0))
            Then 'Linked with Incorrect Promotion and has NULL Fields' 
            when (s1.aex_incorr_promo_flag = 1 
                  and s1.aex_start_date is not null
                  and s1.aex_end_date is not null 
                  and ac.t_ep_site_ep_id<>0
                  and br.t_ep_p2_ep_id<>0
                  and bt.aex_vendor_id<>0
                  and rc.gl_code_id<>0)
            Then 'Linked with Incorrect Promotion'    
            when (s1.aex_incorr_promo_flag <> 1 
                  and s1.aex_start_date is null
                  and s1.aex_end_date is null 
                  and ac.t_ep_site_ep_id=0
                  and br.t_ep_p2_ep_id=0
                  and bt.aex_vendor_id=0
                  and rc.gl_code_id=0)
            Then 'This settlement has NULL fields'  
		end error_comments
	from settlement s1
		,settlement_status ss
		,t_ep_site ac
		,t_ep_p2 br
		,aex_vendor bt
		,gl_code rc
		,aex_ded_specialist so
		,user_id u
	WHERE s1.settlement_status_id = 6
	and s1.settlement_status_id=ss.settlement_status_id
	and s1.t_ep_site_ep_id=ac.t_ep_site_ep_id
	and s1.t_ep_p2_ep_id=br.t_ep_p2_ep_id
	and s1.aex_vendor_id=bt.aex_vendor_id
	and s1.gl_code_id=rc.gl_code_id
	and s1.aex_ded_specialist_id=so.aex_ded_specialist_id
	and s1.aex_ded_specialist_id=u.user_id
	and not exists 
		(SELECT s.settlement_id 
			FROM settlement s
			WHERE s.settlement_id=s1.settlement_id
			and s.settlement_status_id = 6
			and s.aex_start_date is not null
			and s.aex_end_date is not null
			and nvl(s.t_ep_site_ep_id,0) <>0
			and nvl(s.t_ep_p2_ep_id,0) <>0
			and nvl(s.aex_vendor_id,0) <>0
			and nvl(s.gl_code_id,0) <>0
			and nvl(s.aex_incorr_promo_flag,0) <>1)
    order by  u.e_mail_adress,s1.settlement_id  ;  
	

BEGIN
  --l_to := p_to;
  l_to := Null;
  l_mail :=  NULL;
  l_cc := p_cc;
  l_subject := p_subject;

  v_message_in := 'step 1 ';
  v_procedure_name :='mail_settlement_errdata_prc';
  v_package_name  := 'XX_JOB_STATUS_MAIL_PKG';  
  v_step_number := v_step_number + 1;
    
  aex_log.start_log (v_log_id, v_procedure_name, v_message_in, v_step_number, v_package_name);  

	l_stmt := 'stmt 1.0';

	mesg := mesg
			|| '<html>
					<head>
					</head>
					<body bgcolor="#FFFFFF" link="#8B0000">
					Hi Team, <p> Please find the list of settlement records which are not exported to AS400. </p>
           <p> Please take necessary action, so that these records will be exported in the next scheduled program run. </p>';

	l_stmt := 'stmt 2.0';

	mesg := mesg
			|| '<table border="2" width="1000" style="border-collapse:collapse;" cellpadding="5">
				 <font color="BLUE" size="2">
        <tr>
					<th><font color="BLUE">Settlement_Id</font></th>
					<th><font color="BLUE">Linked_Promotion_Id</font></th>
					<th><font color="BLUE">Claim_Start_Date</font></th>
					<th><font color="BLUE">Claim_End_Date</font></th>
					<th><font color="BLUE">Settlement_Date_Posted</font></th>
					<th><font color="BLUE">Settlement_Status</font></th>
					<th><font color="BLUE">Settlement_Planning_Account</font></th>
					<th><font color="BLUE">Settlement_Brand</font></th>
					<th><font color="BLUE">Customer_Bill_To</font></th>
					<th><font color="BLUE">Reason_Code</font></th>
					<th><font color="BLUE">Settlement_Owner</font></th>
          <th><font color="BLUE">E_Mail_Address</font></th>
					<th><font color="BLUE">Error_Comments</font></th>
				</tr>
        </font>';

	l_stmt := 'stmt 3.0';

	FOR cur_excpt in interface_data
	LOOP
		EXIT WHEN interface_data%NOTFOUND;

		mesg :=  mesg
				|| '<font face = "calibri" size="2" > <tr> <div align="center"> <td> <font color="RED">'
				|| cur_excpt.SETTLEMENT_ID
				|| '</font> </td> <td> <div align="center">'
				|| cur_excpt.LINKED_PROMOTION_ID
				|| '</td> <td> <div align="center">'
				|| cur_excpt.CLAIM_START_DATE
				|| '</td> <td> <div align="center">'
				|| cur_excpt.CLAIM_END_DATE
				|| '</td> <td> <div align="center">'
				|| cur_excpt.SETTLEMENT_DATE_POSTED
				|| '</td> <td> <div align="center">'
				|| cur_excpt.SETTLEMENT_STATUS
				|| '</td> <td> <div align="center">'
				|| cur_excpt.SETTLEMENT_PLANNING_ACCOUNT
				|| '</td> <td> <div align="center">'
				|| cur_excpt.SETTLEMENT_BRAND
				|| '</td> <td> <div align="center">'
				|| cur_excpt.CUSTOMER_BILL_TO
				|| '</td> <td> <div align="center">'
				|| cur_excpt.REASON_CODE
				|| '</td> <td> <div align="center">'
				|| cur_excpt.SETTLEMENT_OWNER
				|| '</td> <td> <div align="center">'			
				|| cur_excpt.E_MAIL_ADDRESS
				|| '</td> <td> <div align="center"> <font color="RED">'	        
				|| cur_excpt.ERROR_COMMENTS
				|| '</td> </tr> </font> </font>';
        
    IF cur_excpt.E_MAIL_ADDRESS is not null AND nvl(cur_excpt.E_MAIL_ADDRESS,'abc') <> nvl(l_mail,'abc') then
    l_to := l_to ||','|| cur_excpt.E_MAIL_ADDRESS ;
    l_mail := cur_excpt.E_MAIL_ADDRESS ;
    END IF;
    
	END LOOP;
  
  l_to := p_to||l_to;

	mesg := mesg || '</table>';

	l_stmt := 'stmt 4.0';

	mesg := mesg
			|| '<P> Thanks,<BR>'
			|| 'TIM Support (Infosys)</BR>'
			|| '</BODY></html>';

  --dbms_output.put_line(mesg);
  
  select count(1) INTO l_count
  from settlement s1
  where s1.settlement_status_id = 6
  and not exists 
		(SELECT s.settlement_id 
			FROM settlement s
			WHERE s.settlement_id=s1.settlement_id
			and s.settlement_status_id = 6
			and s.aex_start_date is not null
			and s.aex_end_date is not null
			and nvl(s.t_ep_site_ep_id,0) <>0
			and nvl(s.t_ep_p2_ep_id,0) <>0
			and nvl(s.aex_vendor_id,0) <>0
			and nvl(s.gl_code_id,0) <>0
			and nvl(s.aex_incorr_promo_flag,0) <>1);
  
  IF l_count > 0 THEN
	xx_job_status_mail_pkg.send_mail_prc (l_to,l_cc,l_subject,1,mesg);
  END IF;
  
  aex_log.end_log(v_log_id, v_step_number, v_record_count);
  
EXCEPTION
    WHEN OTHERS THEN
        BEGIN
        aex_log.end_log(v_log_id, v_step_number, v_record_count, TRUE);
        RAISE;
        END;  

END mail_settlement_errdata_prc;


PROCEDURE  do_nothing_prc
IS

BEGIN
dbms_output.put_line('Nothing');
END do_nothing_prc;


END xx_job_status_mail_pkg;

/
--------------------------------------------------------
--  DDL for Package XX_JOB_STATUS_MAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "DEMANTRA12251"."XX_JOB_STATUS_MAIL_PKG" 
AS
/******************************************************************************
   NAME:         xx_job_status_mail_pkg
   PURPOSE:      Package to send mail
   REVISIONS:
   Ver        Date        Author
   ---------  ----------  ---------------------------------------------------
   1.0        11/21/2016  Rajavikraman S R / Infosys - Initial version
   ******************************************************************************/

   --v_package_name VARCHAR2(100) := 'XX_JOB_STATUS_MAIL_PKG';

   PROCEDURE send_mail_prc (p_to VARCHAR2,
            p_cc VARCHAR2,
						p_subject VARCHAR2,
            p_Priority NUMBER,
						p_mesg clob);

   PROCEDURE  mail_intrfc_data_prc (p_to VARCHAR2,
              p_cc VARCHAR2,
							p_subject VARCHAR2);

   PROCEDURE  mail_intrfc_errdata_prc (p_to VARCHAR2,
              p_cc VARCHAR2,
							p_subject VARCHAR2);

   PROCEDURE  mail_wf_status_prc (p_to VARCHAR2,
              p_cc VARCHAR2,
							p_subject VARCHAR2,
							p_eng_check VARCHAR2,
							p_err_check VARCHAR2,
							p_wf_id NUMBER);

   PROCEDURE  mail_settlement_errdata_prc (p_to VARCHAR2,
              p_cc VARCHAR2,
							p_subject VARCHAR2);
              
   PROCEDURE  do_nothing_prc;
   
END	xx_job_status_mail_pkg;

/
