//+------------------------------------------------------------------+
//|                                                EA Supertrend.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
#include <FQInclude\Main.mqh>

// Input parameters
input int MagicNumber = 654;      // Magic Number
input double Lotti = 0.1;         // Lot Size
input double Stop = 30;           // Stop Loss (in pips)
input double Take = 60;           // Take Profit (in pips)
input int    ATR_Period = 10;     // ATR Period
input double ATR_Multiplier = 2;  // ATR Multiplier

// Global variables
int supertrend_handle;
double pips;
double supertrend_buffer[];
double color_buffer[];
CTrade trade;
CInfo info;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   pips = info.Pips();
   trade.SetExpertMagicNumber(MagicNumber);
   
   // Initialize the SuperTrend indicator
   supertrend_handle = iCustom(_Symbol, PERIOD_CURRENT, "Lavori\\SuperTrend Francesco", ATR_Period, ATR_Multiplier);
   if(supertrend_handle == INVALID_HANDLE)
   {
      Print("Failed to create SuperTrend indicator handle");
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release the SuperTrend indicator handle
   if(supertrend_handle != INVALID_HANDLE)
      IndicatorRelease(supertrend_handle);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bool buy = info.CiSonoPosizioni(MagicNumber, Symbol(), POSITION_TYPE_BUY);
   bool sell = info.CiSonoPosizioni(MagicNumber, Symbol(), POSITION_TYPE_SELL);
   
   if(info.NuovaCandela() && !buy && !sell)
   {
      invio_ordini();
   }
}

//+------------------------------------------------------------------+
//| Send orders function                                             |
//+------------------------------------------------------------------+
void invio_ordini()
{
   double entrata, stop, take;
   
   // Check for SuperTrend direction change
   if(supertrendChangedDirection())
   {
      // Check for buy signal
      if(supertrendColor(1) == 0) // 0 indicates uptrend (green)
      {
         entrata = info.Ask();
         stop = entrata - Stop * pips;
         take = entrata + Take * pips;
         Print("Cambio direzione supertrend BUY");
         trade.Buy(Lotti, Symbol(), entrata, stop, take, "Invio buy");
      }
      // Check for sell signal
      else if(supertrendColor(1) == 1) // 1 indicates downtrend (red)
      {
         entrata = info.Bid();
         stop = entrata + Stop * pips;
         take = entrata - Take * pips;
         Print("Cambio direzione supertrend SELL");
         trade.Sell(Lotti, Symbol(), entrata, stop, take, "Invio sell");
      }
   }
}

//+------------------------------------------------------------------+
//| Check if SuperTrend changed direction                            |
//+------------------------------------------------------------------+
bool supertrendChangedDirection()
{
   return supertrendColor(1) != supertrendColor(2);
}

//+------------------------------------------------------------------+
//| SuperTrend value function                                        |
//+------------------------------------------------------------------+
double supertrend(int shift)
{
   // Copy SuperTrend indicator values
   if(CopyBuffer(supertrend_handle, 0, shift, 1, supertrend_buffer) != 1)
   {
      Print("Failed to copy SuperTrend indicator values");
      return 0;
   }
   return NormalizeDouble(supertrend_buffer[0], _Digits);
}

//+------------------------------------------------------------------+
//| SuperTrend color function                                        |
//+------------------------------------------------------------------+
int supertrendColor(int shift)
{
   // Copy SuperTrend color buffer values
   if(CopyBuffer(supertrend_handle, 1, shift, 1, color_buffer) != 1)
   {
      Print("Failed to copy SuperTrend color values");
      return -1;
   }
   return (int)color_buffer[0];
}
//+------------------------------------------------------------------+