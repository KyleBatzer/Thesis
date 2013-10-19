using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.IO.Ports;
using System.ComponentModel;
using System.Windows.Threading;
using System.Runtime.InteropServices;

namespace Data_Acq_and_Stim_Control_Center
{
    public class RS232_Communication : INotifyPropertyChanged
    {
        private readonly SynchronizationContext syncContext;
        private readonly List<Action<CommunicationLog>> actions;

        SerialPort port;
        public BindingList<CommunicationLog> ComLog;

        public RS232_Communication()
        {
            syncContext = AsyncOperationManager.SynchronizationContext;
            actions = new List<Action<CommunicationLog>>();
            actions.Add(t => AddToComLog(t));


            ComLog = new BindingList<CommunicationLog>();

            // Instantiate the communications port with some basic settings 
            port = new SerialPort("COM4", 115200, Parity.None, 8, StopBits.One);

            PortStatus = "RS232 Port not Initialized - Select Comm Port!";

            // Attach a method to be called when there
            // is data waiting in the port's buffer 
            port.DataReceived += new SerialDataReceivedEventHandler(port_DataReceived);
        }

        private void AddToComLog(CommunicationLog temp)
        {
            ComLog.Add(temp);
        }

        public bool Init_Port()
        {
            if (port.IsOpen)
            {
                port.Close();
            }
            port.PortName = PortName;

            try
            {
                port.Open();
                PortStatus = PortName + " Opened Successfully!";
                return true;
            }
            catch { PortStatus = PortName + " not opened!"; return false; }
        }

        public void SendData(byte[] msg)
        {
            string temp = "";

            for (int i = 0; i < msg.Length; i++)
            {
                temp += "0x" + msg[i].ToString("X2") + " ";
            }

            try
            {
                port.Write(msg, 0, msg.Length);
                syncContext.Post(t => RS232Data_Received((CommunicationLog)t), new CommunicationLog(DateTime.Now.ToString("MM/dd/yyyy HH:mm:ss.fff"), temp, ""));
            }
            catch 
            {
                syncContext.Post(t => RS232Data_Received((CommunicationLog)t), new CommunicationLog(DateTime.Now.ToString("MM/dd/yyyy HH:mm:ss.fff"), "Error writing to port!", ""));
                //ComLog.Add(new CommunicationLog(DateTime.Now.ToString("MM/dd/yyyy HH:mm:ss.fff"), "Error writing to port!", "")); 
            }
        }


        /*****************************************************************************************************
         * RS232 Data Received Event
         * 
         * Update RS232 Communication Log with received data
        /*****************************************************************************************************/
        private void port_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            // Show all the incoming data in the port's buffer 
            Thread.Sleep(100);
            byte[] buf = new byte[255];
            int bytes_to_read = port.BytesToRead;
            port.Read(buf, 0, bytes_to_read);

            string temp = "";

            for (int i = 0; i < bytes_to_read; i++)
            {
                temp += "0x" + buf[i].ToString("X2") + " ";
            }
            //this.Dispatcher.Invoke(DispatcherPriority.Normal, (Action)(() =>
            //{
                //ComLog.Add(new CommunicationLog(DateTime.Now.ToString("MM/dd/yyyy HH:mm:ss.fff"), "", temp));
            //}));
            syncContext.Post(t => RS232Data_Received((CommunicationLog)t), new CommunicationLog(DateTime.Now.ToString("MM/dd/yyyy HH:mm:ss.fff"), "", temp));
        }

        private void RS232Data_Received(CommunicationLog data)
        {
            foreach (var action in actions)
                action(data);
        }

        private string _portStatus;
        public string PortStatus
        {
            get { return _portStatus; }
            set
            {
                _portStatus = value;
                this.NotifyPropertyChanged("PortStatus");
            }
        }

        private string _portName;
        public string PortName
        {
            get { return _portName; }
            set
            {
                _portName = value;
                this.NotifyPropertyChanged("PortName");
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        private void NotifyPropertyChanged(string name)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, new PropertyChangedEventArgs(name));
        }
    }

/*****************************************************************************************************
 * Communication Log class
 * 
 * contains configuration information for channels
/*****************************************************************************************************/
    public class CommunicationLog : INotifyPropertyChanged
    {
        private string _Timestamp;
        private string _Send;
        private string _Receive;

        public event PropertyChangedEventHandler PropertyChanged;

        public CommunicationLog(string Timestamp, string Send, string Receive)
        {
            _Timestamp = Timestamp;
            _Send = Send;
            _Receive = Receive;
        }

        public string Timestamp
        {
            get { return _Timestamp; }
            set
            {
                _Timestamp = value;
                this.NotifyPropertyChanged("Timestamp");
            }
        }

        public string Send
        {
            get { return _Send; }
            set
            {
                _Send = value;
                this.NotifyPropertyChanged("Send");
            }
        }

        public string Receive
        {
            get { return _Receive; }
            set
            {
                _Receive = value;
                this.NotifyPropertyChanged("Receive");
            }
        }

        private void NotifyPropertyChanged(string name)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, new PropertyChangedEventArgs(name));
        }
    }
}
