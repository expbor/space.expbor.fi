class ZCL_POSITIONS_WRITER definition
  public
  final
  create public .

public section.

  methods CREATE_REPORT
    returning
      value(RT_POSITIONS) type ZTT_BSI
    raising
      ZCX_ERROR .
  methods CREATE_JSON
    returning
      value(RV_JSON) type STRING
    raising
      ZCX_ERROR .
  methods WRITE_FILE
    returning
      value(RV_FILE_PATH) type STRING
    raising
      ZCX_ERROR .
  methods CONSTRUCTOR
    importing
      !IO_POSITIONS_READER type ref to ZIF_POSITIONS_READER .
  PROTECTED SECTION.

private section.

  constants MC_LOGICAL_FILE_NAME type FILENAME-FILEINTERN value 'ZPOSITIONS_JSON' ##NO_TEXT.
  data MO_POSITIONS_READER type ref to ZIF_POSITIONS_READER .
ENDCLASS.



CLASS ZCL_POSITIONS_WRITER IMPLEMENTATION.


  METHOD constructor.
    mo_positions_reader = io_positions_reader.
  ENDMETHOD.


  METHOD create_json.
    DATA: lv_json TYPE string.

    DATA(lt_positions) = mo_positions_reader->get_data( ).

    TRY.
        DATA(lo_writer_itab) = cl_sxml_string_writer=>create(
                                 type                     =  if_sxml=>co_xt_json                " Format
                               ).
      CATCH cx_sxml_illegal_argument_error INTO DATA(lx_sxml_illegal_argument_error).
        RAISE EXCEPTION TYPE zcx_error MESSAGE e001.
    ENDTRY.

    TRY.
        CALL TRANSFORMATION id SOURCE values = lt_positions RESULT XML lo_writer_itab.

      CATCH cx_transformation_error INTO DATA(lx_transformation_error).
        RAISE EXCEPTION TYPE zcx_error MESSAGE e002.
    ENDTRY.

    TRY.
        DATA(lo_abap_conv_in_ce) = cl_abap_conv_in_ce=>create( ).

        lo_abap_conv_in_ce->convert(
          EXPORTING
            input = lo_writer_itab->get_output( )
          IMPORTING
            data = lv_json
        ).

      CATCH cx_parameter_invalid_type.     " Parameter mit ungültigem Typ
      CATCH cx_parameter_invalid_range.    " Parameter mit ungültigem Wertebereich
      CATCH cx_sy_codepage_converter_init. " System-Exception für Initialisierung Code Page Converter
      CATCH cx_sy_conversion_codepage.
        RAISE EXCEPTION TYPE zcx_error MESSAGE e003.
    ENDTRY.

    rv_json = lv_json.
  ENDMETHOD.


  METHOD create_report.
    DATA(lt_positions) = mo_positions_reader->get_data( ).

    LOOP AT lt_positions ASSIGNING FIELD-SYMBOL(<ls_positions>) GROUP BY ( bukrs = <ls_positions>-bukrs type = <ls_positions>-type id = <ls_positions>-id ).

    ENDLOOP.

    rt_positions = lt_positions.

  ENDMETHOD.


  METHOD write_file.
    DATA: lv_physical_filename  TYPE  string.

    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        logical_filename = mc_logical_file_name
      IMPORTING
        file_name        = lv_physical_filename
      EXCEPTIONS
        file_not_found   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_error MESSAGE e004.
    ENDIF.


    CALL FUNCTION 'FILE_VALIDATE_NAME'
      EXPORTING
        logical_filename           = mc_logical_file_name
      CHANGING
        physical_filename          = lv_physical_filename
      EXCEPTIONS
        logical_filename_not_found = 1
        validation_failed          = 2
        OTHERS                     = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_error MESSAGE e004.
    ENDIF.


    DATA(lv_json) = create_json( ).


    DATA(lv_bytes_xstr) = cl_abap_codepage=>convert_to( source = lv_json ).

    OPEN DATASET lv_physical_filename FOR OUTPUT IN BINARY MODE.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_error MESSAGE e004.
    ENDIF.

    TRANSFER lv_bytes_xstr TO lv_physical_filename.

    CLOSE DATASET lv_physical_filename.

    rv_file_path = lv_physical_filename.

  ENDMETHOD.
ENDCLASS.
