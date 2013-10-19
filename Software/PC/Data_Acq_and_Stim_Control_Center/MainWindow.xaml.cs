using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.IO;
using System.Windows.Forms;
using System.Threading;
using System.ComponentModel;
using System.Windows.Threading;
using CyUSB;
using Microsoft.Research.DynamicDataDisplay;
using Microsoft.Research.DynamicDataDisplay.DataSources;

namespace Data_Acq_and_Stim_Control_Center
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        int NUM_CHANNELS;
        Scripting script;
        public static FPGA_Commands fpga_control;
        string[] theSerialPortNames;
        BindingList<Channels> Channel_List = new BindingList<Channels>();

        CypressDataAcq CypressDA;
        Graphing graph;
        int previous_graph_view = 0;

        public MainWindow()
        {
            InitializeComponent();

            script = new Scripting();
            fpga_control = new FPGA_Commands();
            graph = new Graphing();
            CypressDA = new CypressDataAcq();

            dataGrid_Comm.ItemsSource = fpga_control.RS232_Com.ComLog;

            channels_CB.SelectedIndex = 7;

            theSerialPortNames = System.IO.Ports.SerialPort.GetPortNames();
            com_CB.DataContext = theSerialPortNames;

            this.Title = "Data Acquisition and Stimlation Control Center - Version 0.1";

            dataGrid1.ItemsSource = Channel_List;

            com_CB.SelectedIndex = 1;

            setWaveChan_CB.ItemsSource = Channel_List;
            setWaveChan_CB.DisplayMemberPath = "channel";
            setWaveChan_CB.SelectedIndex = 0;

            fpga_control.RS232_Com.ComLog.ListChanged += new System.ComponentModel.ListChangedEventHandler(Comm_Log_Changed);

            script_Textbox.DataContext = script;

            EndPointsComboBox.ItemsSource = CypressDA.EndpointList;

            if (EndPointsComboBox.Items.Count > 0)
                EndPointsComboBox.SelectedIndex = 0;

            AcqStatus.DataContext = CypressDA;


            NumSamples_CB.ItemsSource = graph.SupportedNumSamples;
            NumSamples_CB.SelectedIndex = 0;

            Graph_DataGrid.ItemsSource = Channel_List;


            //script.StartAcquisitionEvent += script_StartAcqHandler;
            //script.EndAcquisitionEvent += script_EndAcqHandler;

            script.Register(t => ScriptHandler(t));
        }
        private void ScriptHandler(String str)
        {
            if (str == "StartAcquisition") { acq_triggered(); }
            else if (str == "EndAcquisition") { acq_triggered(); }
        }

        //private void script_StartAcqHandler(object sender, EventArgs e)
        //{
        //    acq_button_Click(this, new RoutedEventArgs());
        //    //CypressDA.Start_Cypress_Acq();
        //}
        //private void script_EndAcqHandler(object sender, EventArgs e)
        //{
        //    acq_button_Click(this, new RoutedEventArgs());
        //    //CypressDA.Stop_Cypress_Acq();
        //}

        #region Config Events
        /*****************************************************************************************************
 * dataGrid1 BeginningEdit Event Handler
 * 
 * Launches OpenFileDialog when attempting to change waveform_file 
/*****************************************************************************************************/
        private void dataGrid1_BeginningEdit(object sender, DataGridBeginningEditEventArgs e)
        {
            if (dataGrid1.CurrentCell.Column.DisplayIndex == 1)
            {
                System.Windows.Forms.OpenFileDialog fd = new System.Windows.Forms.OpenFileDialog();
                fd.ShowDialog();

                if (fd.FileName != "") { Channel_List[dataGrid1.SelectedIndex].waveform_file = fd.FileName; }
            }
        }

        /*****************************************************************************************************
         * Number of Channels Combo Box Event Handler
         * 
         * Update NUM_CHANNELS from combo box and calls Update_Channel_List
        /*****************************************************************************************************/
        private void channels_CB_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            NUM_CHANNELS = Convert.ToInt16(channels_CB.SelectedIndex.ToString()) + 1;
            Update_Channel_List();
            graph.ChannelsToGraph = NUM_CHANNELS;
        }

        /*****************************************************************************************************
         * Number of Channels Combo Box Event Handler
         *  
         * Update NUM_CHANNELS from combo box and calls Update_Channel_List
        /*****************************************************************************************************/
        private void com_CB_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            fpga_control.RS232_Com.PortName = theSerialPortNames[com_CB.SelectedIndex];
            fpga_control.RS232_Com.Init_Port();
        }

        /*****************************************************************************************************
         * Update_Channel_List
         * 
         * Modifies the bindinglist used for storing channel configuration by adding or removing channels
         * until the Channel_List count equals NUM_CHANNELS
        /*****************************************************************************************************/
        private void Update_Channel_List()
        {
            while (Channel_List.Count != NUM_CHANNELS)
            {
                if (Channel_List.Count > NUM_CHANNELS)
                {
                    Channel_List.RemoveAt(Channel_List.Count - 1);
                    graph.GraphData.RemoveAt(graph.GraphData.Count - 1);
                    plotter.Children.RemoveAt(plotter.Children.Count - 1);
                }
                else
                {
                    Channel_List.Add(new Channels("Channel " + (Channel_List.Count + 1).ToString(), "", "Stimulation"));
                    graph.GraphData.Add(new GraphingData());
                    //plotter.AddLineGraph(graph.GraphData[Channel_List.Count - 1].Channel_GraphData);
                }
            }
        }
        #endregion //Config Events

        #region Manual Command Events
        /*****************************************************************************************************
         * SendConfig Button Click Event
         * 
         * Sends SendConfig Message out serial port to FPGA
        /*****************************************************************************************************/
        private void SendConfig_Button_Click(object sender, RoutedEventArgs e)
        {
            Byte channel = Convert.ToByte(setWaveChan_CB.SelectedIndex + 1);
            Byte config = 0x00;

            if (Channel_List[setWaveChan_CB.SelectedIndex].mode == "Stimulation") { config += 0x10; }
            if (Channel_List[setWaveChan_CB.SelectedIndex].sw4 == "On") { config += 0x08; }
            if (Channel_List[setWaveChan_CB.SelectedIndex].sw3 == "On") { config += 0x04; }
            if (Channel_List[setWaveChan_CB.SelectedIndex].sw2 == "On") { config += 0x02; }
            if (Channel_List[setWaveChan_CB.SelectedIndex].sw1 == "On") { config += 0x01; }

            fpga_control.FPGA_SetConfig(channel, config);
        }


        private void acq_button_Click(object sender, RoutedEventArgs e)
        {
            acq_triggered();
        }

        private void acq_triggered()
        {
            if (acq_button.Content.ToString() == "Start Acquisition")
            {
                CypressDA.Flush_Cypress_Chip();

                // Adding call to start cypress acquisition
                CypressDA.Start_Cypress_Acq();

                fpga_control.FPGA_StartAcquisition();

                acq_button.Content = "End Acquisition";

            }
            else
            {
                // Adding call to stop cypress acquisition
                CypressDA.Stop_Cypress_Acq();

                fpga_control.FPGA_EndAcquisition();

                acq_button.Content = "Start Acquisition";
            }
        }

        private void setWave_button_Click(object sender, RoutedEventArgs e)
        {
            Byte Channel = Convert.ToByte(setWaveChan_CB.SelectedIndex + 1);
            String Filename = Channel_List[setWaveChan_CB.SelectedIndex].waveform_file;

            fpga_control.FPGA_SetWaveform(Channel, Filename);
        }

        private void getWave_button_Click(object sender, RoutedEventArgs e)
        {
            Byte Channel = Convert.ToByte(setWaveChan_CB.SelectedIndex + 1);

            fpga_control.FPGA_GetWaveform(Channel);
        }

        private void StartMuliStim_Button_Click(object sender, RoutedEventArgs e)
        {
            int chan_index = setWaveChan_CB.SelectedIndex;
            Byte channel = 0x00;

            // Set Channel
            if (chan_index == 0) { channel = 0x01; }
            else if (chan_index == 1) { channel = 0x02; }
            else if (chan_index == 2) { channel = 0x04; }
            else if (chan_index == 3) { channel = 0x08; }
            else if (chan_index == 4) { channel = 0x10; }
            else if (chan_index == 5) { channel = 0x20; }
            else if (chan_index == 6) { channel = 0x40; }
            else if (chan_index == 7) { channel = 0x80; }

            fpga_control.FPGA_StartMultiStim(channel);
        }

        private void EndMuliStim_Button_Click(object sender, RoutedEventArgs e)
        {
            fpga_control.FPGA_EndMuliStim();
        }

        private void SingleStim_Button_Click(object sender, RoutedEventArgs e)
        {
            int chan_index = setWaveChan_CB.SelectedIndex;
            byte channel = 0x00;

            // Set Channel and Continuous
            if (chan_index == 0) { channel = 0x01; }
            else if (chan_index == 1) { channel = 0x02; }
            else if (chan_index == 2) { channel = 0x04; }
            else if (chan_index == 3) { channel = 0x08; }
            else if (chan_index == 4) { channel = 0x10; }
            else if (chan_index == 5) { channel = 0x20; }
            else if (chan_index == 6) { channel = 0x40; }
            else if (chan_index == 7) { channel = 0x80; }

            fpga_control.FPGA_SingleStim(channel);
        }
        #endregion //Manual Command Controls

        #region Scripting Events
        private void SaveAsScript_Button_Click(object sender, RoutedEventArgs e)
        {
            System.Windows.Forms.SaveFileDialog fd = new System.Windows.Forms.SaveFileDialog();
            fd.ShowDialog();

            try
            {
                using (StreamWriter sw = new StreamWriter(fd.FileName))
                {
                    sw.Write(script.ScriptText);
                }

            }
            catch { }
        }


        private void LoadScript_Button_Click(object sender, RoutedEventArgs e)
        {
            System.Windows.Forms.OpenFileDialog fd = new System.Windows.Forms.OpenFileDialog();
            fd.ShowDialog();

            script_Textbox.Text = "";

            try
            {
                using (StreamReader sr = new StreamReader(fd.FileName))
                {
                    while (!sr.EndOfStream)
                    {
                        //sr.ReadLine();
                        script.ScriptText += sr.ReadLine() + "\r\n";
                    }

                }

            }
            catch { }
        }

        private void RunScript_Button_Click(object sender, RoutedEventArgs e)
        {
            script.StartScript();
        }


        #endregion // Scripting Controls


        private void Comm_Log_Changed(object sender, EventArgs e)
        {
            if (dataGrid_Comm.Items.Count > 2)
            {
                dataGrid_Comm.ScrollIntoView(dataGrid_Comm.Items[dataGrid_Comm.Items.Count - 1]);
            }
        }

        private void Window_Closing(object sender, CancelEventArgs e)
        {
            if (CypressDA.usbDevices != null)
                CypressDA.usbDevices.Dispose();
        }

        /*Summary
         This is a system event handler, when the selected index changes(end point selection).
        */
        private void EndPointsComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            CypressDA.SetEndpoint(EndPointsComboBox.SelectedIndex);
        }

        #region graphing events
        private void Graph_DataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            graph.CurrentView = Convert.ToInt16(slider1.Value);
            plotter.Children.RemoveAll<LineGraph>();

            foreach (GraphingData data in graph.GraphData)
            {
                data.Channel_GraphData.Collection.Clear();
            }

            foreach (Channels temp in Graph_DataGrid.SelectedItems)
            {
                string channel_name = temp.channel;
                string[] split = channel_name.Split(' ');
                int index = Convert.ToInt16(split[1]) - 1;

                Point[] AllPoints = graph.GraphData[index].Channel_AllData.Collection.ToArray();

                int points_to_graph = 0; //The last view could have fewer points than SamplesPerView
                while (AllPoints.Length < graph.SamplesPerView)
                {
                    NumSamples_CB.SelectedIndex--;
                }

                if (graph.CurrentView == slider1.Maximum)
                {
                    points_to_graph = AllPoints.Length - graph.CurrentView * graph.SamplesPerView;
                }
                else
                {
                    points_to_graph = graph.SamplesPerView;
                }

                Point[] GraphPoints = new Point[points_to_graph];
                Array.Copy(AllPoints, graph.CurrentView * graph.SamplesPerView, GraphPoints, 0, points_to_graph);

                //graph.GraphData[index].Channel_GraphData.Collection.Clear();
                graph.GraphData[index].Channel_GraphData.AppendMany(GraphPoints);

                plotter.AddLineGraph(graph.GraphData[index].Channel_GraphData, 1, temp.channel);
            }
            plotter.FitToView();
        }

        private void slider1_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            graph.CurrentView = Convert.ToInt16(slider1.Value);
            ViewSelect_TextBox.Text = Convert.ToInt16(slider1.Value).ToString();

            if (graph.CurrentView != previous_graph_view)
            {
                // chan1Points = Channel1_Data.Collection.ToArray();
                //Point[] points = new Point[NUM_SAMPLES_DISPLAYED];
                //Array.Copy(chan1Points, selected_view * NUM_SAMPLES_DISPLAYED, points, 0, NUM_SAMPLES_DISPLAYED);
                //Channel1_Data.Channel_GraphData.Collection.Clear();
                //Channel1_Data.Channel_GraphData.AppendMany(points);

                foreach (GraphingData data in graph.GraphData)
                {
                    data.Channel_GraphData.Collection.Clear();
                }

                foreach (Channels temp in Graph_DataGrid.SelectedItems)
                {
                    string channel_name = temp.channel;
                    string[] split = channel_name.Split(' ');
                    int index = Convert.ToInt16(split[1]) - 1;

                    Point[] AllPoints = graph.GraphData[index].Channel_AllData.Collection.ToArray();

                    int points_to_graph = 0; //The last view could have fewer points than SamplesPerView
                    while (AllPoints.Length < graph.SamplesPerView)
                    {
                        NumSamples_CB.SelectedIndex--;
                    }

                    if (graph.CurrentView == slider1.Maximum)
                    {
                        points_to_graph = AllPoints.Length - graph.CurrentView * graph.SamplesPerView;
                    }
                    else
                    {
                        points_to_graph = graph.SamplesPerView;
                    }


                    Point[] GraphPoints = new Point[points_to_graph];
                    Array.Copy(AllPoints, graph.CurrentView * graph.SamplesPerView, GraphPoints, 0, points_to_graph);

                    //GraphData[index].Channel_GraphData.Collection.Clear();
                    graph.GraphData[index].Channel_GraphData.AppendMany(GraphPoints);
                }
                plotter.FitToView();
            }
            previous_graph_view = graph.CurrentView;
        }

        private void LoadFile_Button_Click(object sender, RoutedEventArgs e)
        {
            // Start computation process in second thread
            /*Thread simThread = new Thread(new ThreadStart(LoadFile));
            simThread.IsBackground = true;
            simThread.Start();*/
            try
            {
                graph.LoadFile();
                //NumSamples_CB_SelectionChanged();
                Graph_DataGrid.SelectedIndex = 0;

                NumSamples_CB_SelectionChanged();

                //graph.SamplesPerView = graph.SupportedNumSamples[NumSamples_CB.SelectedIndex];

                //if (graph.GraphData[Graph_DataGrid.SelectedIndex].Channel_AllData.Collection.Count % graph.SamplesPerView == 0)
                //{
                //    slider1.Maximum = graph.TotalViews - 1;
                //}
                //else { slider1.Maximum = graph.TotalViews; }

                //slider1.Minimum = 0;
                ////slider1.Maximum = graph.TotalViews - 1;
                //slider1.Value = slider1.Maximum;
            }
            catch { }
        }

        private void NumSamples_CB_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            graph.SamplesPerView = graph.SupportedNumSamples[NumSamples_CB.SelectedIndex];



            if (graph.GraphData[0].Channel_AllData.Collection.Count != 0)
            {
                while (graph.GraphData[0].Channel_AllData.Collection.Count < graph.SamplesPerView)
                {
                    NumSamples_CB.SelectedIndex--;
                }

                graph.TotalViews = graph.GraphData[Graph_DataGrid.SelectedIndex].Channel_AllData.Collection.Count / graph.SamplesPerView;
                slider1.Minimum = 0;

                if (graph.GraphData[Graph_DataGrid.SelectedIndex].Channel_AllData.Collection.Count % graph.SamplesPerView == 0)
                {
                    slider1.Maximum = graph.TotalViews - 1;
                }
                else { slider1.Maximum = graph.TotalViews; }

                slider1.Value = slider1.Maximum;
            }
        }


        private void NumSamples_CB_SelectionChanged()
        {
            graph.SamplesPerView = graph.SupportedNumSamples[NumSamples_CB.SelectedIndex];



            if (graph.GraphData[0].Channel_AllData.Collection.Count != 0)
            {
                while (graph.GraphData[0].Channel_AllData.Collection.Count < graph.SamplesPerView)
                {
                    NumSamples_CB.SelectedIndex--;
                }

                graph.TotalViews = graph.GraphData[Graph_DataGrid.SelectedIndex].Channel_AllData.Collection.Count / graph.SamplesPerView;
                slider1.Minimum = 0;

                if (graph.GraphData[Graph_DataGrid.SelectedIndex].Channel_AllData.Collection.Count % graph.SamplesPerView == 0)
                {
                    slider1.Maximum = graph.TotalViews - 1;
                }
                else { slider1.Maximum = graph.TotalViews; }

                slider1.Value = slider1.Maximum;
            }
        }

        #endregion // graphing events



        private void clearContext_Click(object sender, RoutedEventArgs e)
        {
            fpga_control.RS232_Com.ComLog.Clear();
        }

        private void Output_CSV_Button_Click(object sender, RoutedEventArgs e)
        {
            System.Windows.Forms.SaveFileDialog fd = new System.Windows.Forms.SaveFileDialog();
            fd.ShowDialog();

            try
            {
                using (StreamWriter sw = new StreamWriter(fd.FileName))
                {
                   
                    sw.WriteLine("Time,Channel1,Channel2,Channel3,Channel4,Channel5,Channel6,Channel7,Channel8");

                    int j = 0;

                    for(int i = 0; i < graph.GraphData[0].Channel_AllData.Collection.Count; i++)
                    {
                        sw.Write("{0},", graph.GraphData[0].Channel_AllData.Collection[i].X);
                        for(j = 0; j < graph.GraphData.Count; j++)
                        {
                            sw.Write("{0},", graph.GraphData[j].Channel_AllData.Collection[i].Y);
                        }
                        sw.WriteLine("");
                    }

                    
                }

            }
            catch { }
        }


    }
    
}
