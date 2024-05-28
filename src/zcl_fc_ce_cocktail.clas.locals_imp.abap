CLASS lhc_zfc_ce_cocktail_steps DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zfc_ce_cocktail_steps RESULT result.

    METHODS rba_Cocktail FOR READ
      IMPORTING keys_rba FOR READ zfc_ce_cocktail_steps\_Cocktail FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zfc_ce_cocktail_steps IMPLEMENTATION.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Cocktail.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_ZFC_CE_COCKTAIL DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfc_ce_cocktail RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zfc_ce_cocktail RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zfc_ce_cocktail.

    METHODS rba_Steps FOR READ
      IMPORTING keys_rba FOR READ zfc_ce_cocktail\_Steps FULL result_requested RESULT result LINK association_links.


    METHODS generateImage FOR MODIFY
      IMPORTING keys FOR ACTION zfc_ce_cocktail~generateImage RESULT result.

ENDCLASS.

CLASS lhc_ZFC_CE_COCKTAIL IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Steps.
  ENDMETHOD.

  METHOD generateImage.
    DATA: _t_insert TYPE TABLE OF zfc_cocktail_st.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<_key>).
      zcl_fc_https_cocktail=>_get_cocktails( EXPORTING i_drink = CONV #( <_key>-IdDrink ) IMPORTING e_cocktails = DATA(_cocktails) ).
      zcl_fc_https_cocktail=>_get_steps( EXPORTING i_drink = CONV #( <_key>-IdDrink ) IMPORTING e_steps = DATA(_steps) ).
      zcl_fc_openai=>generate_images( EXPORTING i_cocktail = _cocktails-drinks[ 1 ] IMPORTING e_errortext = DATA(_error) CHANGING c_steps = _steps-steps ).

      IF _error IS INITIAL.
        _t_insert = VALUE #( FOR _step IN _steps-steps ( CORRESPONDING #( _step ) ) ).
        MODIFY zfc_cocktail_st FROM TABLE @_t_insert.
        APPEND VALUE #( BASE CORRESPONDING #( <_key> ) %param = CORRESPONDING #( <_key> ) ) TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      ELSE.
        failed-zfc_ce_cocktail = VALUE #( ( CORRESPONDING #( <_key> ) ) ).
        reported-zfc_ce_cocktail = VALUE #( (
          VALUE #( BASE CORRESPONDING #( <_key> )
            %msg = new_message_with_text( text = _error )
          )
        ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZFC_CE_COCKTAIL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZFC_CE_COCKTAIL IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
