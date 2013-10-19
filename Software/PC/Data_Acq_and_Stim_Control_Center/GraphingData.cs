using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Research.DynamicDataDisplay.DataSources;
using System.Windows;

namespace Data_Acq_and_Stim_Control_Center
{
    public class GraphingData
    {
        public ObservableDataSource<Point> Channel_AllData = null;
        public ObservableDataSource<Point> Channel_GraphData = null;

        public GraphingData()
        {
            Channel_AllData = new ObservableDataSource<Point>();
            Channel_GraphData = new ObservableDataSource<Point>();
            Channel_GraphData.SetXYMapping(p => p);
        }
    }
}
