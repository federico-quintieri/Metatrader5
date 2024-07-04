//+------------------------------------------------------------------+
//|                                     CurrencyStrengthIndicator.mq5 |
//|                        Copyright 2024, Your Name                  |
//|                                             https://www.mql5.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   8

#include <FQInclude\Segnali\SegnaliMain.mqh>

// Enums
enum ENUM_TIMEFRAME_CUSTOM
  {
   LAST_WEEK = 0,   // Last Week
   LAST_MONTH = 1,  // Last Month
   CUSTOM = 2       // Custom Date Range
  };

// Input parameters
input ENUM_TIMEFRAME_CUSTOM InpTimeframe = LAST_MONTH;  // Timeframe
input datetime InpCustomStartDate = D'2024.01.01';      // Custom Start Date
input datetime InpCustomEndDate = D'2024.12.31';        // Custom End Date
input bool InpIncludeHigh = true;                       // Include High Impact Events
input bool InpIncludeMedium = true;                     // Include Medium Impact Events
input bool InpIncludeLow = false;                       // Include Low Impact Events

// Buffers for currency strength
double BufferUSD[], BufferEUR[], BufferGBP[], BufferJPY[];
double BufferAUD[], BufferCAD[], BufferCHF[], BufferNZD[];

// Currency names
string CurrencyNames[] = {"USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "NZD"};

// Struct for economic event data
struct EconomicEvent
  {
   datetime          time;
   string            currency;
   string            event;
   ENUM_CALENDAR_EVENT_IMPORTANCE importance;
   double            actual;
   double            forecast;
  };

// Array to store economic events
EconomicEvent EconomicEvents[];

// Variables to store the date range
datetime startDate, endDate;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Initialize buffers
   SetIndexBuffer(0, BufferUSD, INDICATOR_DATA);
   SetIndexBuffer(1, BufferEUR, INDICATOR_DATA);
   SetIndexBuffer(2, BufferGBP, INDICATOR_DATA);
   SetIndexBuffer(3, BufferJPY, INDICATOR_DATA);
   SetIndexBuffer(4, BufferAUD, INDICATOR_DATA);
   SetIndexBuffer(5, BufferCAD, INDICATOR_DATA);
   SetIndexBuffer(6, BufferCHF, INDICATOR_DATA);
   SetIndexBuffer(7, BufferNZD, INDICATOR_DATA);

// Set indicator labels
   for(int i = 0; i < ArraySize(CurrencyNames); i++)
     {
      PlotIndexSetString(i, PLOT_LABEL, CurrencyNames[i] + " Strength");
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
     }

// Set indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Currency Strength Indicator");

// Load economic event data
   if(!LoadEconomicEventData())
     {
      Print("Failed to load economic event data");
      return INIT_FAILED;
     }

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
   int start = prev_calculated == 0 ? 0 : prev_calculated - 1;

// Ensure we don't calculate beyond our loaded data range
   int firstValidBar = rates_total - 1;
   for(int i = rates_total - 1; i >= 0; i--)
     {
      if(time[i] >= startDate)
        {
         firstValidBar = i;
         break;
        }
     }

   start = MathMax(start, firstValidBar);

   for(int i = start; i < rates_total; i++)
     {
      if(time[i] >= startDate && time[i] <= endDate)
        {
         CalculateCurrencyStrength(time[i], i);
        }
      /*
      else
        {
         // Set buffer values to 0 for bars outside our date range
         for(int j = 0; j < 8; j++)
           {
            PlotIndexSetDouble(j, i, 0);
           }
        }
      */
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Load economic event data from API                                |
//+------------------------------------------------------------------+
bool LoadEconomicEventData()
  {
// Determine the date range based on the selected timeframe
   switch(InpTimeframe)
     {
      case LAST_WEEK:
         startDate = TimeCurrent() - 7 * 24 * 60 * 60;
         endDate = TimeCurrent();
         break;
      case LAST_MONTH:
         startDate = TimeCurrent() - 30 * 24 * 60 * 60;
         endDate = TimeCurrent();
         break;
      case CUSTOM:
         startDate = InpCustomStartDate;
         endDate = InpCustomEndDate;
         break;
      default:
         startDate = TimeCurrent() - 30 * 24 * 60 * 60;
         endDate = TimeCurrent();
     }

// Array to store MqlCalendarValue objects
   MqlCalendarValue values[];

// Retrieve calendar values
   int valuesTotal = CalendarValueHistory(values, startDate, endDate);

   if(valuesTotal == 0)
     {
      Print("No economic events found in the specified date range");
      return false;
     }

// Resize EconomicEvents array
   ArrayResize(EconomicEvents, valuesTotal);

// Populate EconomicEvents array
   for(int i = 0; i < valuesTotal; i++)
     {
      EconomicEvent event;

      // Get event details
      MqlCalendarEvent calendarEvent;
      if(!CalendarEventById(values[i].event_id, calendarEvent))
        {
         Print("Failed to retrieve event details for ID: ", values[i].event_id);
         continue;
        }

      // Get country details
      MqlCalendarCountry country;
      if(!CalendarCountryById(calendarEvent.country_id, country))
        {
         Print("Failed to retrieve country details for ID: ", calendarEvent.country_id);
         continue;
        }

      // Populate EconomicEvent struct
      event.time = values[i].time;
      event.currency = country.currency;
      event.event = calendarEvent.name;
      event.importance = calendarEvent.importance;
      event.actual = (double)values[i].actual_value / MathPow(10, calendarEvent.digits);
      event.forecast = (double)values[i].forecast_value / MathPow(10, calendarEvent.digits);

      // Store event in array
      EconomicEvents[i] = event;
     }

   Print("Loaded ", ArraySize(EconomicEvents), " economic events");
   return true;
  }

//+------------------------------------------------------------------+
//| Calculate currency strength based on economic events             |
//+------------------------------------------------------------------+
void CalculateCurrencyStrength(datetime currentTime, int index)
  {
   double strength[8] = {0}; // Strength for each currency

   for(int i = 0; i < ArraySize(EconomicEvents); i++)
     {
      if(EconomicEvents[i].time <= currentTime && IsEventIncluded(EconomicEvents[i].importance))
        {
         int currencyIndex = GetCurrencyIndex(EconomicEvents[i].currency);
         if(currencyIndex != -1)
           {
            strength[currencyIndex] += CalculateEventImpact(EconomicEvents[i]);
           }
        }
     }

// Normalize strength values
   double maxStrength = 0;
   for(int i = 0; i < 8; i++)
     {
      if(MathAbs(strength[i]) > maxStrength)
         maxStrength = MathAbs(strength[i]);
     }

   if(maxStrength > 0)
     {
      for(int i = 0; i < 8; i++)
        {
         strength[i] /= maxStrength;
        }
     }

// Set buffer values
   BufferUSD[index] = strength[0];
   BufferEUR[index] = strength[1];
   BufferGBP[index] = strength[2];
   BufferJPY[index] = strength[3];
   BufferAUD[index] = strength[4];
   BufferCAD[index] = strength[5];
   BufferCHF[index] = strength[6];
   BufferNZD[index] = strength[7];
  }

//+------------------------------------------------------------------+
//| Check if the event should be included based on importance        |
//+------------------------------------------------------------------+
bool IsEventIncluded(ENUM_CALENDAR_EVENT_IMPORTANCE importance)
  {
   switch(importance)
     {
      case CALENDAR_IMPORTANCE_HIGH:
         return InpIncludeHigh;
      case CALENDAR_IMPORTANCE_MODERATE:
         return InpIncludeMedium;
      case CALENDAR_IMPORTANCE_LOW:
         return InpIncludeLow;
      default:
         return false;
     }
  }

//+------------------------------------------------------------------+
//| Get the index of the currency in the CurrencyNames array         |
//+------------------------------------------------------------------+
int GetCurrencyIndex(string currency)
  {
   for(int i = 0; i < ArraySize(CurrencyNames); i++)
     {
      if(CurrencyNames[i] == currency)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Calculate the impact of an economic event                        |
//+------------------------------------------------------------------+
double CalculateEventImpact(const EconomicEvent &event)
  {
   double impact = 0;

// Calculate the difference between actual and forecast
   double difference = event.actual - event.forecast;

// Apply impact based on the event's importance
   switch(event.importance)
     {
      case CALENDAR_IMPORTANCE_HIGH:
         impact = difference * 3;
         break;
      case CALENDAR_IMPORTANCE_MODERATE:
         impact = difference * 2;
         break;
      case CALENDAR_IMPORTANCE_LOW:
         impact = difference;
         break;
     }

   return impact;
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
// Add any additional custom functions here
