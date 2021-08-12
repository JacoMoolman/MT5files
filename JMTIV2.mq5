//+------------------------------------------------------------------+
//|                                                        JMTI1.mq5 |
//|                                                         LeMeJaco |
//|                                            https://protect-za.mimecast.com/s/IhTXCY6Zvjt1nYk0f09Oyz?domain=jacomoolman.co.za |
//+------------------------------------------------------------------+
#property copyright "LeMeJaco"
#property link      "https://protect-za.mimecast.com/s/IhTXCY6Zvjt1nYk0f09Oyz?domain=jacomoolman.co.za"
#property version   "1.00"
#property indicator_chart_window

int TICKCOUNT=0;
int NUMBERofBARS=10;
int CURRANTBARS=0;

float STARTCOUNT;

int TMPINSTORE;

int TOTALLINECOUNT=0;

int MAINLINEDIF;

//ARRAYS
int MAXCALCBARS=2000;
int GRID[2000][2000];
int GRIDCOUNT[2000][2];  //TOTAL Y and LINE COLOR
int MAINLINECOUNT[2000][2];  //TOTAL Y and LINE COLOR
int TMPSORTGRIDCOUNT[2000][2];


int FullColorGrid[511];
int DivColGrid[511];
int COLORdivGRID=0;
int COLSTARTCOUNT=511;

int Counter,Counter2,Counter3;

float HighestHighPrice=0;
float LowestLowPrice=0;

int NumBarsInWindow;

float LineIncrements;

string LINE;

int SKIPCOUNT=10;
int DRAWMAINLINEGRATERTHAN=30;

MqlRates BarsInfo[];



//INPUTS
//============================================================
int GRIDH=510;
bool ShowTextGrid=false;
bool ShowLines=true;
//bool ShowLinesMain=false;
input bool Refresh_on_Tick=false; //Refresh of every tick
int Skip_Bars=0; //Refresh only X #of bars




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

Comment("JMTI v1.0");


ChartSetInteger(0,CHART_COLOR_CHART_UP,clrBlack);
ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrBlack);
ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrBlack);
//ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrWhite);


//////////////// BUILD COLOR CHART               0    ----->>   510
   
   for(Counter=0; Counter<255; Counter++)
   {FullColorGrid[Counter]=(0*256*256)+(255*256)+Counter;}
   
   Counter2=255;
   for(Counter=255; Counter<510; Counter++)
   {FullColorGrid[Counter]=(0*256*256)+(Counter2*256)+255;Counter2--;}
    
//////////////// BUILD COLOR CHART
   //Print("FULL COLOR RANGE");
   //for(Counter=0; Counter<510; Counter++){Print(FullColorGrid[Counter]);} //CORRECT

   COLORdivGRID=510/GRIDH;
   //Print("COLORdivGRID:",COLORdivGRID);
   COLSTARTCOUNT=511;
   for(Counter2=0; Counter2<GRIDH; Counter2++)
   { 
      //Print(COLSTARTCOUNT);
      DivColGrid[Counter2]=FullColorGrid[Counter2];  //ISSUE HERE
      COLSTARTCOUNT=COLSTARTCOUNT-COLORdivGRID;
   }

   //Print("COLGRID"); for(Counter2=0; Counter2<GRIDH; Counter2++){Print(DivColGrid[Counter2]);}
   

   
//---
   return(INIT_SUCCEEDED);
  }
  
