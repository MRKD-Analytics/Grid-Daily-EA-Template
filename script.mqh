


/*
   This file contains a script for a daily grid trading strategy. 
   
   Places a BUY limit at previous day's low and a SELL limit at previous 
   day's high. 
   
   DISCLAIMER: This script does not guarantee future profits, and is 
   created for demonstration purposes only. Do not use this script 
   with live funds. 
*/

/*
#include <B63/Generic.mqh> 
#include "trade_ops.mqh"
*/ 
#include <utilities/Utilities.mqh> 
#include <utilities/TradeOps.mqh> 

enum TradeSignal { Long, Short, None }; 

input int      InpMagic       = 111111; // Magic Number
input int      InpEmaOne      = 9; 
input int      InpEmaTwo      = 21; 
input int      InpEmaThree    = 55; 

class CGridDaily : public CTradeOps {
private: 

public:
   CGridDaily();
   ~CGridDaily() {} 
   
            void Stage(); 
            void PlaceOrders(); 
}; 

CGridDaily::CGridDaily() 
   : CTradeOps(Symbol(), InpMagic) {} 
   
void        CGridDaily::Stage() { 
   /*
   Place Orders at previous day high and low 
   
   Take Profit 1 at Midpoint, and set BE 
   
   Take Profit 2 at Opposite. 
   
   Close all by EOD 
   */ 
   
   // Close all open and delete all pending  
   OP_OrdersCloseAll(); 
   
   // place orders 
   PlaceOrders(); 
} 

void        CGridDaily::PlaceOrders() {
   double previous_day_high   = UTIL_PREVIOUS_DAY_HIGH(); 
   double previous_day_low    = UTIL_PREVIOUS_DAY_LOW(); 
   double midpoint            = (previous_day_high + previous_day_low) / 2; 
   double trade_diff          = (previous_day_high - previous_day_low);  
   
   // base lot: 0.01 per 1000 USD balance
   double base_balance        = 1000.0; 
   int      layers            = 3;
   double lots                = (UTIL_ACCOUNT_BALANCE() / base_balance * 0.01) / layers; 
   
   // send buy limit 
   OP_OrderOpen(Symbol(), ORDER_TYPE_BUY_LIMIT, lots, previous_day_low, previous_day_low - trade_diff, midpoint, NULL); 
   OP_OrderOpen(Symbol(), ORDER_TYPE_BUY_LIMIT, lots, previous_day_low, previous_day_low - trade_diff, previous_day_high, NULL);
   OP_OrderOpen(Symbol(), ORDER_TYPE_BUY_LIMIT, lots, previous_day_low - (trade_diff / 2), (previous_day_low - trade_diff), midpoint, NULL); 
   // send sell limit 
   OP_OrderOpen(Symbol(), ORDER_TYPE_SELL_LIMIT, lots, previous_day_high, previous_day_high + trade_diff, midpoint, NULL); 
   OP_OrderOpen(Symbol(), ORDER_TYPE_SELL_LIMIT, lots, previous_day_high, previous_day_high + trade_diff, previous_day_low, NULL);  
   OP_OrderOpen(Symbol(), ORDER_TYPE_SELL_LIMIT, lots, previous_day_high + (trade_diff / 2), previous_day_high + trade_diff, midpoint, NULL);
   
   
}



CGridDaily  grid_daily; 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if (UTIL_IS_NEW_CANDLE()) { 
      grid_daily.Stage(); 
   }
   
  }
//+------------------------------------------------------------------+
