//+------------------------------------------------------------------+
//|                                            IncludeIndicatori.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CIndicatoreBase
  {
protected:
   int               handle;  // Handle per l'indicatore

public:
   // Costruttore
                     CIndicatoreBase() : handle(INVALID_HANDLE) {}

   // Distruttore
   virtual          ~CIndicatoreBase()
     {
      if(handle != INVALID_HANDLE)
         IndicatorRelease(handle);
     }

   // Metodo virtuale per inizializzare l'indicatore
   virtual void      Init(string symbol, int timeframe) = 0;

   // Metodo per ottenere il valore dell'indicatore
   virtual double    GetValue(int index, int bufferIndex) = 0;
  };
