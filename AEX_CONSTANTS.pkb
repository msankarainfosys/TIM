--------------------------------------------------------
--  File created - Tuesday-April-27-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body AEX_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEMANTRA12251"."AEX_CONSTANTS" 
as
function get_min_sales_date return date
as
	v_min_sales_date date;
begin
    select to_date(pval,'MM-DD-YYYY HH24:MI:SS')
    into   v_min_sales_date
    from   sys_params 
    where  pname in ('min_sales_date');
	return v_min_sales_date;
end get_min_sales_date ;
function get_max_sales_date return date
as
begin
    return to_date(get_max_date,'MM-DD-YYYY HH24:MI:SS');
end get_max_sales_date ;
function get_max_forecast_sales_date return date
as
    v_min_forecast_sales_date       date;
    v_max_forecast_sales_date       date;
begin
    select to_date(pval,'MM-DD-YYYY HH24:MI:SS')
    into   v_min_forecast_sales_date
    from   sys_params 
    where  pname in ('min_fore_sales_date');

    select v_min_forecast_sales_date+ (value_float*7) 
    into   v_max_forecast_sales_date
    from   init_params_1 
    where  pname = 'lead';
    return v_max_forecast_sales_date;
end get_max_forecast_sales_date;
end aex_constants;

/
