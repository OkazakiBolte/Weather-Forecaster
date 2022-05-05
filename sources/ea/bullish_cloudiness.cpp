#property copyright "K. Okazaki"

#define MAGICMA 20220429

input int inp_fma_period = 9;
input int inp_fma_shift  = 0;
input int inp_sma_period = 20;
input int inp_sma_shift  = 0;

input double MaximumRisk    = 0.02;
input double DecreaseFactor = 3;

input int SKY_WINDOW    = 20;
input int CLOUDS_WINDOW = 5;

input double cloudiness_entry_level = 0.0;
input double cloudiness_exit_level  = -0.05;

/* ---- Calculate open positions ---- */
int CalculateCurrentOrders() {
    int buys = 0, sells = 0;
    /* ---- count up positions run by this EA ---- */
    for (int i = 0; i < OrdersTotal(); i++) {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) break;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA) {
            if (OrderType() == OP_BUY) buys++;
            if (OrderType() == OP_SELL) sells++;
        }
    }
    /* ---- return orders volume ---- */
    if (buys > 0)
        return (buys);
    else
        return (-sells);
}

/* ---- Calculate optimal lot size ---- */
double LotsOptimized() {
    /* double lot = Lots; */
    int orders = OrdersHistoryTotal();
    int losses = 0;

    double lot = NormalizeDouble(
        AccountFreeMargin() * MaximumRisk /
            100000.0,  // 1 lot = 100,000 currency in XMTrading
        1              // round off to one decimal place. e.g. 3.1415 --> 3.1
    );

    /* ---- Adjust lot size according to the number of consecutive losing trades
     * ---- */
    if (DecreaseFactor > 0) {
        /* ---- count up consecutive losing trades ---- */
        for (int i = orders - 1; i >= 0; i--) {  // scan from new order to old
            if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
                Print("Error in history!");
                break;
            }
            if (OrderSymbol()!=Symbol() || OrderType()>OP_SELL/* (The order type is either limit or stop order) */){
                continue;
            }
            if (OrderProfit() > 0) { break; }
            if (OrderProfit() < 0) { losses++; }
        }
        /* ---- adjust lot size ---- */
        if (losses >
            1) {  // if there are consecutive losing trades, decrease lot size
            lot = NormalizeDouble(lot - lot * losses / DecreaseFactor, 1);
        }
    }

    if (lot < 0.01) lot = 0.01;
    return (lot);
}

double fma = iMA(NULL,  // Symbol. if NULL, it means the current symbol.
                 PERIOD_CURRENT,  // Timeframe (e.g. M30, H1, D1, ... and so
                                  // on). Google ENUM_TIMEFRAMES for more info.
                 inp_fma_period,  // Moving period
                 inp_fma_shift,   // Moving shift
                 MODE_SMA,        // Type of moving average
                 PRICE_CLOSE,     // Applied price
                 0  // Shift of bars. If 0, it means the MA is calculated based
                    // on the current bar.
);
double sma = iMA(NULL,  // Symbol. if NULL, it means the current symbol.
                 PERIOD_CURRENT,  // Timeframe (e.g. M30, H1, D1, ... and so
                                  // on). Google ENUM_TIMEFRAMES for more info.
                 inp_sma_period,  // Moving period
                 inp_sma_shift,   // Moving shift
                 MODE_SMA,        // Type of moving average
                 PRICE_CLOSE,     // Applied price
                 0  // Shift of bars. If 0, it means the MA is calculated based
                    // on the current bar.
);

string cus_symbol =
    NULL;  // NULL means the current symbol displayed on the main window.
int    cus_period  = PERIOD_CURRENT;
string cus_indname = "Cloudiness";  // The name of the custom indicator
int    shift_index = 0;
double cloudiness =
    iCustom(cus_symbol, cus_period, cus_indname, SKY_WINDOW, CLOUDS_WINDOW,
            0,           // The index of indicator buffer
            shift_index  // 何本前のローソク足を使用するか
    );

/* ---- Check for open order conditions and execute entry ---- */
void CheckForOpen() {
    // Go trading only for the first tick of new bar
    if (Volume[0] > 1) return;

    bool FMA_is_larger_than_SMA = (fma > sma);
    bool getting_sunny          = (cloudiness > cloudiness_entry_level);

    // Buy
    if (FMA_is_larger_than_SMA /* && getting_sunny*/) {
        OrderSend(Symbol(),         // symbol
                  OP_BUY,           // operation
                  LotsOptimized(),  // volume
                  Ask,              // price
                  3,                // slippage
                  0,                // stop loss
                  0,                // take profit
                  "",               // comment
                  MAGICMA,          // magic number
                  0,                // pending order expiration
                  Blue              // color
        );
        return;
    }
}

bool CheckForClose() {
    bool ret = false;
    // Go trading only for the first tick of new bar
    if (Volume[0] > 1) return ret;

    bool getting_rainy = (cloudiness < cloudiness_exit_level);
    for (int i = 0; i < OrdersTotal();
         i++) {  // Scan for trading orders from old to new
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) break;
        if ((OrderMagicNumber() != MAGICMA) || (OrderSymbol() != Symbol()))
            continue;
        if (OrderType() == OP_BUY) {
            if (getting_rainy) {
                ret = OrderClose(OrderTicket(),  // ticket
                                 OrderLots(),    // volume
                                 Bid,            // close price
                                 3,              // slippage
                                 White           // color
                );
                if (!ret) {
                    Print("OrderClose error: ", GetLastError());
                    break;
                }
            }
        }
    }

    return (ret);
}

/* ---- OnTick function ---- */
void OnTick() {
    if (Bars < 100 || !IsTradeAllowed()) {  // Bars = number of total bars
                                            // displayed in chart window.
        Print("Number of displayed bars is smaller that 100, or automatic "
              "trade is not allowed.");
        return;
    }
    int  crnt_orders = CalculateCurrentOrders();
    bool ret;
    if (crnt_orders == 0) {
        CheckForOpen();
    } else {  // close and then recreate position
        ret = CheckForClose();
        if (ret) { CheckForOpen(); }
    }
}