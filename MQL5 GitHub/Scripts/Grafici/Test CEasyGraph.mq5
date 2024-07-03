//+------------------------------------------------------------------+
//|                                              Test CEasyGraph.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include <FQInclude\Main.mqh>
#include <FQInclude\Grafici\EasyGraph.mqh>

CDatabase database;

input string Nome_Database = "Notizie_USD.sqlite";
input string Nome_Tabella = "Interest";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   CEasyGraph graph;

   int height = (int)ChartGetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS);
   int width = (int)ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS);
   ChartSetInteger(ChartID(),CHART_SHOW,false);
   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_HISTORY,false);

   double x[], y[];

   if(!graph.GetDataFromDB(Nome_Database,Nome_Tabella, x, y))
     {
      Print("Failed to get results from database");
      return;
     }

// Initialize the graph
   if(!graph.Init("MyGraph", 0, 0, 0, width, height))
     {
      Print("Failed to initialize graph");
      return;
     }

// Aggiungo una linea
   graph.AddLineCurve(x,y,clrBlack,"Interest Rate");

// Customize the graph
   graph.SetBackgroundColor(clrWhite);
   graph.SetTitle("My Easy Graph", 16);
   graph.SetXAxisName("Tempo");
   graph.SetYAxisName("Valori");

// Show the graph
   graph.Show();
  }
//+------------------------------------------------------------------+
