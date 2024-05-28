@EndUserText.label: 'Fiori Conf Cocktail Custom Entity'
@UI: {
  headerInfo: {
    typeName: 'Cocktail',
    typeNamePlural: 'Cocktail',
    imageUrl: 'StrDrinkThumb',  //case-sensitive
    
    description: { type: #STANDARD, value: 'Strdrink' } //case-sensitive
  }
}
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FC_API_COCKTAIL'
@Search.searchable: true
define root custom entity ZFC_CE_COCKTAIL
{
      @UI.facet         : [
            {
              id        : 'idIdentification',
              type      : #IDENTIFICATION_REFERENCE,
              label     : 'Cocktail',
              position  : 10
            },
            {
            id          : 'idSteps',
            type        : #LINEITEM_REFERENCE,
            label       : 'Steps',
            position    : 30,
            targetElement: '_steps'
            }
          ]
      @EndUserText.label: 'Cocktail ID'    
          
      @UI               : {
        lineItem        : [{ position: 10 }],
        identification  : [
          { position: 10 }, 
          { type: #FOR_ACTION, dataAction: 'generateImage', label: 'Generate Instructions' }
        ]
      }
  key IdDrink           : abap.char(20);
  @EndUserText.label: 'Cocktail' 
      @UI               : {
            lineItem    : [{ position: 20 }],
            identification: [{ position: 20 }]
          }
      @Search.defaultSearchElement: true
      Strdrink          : abap.char(50);
      @UI               : {
        lineItem        : [{ position: 5 }],
        identification  : [{ position: 5 }]
      }
      @Semantics.imageUrl: true
      StrDrinkThumb     : abap.char( 200 );
      @EndUserText.label: 'Category' 
      @UI               :{
        lineItem: [{ position: 30 }],
        identification  : [{ position: 30, label: '' }]
      }
      StrCategory       : abap.char( 30 );
      @EndUserText.label: 'Glass Type'
      @UI               :{
        lineItem: [{ position: 40 }],
        identification  : [{ position: 40 }]
      }
      
      StrGlass          : abap.char( 30 );
      StrDrinkAlternate : abap.char( 30 );
      StrIBA            : abap.char( 30 );
      
      @UI.identification: [{ position: 45, label: 'Ingredients' }]
      StrIngredients: abap.char(300);
      
      StrIngredient1    : abap.char( 40 );
      StrMeasure1       : abap.char( 30 );
      StrIngredient2    : abap.char( 40 );
      StrMeasure2       : abap.char( 30 );
      StrIngredient3    : abap.char( 40 );
      StrMeasure3       : abap.char( 30 );
      StrIngredient4    : abap.char( 40 );
      StrMeasure4       : abap.char( 30 );
      StrIngredient5    : abap.char( 40 );
      StrMeasure5       : abap.char( 30 );
      StrIngredient6    : abap.char( 40 );
      StrMeasure6       : abap.char( 30 );
      StrIngredient7    : abap.char( 40 );
      StrMeasure7       : abap.char( 30 );
      StrIngredient8    : abap.char( 40 );
      StrMeasure8       : abap.char( 30 );
      StrIngredient9    : abap.char( 40 );
      StrMeasure9       : abap.char( 30 );
      StrIngredient10   : abap.char( 40 );
      StrMeasure10      : abap.char( 30 );
      StrIngredient11   : abap.char( 40 );
      StrMeasure11      : abap.char( 30 );
      StrIngredient12   : abap.char( 40 );
      StrMeasure12      : abap.char( 30 );
      StrIngredient13   : abap.char( 40 );
      StrMeasure13      : abap.char( 30 );
      StrIngredient14   : abap.char( 40 );
      StrMeasure14      : abap.char( 30 );
      StrIngredient15   : abap.char( 40 );
      StrMeasure15      : abap.char( 30 );
      _steps            : composition [0..*] of ZFC_CE_COCKTAIL_STEPS;
}
