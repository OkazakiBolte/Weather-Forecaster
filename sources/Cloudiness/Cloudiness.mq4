#property link "https://github.com/OkazakiBolte/Weather-Forecaster/tree/main/sources/cloudiness"
#property description "Cloudiness"
#property copyright "K. Okazaki"
#property version "1.0"
#property strict

#property indicator_separate_window  // Show this custom indicator in a sub
                                     // window
#property indicator_buffers 3        // The number of custome indicators
#property indicator_color1 clrLime
#property indicator_color2 clrAqua
#property indicator_color3 clrWhite

input int    SKY_WINDOW    = 20;
input int    CLOUDS_WINDOW = 5;
input double alpha         = 0.5;
double       cloudiness[];
double       sky[];
double       clouds[];

/* ---- Initialization function ---- */
int OnInit() {
    // Indicator line
    SetIndexBuffer(0, cloudiness);
    SetIndexBuffer(1, sky);
    SetIndexBuffer(2, clouds);
    // Indicator style
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);
    SetIndexStyle(2, DRAW_LINE, STYLE_DOT);

    // Set the indicator name and show it on the window
    string short_name = "Cloudiness(" + IntegerToString(SKY_WINDOW) + "," +
                        IntegerToString(CLOUDS_WINDOW) + ")";
    IndicatorShortName(short_name);
    SetIndexLabel(0, short_name);
    SetIndexLabel(1, "Sky(" + IntegerToString(SKY_WINDOW) + ")");
    SetIndexLabel(2, "Clouds(" + IntegerToString(CLOUDS_WINDOW) + ")");

    // Check for the input
    if (SKY_WINDOW <= 0) {
        Print("Invalid input parameter: SKY_WINDOW = ", SKY_WINDOW);
        return (INIT_FAILED);
    }
    if (CLOUDS_WINDOW <= 0) {
        Print("Invalid input parameter: CLOUDS_WINDOW = ", CLOUDS_WINDOW);
        return (INIT_FAILED);
    }
    if (CLOUDS_WINDOW > SKY_WINDOW) {
        Print("SKY_WINDOW must be larger than CLOUDS_WINDOW.");
        return (INIT_FAILED);
    }
    SetIndexDrawBegin(0, SKY_WINDOW);
    SetIndexDrawBegin(1, SKY_WINDOW);
    SetIndexDrawBegin(2, CLOUDS_WINDOW);

    // Done
    return (INIT_SUCCEEDED);
}

/* ---- The main process ---- */
int OnCalculate(
    // See the blog written in Japanese below for what each variable means.
    // https://mt4program.blogspot.com/2016/01/mql013-oncalculate.html
    const int rates_total, const int prev_calculated, const datetime &time[],
    const double &open[], const double &high[], const double &low[],
    const double &close[], const long &tick_volume[], const long &volume[],
    const int &spread[]) {
    // Check the number of bars and if it's less than the period, do nothing
    if (rates_total <= SKY_WINDOW) return (0);

    // Use tsome properties as time series arrays.
    ArraySetAsSeries(cloudiness, true);
    ArraySetAsSeries(sky, true);
    ArraySetAsSeries(clouds, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(close, true);

    // I want to draw the past part and update the indicator values on every
    // tick
    int limit;
    if (prev_calculated <= 0)
        limit = rates_total - 1;
    else
        limit = rates_total - prev_calculated;

    /* ---- The main part of calculations ---- */
    // You may be able to understand what these for-loop by reading this README;
    // https://github.com/OkazakiBolte/mt4-practice#indicator%E3%82%92%E4%BD%9C%E3%82%8A%E3%81%9F%E3%81%84
    int i, j;
    for (i = limit; i >= 0; i--) {
        sky[i]        = 0.0;
        clouds[i]     = 0.0;
        cloudiness[i] = 0.0;
        if (rates_total - 1 >= SKY_WINDOW + i - 1) {
            for (j = 0; j < SKY_WINDOW; j++) {
                sky[i] += (close[i + j] - open[i + j]) / SKY_WINDOW;
            }
        }
        if (rates_total - 1 >= CLOUDS_WINDOW + i - 1) {
            for (j = 0; j < CLOUDS_WINDOW; j++) {
                clouds[i] += (close[i + j] - open[i + j]) / CLOUDS_WINDOW;
            }
        }
        cloudiness[i] = clouds[i] / (sky[i] + alpha);
    }

    // OnCalculate functions should always return the number of bars
    return (rates_total);
}