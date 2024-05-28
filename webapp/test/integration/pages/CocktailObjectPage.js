sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'zfioriconf2024',
            componentId: 'CocktailObjectPage',
            contextPath: '/Cocktail'
        },
        CustomPageDefinitions
    );
});