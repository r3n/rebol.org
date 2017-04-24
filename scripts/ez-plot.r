REBOL [
    Title: "Easy Quick Plot"
    Date: 20-Feb-2002
    Version: 0.1.1
    File: %ez-plot.r
    Author: "Matt Licholai"
    Purpose: "Simple tutorial for using the quick plot dialect."
    History: [0.1.0 [21-Jan-2002 {Documentation for quick-plot (%q-plot.r)
                     initial release (version 0.8)}] 
    [0.1.1 [30-Jan-2002 {Changes to reflect updated plot dialect (version 0.1.1}]]
]
    Email: m.s.licholai@ieee.org
    Requires: %q-plot.r
    Comments: {
    Uses easy-vid 1.1.2 by Carl Sassenrath. Modified by Brett Handley
    to add sliders and then hacked in a very ugly way by me to allow
    arbitrary REBOL code before 'view in the examples.

   Provides basic documentation for my quick-plot dialect.
   }
    library: [
        level: [intermediate] 
        platform: none 
        type: 'tutorial 
        domain: [GUI x-file] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
] 

CVS-id: {$Id: ez-plot.r,v 1.24 2002/02/19 15:30:18 matt Exp $ }

; load q-plot before starting the tutorial
; use 'require if it is available, if not fall back to using 'do
if error? try [require %q-plot.r] [
    if error? try [do %q-plot.r] [
        throw make error! "You need %q-plot.r in your working directory to run this tutorial"
    ]
]

content: {Easy 'Quick-Plot' -- A REBOL Plotting Dialect

===Introduction to Quick-Plot

Quick-Plot (quick-plot) is intended as an easy to use dialect to
simplify displaying 2D plots within REBOL/View.

Plots can be created from a REBOL block containing data or a function which generates
a block of data.  The quick-plot dialect returns a face object
that can then be used for immediate display, as part of a multi-pane user interface
or for further manipulation by REBOL.

The quick-plot dialect was written to address a common request of some new programmers
learning REBOL.  Quick-plot should also be fast and flexible enough
that it is beneficial for experienced REBOL users by providing an additional level of
abstraction when working with 2 dimensional output.

Quick-plot is built on top of the draw and layout dialects of REBOL/View. As such it
relies heavily on the well tested and efficient display routines provided by
those two dialects. 

!Note: Quick-plot requires that %q-plot.r be loaded before using the dialect, since
quick-plot is not part of the standard REBOL environment.

===Creating Plots

Plots are created by calling the quick-plot dialect with a block of plot commands
and options.  The quick-plot dialect returns a face object containing a single pane
that can then be immediately displayed, associated with a word, or
further processed with standard REBOL.

Here is a rather convoluted sample of what is possible.

    view quick-plot [
        600x600
        title "Quick Plot Dialect" style vh1
        x-data [(now/date - 200) (now/date)]
        pen blue
        fill-pen 100.100.90
        y-min 0
        y-max 10
        bars [ (b-data: copy []
                for i 1 9 1 [
                    append b-data (i)
                ]
            )]
        label "Bar graph"
        y-max 1.0
        y-min -1.0
        line [ (y-data: copy []
                for i -200 200 .5 [
                    append y-data sine i
                ]
            )] color yellow
        label "A sine curve"
        line-pattern 1 4 4 4
        line [ (y-data2: copy []
                for i -200 200 .5 [
                    append y-data2 (- abs i / 200.0)
                ]
            )] color green
        label "A Useless function"
        pen forest
        text "Quick-plot makes plotting easy!" up 73 over 20 
        text "Give it a try ..." up 70 over 20
        pen black
        x-grid 5
        y-grid 5
        x-axis 5 border
        y-axis 5 border
    ]

Here is a simple example of a multi-plot.

    y-data1: copy []
    y-data2: copy []
    b-data: copy []
    for i -200 200 .5 [
        append y-data1 (- abs i / 200.0)
        append y-data2 (sine i)
    ]
    for i 1 9 1 [
        append b-data (i)
    ]
    
    plots: multi-plot/ratio 350x600 [
        [ ; top most plot
            title "On Top" style vh2
            line [(y-data1)]
            x-grid 5
            y-grid 5
            x-axis 5
            y-axis 5
        ] ; top
        [ ; 2nd down plot
            fill-pen 100.100.90
            y-min 0
            bars [(b-data)]
            title "Bars"
            x-grid 5
            y-grid 5
            x-axis 5
            y-axis 5
        ] ; 2nd
        [ ; bottom plot
            title "Biggest" style vh1
            line [(y-data2)]
            x-grid 5
            y-grid 5
            x-axis 5
            y-axis 5
        ] ; bottom
    ]
    [0.75 1 1.75] ; specify the relative sizes of the plots
    
    view plots

!Click on the example above to see how it will appear on your
screen.  Click on the close box to remove it.  All of the
examples that follow can be viewed this way.

===Simple Examples

Here is a minimal plotting example. This is the absolute minimum 
required to produce output (although it does nothing useful). 

    view quick-plot [
        100x100
        ]

Here is a slightly more interesting example. It creates a very simple
plot consisting of a title and a piecewise curve that resembles a big "W".

    view quick-plot [
        300x200
        title "Quick Plots"
        line [2 0 1 0 2]
    ]

The line plot type can even be used with a block of data generated by REBOL code 
embedded within the quick-plot block.

    view quick-plot [
        400x400
        line [ (y-data: copy []
                for i -200 200 .5 [
                    append y-data sine 2 * i
                ]
            )]
        label "Sine curve"
        title "Easy REBOL Plotting"
    ]


===Plot Types

There are three basic types of plots elements available using the quick-plot dialect.

---Plot elements

* line

* bar-graph 

* stock market type (showing open, high, low and close prices for one x-value)

!A singe plot pane can contain more than one plot element.

The plot element can be modified by any of the effects possible using the draw 
dialect.  

---Element Effects

* pen color

* line-pattern

* fill-pen

* arbitrary text 

Additional options are available to enhance the readability of a plot.  Options
can be added or modified at anytime when describing a plot.

---Options

* title

* x-grid line

* y-grid lines

* x-axis labels

* y-axis labels

* plot element label

* minimum and maximum x values

* minimum and maximum y values

---Multi-plots

Combining multiple plots into one pane can be accomplished by using the multi-plot
function.  Please see the appropriate section for details.


===Data Requirements

The data required for quick-plot to create panes for display are a pair specifying the 
size of the plot and a block of y-values.  If there is more than one plot element to be 
plotted on a pane then a block of y-values for each element is required.  The 
minimum and maximum values for the x and y coordinates are derived from the first y-data
block provided (unless explicitly given using x-min, x-max and y-min, y-max keywords).

Since most data sources generate a series of y-values with implied x-values, quick-plot 
does not need the x values for a sequence to be plotted.  In other words, the y-values are 
taken to correspond to a regular sequence of x-values. If there is a gap between 
successive plotted points, a 'none should be inserted in the y-value block at that point 
to mark a skipped y value.  The line plot element will use linear interpolation to 
join the points on either side of the skipped value.

---Automatic x incrementing

As described above there is no need to provide a series of x-values corresponding the the
y-value sequence, although it is an option if desired.  The correct values for x will 
be supplied by providing the minimum and maximum x values, quick-plot will automatically 
generate a correct sequence to match the supplied y-values.

The one case where this does not happen is when x represents a series of dates.  
When x is a date series, the only way to display the dates correctly (they are, however, 
properly handled internally to produce the plot element), is to explicitly provide them
using the x-data option.  There is a shortcut available, please see the 
'Special Rules for Dates' topic.

---Block values

Data for use by quick-plot must be in the form of a block.  If using REBOL code embedded in the 
quick-plot block, it is automatically composed (all code within parenthetical marks is 
evaluated).  The data remaining must be in the form of a block.  If using parentheses to
substitute for a word, the parenthesis must be enclosed in a surrounding set 
of brackets, eg. looks like this  [(word-holding-data)].



===Line

Line plots are the most basic plot element processed by quick-plot.  It is very
easy to generate a line element, simply use the keyword 'line followed by a
block of y values.  There is no need to explicitly provide corresponding
x values (see the Data Requirements topic for more details).

Here is a simple example using explicit data values.

    view quick-plot [
        250x250
        line [1 2 4 8 16 32 64 128]
    ]

Here is an example of generating the data with an embedded (and anonymous)
function.

    view quick-plot [
        300x300
        line [(data: copy [2]
                loop 10 [append data (2 * last data)])
        ]
    ]


===Bar Graph

Bar graphs are produce by using the keyword 'bars followed by a
data block.  Options for fill-pen to change the color of the 
interior of the bars, pen to change the color of the bar outline
and bar-width to change the width of the bars, must precede the
'bars keyword if they are desired.

!Note that unless a y-minimum is specified, the bottom of the bar plot
is the smallest y value (not zero).  Use "y-min 0" to specify that the
floor of the plot should be zero and not the minimum of the y-data.

A simple example (using all the defaults)

    view quick-plot [
        300x300
        bars [5 3 8 2 10 3 4 9 5 7]
    ]

Adding options, here is the example again.

    view quick-plot [
        300x300
        fill-pen blue
        pen red
        bar-width 15
        bars [5 3 8 2 10 3 4 9 5 7]
        label "Meaningless bars"
        y-axis 9
    ]

Here is the same data with a y-min of zero specified and fat overlapping
bars.

    view quick-plot [
        600x300
        y-min 0
        fill-pen blue
        pen red
        bar-width 80
        bars [5 3 8 2 10 3 4 9 5 7]
        label "Fat Meaningless bars"
        y-axis 11
        x-axis 10
    ]



===Stock (OHLC)

Stock charts can also be easily plotted using quick-plot.  A stock plot element
attempts to comprehensively show the price movement of an asset during a day's
trading by showing the opening, high, low and close prices.  This type of plot
is also know as an OHLC chart. A stock element contains a left tick to represent
the opening price of a stock, a vertical
bar representing the prices between the day's high and low and a right tick 
representing the closing price of the day.

!Note that all the examples in this section rely on %get-stock.r to fetch
real stock prices from www.yahoo.com.  Please ensure get-stock.r is in your
working directory before trying these examples.  If needed, get-stock.r can be
down loaded via the reb or the web from the www.rebol.com script library.

    do %get-stock.r
    
    fl: flash "Downloading IBM stock data"
    set [dt op hi lo cl vo] get-stock/data "IBM" (now/date - 50) now/date
    unview/only fl
    prices: reduce [op hi lo cl]

    view quick-plot [
        600x600
        title "IBM"
        x-data [(dt)]
        stock [(prices)]
        x-axis 5
        y-axis 7
        x-grid 5
        y-grid 7
    ]


To create a stock element, the keyword stock is used, followed by a block holding
four blocks containing the price data.  The four data blocks must be in the 
following order; open, low, high and close.  All four blocks should then be wrapped 
in a singe block before being used by quick-plot.

Anyone interested in technical or graphic analysis of a shock can use quick-plot to overlay
various studies on the stock data.  

The next example shows a simple moving average and an exponential
moving average (EMA) along with the OHLC data (Also see the Additional Examples section).


    do %get-stock.r

    either exists? %IBM.csv [
        set [dt op hi lo cl vo] get-stock/data/retrieve "IBM" (now/date - 250) now/date %IBM.csv
    ][
        fl: flash "Downloading IBM stock data"
        set [dt op hi lo cl vo] get-stock/data/store "IBM" (now/date - 250) now/date %IBM.csv 
        unview/only fl
    ]
    prices: reduce [op hi lo cl]

    ma: copy []
    ema: copy []
    hold-blk: copy []

    ma-length: 10  ;length of the moving average
    ma-str: rejoin ["Simple Moving Avg (" ma-length " day)"]
    ema-val: 2 / ( ma-length + 1) ; ema multiplier
       ; corresponding to a time constant of ma-length
    ema-carry: 1.0 - ema-val
    
    loop (ma-length - 1) [
        append ma none ; val: first cl
        append ema val: first cl ; val
        append hold-blk val
        cl: next cl ; cl going to ma-length + 1
    ]
    sum: func [bk [block!]][
        total: 0
        foreach val bk [
            total: total + val
        ]
        return total
    ]

    until [
        ; simple ma calculation
        append hold-blk today: first cl
        append ma ((sum hold-blk ) / ma-length)
        remove hold-blk
        
        ; ema calculations
        append ema (today * ema-val + (ema-carry * last ema))  

        ; advance one day
        tail? cl: next cl
    ]
    head cl

    view quick-plot [
        600x600
        title "IBM"
        x-data [(dt)]
        stock [(prices)]
        x-axis 5 border
        y-axis 7 border
        x-grid 5
        y-grid 7
        line [(ema)] color yellow
        label "EMA"
        line [(ma)] color green
        label (ma-str)
    ]


===Stock (Candlestick)


Candlestick charting is now included in the quick-plot dialect.  Candlestick charts
are created in the same way as OHLC stock charts, but the keyword 'candles is used to
produce the plot.


    do %get-stock.r
    ticker: "IBM"

    either exists? (t-file: to-file join ticker ".csv") [
        set [dt op hi lo cl vo] get-stock/data/retrieve ticker (now/date - 250) now/date t-file
    ][
        fl: flash join join "Downloading " ticker " stock data"
        set [dt op hi lo cl vo] get-stock/data/store ticker (now/date - 250) now/date t-file 
        unview/only fl
    ]
    prices: reduce [op hi lo cl]
    
    view quick-plot [
        600x600
        scale log
        title (ticker)
        x-data [(dt)]
        candles [(prices)]
        x-axis 5
        y-axis 7
        x-grid 5
        y-grid 7
    ]

Changing the color of the up and down candlesticks is easily done by following the 'candles keyword
with the 'up or 'down keyword followed by a color or tuple.  The order of keywords and data does not 
matter (e.g., "down pink  [(prices)]  up gold" would be an acceptable, but rather ugly input).    


    do %get-stock.r
    ticker: "MSFT"

    either exists? (t-file: to-file join ticker ".csv") [
        set [dt op hi lo cl vo] get-stock/data/retrieve ticker (now/date - 250) now/date t-file
    ][
        fl: flash join join "Downloading " ticker " stock data"
        set [dt op hi lo cl vo] get-stock/data/store ticker (now/date - 250) now/date t-file 
        unview/only fl
    ]
    prices: reduce [op hi lo cl]
    
    view quick-plot [
        600x600
        scale dynamic 50
        title (ticker) style vh1
        x-data [(dt)]
        candles [(prices)] up navy down brick
        ; candles down pink [(prices)] up gold ; order doesn't matter
        x-axis 5 border
        y-axis 7 border
        x-grid 5
        y-grid 7
    ]


Also note the use of dynamic scale selection, title style and border axis labels in the 
example above.


===Expanded Stock System Model

Here is a more developed stock charting and analysis example. This section
uses the %get-stock.r and %condense.r function scripts to develop a REBOL
implementation of Dr. Alexander Elder's "Triple Screen System."  The "Triple
Screen System" is described in Dr Elder's book "Trading for a Living."  Since the
system can be used for visually analyzing stock opportunities and is relatively
straight forward to implement it is presented here.

For this demonstration we will construct only the first two parts of the 
"Triple Screen" and avoid all the issues surrounding 
day-trading and use of intra-day prices.

First we need to create a Moving Average Convergence Divergence (MACD) indicator.
For this project we will use 12 and 26 day exponential moving averages, and a 9 day
EMA to make the slow signal line.
The time constant (K) for computing EMA is K = 2 / (N + 1) where N is the number of days.
The values we need are (N, K): (12, 0.153846), (26, 0.074074) and (9, 0.2).
Although we will (and should for more precision) use REBOL to compute these constants. 

The first model is the Weekly MACD Histogram.  We need to use the %condense.r package to
create weekly market data from the daily data downloaded by get-stock.

The Fast MACD line (f-macd)
is the 12 day EMA minus the 26 day EMA.  The signal line (signal) is the 9 day EMA of f-macd.
The MACD Histogram (macd-hist) is the difference between f-macd and the signal line.
When the histogram is positive it is supposed to indicate that 'bulls' dominate the market and
it is better to trade to the long side (buy).  We will use the sign of histogram slope to create
a gross buy/sell indicator.  On our chart the indicator will be shown as a greater than 0 (buy) 
or a less than 0 (sell) bar.  Here it is...

    do %get-stock.r
    do %condense.r

    ticker: copy "IBM"
    either exists? (stock-file: to-file join ticker ".csv") [
        daily-prices: get-stock/data/retrieve ticker (now/date - 250) now/date stock-file
    ][
        fl: flash join join "Downloading " ticker " stock data"
        daily-prices: get-stock/data/store ticker (now/date - 250) (now/date) stock-file
        unview/only fl
    ]
    set [dt op hi lo cl vo] aggregate-weeks daily-prices
    prices: reduce [op hi lo cl]

    ema12: copy []
    ema26: copy []
    f-macd: copy []
    signal: copy []
    macd-hist: copy []
    hist-slope: copy []

    ema9-length: 9  ;length of the moving average
    ema9-val: 2 / ( ema9-length + 1) ; ema multiplier (K)
    ema9-carry: 1.0 - ema9-val
    ema12-length: 12  
    ema12-val: 2 / ( ema12-length + 1) 
    ema12-carry: 1.0 - ema12-val
    ema26-length: 26  
    ema26-val: 2 / ( ema26-length + 1) 
    ema26-carry: 1.0 - ema26-val
    
    append ema12 first cl
    append ema26 first cl
    append f-macd 0.0
    append signal 0.0
    append macd-hist 0.0
    append hist-slope 0.0
    cl: next cl 
    
    until [
        today: first cl
        ; calculations
        append ema12 this-12: (today * ema12-val + (ema12-carry * last ema12))  
        append ema26 this-26: (today * ema26-val + (ema26-carry * last ema26))  
        append f-macd this-macd: (this-12 - this-26)
        append signal this-sig: (this-macd * ema9-val + (ema9-carry * last signal))  
        prior-hist: last macd-hist
        append macd-hist this-hist: (this-macd - this-sig)
        append hist-slope either ((this-hist - prior-hist) < 0) [ -1][1]

        ; advance one day
        tail? cl: next cl
    ]
    cl: head cl

    macd-plot: multi-plot/ratio 600x600 [
        [
            title (rejoin [ticker " Weekly data"]) style vh2
            scale dynamic 50
            stock [(prices)]
            ; x-axis 5
            y-axis 7 border
            x-grid 5
            y-grid 7
        ]
        [
            scale linear
            title "MACD Histogram" style h3
            x-data [(dt)]
            pen blue
            bars [(macd-hist)]
            rescale
            line [(f-macd)] color yellow
            label "Fast MACD"
            line [(signal)] color red
            label "Signal"
            pen black
            y-axis 2 border
            x-grid 5
            y-grid 2
        ]
        [
            scale linear
            title "Buy/Sell Signal" style h3
            x-data [(dt)]
            y-max 1.1
            y-min -1.1
            pen oldrab
            bars [(hist-slope)] fill leaf
            pen black
            text "BUY" up 85 over 30
            text "SELL" up 35
            y-axis 3 border
            x-grid 5
            y-grid 2
        ]
        [   pen coal
            fill-pen 110.110.110
            bars [(vo)]
            x-data [(dt)]
            rescale
            y-axis 3 border
            pen black
            text "Daily Volume" over 10 up 85 
            x-axis 5 border
            x-grid 5]
    ][4 2 1 2]
    
    view macd-plot


For the second part of the "Triple Screen" we use daily data to construct a "Force Index" showing
the market sentiment.  According to Dr. Elder the "Force Index" should be used as a contrarian
indicator for timing moves based on the weekly MACD signal.  The force index (f-index) is calculated
as today's  volume * (today's close - yesterday's close).  
We start out by calculating the weekly MACD as before and then computing the daily f-index.


    do %get-stock.r
    do %condense.r

    ticker: copy "IBM"
    either exists? (stock-file: to-file join ticker ".csv") [
        daily-prices: get-stock/data/retrieve ticker (now/date - 250) now/date stock-file
    ][
        fl: flash join join "Downloading " ticker " stock data"
        daily-prices: get-stock/data/store ticker (now/date - 250) (now/date) stock-file
        unview/only fl
    ]

    ;; weekly MACD calculations
    set [dt op hi lo cl vo] aggregate-weeks daily-prices
    weekly-dt: dt
    prices: reduce [op hi lo cl]
    ema12: copy []
    ema26: copy []
    f-macd: copy []
    signal: copy []
    macd-hist: copy []
    hist-slope: copy []

    ema2-length: 2  
    ema2-val: 2 / ( ema2-length + 1) 
    ema2-carry: 1.0 - ema2-val
    ema9-length: 9  
    ema9-val: 2 / ( ema9-length + 1) 
    ema9-carry: 1.0 - ema9-val
    ema12-length: 12  
    ema12-val: 2 / ( ema12-length + 1) 
    ema12-carry: 1.0 - ema12-val
    ema26-length: 26  
    ema26-val: 2 / ( ema26-length + 1) 
    ema26-carry: 1.0 - ema26-val
    
    append ema12 first cl
    append ema26 first cl
    append f-macd 0.0
    append signal 0.0
    append macd-hist 0.0
    append hist-slope 0.0
    cl: next cl 
    
    until [
        today: first cl
        ; calculations
        append ema12 this-12: (today * ema12-val + (ema12-carry * last ema12))  
        append ema26 this-26: (today * ema26-val + (ema26-carry * last ema26))  
        append f-macd this-macd: (this-12 - this-26)
        append signal this-sig: (this-macd * ema9-val + (ema9-carry * last signal))  
        prior-hist: last macd-hist
        append macd-hist this-hist: (this-macd - this-sig)
        append hist-slope either ((this-hist - prior-hist) < 0) [ -1][1]

        ; advance one day
        tail? cl: next cl
    ]
    cl: head cl

    ;; reset to daily prices
    set [dt op hi lo cl vo] daily-prices
    prices: reduce [op hi lo cl]

    f-index: copy []
    smooth-fi: copy []

    today first cl
    cl: next cl
    vo: next vo
    append f-index vo
    append smooth-fi 0.0

    until [
        yesterday: today
        today: first cl
        volume: first vo
        ; calculations
        append f-index this-f: (volume * (today - yesterday))
        append smooth-fi (this-f * ema2-val + (ema2-carry * last f-index))  

        ; advance one day
        vo: next vo
        tail? cl: next cl
    ]
    cl: head cl
    vo: head vo

    force-plot: multi-plot/ratio 600x600 [
        [
            title (rejoin [ticker " Daily Data"]) style vh2
            scale dynamic 50
            stock [(prices)]
            ; x-axis 5
            y-axis 7 border
            x-grid 5
            y-grid 7
        ]
        [
            scale linear
            title "Buy/Sell Signal" style h3
            x-data [(weekly-dt)]
            y-max 1.1
            y-min -1.1
            pen oldrab
            bars [(hist-slope)] fill leaf
            pen black
            text "BUY" up 85 over 30
            text "SELL" up 35
            y-axis 3 border
            x-grid 5
            y-grid 2
        ]
        [
            scale linear
            x-data [(dt)]
            pen violet
            bars [(smooth-fi)] fill crimson
            pen black
            text "SELL" up 85 over 30
            text "BUY" up 35
            text "Force Index Histogram" over 40 up 20
            y-axis 2 border
            x-grid 5
            y-grid 2
        ]   
        [   pen coal
            fill-pen 110.110.110
            bars [(vo)]
            x-data [(dt)]
            rescale
            y-axis 3 border
            pen black
            text "Daily Volume" over 10 up 85 
            x-axis 5 border
            x-grid 5]
    ][3 1 1 1]
    
    view force-plot



Some aspects of this model worth noting are the multiple time scales, volume information in 
an indicator, and contraian use of an indicator.  

Now that a simple starting model has been developed, feel free to incorporate your own
trading ideas into a REBOL stock system.  Please let me know if you find a system that 
makes consistent or significant profits (email me at m.s.licholai@ieee.org).  
Thank you and good luck.

Here are the above charts with a simple GUI to switch between them.  Since we only
have two parts to this model I call the "Double Screen."


    do %get-stock.r
    do %condense.r

    ticker: copy "IBM"
    either exists? (stock-file: to-file join ticker ".csv") [
        daily-prices: get-stock/data/retrieve ticker (now/date - 250) now/date stock-file
    ][
        fl: flash join join "Downloading " ticker " stock data"
        daily-prices: get-stock/data/store ticker (now/date - 250) (now/date) stock-file
        unview/only fl
    ]

    ;; weekly MACD calculations
    set [dt op hi lo cl vo] aggregate-weeks daily-prices
    weekly-dt: dt
    prices: reduce [op hi lo cl]
    ema12: copy []
    ema26: copy []
    f-macd: copy []
    signal: copy []
    macd-hist: copy []
    hist-slope: copy []

    ema2-length: 2  
    ema2-val: 2 / ( ema2-length + 1) 
    ema2-carry: 1.0 - ema2-val
    ema9-length: 9  
    ema9-val: 2 / ( ema9-length + 1) 
    ema9-carry: 1.0 - ema9-val
    ema12-length: 12  
    ema12-val: 2 / ( ema12-length + 1) 
    ema12-carry: 1.0 - ema12-val
    ema26-length: 26  
    ema26-val: 2 / ( ema26-length + 1) 
    ema26-carry: 1.0 - ema26-val
    
    append ema12 first cl
    append ema26 first cl
    append f-macd 0.0
    append signal 0.0
    append macd-hist 0.0
    append hist-slope 0.0
    cl: next cl 
    
    until [
        today: first cl
        ; calculations
        append ema12 this-12: (today * ema12-val + (ema12-carry * last ema12))  
        append ema26 this-26: (today * ema26-val + (ema26-carry * last ema26))  
        append f-macd this-macd: (this-12 - this-26)
        append signal this-sig: (this-macd * ema9-val + (ema9-carry * last signal))  
        prior-hist: last macd-hist
        append macd-hist this-hist: (this-macd - this-sig)
        append hist-slope either ((this-hist - prior-hist) < 0) [ -1][1]

        ; advance one day
        tail? cl: next cl
    ]
    cl: head cl

    macd-plot: multi-plot/ratio 500x500 [
        [
            title (rejoin [ticker " Weekly data"]) style vh2
            scale dynamic 50
            stock [(prices)]
            ; x-axis 5
            y-axis 7 border
            x-grid 5
            y-grid 7
        ]
        [
            scale linear
            title "MACD Histogram" style h3
            x-data [(dt)]
            pen blue
            bars [(macd-hist)]
            rescale
            line [(f-macd)] color yellow
            label "Fast MACD"
            line [(signal)] color red
            label "Signal"
            pen black
            y-axis 2 border
            x-grid 5
            y-grid 2
        ]
        [
            scale linear
            title "Buy/Sell Signal" style h3
            x-data [(dt)]
            y-max 1.1
            y-min -1.1
            pen oldrab
            bars [(hist-slope)] fill leaf
            pen black
            text "BUY" up 85 over 30
            text "SELL" up 35
            y-axis 3 border
            x-grid 5
            y-grid 2
        ]
        [   pen coal
            fill-pen 110.110.110
            bars [(vo)]
            x-data [(dt)]
            rescale
            y-axis 3 border
            pen black
            text "Daily Volume" over 10 up 85 
            x-axis 5 border
            x-grid 5]
    ][4 2 1 2]

    ;; reset to daily prices
    set [dt op hi lo cl vo] daily-prices
    prices: reduce [op hi lo cl]

    f-index: copy []
    smooth-fi: copy []

    today first cl
    cl: next cl
    vo: next vo
    append f-index vo
    append smooth-fi 0.0

    until [
        yesterday: today
        today: first cl
        volume: first vo
        ; calculations
        append f-index this-f: (volume * (today - yesterday))
        append smooth-fi (this-f * ema2-val + (ema2-carry * last f-index))  

        ; advance one day
        vo: next vo
        tail? cl: next cl
    ]
    cl: head cl
    vo: head vo

    force-plot: multi-plot/ratio 500x500 [
        [
            title (rejoin [ticker " Daily Data"]) style vh2
            scale dynamic 50
            stock [(prices)]
            ; x-axis 5
            y-axis 7 border
            x-grid 5
            y-grid 7
        ]
        [
            scale linear
            title "Buy/Sell Signal" style h3
            x-data [(weekly-dt)]
            y-max 1.1
            y-min -1.1
            pen oldrab
            bars [(hist-slope)] fill leaf
            pen black
            text "BUY" up 85 over 30
            text "SELL" up 35
            y-axis 3 border
            x-grid 5
            y-grid 2
        ]
        [
            scale linear
            x-data [(dt)]
            pen violet
            bars [(smooth-fi)] fill crimson
            pen black
            text "SELL" up 85 over 30
            text "BUY" up 35
            text "Force Index Histogram" over 40 up 20
            y-axis 2 border
            x-grid 5
            y-grid 2
        ]   
        [   pen coal
            fill-pen 110.110.110
            bars [(vo)]
            x-data [(dt)]
            rescale
            y-axis 3 border
            pen black
            text "Daily Volume" over 10 up 85 
            x-axis 5 border
            x-grid 5]
    ][3 1 1 1]
    window: layout [
        vh3 "Double Screen Model" h3 "Implemented in Rebol; The easy way!"
        guide 
        pad 20
        button "Weekly"   [graph/pane: macd-plot show graph]
        button "Daily"    [graph/pane: force-plot show graph]
        ; button "Cubic Curve" [graph/pane: plot3 show graph]
        return
        ; box 2x502 blue
        return
        graph: box 504x504 coal
    ]
    macd-plot/offset: 2x2
    force-plot/offset: 2x2
    ; plot3/offset: 2x2

    graph/pane: macd-plot
    view window
    





===Pie Charts

Simple pie charts can be constructed with the keyword 'pie.

    view quick-plot [
        400x400
        pie [2 3 4 2 5]
        title "A Pie Chart" style vh1
    ]

Colors will be given to each wedge in sequence ensuring that no adjacent wedges have the same color.
There can be an unlimited number of wedges, although the pie chart get less readable as the number
of slices increases.

    n: 24
    ones: copy []
    loop n [
        append ones 1
    ]
    view quick-plot [
        400x400
        pie [(ones)]
        title "A Crowded Pie Chart" style vh2
    ]

Adding labels is accomplished by using the keyword 'labels followed by a block with the data labels.

    view quick-plot [
        400x400
        pie [2 3 4 2 5] labels [First two 3 "4th" fifth]
        title "A Labeled Pie Chart" style vh2
    ]

Sections of the pie chart can be emphasized by 'exploding' them.  This is done
by adding the keyword 'explode followed by a block with the number of each section 
to be exploded.  This is shown in the following example.

    view quick-plot [
        400x400
        pie [2 3 4 2 5] labels [A B C D E] explode [3]
        title "An Exploded Section" style vh2
    ]

More than one section can be exploded in a pie chart.  Also notice that
the number of labels can be different then the number of sections (if it
makes sense).

    view quick-plot [
        400x400
        pie [2 3 4 2 5] explode [3 5] labels [A B C D] 
        title "An Exploded Pie Chart" style vh2
    ]

The relative size of the pie chart as a percentage of the plot can be set using the
'size keyword.  The default is 80% of the face.

    view quick-plot [
        400x400
        pie [2 3 4 2 5] size 45
        title "A Sized Pie Chart" style vh1
    ]

All of the options for a pie chart can be used in any combination or order.  Have
fun.

===Scatter Plot

Scatter plots are designed for plotting points that are not generated by a series.  In a
scatter plot the x and y values change independently, and therefore must both be specified.
Scatter plots are created using the 'scatter keyword, followed by a block holding the x,y 
data values.

The x and y data can be in the form of blocks, tuples, or pairs. Here is an example using 
blocks (the most REBOLish data structure).

    random/seed now/time
    vals: copy []
    
    loop 500 [
        append/only vals reduce [random 100  random 100]
    ]
    
    view quick-plot [
        450x450
        x-min 0
        x-max 101
        y-min 0
        y-max 101
        title "Randomness" style vh1
        scatter [(vals)]
    ]

Here is the same plot, but using tuples.  The plotting symbol is also changed to
a diamond for this example.

    random/seed now/time
    vals: copy []
    
    loop 500 [
        append vals to-tuple compose [(random 100) (random 100)]
    ]
    
    view quick-plot [
        450x450
        x-min 0
        x-max 101
        y-min 0
        y-max 101
        title "Randomness 2" style vh1
        scatter [(vals)] symbol diamond fill green
    ]

Options for scatter plots include the symbol, color, fill and symbol size.  They
are specified using the keywords 'symbol, 'color, 'fill, and 'size respectively.
Symbol recognized are: circle,  box, diamond, cross, X-mark (the default), and 
point.  The size is the size of the symbol in pixels.

Here are some examples

    random/seed now/time
    vals: copy []
    
    loop 100 [
        append vals to-pair compose [(random 100) (random 100)]
    ]
    
    view quick-plot [
        450x450
        x-min 0
        x-max 101
        y-min 0
        y-max 101
        title "Randomness 3" style vh1
        scatter [(vals)] symbol diamond fill red size 5
    ]

Note that the diamond does not draw a border, only the filled interior of the symbol.

Another

    random/seed now/time
    vals: copy []
    
    loop 500 [
        append/only vals reduce [random 100 random 100]
    ]
    
    view quick-plot [
        450x450
        x-min 0
        x-max 101
        y-min 0
        y-max 101
        title "Randomness 4" style vh1
        scatter [(vals)] symbol circle
    ]

Again

    random/seed now/time
    vals: copy []
    
    loop 500 [
        append/only vals reduce [random 100 random 100]
    ]
    
    view quick-plot [
        450x450
        x-min 0
        x-max 101
        y-min 0
        y-max 101
        title "Randomness 5" style vh1
        scatter color purple [(vals)] symbol cross 
    ]




===Plot Options

Various options can be added to the plot elements to enhance the usability and presentation
of the generated plots.  The following options are available.

plot scale (logarithmic or linear)

plot title

element label

x-axis labels

y-axis labels

x-dimension grid line

y-dimension grid line

text at an arbitrary location on the plot


Additional effects can be added to the plot elements themselves. Some effects are;

line color

fill color

line pattern

All are covered in more detail in the following sections.


===Scales

There are 3 options for selecting the scale of the plot.  They are linear, log (or log-linear) and log-log.

A linear scale plots the chart with both axis using conventional linear scales.  Linear scales are the default and will be
used if no scale is specified.


    view quick-plot [
        300x300
        scale linear ; this is the default
        line [(data: copy [2]
                loop 10 [append data (2 * last data)])
        ]
        title style vh1 "Linear scale"
        x-axis 7 border
        y-axis 7 border
        x-grid 7
        y-grid 7
    ]



A log or log-linear scale plot the chart with logarithmic y values and linear x values.

    view quick-plot [
        300x300
        scale log-linear ; this can be shortened to log
        line [(data: copy [2]
                loop 10 [append data (2 * last data)])
        ]
        title style vh1 "Log scale"
        x-axis 7 border
        y-axis 7 border
        x-grid 7
        y-grid 7
    ]

A log-log scale plots the chart with logarithmic x and y values.  The x axis plots in
true logarithmic manner, however the x-axis labels are only approximately correct.  If
anyone needs this fixed now, let me know and I will work on it.

    view quick-plot [
        300x300
        scale log-log ; both axis logarithmic
        line [(data: copy [2]
                loop 10 [append data (2 * last data)])
        ]
        title style vh1 "Log-log scale"
        x-axis 7 border
        y-axis 7 border
        x-grid 7
        y-grid 7
    ]

Finally the scales can be set to 'dynamic and quick-plot will determine when to use a logarithmic y-axis.
Dynamic mode will use a log y-axis when the range of y-data is large compared to the max y value. When
using dynamic scale mode the criteria for switching between log and linear scales can optionally be specified.

    view quick-plot [
        300x300
        scale dynamic ; this will use a linear scale 
        line [(data: copy [2]
                loop 10 [append data (2 * last data)])
        ]
        title style vh1 "Dynamic scale (linear)"
        x-axis 7 border
        y-axis 7 border
        x-grid 7
        y-grid 7
    ]


The switchover value if specified is a percentage of the max y value. When the range of y values exceeds the switchover
point then a log scale will be used if the y range is less than the percentage specified then a linear scale
is used.  The percentage tested against the specified value is:  (y-max - y-min) / y-max x 100.  The default is 100 pct.

    view quick-plot [
        300x300
        scale dynamic 50 ; this will use a log scale
        line [(data: copy [2]
                loop 10 [append data (2 * last data)])
        ]
        title style vh1 "Dynamic scale (log)"
        x-axis 7 border
        y-axis 7 border
        x-grid 7
        y-grid 7
    ]




===Title

To enter a title in a quick-plot pane simply use the keyword 'title followed by a string.
Note that quick-plot will do a fair approximation of horizontally centering the title within
the pane.
Here is a very simple example.

    view quick-plot [
        200x100
        title "Title Sample"
    ]

The style of the title can be changed by using the keyword 'style after the 'title keyword.
The 'style keyword can either precede or follow the title string.

    view quick-plot [
        300x100
        title style vh3 "Style Sample"
    ]

The order of inputs to 'title doesn't matter as shown in this example.


    view quick-plot [
        300x100
        title "Reverse Keywords" style code
    ]

The usable words for style are any of the predefined View styles. They include: 
h1, h2, h3, h4, h5, banner, vh1, vh2, vh3, txt, text, vtext, tt, and  code.

===Element Labels

Labels are attached to plot elements by following them with the keyword 'label and
a string to use as the label.  Note that unless changed, the label will appear in the
same color as the plot element it follows.

    data1: copy []
    data2: copy []
    for i 1 500 .5 [
        append data1 sine i
        append data2 cosine i
    ]
    view quick-plot [
        400x400
        pen red
        line [(data1)]
        label "Sine curve"
        pen green
        line [(data2)]
        label "Cosine curve"
     ]

Notice that the labels are plotted close to the element they follow.  The text for each
label is indented from the preceding label for legibility.  Quick-plot will display
25 labels moving across the pane (left to right) before the label text location 
resets to the left edge of the pane.


===Axis


Axis labels are added to any plot by 
using the keyword x-axis or y-axis followed by the 
number of labels to be drawn.  The x-axis and
y-axis do not need to be the same number.

Here is an example

    view quick-plot [
        300x200
        line [4 5 6 7 8 9 10]
        x-axis 7
        y-axis 4
    ]

Note that the last x-axis label is inset from the right edge so that the entire 
label can be displayed.

---Borders for Axis labels

Each axis can also be drawn in a border area around the plot by using the 'border keyword. 
The size of the plot elements will be reduced to accommodate the border into the given 
plot size.  The x and y axis are independently specified.  The following examples
include grids so the effect of the border is clear, the grids are not required when
using the axis 'border option.

X-axis example

    view quick-plot [
        300x200
        line [4 5 6 7 8 9 10]
        x-axis 7 border
        y-axis 4
        x-grid 7
        y-grid 4
    ]

Y-axis example


    view quick-plot [
        300x200
        line [4 5 6 7 8 9 10]
        x-axis 7
        y-axis 4 border
        x-grid 7
        y-grid 4
    ]



Both axis


    view quick-plot [
        300x200
        line [4 5 6 7 8 9 10]
        x-axis 7 border
        y-axis 4 border
        x-grid 7
        y-grid 4
    ]


The default is to have the axis labels drawn inside the plot.  This can be made 
explicit by using the 'inset keyword.


    view quick-plot [
        300x200
        line [4 5 6 7 8 9 10]
        x-axis 7 inset
        y-axis 4 inset
        x-grid 7
        y-grid 4
    ]



===Special Rules for Dates (X axis)

When the x-data is make up of date! entries, they can be passed in a block as
any other data series. Note that the values may appear to increment irregularly,
if the number of data entries is not evenly divisible by the number of axis marks
displayed (due to rounding errors).  Here is an example.

    date-data: copy []
    y-data: copy []
    for i 0 10 1 [
        insert y-data i
        insert date-data (now/date - i) 
    ]
    val: 6

    view quick-plot [
        600x300
        x-data [(date-data)]
        line [(y-data)]
        x-axis (val) border
        x-grid (val)
    ]

Alternatively, the x-data block can be condensed to a block containing only two
values, the minimum and maximum of the data series.

!Note: There may be slight differences is the values displayed for the axis
between these two methods if the number of axis values is not a factor of the
number of data points. This discrepancy is caused by rounding errors when
selecting which whole number date to display.

Here is an example of the shorthand method of specifying x values
(two item x-data block).

    date-data: reduce [now/date - 10  now/date]
    y-data: copy []
    for i 1 10 1 [
        insert y-data i
    ]
    val: 6

    view quick-plot [
        600x300
        x-data [(date-data)]
        line [(y-data)]
        x-axis (val) border
        x-grid (val)
    ]


===Grid Lines

Grid lines are added to any plot by 
using the keyword x-grid or y-grid followed by the 
number of grid lines to be drawn.  The x-grid and
y-grid do not need to be the same number.

Here is an example

    view quick-plot [
        200x200
        line [4 5 6 7 8 9 10]
        x-grid 5
        y-grid 4
    ]


===Text

To add text at an arbitrary location the keyword 'text are used in combination with keywords
'up and 'over.
Keywords 'up and 'over are followed by an integer specifying the amount to move the pen
before writing the text string.  The amounts are specified in percent, i.e., up 25 means
start the text 25% of the distance from the bottom of the plot and
over 50% means start the text 50% of the way across the plot. If not specified the text 
will be added at the current pen location (usually off the visible plot).


    view quick-plot[
        300x300
        title "Adding Text"
        pen green
        line [0 2 4 6 8 10 12 14 16 18 20 22]
        label "A Line"
        pen black
        y-axis 6
        y-grid 6
        x-axis 6
        x-grid 6
        pen yellow
        text "y = 2x + 0" up 75 over 15
        ]

Additionally the font for the text can be changed using the 'font keyword 
followed by a font object. The text color can also be changed in the same
way by using the keyword 'color followed by a color.

    data1: copy []
    for i 1 500 .5 [
        append data1 sine i
    ]
    option-font: make face/font [
        size: 13
        style: [italic bold]
        name: font-serif
    ]
    
    view quick-plot [
        300x300
        pen red
        title "Using Fonts"
        line [(data1)]
        label "Sine curve"
        text color green "Not an exciting plot" up 25 over 45
        text font option-font "But the colors are bold" color red up 20
     ]


Notice that the over keyword need not be specified if the value is not changed between uses.


===Element Effects

Element effects can be used to visually enhance the plots generated
by quick-plot.  The same options usable in the draw dialect are
usable in the quick-plot dialect.  Please see the draw dialect documentation
of details.
Some specific comments follow.

---Line Colors

Line colors are changed by using the 'pen keyword followed by
a color or tuple specifying the color.

---Line Pattern

Line patterns are changed by using the 'line-pattern keyword followed by integers
indicating how many pixels to draw and then skip.  

---Fill Color

When drawing bar charts, a fill color can be specified using the 'fill-pen keyword.
The default is no fill (transparent boxes).


===Multi-Plots

A multi-plot is an embedding of two or more plots in
a single pane.  

!A multi-plot is created by calling the
multi-plot function with the following parameters;

size  [pair!] representing the total size of the plot

plots [block!] a block of quick-plot data blocks 

!refinements that can be added include

/ratio [block!] a block of the relative size of the plots 
The default is for each sub-plot to be of equal size.

/down  assemble the component plots going down (default)

/across assemble the component plots going left to right



Note that when using a multi-plot if any of the quick-plot
data blocks contain an initial pair (as required by the 
quick-plot dialect) it is ignored and the sub-plot will be
generated in a appropriate size to meet the requirements of the
multi-plot.  Optionally, the initial pair can be left out of a
data bock and multi-plot will supply a correct value.  
This scheme was adopted to enable the simple reuse of
plot data blocks, the initial quick-plot pair is accepted and 
ignored, if it is included in the block.

Here is a basic example

    m-plots: multi-plot 400x400 [ 
        [ ; note that no initial pair is used 
            title "2 to a Power" 
            pen green 
            line [0 2 4 8 16 32 64 128] 
            pen white 
            y-axis 5 ; y-grid 5 x-axis 8 x-grid 8
        ]
        [200x400 ; this will be ignored by multi-plot 
            line [0 5 10 15 20 25] 
            title "A Line"
            y-axis 4 ; y-grid 4 x-grid 5
        ]
        [600x600 ; this will be ignored as well
            title "No Meaning"
            line [0 10 20 10 0] 
            y-axis 5; y-grid 5 ;x-axis 5 
            ; x-grid 5
        ] 
    ]
    
    view m-plots
    


A multi-plot example showing the use of the /ratio refinement.


    m-plots: multi-plot/ratio 600x600 [ 
        [200x400 ; ignored in multi-plot
            title "2 to a Power"
            pen green 
            line [0 2 4 8 16 32 64 128] 
            pen white 
            y-axis 5 y-grid 5 x-axis 8 x-grid 8]
        [line [0 5 10 15 20 25] 
            title "A Line"
            y-axis 4 y-grid 4 x-grid 5
        ]
        [600x600 ; ignored in multi-plot
            title "Still No Meaning"
            line [0 10 20 10 0] 
            y-axis 5 y-grid 5 
            x-grid 5
        ] 
    ][3 1 2] ; need not be integers
    
    view m-plots
    
Plots going across the page.


    m-plots: multi-plot/across 600x200 [ 
        [200x400 ; ignored in multi-plot
            title "2 to a Power"
            pen green 
            line [0 2 4 8 16 32 64 128] 
            pen white 
            y-axis 5 y-grid 5 x-axis 8 x-grid 8]
        [line [0 5 10 15 20 25] 
            title "A Line"
            y-axis 4 y-grid 4 x-grid 5
        ]
        [600x600 ; ignored in multi-plot
            title "Still No Meaning"
            line [0 10 20 10 0] 
            y-axis 5 y-grid 5 
            x-grid 5
        ] 
    ][3 1 2] ; this will be ignored since the
             ;  ratio refinement was not specified
    
    view m-plots
    


!Note, since multi-plot is a function, the order of arguments is significant.  
When using multi-plot you must provide a pair (size) a block of blocks (plot data)
and if using the /ratio refinement a block of relative sizes.


===Plots in a Sub-panel

When building applications and interactive programs with plots it may be
useful to place them in sub-panels within the GUI.  A plot returned by
quick-plot is a complete pane and can be easily incorporated into a
sub-panel.  

Here is a simple and fun example of 
switching plots dynamically.

    window: layout [
        vh2 "Switching plots"
        guide 
        pad 20
        button "Sine wave"   [graph/pane: plot1 show graph]
        button "Parabola"    [graph/pane: plot2 show graph]
        button "Cubic Curve" [graph/pane: plot3 show graph]
        return
        box 2x204 blue
        return
        graph: box 354x204 coal
    ]
    data1: copy []
    data2: copy []
    data3: copy []
    for i -400 400 .5 [
        append data1 sine i
        append data2 (i * i)
        append data3 (i ** 3)
    ]
    graph-size: 350x200
    plot1: quick-plot [
        (graph-size)
        line [(data1)]
        title "Sine Wave"
    ]
    plot2: quick-plot [
        (graph-size)
        line [(data2)]
        title "Parabola"
    ]
    plot3: quick-plot [
        (graph-size)
        line [(data3)]
        title "Cubic Function"
    ]
    plot1/offset: 2x2
    plot2/offset: 2x2
    plot3/offset: 2x2

    graph/pane: plot1
    view window


===Data Set Size Limits

Quick-plot is usable even with large data sets, its scalability is limited
only by the interpreted nature of REBOL.  On a reasonably fast computer 
creating panes with well over 10,000 points is not a problem. 

Here is an example of 50,000 points being calculated and plotted.

    view quick-plot [
        600x200
        title "A Big Example"
        line [( data: copy [] fl: flash "Calculating points" i: 0
                loop 50000 [
                    i: i + 1
                    append data sine (i / 40)
                ] unview/only fl data
            )]
        x-axis 5
    ]




===Additional Examples

Here are some additional examples you may want to try.

    plotter: quick-plot [
        200x200
        title "Example"
        line [( data: copy [] i: 0 
                loop 500 [
                    i: i + 1
                    append data sine (i * 4)
                ] 
            )]
        text "A fast sine" over 20 up 30 
      ]
    view plotter

Skipping some y values in the data.

    data: copy [] i: 0 
    loop 500 [
        i: i + 1
        either ((remainder i 5) = 0) [append data none]
        [append data sine (i)]
    ]
    plotter: quick-plot [
        200x200
        title "More Examples"
        line [(data)]
        text "Every 5th value skipped" over 30 up 30 
      ]
    view plotter


A stock chart with an exponential moving average and OHLC plot, displayed over 
a volume plot.


    do %get-stock.r

    ticker: copy "IBM"
    either exists? (stock-file: to-file join ticker ".csv") [
        set [dt op hi lo cl vo] get-stock/data/retrieve ticker (now/date - 250) now/date stock-file
    ][
        fl: flash join join "Downloading " ticker " stock data"
        set [dt op hi lo cl vo] get-stock/data/store ticker (now/date - 250) (now/date) stock-file
        unview/only fl
    ]
    prices: reduce [op hi lo cl]

    ema: copy []
    hold-blk: copy []

    ma-length: 10  ;length of the moving average
    ema-val: 2 / ( ma-length + 1) ; ema multiplier
       ; corresponding to a time constant of ma-length
    ema-carry: 1.0 - ema-val
    
    append ema first cl
    cl: next cl 
    
    until [
        today: first cl
        ; ema calculations
        append ema (today * ema-val + (ema-carry * last ema))  
        
        ; advance one day
        tail? cl: next cl
    ]
    cl: head cl

    total-plot: multi-plot/ratio 600x600 [
        [600x600
            scale dynamic 25
            title (ticker) style vh2
            x-data [(dt)]
            stock [(prices)]
            ; x-axis 5
            y-axis 7 border
            x-grid 5
            y-grid 7
            pen yellow
            line [(ema)]
            label "EMA"]
        [600x100
            pen coal
            fill-pen 110.110.110
            bars [(vo)]
            x-data [(dt)]
            rescale
            y-axis 3 border
            pen black
            text "Daily Volume" over 10 up 85 
            x-axis 5 border
            x-grid 5]
    ][4 1]
    
    view total-plot

This may be taking these toy examples a little too far, but
it provides an idea of what is easy to do using REBOL.  
(Perhaps useful as a prototype for another whiteboard?)


    ; lets add some user interaction/annotation
    m-plots: multi-plot/ratio 450x400 [ 
        [title "2 to a Power"
            pen green 
            line [0 2 4 8 16 32 64 128] 
            pen white 
            y-axis 5 y-grid 5 x-axis 8 x-grid 8]
        [200x400 
            line [0 5 10 15 20 25] 
            title "A Line"
            y-axis 4 y-grid 4 x-grid 5
        ]
        [600x600 
            title "Pointless"
            line [0 10 20 10 0] 
            y-axis 5 y-grid 5 ;x-axis 5 
            x-grid 5
        ] 
    ][3 1 2]
    top-pane: layout [
        h1 "Hand Annotations!!!"
        h3 "Write on the plots with the mouse while holding down mouse button-1" 
        image to-image m-plots with [
            ; this borrows from Allen Kamp's Simple Canvas
            effect: copy/deep [draw [pen red line]]
            line: second effect
            feel: make feel [
                engage: func [top-pane a e][
                    if find [down over] a [
                        append top-pane/line e/offset
                        show top-pane
                    ]
                    if a = 'up [
                        append top-pane/line 'line
                        ; posit: e/offset
                    ]
                ]
            ]
        ]
        across
        button "Save Image" [save/png request-file/only/filter 'png  to-image top-pane]
        button "View Saved" [
            view/new saved-pix: layout [
                do [ txt: ""
                      if (error? try [img: load request-file/only/filter 'png]) 
                         [txt: "Unable to load the Image file you requested." img: logo.gif]
                ]
                image img frame aqua
                h2 :txt
                button "close" [unview saved-pix]
            ]
        ]
    ]
    view top-pane 
    

} ; end of content

code: text: layo: xview: none
sections: []
layouts: []
space: charset " ^-"
chars: complement charset " ^-^/"

rules: [title some parts]

title: [text-line (title-line: text)]

parts: [
      newline
    | "===" section
    | "---" subsect
    | "!" note
    | example
    | paragraph
]

text-line: [copy text to newline newline]
indented:  [some space thru newline]
paragraph: [copy para some [chars thru newline] (emit txt para)]
note: [copy para some [chars thru newline] (emit-note para)]
example: [
    copy code some [indented | some newline indented]
    (emit-code code)
]
section: [
    text-line (
        append sections text
        append/only layouts layo: copy page-template
        emit h1 text
    ) newline
]
subsect: [text-line (emit h2 text)]

emit: func ['style data] [repend layo [style data]]

emit-code: func [code] [
    remove back tail code
    repend layo ['code 460x-1 trim/auto code 'show-example]
]

emit-note: func [code] [
    remove back tail code
    repend layo ['tnt 460x-1 code]
]

show-example: [
    if xview [xy: xview/offset  unview/only xview]
    xcode: load/all face/text
    if not block? xcode [xcode: reduce [xcode]] ;!!! fix load/all

    intro-blk: copy xcode
    ;; Here's the mess I added to allow arbitrary code before 'view
    either xcode: next find xcode 'view [
        ; if there is an explicit 'view in the block,
        ; then break it up and 'do the part of the block up to 'view
        reduce head clear find intro-blk 'view
        
        ; finally feed the part after 'view to the dialect 
        ; to make a face (quick-plot) and then drive 
        ; the properly offset 'view
        either 'quick-plot = first xcode [
            xview: view/new/offset quick-plot second xcode xy
        ][
            xview: view/new/offset do xcode xy
        ]
    ][
        if here: select xcode 'layout [xcode: here]
        xview: view/new/offset layout xcode xy
    ]
]

page-template: [
    size 500x480 origin 8x8
    backdrop white
    style code tt black silver bold as-is para [origin: margin: 12x8]
        font [colors: [0.0.0 0.80.0]]
    style tnt txt maroon bold
]

parse/all detab content rules

show-page: func [i /local blk last-face][
    i: max 1 min length? sections i
    append clear tl/picked pick sections i show tl
    if blk: pick layouts this-page: i [
        f-box/pane: layout/offset blk 0x0
        last-face: last f-box/pane/pane
        f-box/pane/pane/1/size: f-box/pane/size: max 500x480 add 20x20 add last-face/offset last-face/size
        update-slider
        show f-box
    ]
]

update-slider: does [
    either object? f-box/pane [
        sld/redrag min 1.0 divide sld/size/2 f-box/pane/size/2
        sld/action: func[face event] compose [
            f-box/pane/offset/2: multiply face/data (subtract 480 f-box/pane/size/2)
            show f-box
        ]
    ][
        sld/redrag 1.0 show sld
        sld/action: none
    ]
    sld/data: 0
    show sld
]

main: layout [
    backdrop effect [gradient 1x1 220.220.255 0.0.172]
    across
    h2 title-line return
    space 0
    tl: text-list 160x480 bold black white data sections [
        show-page index? find sections value
    ]
    h: at
    f-box: info 500x480
    at h + 500x0 sld: slider 16x480
    at h + 456x-24
    across space 4
    arrow left  keycode [up left] [show-page this-page - 1]
    arrow right keycode [down right] [show-page this-page + 1]
    pad -120
    txt form system/script/header/date/date
]
update-slider
show-page 1
xy: main/offset + 480x100
view main

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              