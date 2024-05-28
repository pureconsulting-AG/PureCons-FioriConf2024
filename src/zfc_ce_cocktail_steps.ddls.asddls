@EndUserText.label: 'Fiori Conf Cocktail Steps Custom Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FC_API_COCKTAIL'
define custom entity ZFC_CE_COCKTAIL_STEPS
{
   @UI.facet : [{
              id        : 'idIngredientsStep',
              type      : #IDENTIFICATION_REFERENCE,
              label     : 'Ingredients',
              position  : 20 
            }]
  key IdDrink     : abap.char(20);
  key Idstep      : abap.int2;
      Strdrink    : abap.char(50);
      @UI         : {
            lineItem: [{ position: 10 }],
            identification: [{ position: 10 }]
      }
      @EndUserText.label: 'Instruction'
      Instruction : abap.char(100);
      Image_Url   : abap.string;
      @UI.lineItem: [{ position: 20, criticality: 'CriticalityImage', label: 'Image generated?' }]
      ImageGenerated: abap_boolean;
      CriticalityImage: abap.int1;
      _cocktail   : association to parent ZFC_CE_COCKTAIL on $projection.IdDrink = _cocktail.IdDrink;
}
