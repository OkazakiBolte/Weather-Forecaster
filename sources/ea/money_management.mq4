#include "money_management.mqh"

extern int g_MAGIC_NUMBER;

int CalculateCurrentOrders(){
    int buys = 0, sells = 0;
    /* ---- count up positions run by this EA ---- */
    for (int i=0; i<OrdersTotal(); i++){
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) break;
        if (OrderSymbol()==Symbol() && OrderMagicNumber()==g_MAGIC_NUMBER){
            if (OrderType()==OP_BUY)   buys++;
            if (OrderType()==OP_SELL) sells++;
        }
    }
    /* ---- return orders volume ---- */
    if (buys > 0) return(buys);
    else return (-sells);
}