CLASS zcl_fc_cocktail_token DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS: BEGIN OF ty_token,
                 dalle3 TYPE string VALUE 'Bearer <ENTER YOUR BEARER TOKEN>',
                 cocktail TYPE string VALUE '1', "Default Key
               END OF ty_token.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fc_cocktail_token IMPLEMENTATION.
ENDCLASS.
