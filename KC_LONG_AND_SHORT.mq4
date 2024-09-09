//+------------------------------------------------------------------+
//|                                                 FileTrader.mq4   |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property link      "http://www.yourwebsite.com"
#property version   "1.01"
#property strict

// Global Variables
int fileHandle;
string fileName = "Command.txt";
string symbol = ".US30.";
double lotSize = 2.5; // $2.5 per point = £2 per point (CFD's denominated in USD)
string lastProcessedCommand = "";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
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
   // Read command from file
   string command = ReadCommandFromFile();
   
   if(command != "" && command != lastProcessedCommand)
   {
      if(command == "rsi-buy-long" || command == "kc-buy-long")
      {
         OpenLongTrade();
      }
      else if(command == "rsi-sell-long" || command == "kc-sell-long")
      {
         CloseLongTrade();
      }
      else if(command == "rsi-sell-short" || command == "kc-sell-short")
      {
         OpenShortTrade();
      }
      else if(command == "rsi-buy-short" || command == "kc-buy-short")
      {
         CloseShortTrade();
      }
      
      // Clear the command file after processing
      ClearCommandFile();
      lastProcessedCommand = command;
   }
}

//+------------------------------------------------------------------+
//| Read command from file                                           |
//+------------------------------------------------------------------+
string ReadCommandFromFile()
{
   string command = "";
   fileHandle = FileOpen(fileName, FILE_READ|FILE_TXT);
   
   if(fileHandle != INVALID_HANDLE)
   {
      command = FileReadString(fileHandle);
      FileClose(fileHandle);
   }
   
   return command;
}

//+------------------------------------------------------------------+
//| Open a long trade                                                |
//+------------------------------------------------------------------+
void OpenLongTrade()
{
   if(CountOpenTrades() < 2)  // Allow opening a new trade if less than 2 are open
   {
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int ticket = OrderSend(symbol, OP_BUY, lotSize, ask, 0, 0, 0, "Long Trade", 0, 0, clrGreen);
      
      if(ticket > 0)
      {
         Print("Long trade opened successfully. Ticket: ", ticket);
      }
      else
      {
         Print("Failed to open long trade. Error: ", GetLastError());
      }
   }
   else
   {
      Print("Maximum number of positions are already open. Cannot open new trade.");
   }
}

//+------------------------------------------------------------------+
//| Close the open long trade                                        |
//+------------------------------------------------------------------+
void CloseLongTrade()
{
   if(CountOpenTrades() > 0)
   {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if(OrderSymbol() == symbol && OrderType() == OP_BUY)
            {
               bool closed = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrRed);
               
               if(closed)
               {
                  Print("Long trade closed successfully. Ticket: ", OrderTicket());
               }
               else
               {
                  Print("Failed to close long trade. Error: ", GetLastError());
               }
            }
         }
      }
   }
   else
   {
      Print("No open long position to close.");
   }
}

//+------------------------------------------------------------------+
//| Open a short trade                                               |
//+------------------------------------------------------------------+
void OpenShortTrade()
{
   if(CountOpenTrades() < 2)  // Allow opening a new trade if less than 2 are open
   {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      int ticket = OrderSend(symbol, OP_SELL, lotSize, bid, 0, 0, 0, "Short Trade", 0, 0, clrRed);
      
      if(ticket > 0)
      {
         Print("Short trade opened successfully. Ticket: ", ticket);
      }
      else
      {
         Print("Failed to open short trade. Error: ", GetLastError());
      }
   }
   else
   {
      Print("Maximum number of positions are already open. Cannot open new trade.");
   }
}

//+------------------------------------------------------------------+
//| Close the open short trade                                       |
//+------------------------------------------------------------------+
void CloseShortTrade()
{
   if(CountOpenTrades() > 0)
   {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if(OrderSymbol() == symbol && OrderType() == OP_SELL)
            {
               bool closed = OrderClose(OrderTicket(), OrderLots(), Ask, 0, clrGreen);
               
               if(closed)
               {
                  Print("Short trade closed successfully. Ticket: ", OrderTicket());
               }
               else
               {
                  Print("Failed to close short trade. Error: ", GetLastError());
               }
            }
         }
      }
   }
   else
   {
      Print("No open short position to close.");
   }
}

//+------------------------------------------------------------------+
//| Count open trades                                                |
//+------------------------------------------------------------------+
int CountOpenTrades()
{
   int openTradeCount = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == symbol && (OrderType() == OP_BUY || OrderType() == OP_SELL))
         {
            openTradeCount++;
         }
      }
   }

   return openTradeCount;
}

//+------------------------------------------------------------------+
//| Clear the command file                                           |
//+------------------------------------------------------------------+
void ClearCommandFile()
{
   fileHandle = FileOpen(fileName, FILE_WRITE|FILE_TXT);
   
   if(fileHandle != INVALID_HANDLE)
   {
      FileWrite(fileHandle, "");
      FileClose(fileHandle);
      Print("Command file cleared.");
   }
   else
   {
      Print("Failed to clear command file. Error: ", GetLastError());
   }
}
