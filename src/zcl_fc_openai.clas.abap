CLASS zcl_fc_openai DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES: if_oo_adt_classrun,
      if_abap_parallel .

    DATA:
      m_prompt    TYPE string READ-ONLY,
      m_image     TYPE string READ-ONLY,
      m_errortext TYPE string READ-ONLY,
      m_step      TYPE zfc_ce_cocktail_steps READ-ONLY.

    TYPES:
      BEGIN OF ty_data,
        revised_prompt TYPE string,
        url            TYPE string,
      END OF ty_data.
    DATA: _data TYPE STANDARD TABLE OF ty_data.
    TYPES:
      BEGIN OF ty_json_response,
        created TYPE string,
        data    LIKE _data,
      END OF ty_json_response.

    DATA _response TYPE ty_json_response.

    METHODS call_openai_dall_e
      IMPORTING i_prompt       TYPE string
      RETURNING VALUE(r_image) TYPE string
      RAISING
                cx_web_http_client_error.

    CLASS-METHODS generate_images
      IMPORTING
        i_cocktail  TYPE zfc_ce_cocktail
      EXPORTING
        e_errortext TYPE string
      CHANGING
        c_steps     TYPE zcl_fc_https_cocktail=>_t_steps
      .

    METHODS constructor
      IMPORTING i_prompt TYPE string
                i_step   TYPE zfc_ce_cocktail_steps OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fc_openai IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    "me->call_openai_dall_e( i_prompt = 'comic book style: three astronauts wearing white uniforms with orange elements are recording a new song in a collaborative jamming session' ).
    DATA(lo_image1) = NEW zcl_fc_openai( i_prompt = 'comic book style: three astronauts wearing white uniforms with orange elements are recording a new song in a collaborative jamming session' ).
    DATA(lo_image2) = NEW zcl_fc_openai( i_prompt = 'comic book style: three astronauts drinking beer' ).
    DATA(lo_parallel) = NEW cl_abap_parallel( ).
    lo_parallel->run_inst( EXPORTING p_in_tab = VALUE #( ( lo_image1 ) ( lo_image2 ) ) IMPORTING p_out_tab = DATA(lt_out) ).
  ENDMETHOD.


  METHOD call_openai_dall_e.
    DATA: lv_url       TYPE string VALUE 'https://api.openai.com/v1/images/generations'.

    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( cl_http_destination_provider=>create_by_url( lv_url ) ).
      CATCH cx_http_dest_provider_error.
        me->m_errortext = |Error while creating HTTP client|.
    ENDTRY.

    lo_client->get_http_request( )->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
    lo_client->get_http_request( )->set_header_field( i_name = 'Authorization' i_value = zcl_fc_cocktail_token=>ty_token-dalle3 ).

    DATA(lv_json_body) = CONV string( '{ "prompt": "' && i_prompt && '", "n": 1, "style": "natural", "size": "1024x1024", "model": "dall-e-3" }' ).


    lo_client->get_http_request( )->set_text( lv_json_body ).


    TRY.
        DATA(lo_request) = lo_client->execute( if_web_http_client=>post ).
        DATA(ls_status) = lo_request->get_status(  ).
        DATA(lv_response) = lo_request->get_text( ).

      CATCH cx_web_message_error INTO DATA(lx_http_request_failed).
        me->m_errortext = |Error while executing request, E: { lx_http_request_failed->get_text( ) }|.
    ENDTRY.


    lo_client->close( ).

    IF ls_status-code = 200.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response CHANGING data = _response ).
      r_image = VALUE #( _response-data[ 1 ]-url OPTIONAL ).

    ELSE.
      me->m_errortext = |HTTP:{ ls_status-code }, Error:{ ls_status-reason }|.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.
    m_prompt = i_prompt.
    m_step = i_step.
  ENDMETHOD.

  METHOD if_abap_parallel~do.
    TRY.
        m_image = me->call_openai_dall_e( i_prompt = m_prompt ).
      CATCH cx_web_http_client_error.
        me->m_errortext = |Error while creating HTTP request|.
    ENDTRY.
  ENDMETHOD.

  METHOD generate_images.

    DATA(_t_gen) = VALUE cl_abap_parallel=>t_in_inst_tab( FOR _step IN c_steps (
      NEW zcl_fc_openai(
        i_prompt = |We are preparing the cocktail { i_cocktail-Strdrink }, consider the following information while generating: Glass Type: { i_cocktail-StrGlass } actually we are at Step: { _step-Idstep } we are doing the following:| &&
                   | { _step-Instruction } please generate a realistic image as reference bar Sazerac-Bar, New Orleans|
          i_step = _step
      )
    ) ).

    NEW cl_abap_parallel( )->run_inst( EXPORTING p_in_tab = _t_gen IMPORTING p_out_tab = DATA(_t_out) ).

    LOOP AT _t_out ASSIGNING FIELD-SYMBOL(<_out>).
      DATA(_obj) = CAST zcl_fc_openai( <_out>-inst ).
      c_steps[ Idstep = _obj->m_step-Idstep ]-Image_Url = _obj->m_image.
      e_errortext = _obj->m_errortext.
    ENDLOOP.

  ENDMETHOD.



ENDCLASS.
