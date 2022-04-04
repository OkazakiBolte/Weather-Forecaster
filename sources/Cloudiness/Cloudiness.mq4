#property link "https://github.com/OkazakiBolte/Weather-Forecaster/tree/main/sources/cloudiness"
#property description "Cloudiness"
#property copyright "K. Okazaki"
#property version "0.0"
#property strict

#property indicator_separate_window // Show this custom indicator in a sub window
#property indicator_buffers 3 // The number of indicators we're going to create, I guess
#property indicator_color1 DodgerBlue // The colour of the first indicator
#property indicator_color2 clrAqua
#property indicator_color3 clrWhite

// input int window_width = 5;

input int sky_window = 10;
input int clouds_window = 3;
double cloudiness[];
double sky[];
double clouds[];

/* ---- Initialization function ---- */
int OnInit() {
    // Indicator line
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);
    SetIndexStyle(2, DRAW_LINE);
    SetIndexBuffer(0, cloudiness);
    SetIndexBuffer(1, sky);
    SetIndexBuffer(2, clouds);
    // Set the indicator name and show it on the window
    string short_name = "Cloudiness(" + IntegerToString(sky_window) + "," + IntegerToString(clouds_window) + ")";
    IndicatorShortName(short_name);
    SetIndexLabel(0, short_name);
    SetIndexLabel(1, "Sky(" + IntegerToString(sky_window) + ")");
    SetIndexLabel(2, "Clouds(" + IntegerToString(clouds_window) + ")");
    // Check for the input
    if (sky_window <= 0) {
        Print("Invalid input parameter: sky_window = ", sky_window);
        return(INIT_FAILED);
    }
    if (clouds_window <= 0) {
        Print("Invalid input parameter: clouds_window = ", clouds_window);
        return(INIT_FAILED);
    }
    if (clouds_window > sky_window) {
        Print("sky_window must be larger than clouds_window.");
        return(INIT_FAILED);
    }
    SetIndexDrawBegin(0, sky_window);
    SetIndexDrawBegin(1, sky_window);
    SetIndexDrawBegin(2, clouds_window);
    // Done
    return(INIT_SUCCEEDED);
}

/* ---- The main process ---- */
int OnCalculate(
    // See the blog written in Japanese below for what each variable means.
    // https://mt4program.blogspot.com/2016/01/mql013-oncalculate.html
    const int      rates_total,
    const int      prev_calculated,
    const datetime &time[],
    const double   &open[],
    const double   &high[],
    const double   &low[],
    const double   &close[],
    const long     &tick_volume[],
    const long     &volume[],
    const int      &spread[]
) {
    // Check the number of bars and if it's less than the period, do nothing
    if (rates_total <= sky_window) return (0);

    // Use 'cloudiness', 'open', and 'close' as time series arrays.
    ArraySetAsSeries(cloudiness, false);
    ArraySetAsSeries(sky, false);
    ArraySetAsSeries(clouds, false);
    ArraySetAsSeries(open, false);
    ArraySetAsSeries(close, false);

    // Initialize my custom indicators
    int i, limit;
    if (prev_calculated <= 0) {
        for (i = 0; i < sky_window; i++) {
            cloudiness[i] = 0.0;
            sky[i] = 0.0;
            clouds[i] = 0.0;
        };
        limit = sky_window;
    } else {
        limit = prev_calculated - 1;
    }

    // The main loop of calculations
    for (i = limit; i < rates_total; i++) {
        sky[i]        = close[i-1] - open[i-sky_window];
        clouds[i]     = close[i] - open[i-clouds_window];
        cloudiness[i] = clouds[i] / sky[i];
        // cloudiness[i] = sky[i] - clouds[i];
    }

    // Done
    return(rates_total);
}