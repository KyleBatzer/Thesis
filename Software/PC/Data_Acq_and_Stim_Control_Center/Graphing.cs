using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Collections;
using System.Windows;
using System.IO;
using System.ComponentModel;

namespace Data_Acq_and_Stim_Control_Center
{
    public class Graphing : INotifyPropertyChanged
    {
        #region graphing globals

        public List<int> SupportedNumSamples = new List<int>();


        //static int NUM_CHANNELS_GRAPH = 8;
        static int NUM_PACKETS = 65536;
        //static int NUM_SAMPLES_DISPLAYED = 32768 / 4;

        static int previous_view = 0;

        Double time_from_start = 0;
        Double prev_time_calc = 0;

        //GraphingData Channel1_Data = new GraphingData();

        public List<GraphingData> GraphData = new List<GraphingData>();

        #endregion

        private int _SamplesPerView;
        public int SamplesPerView
        {
            get { return _SamplesPerView; }
            set
            {
                _SamplesPerView = value;
                this.NotifyPropertyChanged("SamplesPerView");
            }
        }

        private int _TotalViews;
        public int TotalViews
        {
            get { return _TotalViews; }
            set
            {
                _TotalViews = value;
                this.NotifyPropertyChanged("TotalViews");
            }
        }

        private int _CurrentView;
        public int CurrentView
        {
            get { return _CurrentView; }
            set
            {
                _CurrentView = value;
                this.NotifyPropertyChanged("CurrentView");
            }
        }

        private int _ChannelsToGraph;
        public int ChannelsToGraph
        {
            get { return _ChannelsToGraph; }
            set
            {
                _ChannelsToGraph = value;
                this.NotifyPropertyChanged("ChannelsToGraph");
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        private void NotifyPropertyChanged(string name)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, new PropertyChangedEventArgs(name));
        }


        #region graphing code

        public Graphing()
        {
            SupportedNumSamples.Add(512);
            SupportedNumSamples.Add(1024);
            SupportedNumSamples.Add(2048);
            SupportedNumSamples.Add(4096);
            SupportedNumSamples.Add(8192);
            SupportedNumSamples.Add(16384);

        }
        

        public void LoadFile()
        {
            Stream myStream = null;
            Int16 val;
            UInt32 time_offset;
            //Int16[] channel = new Int16[NUM_CHANNELS];
            Double time_calc;
            int pos = 0;
            string packet_display = "";

            Int32 buffer_loc = 0;

            Double SampleCount = 0;


            // Show the dialog and get result.
            Microsoft.Win32.OpenFileDialog openFileDialog1 = new Microsoft.Win32.OpenFileDialog();

            bool? result = openFileDialog1.ShowDialog();
            if (result == true) // Test result.
            {
                if ((myStream = openFileDialog1.OpenFile()) != null)
                {

                    foreach (GraphingData data in GraphData)
                    {
                        data.Channel_AllData.Collection.Clear();
                    }

                    //textBox1.AppendText(openFileDialog1.FileName + " Opened Successfully! File Size: " + myStream.Length + "\r\n"); // <-- For debugging use only.
                    //myStream.Length
                    byte[] buffer = new byte[myStream.Length];
                    // buffer_loc += 32 * NUM_PACKETS;
                    while (buffer_loc < myStream.Length)
                    {
                        //myStream.Read(buffer,
                        myStream.Read(buffer, 0, NUM_PACKETS);
                        byte[] packet = new byte[32];

                        while (pos < NUM_PACKETS)
                        {
                            // packet_display = "";
                            Array.Copy(buffer, pos, packet, 0, 32);
                            /*for (int i = 0; i < 32; i++)
                            {
                                packet[i] = buffer[i + pos];

                                //textBox1.AppendText(packet[i].ToString("X") + " ");
                                //packet_display += packet[i].ToString("X") + " ";

                            }*/



                            val = BitConverter.ToInt16(packet, 0);
                            time_offset = BitConverter.ToUInt32(packet, 2);
                            time_calc = time_offset * .00000002;

                            if (SampleCount == 0)
                            {
                                time_from_start = time_calc;
                                prev_time_calc = time_calc;
                            }
                            else if (time_calc < prev_time_calc)
                            {
                                time_from_start += (4294967296 * .00000002 - prev_time_calc) + time_calc;
                                prev_time_calc = time_calc;
                            }
                            else
                            {
                                time_from_start += time_calc - prev_time_calc;
                                prev_time_calc = time_calc;
                            }

                            //textBox1.AppendText("\r\n\r\nTimeOffset: " + time_calc.ToString("00.000000"));
                            // packet_display += "\r\nTimeOffset: " + time_calc.ToString("00.000000");

                            for (int i = 0; i < ChannelsToGraph; i++)
                            {
                                Int16 raw_voltage = BitConverter.ToInt16(packet, 7 + i * 3);
                                //textBox1.AppendText("\tChannel" + i.ToString() + ": " + (channel[i] / 32768.0 * 5.0).ToString("0.000") + "V\t");
                                // packet_display += "\tChannel" + i.ToString() + ": " + (channel[i] / 32768.0 * 5.0).ToString("0.000") + "V\t";
                                if (raw_voltage == 0) { raw_voltage = 1; }
                                Point p1 = new Point(time_from_start, raw_voltage / 32768.0 * 10.0);
                                GraphData[i].Channel_AllData.Collection.Add(p1);
                            }
                            //textBox1.AppendText(packet_display + "\r\n\r\n");

                            //Point p1 = new Point(time_from_start, channel[0] / 32768.0 * 5.0);
                            //Point p1 = new Point(SampleCount, channel[0] / 32768.0 * 5.0);
                            //Point p1 = new Point(SampleCount, SampleCount);
                            //Channel1_Data.AppendAsync(Dispatcher, p1);
                            //Channel1_Data.Channel_AllData.Collection.Add(p1);
                            //Channel1_Data.Collection.Add(p1);
                            // Thread.Sleep(5);


                            pos += 32;
                            SampleCount++;

                            //plotter.Viewport.FitToView();
                        }
                        buffer_loc += NUM_PACKETS;
                        pos = 0;
                        if (buffer_loc > myStream.Length)
                        {
                        }
                    }



                }
                myStream.Close();
                //System.Text.Encoding.
                /*foreach (Channels temp in Graph_DataGrid.SelectedItems)
                {
                    string channel_name = temp.channel;
                    string[] split = channel_name.Split(' ');
                    int index = Convert.ToInt16(split[1]) - 1;

                    Point[] AllPoints = GraphData[index].Channel_AllData.Collection.ToArray();
                    Point[] GraphPoints = new Point[NUM_SAMPLES_DISPLAYED];
                    Array.Copy(AllPoints, AllPoints.Length - NUM_SAMPLES_DISPLAYED, GraphPoints, 0, NUM_SAMPLES_DISPLAYED);

                    GraphData[index].Channel_GraphData.Collection.AddMany(GraphPoints);
                }*/
                //plotter.Children.RemoveAll<LineGraph>();

                //foreach (GraphingData data in GraphData)
                //{
                //    plotter.AddLineGraph(data.Channel_GraphData);
                //data.SetAllPointArray();

                // }
                //Graph_DataGrid.SelectedIndex = 0;

                //chan1Points = Channel1_Data.Channel_AllData.Collection.ToArray();


                // Point[] points = new Point[NUM_SAMPLES_DISPLAYED];
                //Array.Copy(chan1Points, chan1Points.Length - NUM_SAMPLES_DISPLAYED, points, 0, NUM_SAMPLES_DISPLAYED);


                // Channel1_Data.Channel_GraphData.Collection.AddMany(points);
                //plotter.AddLineGraph(Channel1_Data.Channel_GraphData, 2, "Data row 1");
                //plotter.AddLineGraph(Channel1_Data, 2, "Data row 1");
            }

        }

