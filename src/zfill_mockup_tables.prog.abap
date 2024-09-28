*&---------------------------------------------------------------------*
*& Report ZFILL_TABLES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfill_mockup_tables.

DATA: gt_zbsid TYPE TABLE OF zbsid.
DATA: gt_zbsik TYPE TABLE OF zbsik.

SELECT COUNT( * ) FROM zbsid INTO @DATA(gv_zbsid_count).
SELECT COUNT( * ) FROM zbsik INTO @DATA(gv_zbsik_count).

IF gv_zbsid_count = 0.

  gt_zbsid = VALUE #(
  ( bukrs = '0001' kunnr = '0000000001' belnr_d = '0000000001' budat = '20240101' due_date = '20241010' zuonr = '000000000000000001' dmbtr = 1 waers = 'EUR' )
  ( bukrs = '0001' kunnr = '0000000002' belnr_d = '0000000002' budat = '20240102' due_date = '20241010' zuonr = '000000000000000002' dmbtr = 1 waers = 'EUR' )
  ( bukrs = '0001' kunnr = '0000000003' belnr_d = '0000000003' budat = '20240103' due_date = '20241010' zuonr = '000000000000000003' dmbtr = 1 waers = 'EUR' )
  ( bukrs = '0001' kunnr = '0000000004' belnr_d = '0000000004' budat = '20240104' due_date = '20241010' zuonr = '000000000000000004' dmbtr = 1 waers = 'EUR' )
  ( bukrs = '0001' kunnr = '0000000005' belnr_d = '0000000005' budat = '20240105' due_date = '20241010' zuonr = '' dmbtr = 1 waers = 'EUR' )
   ).

  INSERT zbsid FROM TABLE gt_zbsid.
ENDIF.

IF gv_zbsik_count = 0.

  gt_zbsik = VALUE #(
  ( bukrs = '0001' lifnr = '0000000006' belnr_d = '0000000001' budat = '20240101' due_date = '20241010' zuonr = '000000000000000001' dmbtr = 1 waers = 'EUR' )
  ( bukrs = '0001' lifnr = '0000000007' belnr_d = '0000000002' budat = '20240102' due_date = '20241010' zuonr = '000000000000000002' dmbtr = 1 waers = 'EUR' )
  ( bukrs = '0001' lifnr = '0000000008' belnr_d = '0000000003' budat = '20240103' due_date = '20241010' zuonr = '000000000000000003' dmbtr = 1 waers = 'EUR' )
  ( bukrs = '0001' lifnr = '0000000009' belnr_d = '0000000004' budat = '20240104' due_date = '20241010' zuonr = '000000000000000004' dmbtr = 1 waers = 'EUR' )
  ( bukrs = '0001' lifnr = '0000000010' belnr_d = '0000000005' budat = '20240105' due_date = '20241010' zuonr = '' dmbtr = 1 waers = 'EUR' )
   ).

  INSERT zbsik FROM TABLE gt_zbsik.
ENDIF.

MESSAGE s000(zm_test2).
