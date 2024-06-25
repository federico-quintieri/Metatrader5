//+------------------------------------------------------------------+
//|                                                      Notizie.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Info\Database\Database.mqh>

enum ENUM_VALUTA
  {
   AUD, //Dollaro autraliano
   BRL, //Real brasiliano
   CAD, //Dollaro canadese
   CHF, //Franco svizzero
   CNT, //Yuan cinese
   EUR, //Euro
   GBP, //Sterlina
   HKD, //Dollaro di Hong Kong
   INR, //Rupia indiana
   JPY, //Yen giapponese
   KRW, //Won sudcoreano
   MXN, //Peso messicano
   NOK, //Corona norvegese
   NZD, //Dollaro neozelandese
   SEK, //Corona svedese
   SGD, //Dollaro di Singapore
   USD, //Dollari americani
   ZAR  //Rand sudafricano
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNotizie : public CDatabase
  {
public:

                     CNotizie() {};
                    ~CNotizie() {};

   int               pos_GDP(string nome_evento);
   int               pos_INT(string nome_evento);
   int               pos_NFP(string nome_evento);
   int               pos_CPI(string nome_evento);
   string            QueryNotizie(string table_name,datetime data_evento, string nome_evento, double Attuale, double Previsto, double Precedente);
   void              InitDatabase(string valuta);
   int               RetrieveCalendarValues(string valuta, datetime from, MqlCalendarValue& out_values[]);
   void              ProcessCalendarEvent(int handle, string valuta, MqlCalendarEvent& event, MqlCalendarValue& value);
   void              UpdateDatabase(string valuta,datetime from);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::pos_GDP(string nome_evento)
  {
   int ritorno_posizione = -1;

   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "PIL") : ritorno_posizione;

   return ritorno_posizione;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::pos_INT(string nome_evento)
  {
   int ritorno_posizione = -1;

   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "Interesse") : ritorno_posizione;
   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "interesse") : ritorno_posizione;

   return ritorno_posizione;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::pos_NFP(string nome_evento)
  {
   int ritorno_posizione = -1;

   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "Agricoli") : ritorno_posizione;

   return ritorno_posizione;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::pos_CPI(string nome_evento)
  {
   int ritorno_posizione = -1;

   ritorno_posizione = (ritorno_posizione == -1) ? StringFind(nome_evento, "IPC") : ritorno_posizione;

   return ritorno_posizione;
  }
//+------------------------------------------------------------------+
string CNotizie::QueryNotizie(string table_name,datetime data_evento, string nome_evento, double Attuale, double Previsto, double Precedente)
  {
   string query ="";
   string Attuale_Previsto ="";
   string Attuale_Precedente="";
   string giorno = TimeToString(data_evento,TIME_DATE | TIME_MINUTES);

   double Attuale_Previsto_percent =(Previsto != 0) ? NormalizeDouble(((Attuale - Previsto) / Previsto) * 100,2) : 0;
   double Attuale_Precedente_percent =(Precedente != 0) ? NormalizeDouble(((Attuale - Precedente) / Precedente) * 100,2) : 0;

   Attuale_Previsto = StringFormat("%.2f%%", Attuale_Previsto_percent);
   Attuale_Precedente = StringFormat("%.2f%%", Attuale_Precedente_percent);

   query = StringFormat("INSERT INTO %s (Data,Nome,Attuale,Previsto,Precedente,Attuale_Previsto,Attuale_Precedente) VALUES ('%s','%s',%f,%f,%f,'%s','%s')",
                        table_name,
                        giorno,
                        nome_evento,
                        Attuale,
                        Previsto,
                        Precedente,
                        Attuale_Previsto,
                        Attuale_Precedente
                       );

   return query;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNotizie::InitDatabase(string valuta)
  {
   string QUERY[];
   string TableName[] = {"CPI", "Interest", "NFP", "GDP"};
   const int tableCount = ArraySize(TableName);

// Inizializzare l'array QUERY con la stessa dimensione di TableName
   ArrayResize(QUERY, tableCount);

   int handle_database = ApriDatabase("Notizie_"+valuta);

// Costruire le query per la creazione delle tabelle
   for(int i = 0; i < tableCount; i++)
     {
      QUERY[i] = "CREATE TABLE " + TableName[i] + " ("
                 "Data TEXT,"
                 "Nome TEXT,"
                 "Attuale REAL,"
                 "Previsto REAL,"
                 "Precedente REAL,"
                 "Attuale_Previsto REAL,"
                 "Attuale_Precedente REAL);";
     }

// Creare le tabelle nel database
   for(int i = 0; i < tableCount; i++)
     {
      CancellaTabella(handle_database, TableName[i]);
      CreaTabella(handle_database, TableName[i], QUERY[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CNotizie::RetrieveCalendarValues(string valuta, datetime from, MqlCalendarValue& out_values[])
  {
   int valuesTotal = CalendarValueHistory(out_values, from, TimeTradeServer());
   return valuesTotal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNotizie::ProcessCalendarEvent(int handle, string valuta, MqlCalendarEvent& event, MqlCalendarValue& value)
  {
   MqlCalendarCountry country;
   CalendarCountryById(event.country_id, country);

   bool attuale_valid = MathIsValidNumber(value.actual_value) && value.actual_value != 0;
   bool precedente_valid = MathIsValidNumber(value.prev_value);
   bool previsto_valid = MathIsValidNumber(value.forecast_value) && value.forecast_value != 0;

   if(country.currency == valuta && attuale_valid && precedente_valid && previsto_valid)
     {
      double attuale = NormalizeDouble(value.actual_value, 2);
      double precedente = NormalizeDouble(value.prev_value, 2);
      double previsto = (value.forecast_value == -9.223372036854776e+18) ? 0 : NormalizeDouble(value.forecast_value, 2);

      Print("Nome evento: ", event.name);

      if(pos_CPI(event.name) >= 0)
         InserisciQuery(handle, QueryNotizie("CPI", value.time, event.name, attuale, previsto, precedente));

      if(pos_INT(event.name) >= 0)
         InserisciQuery(handle, QueryNotizie("Interest", value.time, event.name, attuale, previsto, precedente));

      if(pos_NFP(event.name) >= 0)
         InserisciQuery(handle, QueryNotizie("NFP", value.time, event.name, attuale, previsto, precedente));

      if(pos_GDP(event.name) >= 0)
         InserisciQuery(handle, QueryNotizie("GDP", value.time, event.name, attuale, previsto, precedente));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNotizie::UpdateDatabase(string valuta, datetime from)
  {
   int handle = ApriDatabase("Notizie_" + valuta);
   MqlCalendarValue values[];

   int valuesTotal = RetrieveCalendarValues(valuta, from, values);

   for(int i = 0; i < valuesTotal; i++)
     {
      MqlCalendarEvent event;
      CalendarEventById(values[i].event_id, event);

      ProcessCalendarEvent(handle, valuta, event, values[i]);
     }
  }
//+------------------------------------------------------------------+
