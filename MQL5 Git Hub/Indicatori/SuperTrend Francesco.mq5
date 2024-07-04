//+------------------------------------------------------------------+
//|                                               SuperTrend.mq5     |
//|                        Copyright 2024, Your Name                 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Francesco"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen, clrRed
#property indicator_width1  2

// Input parameters
input int    ATR_Period = 10;     // ATR Period
input double ATR_Multiplier = 2;  // ATR Multiplier (reduced from 3 to 2)

// Indicator buffers
double SuperTrendBuffer[];
double ColorBuffer[];
double UpperBandBuffer[];
double LowerBandBuffer[];

// Global variables
int atr_handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Indicator buffers mapping
   SetIndexBuffer(0, SuperTrendBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, UpperBandBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, LowerBandBuffer, INDICATOR_CALCULATIONS);
   
   // Set indicator label
   PlotIndexSetString(0, PLOT_LABEL, "SuperTrend");
   
   // Initialize ATR handle
   atr_handle = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit;
   if(prev_calculated == 0)
      limit = 1;
   else
      limit = prev_calculated - 1;
   
   // Check for possible errors
   if(BarsCalculated(atr_handle) < rates_total) return(0);
   
   // Copy ATR values
   double atr_values[];
   if(CopyBuffer(atr_handle, 0, 0, rates_total, atr_values) != rates_total) return(0);
   
   // Main loop
   for(int i = limit; i < rates_total; i++)
   {
      double atr = atr_values[i] * ATR_Multiplier;
      double hl2 = (high[i] + low[i]) / 2;
      
      if(i > 0)
      {
         UpperBandBuffer[i] = hl2 + atr;
         LowerBandBuffer[i] = hl2 - atr;
         
         // Trend logic
         bool isUpTrend = close[i-1] > SuperTrendBuffer[i-1];
         
         if(isUpTrend)
         {
            SuperTrendBuffer[i] = MathMax(LowerBandBuffer[i], SuperTrendBuffer[i-1]);
            ColorBuffer[i] = 0; // Green for uptrend
         }
         else
         {
            SuperTrendBuffer[i] = MathMin(UpperBandBuffer[i], SuperTrendBuffer[i-1]);
            ColorBuffer[i] = 1; // Red for downtrend
         }
         
         // Trend change check
         if(isUpTrend && close[i] < SuperTrendBuffer[i])
         {
            SuperTrendBuffer[i] = UpperBandBuffer[i];
            ColorBuffer[i] = 1; // Change to red
         }
         else if(!isUpTrend && close[i] > SuperTrendBuffer[i])
         {
            SuperTrendBuffer[i] = LowerBandBuffer[i];
            ColorBuffer[i] = 0; // Change to green
         }
      }
      else
      {
         SuperTrendBuffer[i] = hl2;
         ColorBuffer[i] = 0;
         UpperBandBuffer[i] = high[i];
         LowerBandBuffer[i] = low[i];
      }
   }
   
   return(rates_total);
}