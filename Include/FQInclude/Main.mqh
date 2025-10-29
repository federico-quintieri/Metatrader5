//+------------------------------------------------------------------+
//|                                                         Main.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| File che serve per includere tutte le mie librerie               |
//+------------------------------------------------------------------+

#include <FQInclude\Rischio\Rischio.mqh>                            // Libreria per gestire il lottaggio
#include <FQInclude\Gestione\Gestione.mqh>                          // Libreria per la gestione degli ordini/posizioni
#include <FQInclude\Database\Notizie.mqh>                           // Libreria per gestire le notizie nel database 
#include <FQInclude\Database\Andamento.mqh>                         // Libreria per gestire il database dell'andamento
#include <FQInclude\Info\NotizieLive.mqh>                           // Libreria per gestire dati notizia