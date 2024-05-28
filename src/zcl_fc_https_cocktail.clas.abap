CLASS zcl_fc_https_cocktail DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      _t_cocktails TYPE STANDARD TABLE OF zfc_ce_cocktail WITH KEY iddrink,
      BEGIN OF _response_cocktails,
        drinks TYPE _t_cocktails,
      END OF _response_cocktails,

      _t_steps TYPE STANDARD TABLE OF zfc_ce_cocktail_steps WITH KEY iddrink idstep,
      BEGIN OF _response_steps,
        steps TYPE _t_steps,
      END OF _response_steps.


    CLASS-METHODS _get_cocktails
      IMPORTING
        i_drink     TYPE string OPTIONAL
        i_search    TYPE string OPTIONAL
      EXPORTING
        e_cocktails TYPE zcl_fc_https_cocktail=>_response_cocktails
        e_lines     TYPE i.

    CLASS-METHODS _get_steps
      IMPORTING
        i_drink TYPE string
      EXPORTING
        e_steps TYPE _response_steps
        e_lines TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS _api_call
      IMPORTING i_url             TYPE string
      RETURNING VALUE(r_response) TYPE string .
ENDCLASS.



CLASS zcl_fc_https_cocktail IMPLEMENTATION.
  METHOD _api_call.
    TRY.
        TRY.
            DATA(_client) = cl_web_http_client_manager=>create_by_http_destination( cl_http_destination_provider=>create_by_url( i_url )  ).
          CATCH cx_http_dest_provider_error.
            "handle exception
        ENDTRY.
        DATA(_response) = _client->execute( if_web_http_client=>get ).
        DATA(_status) = _response->get_status( ).
        IF _status-code = 200.
          r_response = _response->get_text( ).
        ELSE.
          RETURN.
        ENDIF.

        _client->close( ).

      CATCH cx_web_http_client_error INTO DATA(lx_http_error).
*        WRITE: / lx_http_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
  METHOD _get_cocktails.
    DATA(_response_body) = zcl_fc_https_cocktail=>_api_call(
    i_url = COND #(
      WHEN i_drink IS NOT INITIAL THEN |https://www.thecocktaildb.com/api/json/v1/| && zcl_fc_cocktail_token=>ty_token-cocktail && |/lookup.php?i={ i_drink }|
      WHEN i_search IS NOT INITIAL THEN |https://www.thecocktaildb.com/api/json/v1/| && zcl_fc_cocktail_token=>ty_token-cocktail && |/search.php?s={ substring( val = i_search off = 1 len = strlen( i_search ) - 2 ) }|
      ELSE |https://www.thecocktaildb.com/api/json/v1/| && zcl_fc_cocktail_token=>ty_token-cocktail && |/search.php?s=c| )
    ).
    /ui2/cl_json=>deserialize(
          EXPORTING
            json        = _response_body
          CHANGING
            data        = e_cocktails
        ).
    e_lines = lines( e_cocktails-drinks ).
  ENDMETHOD.


  METHOD _get_steps.
    TYPES: BEGIN OF _response_instr,
             iddrink         TYPE string,
             strinstructions TYPE string,
             strdrink        TYPE string,
           END OF _response_instr.
    DATA:
      _t_response_instr TYPE STANDARD TABLE OF _response_instr,
      BEGIN OF _response_steps,
        drinks LIKE _t_response_instr,
      END OF _response_steps.
    DATA: _count TYPE i.

    SELECT * FROM zfc_cocktail_st WHERE iddrink = @i_drink INTO TABLE @DATA(_steps_image).
    DATA(_response_body) = zcl_fc_https_cocktail=>_api_call( i_url = |https://www.thecocktaildb.com/api/json/v1/| && zcl_fc_cocktail_token=>ty_token-cocktail && |/lookup.php?i={ i_drink }| ).
    /ui2/cl_json=>deserialize(
          EXPORTING
            json        = _response_body
          CHANGING
            data        = _response_steps
        ).
    DATA(_instructions) = _response_steps-drinks[ iddrink = i_drink ]-strinstructions.
    SPLIT _instructions AT |.| INTO TABLE DATA(_splitted_instructions).

    LOOP AT _splitted_instructions ASSIGNING FIELD-SYMBOL(<_splitted_instruction>).
      APPEND INITIAL LINE TO e_steps-steps ASSIGNING FIELD-SYMBOL(<_step>).
      _count = _count + 1.
      <_step>-idstep = _count.
      <_step>-image_url = VALUE #( _steps_image[ _count ]-image_url OPTIONAL ).
      <_step>-iddrink = i_drink.
      <_step>-instruction = condense( <_splitted_instruction> ).
      <_step>-imagegenerated = COND #( WHEN <_step>-image_url IS NOT INITIAL THEN abap_true ELSE abap_false ).
      <_step>-criticalityimage = COND #( WHEN <_step>-image_url IS NOT INITIAL THEN 3 ELSE 1 ).
    ENDLOOP.
    e_lines = _count.
  ENDMETHOD.

ENDCLASS.
