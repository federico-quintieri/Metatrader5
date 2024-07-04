//+------------------------------------------------------------------+
//|                                                  EasyGraph.mqh   |
//|                        Copyright 2024, Your Name                 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Graphics\Graphic.mqh>
#include <FQInclude\Info\Database\Database.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEasyGraph
  {
private:
   CGraphic          m_graphic;           // Main graphic object
   string            m_name;              // Graph name
   int               m_window_index;      // Chart window index
   int               m_x;                 // X coordinate
   int               m_y;                 // Y coordinate
   int               m_width;             // Graph width
   int               m_height;            // Graph height
   CDatabase         m_database;

public:
                     CEasyGraph();
                    ~CEasyGraph();

   // Initialization methods
   bool              Init(const string name, const int window_index = 0, const int x = 30, const int y = 30, const int width = 780, const int height = 380);

   // Database methods
   bool              GetDataFromDB(string Nome_database,const string table_name, double &x[], double &y[], const string x_column = "Data", const string y_column = "Attuale");

   // Graph type creation methods
   CCurve            *AddLineCurve(const double &x[], const double &y[], const color clr = clrBlue, const string name = "");
   CCurve            *AddHistogram(const double &x[], const double &y[], const color clr = clrGreen, const string name = "");

   // Data management methods
   bool              UpdateData(const int curve_index, const double &x[], const double &y[]);
   bool              RemoveCurve(const int curve_index);

   // Customization methods
   void              SetBackgroundColor(const color clr);
   void              SetTitle(const string title, const int font_size = 14);
   void              SetXAxisName(const string name, const int font_size = 12);
   void              SetYAxisName(const string name, const int font_size = 12);

   // Display management methods
   void              Show();
   void              Hide();
   void              Update();

   // Utility methods
   int               CurvesTotal() { return m_graphic.CurvesTotal(); }
   CGraphic          *GetGraphicPtr() { return GetPointer(m_graphic); }
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEasyGraph::CEasyGraph()
  {
   m_name = "EasyGraph";
   m_window_index = 0;
   m_x = 30;
   m_y = 30;
   m_width = 780;
   m_height = 380;
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CEasyGraph::~CEasyGraph()
  {
// Cleanup if necessary
  }

//+------------------------------------------------------------------+
//| Initialize the graph with given or default parameters            |
//+------------------------------------------------------------------+
bool CEasyGraph::Init(const string name, const int window_index = 0, const int x = 30, const int y = 30, const int width = 780, const int height = 380)
  {
   m_name = name;
   m_window_index = window_index;
   m_x = x;
   m_y = y;
   m_width = width;
   m_height = height;

   return m_graphic.Create(0, m_name, m_window_index, m_x, m_y, m_width+55, m_height+25);
  }

//+------------------------------------------------------------------+
//| Add a line curve to the graph                                    |
//+------------------------------------------------------------------+
CCurve *CEasyGraph::AddLineCurve(const double &x[], const double &y[], const color clr = clrBlue, const string name = "")
  {
   return m_graphic.CurveAdd(x, y, clr, CURVE_LINES, name);
  }
//+------------------------------------------------------------------+
//| Add a histogram to the graph                                     |
//+------------------------------------------------------------------+
CCurve *CEasyGraph::AddHistogram(const double &x[], const double &y[], const color clr = clrGreen, const string name = "")
  {
   return m_graphic.CurveAdd(x, y, clr, CURVE_HISTOGRAM, name);
  }

//+------------------------------------------------------------------+
//| Update data for an existing curve                                |
//+------------------------------------------------------------------+
bool CEasyGraph::UpdateData(const int curve_index, const double &x[], const double &y[])
  {
   if(curve_index >= 0 && curve_index < m_graphic.CurvesTotal())
     {
      CCurve *curve = m_graphic.CurveGetByIndex(curve_index);
      if(curve != NULL)
        {
         curve.Update(x, y);
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Remove a curve from the graph                                    |
//+------------------------------------------------------------------+
bool CEasyGraph::RemoveCurve(const int curve_index)
  {
   return m_graphic.CurveRemoveByIndex(curve_index);
  }

//+------------------------------------------------------------------+
//| Set the background color of the graph                            |
//+------------------------------------------------------------------+
void CEasyGraph::SetBackgroundColor(const color clr)
  {
   m_graphic.BackgroundMain(IntegerToString(clr));
  }

//+------------------------------------------------------------------+
//| Set the title of the graph                                       |
//+------------------------------------------------------------------+
void CEasyGraph::SetTitle(const string title, const int font_size = 14)
  {
   m_graphic.FontSet("Aerial", font_size, FW_NORMAL);
   m_graphic.TextAdd(50, 30, title, TA_LEFT|TA_TOP);
  }

//+------------------------------------------------------------------+
//| Set the name of the X-axis                                       |
//+------------------------------------------------------------------+
void CEasyGraph::SetXAxisName(const string name, const int font_size = 12)
  {
   m_graphic.XAxis().Name(name);
   m_graphic.XAxis().NameSize(font_size);
  }

//+------------------------------------------------------------------+
//| Set the name of the Y-axis                                       |
//+------------------------------------------------------------------+
void CEasyGraph::SetYAxisName(const string name, const int font_size = 12)
  {
   m_graphic.YAxis().Name(name);
   m_graphic.YAxis().NameSize(font_size);
  }

//+------------------------------------------------------------------+
//| Show the graph                                                   |
//+------------------------------------------------------------------+
void CEasyGraph::Show()
  {
   m_graphic.CurvePlotAll();
   m_graphic.Update();
  }

//+------------------------------------------------------------------+
//| Hide the graph                                                   |
//+------------------------------------------------------------------+
void CEasyGraph::Hide()
  {
   ObjectSetInteger(0, m_name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
  }

//+------------------------------------------------------------------+
//| Update the graph display                                         |
//+------------------------------------------------------------------+
void CEasyGraph::Update()
  {
   m_graphic.Redraw();
   m_graphic.Update();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEasyGraph::GetDataFromDB(string Nome_database, const string table_name, double &x[], double &y[], const string x_column = "Data", const string y_column = "Attuale")
  {
   int database_handle = m_database.ApriDatabase(Nome_database);

   string sql = StringFormat("SELECT %s, %s FROM %s", x_column, y_column, table_name);
   int request = DatabasePrepare(database_handle,sql);
   if(request == INVALID_HANDLE)
     {
      Print("DB: request to get results failed with code ", GetLastError());
      return false;
     }

   int count = 0;
   while(DatabaseRead(request))
     {
      double x_value, y_value;
      if(DatabaseColumnDouble(request, 0, x_value) && DatabaseColumnDouble(request, 1, y_value))
        {
         ArrayResize(x, count + 1);
         ArrayResize(y, count + 1);

         x[count] = x_value;
         y[count] = y_value;

         count++;
        }
     }

   DatabaseFinalize(request);
   m_database.ChiudiDatabase(database_handle);
   return count > 0;
  }
//+------------------------------------------------------------------+
