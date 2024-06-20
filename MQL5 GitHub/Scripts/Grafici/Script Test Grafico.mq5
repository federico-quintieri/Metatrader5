//+------------------------------------------------------------------+
//|                                          Script Test Grafico.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Graphics\Graphic.mqh>
#include <Database.mqh>

CDatabase database;

CGraphic grafico;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string database_name = "Database " +IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+".sqlite";
int handle_database;
//+------------------------------------------------------------------+
//| Script per disegnare il grafico                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   handle_database = database.CreateDatabase(database_name);

   string table_name = "EA_Volatilita";

   double results[];

   if(GetResults(handle_database, table_name, results))
     {
      // Crea l'array x con gli indici corrispondenti ai risultati
      double x[];

      ArrayResize(x, ArraySize(results));

      for(int i = 0; i < ArraySize(results); i++)
        {
         x[i] = i + 1; // Indice da 1 a N
        }

      string NomeGrafico = GraphPlot(x, results,CURVE_LINES);
     
     }
   else
     {
      Print("Nessun dato trovato nella tabella ", table_name);
     }

   DatabaseClose(handle_database);
  }
//+------------------------------------------------------------------+
bool GetResults(int database_handle, string table_name, double &results[])
  {
   string sql = "SELECT Risultato FROM " + table_name;
   int request = DatabasePrepare(database_handle, sql);

   if(request == INVALID_HANDLE)
     {
      Print("DB: richiesta per ottenere i risultati fallita con codice ", GetLastError());
      return false;
     }

   int count = 0;
   while(DatabaseRead(request))
     {
      double value;
      if(DatabaseColumnDouble(request, 0, value) && value != 0)
        {
         ArrayResize(results, count + 1);

         results[count] = value;

         count++;
        }
     }

   DatabaseFinalize(request);
   return count > 0;
  }
//+------------------------------------------------------------------+