        //private void Graph_DataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        //{
        //    int selected_view = Convert.ToInt16(slider1.Value);
        //    plotter.Children.RemoveAll<LineGraph>();

        //    foreach (GraphingData data in GraphData)
        //    {
        //        data.Channel_GraphData.Collection.Clear();
        //    }

        //    foreach (Channels temp in Graph_DataGrid.SelectedItems)
        //    {
        //        string channel_name = temp.channel;
        //        string[] split = channel_name.Split(' ');
        //        int index = Convert.ToInt16(split[1]) - 1;

        //        Point[] AllPoints = GraphData[index].Channel_AllData.Collection.ToArray();
        //        Point[] GraphPoints = new Point[NUM_SAMPLES_DISPLAYED];
        //        Array.Copy(AllPoints, selected_view * NUM_SAMPLES_DISPLAYED, GraphPoints, 0, NUM_SAMPLES_DISPLAYED);

        //        //GraphData[index].Channel_GraphData.Collection.Clear();
        //        GraphData[index].Channel_GraphData.AppendMany(GraphPoints);

        //        plotter.AddLineGraph(GraphData[index].Channel_GraphData, 1, temp.channel);
        //    }
        //    plotter.FitToView();
        //}

        //private void slider1_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        //{

        //    int selected_view = Convert.ToInt16(slider1.Value);
        //    ViewSelect_TextBox.Text = Convert.ToInt16(slider1.Value).ToString();

        //    if (selected_view != previous_view)
        //    {
        //        // chan1Points = Channel1_Data.Collection.ToArray();
        //        //Point[] points = new Point[NUM_SAMPLES_DISPLAYED];
        //        //Array.Copy(chan1Points, selected_view * NUM_SAMPLES_DISPLAYED, points, 0, NUM_SAMPLES_DISPLAYED);
        //        //Channel1_Data.Channel_GraphData.Collection.Clear();
        //        //Channel1_Data.Channel_GraphData.AppendMany(points);

        //        foreach (GraphingData data in GraphData)
        //        {
        //            data.Channel_GraphData.Collection.Clear();
        //        }

        //        foreach (Channels temp in Graph_DataGrid.SelectedItems)
        //        {
        //            string channel_name = temp.channel;
        //            string[] split = channel_name.Split(' ');
        //            int index = Convert.ToInt16(split[1]) - 1;

        //            Point[] AllPoints = GraphData[index].Channel_AllData.Collection.ToArray();
        //            Point[] GraphPoints = new Point[NUM_SAMPLES_DISPLAYED];
        //            Array.Copy(AllPoints, selected_view * NUM_SAMPLES_DISPLAYED, GraphPoints, 0, NUM_SAMPLES_DISPLAYED);

        //            //GraphData[index].Channel_GraphData.Collection.Clear();
        //            GraphData[index].Channel_GraphData.AppendMany(GraphPoints);
        //        }
        //        plotter.FitToView();
        //    }
        //    previous_view = selected_view;
        //}


        
        #endregion


    }
}
