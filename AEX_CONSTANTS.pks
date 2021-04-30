--------------------------------------------------------
--  File created - Tuesday-April-27-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package AEX_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "DEMANTRA12251"."AEX_CONSTANTS" 
as
  	function get_min_sales_date return date;
    function get_max_sales_date return date;
    function get_max_forecast_sales_date return date;
end aex_constants;
 
 
 
 
 

/
