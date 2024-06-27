//+------------------------------------------------------------------+
//|                                                     Trailing.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Info\Gestione\Gestione.mqh>
#include <Indicators\Trend.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrailing:public CGestione
  {
public:
                     CTrailing() {};
                    ~CTrailing() {};

   void              MassimiMinimi(int magic, string simbolo, int TotaleCandele, int StartCandela);
   void              Media(int magic,string simbolo,ENUM_TIMEFRAMES periodo, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailing::MassimiMinimi(int magic, string simbolo, int TotaleCandele, int StartCandela)
  {
   double Minimo = Minimo(TotaleCandele,StartCandela);
   double Massimo = Massimo(TotaleCandele,StartCandela);

   Trailing(magic,simbolo,Minimo,Massimo);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailing::Media(int magic,string simbolo,ENUM_TIMEFRAMES periodo, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied)
  {
   CiMA *ob_ma = new CiMA();
   ob_ma.Create(simbolo,periodo,ma_period,ma_shift,ma_method,applied);
   ob_ma.BufferResize(ma_period);
   ob_ma.Refresh(-1);

   if(ob_ma.Main(0) != ob_ma.Main(1))
     {
      double media =NormalizeDouble(ob_ma.Main(0),Digits());
      Trailing(magic,simbolo,media,media);
     }

   delete ob_ma;
  }
//+------------------------------------------------------------------+
