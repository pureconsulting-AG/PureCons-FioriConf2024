sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'zfioriconf2024/test/integration/FirstJourney',
		'zfioriconf2024/test/integration/pages/CocktailList',
		'zfioriconf2024/test/integration/pages/CocktailObjectPage'
    ],
    function(JourneyRunner, opaJourney, CocktailList, CocktailObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('zfioriconf2024') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheCocktailList: CocktailList,
					onTheCocktailObjectPage: CocktailObjectPage
                }
            },
            opaJourney.run
        );
    }
);