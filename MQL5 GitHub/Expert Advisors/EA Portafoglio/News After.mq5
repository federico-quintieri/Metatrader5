//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <FQInclude.mqh>
#include <Gestione.mqh>
#include <Rischio.mqh>
#include <Segnali.mqh>
#include <Trade\trade.mqh>
#include <Database.mqh>

CInfo info;
CGestione gestione;
CRisk rischio;
CTrade trade;
CSegnali segnale;
CDatabase database;

input group "Input EA";
input string NomeEA = "EA_News_After";
input int Mesi_Lungo_Termine = 6;
input int Mesi_Breve_Termine = 3;
input bool CancellaTabelle = true;
input int MagicNumber = 11;
input int Ore = 12;
input double StopLoss = 30 ;
input double Lotti = 0.01;
input int RangePuntiContrazione = 300;
input int CandeleContrazioneMassima = 10;
input int minuti = 60;
input double Pips_Ordini = 30;

// Preferisco inizializzare sempre le variabili che utilizzo nel codice
double pips = 0.0,
       LivelloStopBuy = 0.0,
       LivelloStopSell=0.0,
       LivelloTakeSell=0.0,
       LivelloTakeBuy=0.0,
       LivelloBuy=0.0,
       LivelloSell = 0.0;

bool buy = false,
     sell = false,
     buystop = false,
     sellstop = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   database.InitDatabase(MagicNumber,NomeEA);

   pips = info.Pips();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(info.NuovaCandela())
     {

      MqlDateTime time;
      TimeCurrent(time);

      gestione.TrailingMaxMin(MagicNumber,Symbol(),20,1);

      buy = info.CiSonoPosizioni(MagicNumber,Symbol(),POSITION_TYPE_BUY);
      sell = info.CiSonoPosizioni(MagicNumber,Symbol(),POSITION_TYPE_SELL);
      buystop = info.CiSonoOrdini(MagicNumber,Symbol(),ORDER_TYPE_BUY_STOP);
      sellstop = info.CiSonoOrdini(MagicNumber,Symbol(),ORDER_TYPE_SELL_STOP);

      if(!buy && !sell && !buystop && !sellstop)
        {
         invio_posizioni();
        }

      if(time.hour==23)
        {
         database.UpdateDatabase(MagicNumber,NomeEA,Mesi_Lungo_Termine,Mesi_Breve_Termine);
        }
     }
  }

// Contrazione + Tocco Banda in direzione della news
void invio_posizioni()
  {
   trade.SetExpertMagicNumber(MagicNumber);

   double Ask = info.Ask();
   double Bid = info.Bid();
   int expirationTime = 3600 * Ore;
   datetime expirationDate = TimeCurrent() + expirationTime;

   bool contrazione = segnale.ContrazioneVolatilitaRange(RangePuntiContrazione,CandeleContrazioneMassima,Symbol(),PERIOD_H1,20,0,MODE_SMA,PRICE_CLOSE);
   bool news_after = segnale.NewsDopo(minuti,"USD",3,CALENDAR_TYPE_INDICATOR);
   bool tocco_banda_buy = segnale.ToccoBanda("up",1,Symbol(),PERIOD_CURRENT,20,0,2,PRICE_CLOSE);
   bool tocco_banda_sell = segnale.ToccoBanda("down",1,Symbol(),PERIOD_CURRENT,20,0,2,PRICE_CLOSE);

   if(contrazione  && tocco_banda_sell)
     {
      LivelloSell = info.Ask() - Pips_Ordini * pips;
      LivelloStopSell = NormalizeDouble(LivelloSell+StopLoss*pips,Digits());
      trade.SellStop(Lotti,LivelloSell,Symbol(),LivelloStopSell,NULL,ORDER_TIME_SPECIFIED,expirationDate,"Invio SELLSTOP");
     }

   if(contrazione  && tocco_banda_buy)
     {
      LivelloBuy = info.Bid() + Pips_Ordini * pips;
      LivelloStopBuy = NormalizeDouble(LivelloBuy-StopLoss*pips,Digits());
      trade.BuyStop(Lotti,LivelloBuy,Symbol(),LivelloStopBuy,NULL,ORDER_TIME_SPECIFIED,expirationDate,"Invio BUYSTOP");
     }

  }
//+------------------------------------------------------------------+
