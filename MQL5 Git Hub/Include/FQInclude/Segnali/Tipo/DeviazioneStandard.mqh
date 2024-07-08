//+------------------------------------------------------------------+
//|                                           DeviazioneStandard.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Segnali\SegnaliMain.mqh>

//+------------------------------------------------------------------+
class CDevazioneStandard : public CSegnaliMain
  {

private:
   double            GetMaxDeviation(CiStdDev *OBDev, int start, int end);

public:
   bool              ContrazioneVolatilitaRange(double RangeInPunti, int TotaleCandeleMassimo, string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied);
   bool              EspansioneVolatilitaRange(double RangeInPunti, int TotaleCandeleMassimo, string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied);
   bool              ContrazioneVolatilitaPercentuale(double Percentuale, int Primo_Massimo, int Secondo_Massimo, string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDevazioneStandard::GetMaxDeviation(CiStdDev *OBDev, int start, int end)
  {
   double maxDeviation = 0.0;
   for(int i = start; i < end; i++)
     {
      if(OBDev.Main(i) > maxDeviation)
        {
         maxDeviation = OBDev.Main(i);
        }
     }
   return maxDeviation;
  }

bool CDevazioneStandard::ContrazioneVolatilitaRange(double RangeInPunti, int TotaleCandeleMassimo, string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied)
  {
   CiStdDev *OBDev = CreateStdDevIndicator(symbol, period, ma_period, ma_shift, ma_method, applied, TotaleCandeleMassimo);

   if(OBDev.Main(0) != OBDev.Main(1))
     {
      double DeviazioneMassima = GetMaxDeviation(OBDev, 1,TotaleCandeleMassimo);
      if(DeviazioneMassima / Point() <= RangeInPunti)
        {
         DeleteStdDevIndicator(OBDev);
         return true;
        }
     }

   DeleteStdDevIndicator(OBDev);
   return false;
  }

//+------------------------------------------------------------------+
bool CDevazioneStandard::EspansioneVolatilitaRange(double RangeInPunti, int TotaleCandeleMassimo, string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied)
  {
   CiStdDev *OBDev = CreateStdDevIndicator(symbol, period, ma_period, ma_shift, ma_method, applied, TotaleCandeleMassimo);

   if(OBDev.Main(0) != OBDev.Main(1))
     {
      double DeviazioneMassima = GetMaxDeviation(OBDev,1,TotaleCandeleMassimo);
      if(DeviazioneMassima / Point() >= RangeInPunti)
        {
         DeleteStdDevIndicator(OBDev);
         return true;
        }
     }

   DeleteStdDevIndicator(OBDev);
   return false;
  }

//+------------------------------------------------------------------+
bool CDevazioneStandard::ContrazioneVolatilitaPercentuale(double Percentuale, int Primo_Massimo, int Secondo_Massimo, string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied)
  {
   Percentuale /= 100.0;
   CiStdDev *OBDev = CreateStdDevIndicator(symbol, period, ma_period, ma_shift, ma_method, applied, Secondo_Massimo);

   if(OBDev.Main(0) != OBDev.Main(1))
     {
      double Massimo_Recente = 0.0;
      double Massimo_Lontano = 0.0;

      for(int i = 0; i < Secondo_Massimo; i++)
        {
         if(i < Primo_Massimo)
           {
            if(OBDev.Main(i) > Massimo_Recente)
              {
               Massimo_Recente = OBDev.Main(i);
              }
           }
         else
           {
            if(OBDev.Main(i) > Massimo_Lontano)
              {
               Massimo_Lontano = OBDev.Main(i);
              }
           }
        }

      if(Massimo_Lontano - (Massimo_Lontano * Percentuale) > Massimo_Recente)
        {
         DeleteStdDevIndicator(OBDev);
         return true;
        }
     }

   DeleteStdDevIndicator(OBDev);
   return false;
  }
//+------------------------------------------------------------------+
