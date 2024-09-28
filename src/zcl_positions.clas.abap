class ZCL_POSITIONS definition
  public
  final
  create public .

public section.

  interfaces ZIF_POSITIONS_READER .

  methods READ_POSITIONS
    importing
      !IV_BUKRS type BUKRS
      !IV_DUE_DATE type ZDE_DUE_DATE
      !IV_ID type ZDE_ID
      !IV_OPEN_POSITION type ZDE_OPEN_POSITION .
  PROTECTED SECTION.
    METHODS select_positions
      IMPORTING
        !iv_bukrs           TYPE bukrs
        !iv_due_date        TYPE zde_due_date
        !iv_id              TYPE zde_id
        !iv_open_position   TYPE zde_open_position
      RETURNING
        VALUE(rt_positions) TYPE ztt_bsi .

PRIVATE SECTION.

  DATA mt_positions TYPE ztt_bsi .
  CONSTANTS: BEGIN OF mc_type .
  CONSTANTS: creditor TYPE zde_type VALUE 'C'.
  CONSTANTS: debitor TYPE zde_type VALUE 'D'.
  CONSTANTS: END OF mc_type.
ENDCLASS.



CLASS ZCL_POSITIONS IMPLEMENTATION.


  METHOD READ_POSITIONS.
    mt_positions = select_positions(
                     iv_bukrs         = iv_bukrs         " Buchungskreis
                     iv_due_date      = iv_due_date      " Fälligkeitsdatum
                     iv_id            = iv_id            " Kennung
                     iv_open_position = iv_open_position " Offene Position
                   ).

  ENDMETHOD.


  METHOD select_positions.
    DATA: lt_positions_creditor TYPE TABLE OF zbsik.
    DATA: lt_positions_debitor TYPE TABLE OF zbsik.

    SELECT * FROM zbsik
      INTO TABLE @lt_positions_creditor
      WHERE bukrs     = @iv_bukrs
        AND due_date  = @iv_due_date
        AND lifnr     = @iv_id.

    IF iv_open_position = abap_true.
      DELETE lt_positions_creditor WHERE zuonr IS NOT INITIAL.
    ENDIF.

    LOOP AT lt_positions_creditor ASSIGNING FIELD-SYMBOL(<ls_positions>).
      APPEND INITIAL LINE TO rt_positions ASSIGNING FIELD-SYMBOL(<ls_positions_return>).
      MOVE-CORRESPONDING <ls_positions> TO <ls_positions_return>.
      <ls_positions_return>-id = <ls_positions>-lifnr.
      <ls_positions_return>-type = mc_type-creditor.
    ENDLOOP.

    SELECT * FROM zbsid
      INTO TABLE @lt_positions_debitor
      WHERE bukrs     = @iv_bukrs
        AND due_date  = @iv_due_date
        AND kunnr     = @iv_id.

    IF iv_open_position = abap_true.
      DELETE lt_positions_debitor WHERE zuonr IS NOT INITIAL.
    ENDIF.

    LOOP AT lt_positions_debitor ASSIGNING <ls_positions>.
      APPEND INITIAL LINE TO rt_positions ASSIGNING <ls_positions_return>.
      MOVE-CORRESPONDING <ls_positions> TO <ls_positions_return>.
      <ls_positions_return>-id = <ls_positions>-lifnr.
      <ls_positions_return>-type = mc_type-debitor.
    ENDLOOP.
  ENDMETHOD.


  METHOD ZIF_POSITIONS_READER~GET_DATA.
    rt_positions = mt_positions.
  ENDMETHOD.
ENDCLASS.