void DrawHighLowLines()
  {
   ObjectSetInteger(0,"Highest",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"Highest",OBJ_HLINE,0,TimeCurrent(),HighestHighPrice);
   ObjectSetDouble(0,"Highest",OBJPROP_PRICE,HighestHighPrice);

   ObjectSetInteger(0,"Lowest",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"Lowest",OBJ_HLINE,0,TimeCurrent(),LowestLowPrice);
   ObjectSetDouble(0,"Lowest",OBJPROP_PRICE,LowestLowPrice);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetHighLow()
  {
   HighestHighPrice=0;
   LowestLowPrice=100000000;
   for(Counter=0; Counter<NumBarsInWindow; Counter++)
     {
      if(BarsInfo[Counter].high>HighestHighPrice)
        {
         HighestHighPrice=BarsInfo[Counter].high;
        }
      if(BarsInfo[Counter].low<LowestLowPrice)
        {
         LowestLowPrice=BarsInfo[Counter].low;
        }
     }
  }  
  
  
  
void CreateGrid()
{
   //Print("NUMBarsInWindow: ",NumBarsInWindow);
   //Print("GRIDH: ",GRIDH);
   
   for(Counter3=0; Counter3<NumBarsInWindow; Counter3++)
   {
      STARTCOUNT=LowestLowPrice;
      for(Counter2=0; Counter2<GRIDH; Counter2++)
      {
         if((BarsInfo[Counter3].high>STARTCOUNT))
         {
            GRID[Counter3][Counter2]=1;
         }
      
         if((BarsInfo[Counter3].low>STARTCOUNT))
         {
            GRID[Counter3][Counter2]=0;
         }

         STARTCOUNT=STARTCOUNT+LineIncrements;
      }
   
  }

}  
 
void CreateGridCount() 
{
   for(Counter2=0; Counter2<GRIDH; Counter2++)
   {
      TOTALLINECOUNT=0;
      for(Counter3=0; Counter3<NumBarsInWindow; Counter3++)
      { 
         TOTALLINECOUNT=TOTALLINECOUNT+GRID[Counter3][Counter2];
      }
      GRIDCOUNT[Counter2][0]=TOTALLINECOUNT;
  }
   //for(Counter=0; Counter<GRIDH; Counter++){Print(TMPSORTGRIDCOUNT[Counter][0]);}
} 


void CloneGridCount()
{
   for(Counter=0; Counter<GRIDH; Counter++)
   {
      TMPSORTGRIDCOUNT[Counter][0]=GRIDCOUNT[Counter][0];
      MAINLINECOUNT[Counter][0]=GRIDCOUNT[Counter][0];
   } 
}
 
void SortTmpSortGridCount()
{
   for(Counter2=0; Counter2<GRIDH; Counter2++)
   {
      for(Counter=0; Counter<GRIDH; Counter++)
      {
         if (TMPSORTGRIDCOUNT[Counter][0]>TMPSORTGRIDCOUNT[Counter+1][0])
         {
            TMPINSTORE=TMPSORTGRIDCOUNT[Counter][0];
            TMPSORTGRIDCOUNT[Counter][0]=TMPSORTGRIDCOUNT[Counter+1][0];
            TMPSORTGRIDCOUNT[Counter+1][0]=TMPINSTORE;
         }
      }
   }
//for(Counter=0; Counter<GRIDH; Counter++){Print(TMPSORTGRIDCOUNT[Counter][0]);}   
} 
 
 

 
void DeleteGrid()
{
   for(Counter3=0; Counter3<MAXCALCBARS; Counter3++)
   {
      
      for(Counter2=0; Counter2<MAXCALCBARS; Counter2++)
      {
         GRID[Counter3][Counter2]=0;
      } 
   }
}  
  
 
void ShowTextGrid()
{
   for(Counter3=0; Counter3<NumBarsInWindow; Counter3++) 
   {
      LINE="";
      for(Counter2=0; Counter2<GRIDH; Counter2++)     
      { 
         StringConcatenate(LINE,LINE,GRID[Counter3][Counter2]);
      }
      //Print(Counter3,":",LINE);
   }    
}  

void AssignColToTmpSortGrid()
{
   for(Counter=0; Counter<GRIDH; Counter++)
   {
      TMPSORTGRIDCOUNT[Counter][1]=DivColGrid[Counter];
   } 
   
//for(Counter=0; Counter<GRIDH; Counter++){Print(TMPSORTGRIDCOUNT[Counter][0],":",TMPSORTGRIDCOUNT[Counter][1]);}      
     
}

void PutColBacktoGridCount()
{

           for(Counter=0; Counter<GRIDH; Counter++)
            {
               for(Counter2=0; Counter2<GRIDH; Counter2++)
               {
                  if (GRIDCOUNT[Counter][0]==TMPSORTGRIDCOUNT[Counter2][0])
                  {
                     GRIDCOUNT[Counter][1]=TMPSORTGRIDCOUNT[Counter2][1];
                  }
               } 
            }
//for(Counter=0; Counter<GRIDH; Counter++){Print(GRIDCOUNT[Counter][0],":",GRIDCOUNT[Counter][1]);}      
}


void ShowLines()
{
   STARTCOUNT=LowestLowPrice;
   for(Counter2=0; Counter2<GRIDH; Counter2++)
      {
         ObjectSetInteger(0,Counter2,OBJPROP_BACK,true);
         ObjectSetInteger(0,Counter2,OBJPROP_COLOR,GRIDCOUNT[Counter2][1]);
         ObjectSetInteger(0,Counter2,OBJPROP_WIDTH,3);
         
         
         ObjectCreate(0,Counter2,OBJ_HLINE,0,TimeCurrent(),STARTCOUNT);
         
         ObjectSetDouble(0,Counter2,OBJPROP_PRICE,STARTCOUNT);

         STARTCOUNT=STARTCOUNT+LineIncrements;
   }
}


void CalcMainLineDif()
{
   
   //Print("XXXXXXXXXXX",SKIPCOUNT);
   for(Counter=0; Counter<GRIDH; Counter++)
   {
      //Print(MAINLINECOUNT[Counter][0]);
      if (Counter+SKIPCOUNT<GRIDH)
      {
         if (MAINLINECOUNT[Counter][0]>MAINLINECOUNT[Counter+SKIPCOUNT][0])
         {
            MAINLINEDIF=MAINLINECOUNT[Counter][0]-MAINLINECOUNT[Counter+SKIPCOUNT][0];
            //Print(MAINLINECOUNT[Counter][0],"-",MAINLINECOUNT[Counter+SKIPCOUNT][0],"=",MAINLINEDIF);         
         }
         else
         {
            MAINLINEDIF=MAINLINECOUNT[Counter+SKIPCOUNT][0]-MAINLINECOUNT[Counter][0];
            //Print(MAINLINECOUNT[Counter+SKIPCOUNT][0],"-",MAINLINECOUNT[Counter][0],"=",MAINLINEDIF);         
         }
      MAINLINECOUNT[Counter][0]=MAINLINEDIF;
      }
   } 
   
  //for(Counter=0; Counter<GRIDH; Counter++){Print(MAINLINECOUNT[Counter][0]);}  

}

void AssignMainLineDifCol()
{
   for(Counter=0; Counter<GRIDH; Counter++)
   {
      if (MAINLINECOUNT[Counter][0]>DRAWMAINLINEGRATERTHAN)
      {
         MAINLINECOUNT[Counter][1]=200;
      }
      else
      {
         MAINLINECOUNT[Counter][1]=1;
      }
   }
   
//for(Counter=0; Counter<GRIDH; Counter++){Print(MAINLINECOUNT[Counter][1]);}     
}

void ShowLinesMain()
{
   STARTCOUNT=LowestLowPrice;
   for(Counter2=0; Counter2<GRIDH; Counter2++)
      {
         if (MAINLINECOUNT[Counter2][1]>100)
         {
            ObjectSetInteger(0,Counter2+"x",OBJPROP_BACK,true);
            ObjectSetInteger(0,Counter2+"x",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0,Counter2+"x",OBJPROP_WIDTH,3);
            
            ObjectCreate(0,Counter2+"x",OBJ_HLINE,0,TimeCurrent(),STARTCOUNT);
         
            ObjectSetDouble(0,Counter2+"x",OBJPROP_PRICE,STARTCOUNT);
         }
         STARTCOUNT=STARTCOUNT+LineIncrements;
      }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
                
                
                
  {
//---
   
      
      if (NUMBERofBARS>CURRANTBARS)
      { 
         //Print("NEWBAR");
         CURRANTBARS=NUMBERofBARS;
         // START OF ALL
         
         NumBarsInWindow=ChartGetInteger(0,CHART_WIDTH_IN_BARS,0);
         //Print(NumBarsInWindow);
         CopyRates(Symbol(),0,0,NumBarsInWindow,BarsInfo);

         GetHighLow();
         DrawHighLowLines();
         
            //DIFF BETEEN / HOW FAR LINE GRIDS MUST BE APART ON GRAPTH
         LineIncrements=HighestHighPrice-LowestLowPrice;
         LineIncrements=LineIncrements/GRIDH;
         
         CreateGrid();
         //if (ShowTextGrid==true){ShowTextGrid();}
                 
         CreateGridCount();
         
         CloneGridCount();
         
         SortTmpSortGridCount();
         
         AssignColToTmpSortGrid();
         
         PutColBacktoGridCount();
         
         if (ShowLines==true){ShowLines();}         

            //CalcMainLineDif();         
         
            //AssignMainLineDifCol();
         
            //if (ShowLinesMain==true){ShowLinesMain();}       

         DeleteGrid();



     }  // END OF ALL
      
      if (Refresh_on_Tick==true)
      {
         NUMBERofBARS=10;
         CURRANTBARS=1;
      }
      else
      {
        NUMBERofBARS=Bars(Symbol(),0);
      }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
