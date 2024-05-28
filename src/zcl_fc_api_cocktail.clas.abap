CLASS zcl_fc_api_cocktail DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS _get_ingredients
      IMPORTING i_cocktail TYPE zfc_ce_cocktail
      RETURNING VALUE(r_ingredients) TYPE string.

ENDCLASS.



CLASS zcl_fc_api_cocktail IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA(_paging) = io_request->get_paging( ).
    DATA(_search) = io_request->get_search_expression( ).
    DATA(_offset) = io_request->get_paging( )->get_offset( ).
    DATA(_filter_range) = io_request->get_filter( )->get_as_ranges( ).
    DATA(_page_size) = io_request->get_paging( )->get_page_size( ).
    DATA(_max_rows) = COND #(
      WHEN _page_size = if_rap_query_paging=>page_size_unlimited THEN 100
      ELSE _page_size
    ).

    CASE io_request->get_entity_id( ).
      WHEN 'ZFC_CE_COCKTAIL'.
        DATA _r_cocktails TYPE STANDARD TABLE OF zfc_ce_cocktail.

        zcl_fc_https_cocktail=>_get_cocktails(
          EXPORTING
            i_drink = VALUE #( _filter_range[ name = 'IDDRINK' ]-range[ 1 ]-low OPTIONAL )
            i_search = _search
          IMPORTING
            e_cocktails = DATA(_response) e_lines = DATA(_number_of_rec)
        ).

        _r_cocktails = VALUE #(
          FOR i = 1 WHILE i <= COND #( WHEN _max_rows <> 0 AND lines( _response-drinks ) > _max_rows THEN _max_rows ELSE _number_of_rec )
          ( VALUE #( BASE CORRESPONDING #( _response-drinks[ i ] )
            StrIngredients = me->_get_ingredients( i_cocktail = _response-drinks[ i ] )
           ) )
        ).

        io_response->set_data( _r_cocktails ).
        io_response->set_total_number_of_records( CONV #( _number_of_rec ) ).
      WHEN 'ZFC_CE_COCKTAIL_STEPS'.
        DATA(_id_drink) = _filter_range[ name = 'IDDRINK' ]-range[ 1 ]-low.
        DATA(_id_step) = VALUE #( _filter_range[ name = 'IDSTEP' ]-range[ 1 ]-low OPTIONAL ).
        DATA: _r_steps TYPE STANDARD TABLE OF zfc_ce_cocktail_steps.
        zcl_fc_https_cocktail=>_get_steps( EXPORTING i_drink = _id_drink IMPORTING e_lines = DATA(_number_of_steps) e_steps = DATA(_steps) ).
        IF _id_step IS INITIAL OR _id_step = 0.
          _r_steps = _steps-steps.
        ELSE.
          _r_steps = VALUE #( ( _steps-steps[ Idstep = _id_step ] ) ).
        ENDIF.

        io_response->set_data( _r_steps ).
        io_response->set_total_number_of_records( lines( _r_steps ) ).

    ENDCASE.

  ENDMETHOD.

  METHOD _get_ingredients.
    DO 15 TIMES.
      ASSIGN COMPONENT |StrIngredient{ sy-index }| OF STRUCTURE i_cocktail TO FIELD-SYMBOL(<ingredient>).
      ASSIGN COMPONENT |StrMeasure{ sy-index }| OF STRUCTURE i_cocktail TO FIELD-SYMBOL(<measure>).
      IF <ingredient> IS ASSIGNED AND <ingredient> IS NOT INITIAL.
        r_ingredients = r_ingredients && | - { <ingredient> } { <measure> }{ cl_abap_char_utilities=>newline }|.
      ENDIF.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
