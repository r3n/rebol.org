REBOL [
    Title: "REBOL Ale"
    Date: 30-Oct-1998
    File: %beer.r
    Purpose: "A rich, malty, copper brew."
    library: [
        level: 'beginner
        platform: none
        type: 'Idiom
        domain: [dialects x-file]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

Ingredients: [
    0.5 lb. "Toasted malted barley"
    7 lb.   "Amber malt extract"
    1 lb.   "Crystal malt"
    1.5 oz. "Northern brewer hops"
    1 oz.   "Cascade hops"
    1 pkg.  "Ale yeast"
    5 gal.  "Sassenranch water"
]

Instructions: {
    After toasting barley to red color (15 minutes), boil
    it in 1/3 of the water for 10 minutes along with
    the crystal malt.  Add malt extract and brewer hops,
    then cook 55 minutes.  Add cascade hops and remove
    from heat.  Sparge into remaining cold water.
    Add yeast when cool. Rack twice. Wait four weeks.
    Cheers to the revolution!
}


;-- Conversion to Metric Units:

Equivalent: [
    gal. 3.8  l. ; liters per gallon
    lb.  0.45 kg.
    oz.  28.3 g.
]

foreach [amount units description] Ingredients [
    conversion: find equivalent units
    either conversion [
        print [
            amount * second conversion
            third conversion
            description
        ]
    ][
        print [amount units description]
    ]
]
