*&---------------------------------------------------------------------*
*& Report ZREAD_POSITIONS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zread_positions MESSAGE-ID zm_test2.

CLASS lcl_positions_alv DEFINITION
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS mc_btn_xl_export TYPE string VALUE 'BTN_XL_EXPORT' ##NO_TEXT.

    METHODS display .
    METHODS constructor
      IMPORTING
        !iv_bukrs         TYPE bukrs
        !iv_due_date      TYPE zde_due_date
        !iv_id            TYPE zde_id
        !iv_open_position TYPE zde_open_position
      RAISING
        zcx_error .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mo_positions        TYPE REF TO zcl_positions .
    DATA mo_positions_writer TYPE REF TO zcl_positions_writer.
    DATA mo_salv_table       TYPE REF TO cl_salv_table .
    DATA mt_positions        TYPE ztt_bsi.

    METHODS on_toolbar_click
      FOR EVENT added_function OF cl_salv_events_table
      IMPORTING
        !e_salv_function
        !sender .
ENDCLASS.



CLASS lcl_positions_alv IMPLEMENTATION.

  METHOD constructor.
    mo_positions = NEW zcl_positions( ).
    mo_positions_writer = NEW zcl_positions_writer( io_positions_reader = mo_positions ).

    mo_positions->read_positions(
      EXPORTING
        iv_bukrs         = iv_bukrs                         " Buchungskreis
        iv_due_date      = iv_due_date                      " Fälligkeitsdatum
        iv_id            = iv_id                            " Kennung
        iv_open_position = iv_open_position                 " Offene Position
    ).


    mt_positions = mo_positions_writer->create_report( ).

    TRY.
        cl_salv_table=>factory(
        EXPORTING
            r_container = cl_gui_container=>default_screen
          IMPORTING
            r_salv_table   = mo_salv_table                          " Basisklasse einfache ALV Tabellen
          CHANGING
            t_table        = mt_positions
        ).
      CATCH cx_salv_msg. " ALV: Allg. Fehlerklasse  mit Meldung
        RAISE EXCEPTION TYPE zcx_error MESSAGE e005.
    ENDTRY.

    mo_salv_table->get_functions( )->set_all( abap_false ).

    TRY.
        mo_salv_table->get_functions( )->add_function( name = |{ mc_btn_xl_export }|
                                            icon = |{ icon_export }|
                                            text = 'Export'
                                            tooltip = 'Daten exportieren'
                                            position = if_salv_c_function_position=>right_of_salv_functions ).

      CATCH cx_salv_wrong_call. " ALV: Allg. Fehlerklasse  mit Meldung
        RAISE EXCEPTION TYPE zcx_error MESSAGE e005.
      CATCH cx_salv_existing. " ALV: Allg. Fehlerklasse  mit Meldung
        RAISE EXCEPTION TYPE zcx_error MESSAGE e005.
    ENDTRY.

    SET HANDLER on_toolbar_click FOR mo_salv_table->get_event( ).

  ENDMETHOD.

  METHOD display.
    mo_salv_table->display( ).
    WRITE: space.
  ENDMETHOD.

  METHOD on_toolbar_click.
    CASE e_salv_function.
      WHEN mc_btn_xl_export.
        TRY.
            DATA(lv_file_path) = mo_positions_writer->write_file( ).

            MESSAGE s006(zm_test2) WITH lv_file_path.
          CATCH zcx_error INTO DATA(lx_error).
            MESSAGE lx_error TYPE 'S' DISPLAY LIKE 'E'.
        ENDTRY.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

PARAMETERS: p_bukrs     TYPE bukrs.
PARAMETERS: p_ddate     TYPE zde_due_date.
PARAMETERS: p_id        TYPE zde_id.
PARAMETERS: p_op        TYPE zde_open_position.

DATA: go_positions_alv TYPE REF TO lcl_positions_alv.

START-OF-SELECTION.

  TRY.

      go_positions_alv = NEW lcl_positions_alv(
        iv_bukrs         = p_bukrs
        iv_due_date      = p_ddate
        iv_id            = p_id
        iv_open_position = p_op

      ).

      go_positions_alv->display( ).

    CATCH zcx_error INTO DATA(lx_error). " Fehler
      MESSAGE lx_error TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.
