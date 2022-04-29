#property strict

// Window settings
#property indicator_separate_window
#property indicator_minimum -1000
#property indicator_maximum  3500

// Indicator settings
#property indicator_buffers 2
#property indicator_color1  clrGreen
#property indicator_color2  clrWhite
#property indicator_width1  2
#property indicator_width2  1
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_LINE

// Level line settings
#property indicator_level1        0
#property indicator_level2     1000
#property indicator_level3     2000
#property indicator_level4     3000
#property indicator_levelcolor clrGray
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

// Indicator buffers
double ExIndVol[];
double ExIndLine[];

input int VolumeAvePeriod = 10;

// Initialization function
void OnInit() {
    SetIndexBuffer(0, ExIndVol);
    SetIndexBuffer(1, ExIndLine);
}

// On-tick function
int OnCalculate(
    const int       rates_total,    // 入力された時系列のバー数
    const int       prev_calculated,// 計算済み(前回呼び出し時)のバー数
    const datetime& time[],         // 時間
    const double&   open[],         // 始値
    const double&   high[],         // 高値
    const double&   low[],          // 安値
    const double&   close[],        // 終値
    const long&     tick_volume[],  // Tick出来高
    const long&     volume[],       // Real出来高
    const int&      spread[]        // スプレッド
) {
    int icount = 0;
    int icounted;
    int vcount = 0;
    int vcounted;
    double ave_volume;

    icounted = rates_total - prev_calculated;
    if (icounted >= rates_total) icounted = rates_total - 1;

    for (icount = 0; icount <= icounted; icount++) {
        ExIndVol[icount] = (double)tick_volume[icount];
    }

    // Calculate a moving average of volumes
    for (icount = 0; icount <= icounted; icount++) {
        ave_volume = 0;
        vcounted = icount + VolumeAvePeriod;
        if (vcounted < icounted) {
            for (vcount = icount; vcount <= vcounted; vcount++){
                ave_volume += ExIndVol[vcount];
            }
            ave_volume = (int)(ave_volume / VolumeAvePeriod);
        }
        ExIndLine[icount] = ave_volume;
    }

    for( icount = 0; icount <= 20 ; icount++ ) {
        printf(
            "\"test_ind\"custom indicator (input param1 = %d)(%s,%d), volume[%d]=%g, averaged volume[%d]=%g",
            VolumeAvePeriod,
            Symbol(),
            Period(),
            icount,
            ExIndVol[icount],
            icount,
            ExIndLine[icount]
        );
    }

    return(rates_total);
}






