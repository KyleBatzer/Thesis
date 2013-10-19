using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Threading;
using System.ComponentModel;

namespace Data_Acq_and_Stim_Control_Center
{
    public class Scripting : INotifyPropertyChanged
    {
        //public delegate void StartAcquisitionHandler(object sender, EventArgs e);
        //public event StartAcquisitionHandler StartAcquisitionEvent;

        //public delegate void EndAcquisitionHandler(object sender, EventArgs e);
        //public event EndAcquisitionHandler EndAcquisitionEvent;

        #region SynchronizationContext - Script_Command_To_Main

        private readonly SynchronizationContext syncContext;
        private readonly List<Action<String>> actions;

        private void Script_Command_To_Main(String data)
        {
            foreach (var action in actions)
                action(data);
        }

        public void Register(Action<string> action)
        {
            actions.Add(action);
        }
        #endregion //SynchronizationContext - Script_Command_To_Main


        public Scripting()
        {
            syncContext = AsyncOperationManager.SynchronizationContext;
            actions = new List<Action<string>>();
        }

        public void StartScript()
        {
            var thread = new Thread(RunScript);
            thread.IsBackground = true;
            thread.Start();
        }

        private void RunScript()
        {
            string[] commands = (ScriptText).Split(new String[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string str in commands)
            {
                if (str.StartsWith("SetConfig(")) { SetConfig(str); }
                else if (str.StartsWith("GetConfig(")) { GetConfig(str); }
                else if (str.StartsWith("SetWaveform(")) { SetWaveform(str); }
                else if (str.StartsWith("GetWaveform(")) { GetWaveform(str); }
                else if (str.StartsWith("StartAcquisition(")) {
                    syncContext.Post(e => Script_Command_To_Main((string)e), "StartAcquisition");
                                                                //MainWindow.fpga_control.FPGA_StartAcquisition(); 
                }
                else if (str.StartsWith("EndAcquisition(")){ syncContext.Post(e => Script_Command_To_Main((string)e), "EndAcquisition"); 
                                                                //MainWindow.fpga_control.FPGA_EndAcquisition(); 
                }
                else if (str.StartsWith("SingleStim(")) { SingleStim(str); }
                else if (str.StartsWith("StartMultiStim(")) { StartMultiStim(str); }
                else if (str.StartsWith("EndMultiStim(")) { MainWindow.fpga_control.FPGA_EndMuliStim(); }
                else if (str.StartsWith("Sleep(")) { SleepCmd(str); }
                else { }
            }
        }

        private void SetConfig(string str)
        {
            int payloadStart = str.IndexOf('(') + 1;
            int payloadEnd = str.IndexOf(')') - 1;
            int payloadLength = payloadEnd - payloadStart + 1;
            string[] payload = (str.Substring(payloadStart, payloadLength)).Split(',');

            if (payload[0].Length == 1) { payload[0] = "0" + payload[0]; }
            if (payload[1].Length == 1) { payload[1] = "0" + payload[0]; }

            Byte Channel = Convert.ToByte((ToNibble(payload[0][0]) << 4) + ToNibble(payload[0][1]));
            Byte Config = Convert.ToByte((ToNibble(payload[1][0]) << 4) + ToNibble(payload[1][1]));

            MainWindow.fpga_control.FPGA_SetConfig(Channel, Config);
        }

        private void GetConfig(string str)
        {
            int payloadStart = str.IndexOf('(') + 1;
            int payloadEnd = str.IndexOf(')') - 1;
            int payloadLength = payloadEnd - payloadStart + 1;
            string[] payload = (str.Substring(payloadStart, payloadLength)).Split(',');

            if (payload[0].Length == 1) { payload[0] = "0" + payload[0]; }

            Byte Channel = Convert.ToByte((ToNibble(payload[0][0]) << 4) + ToNibble(payload[0][1]));

            MainWindow.fpga_control.FPGA_GetConfig(Channel);
        }

        private void SetWaveform(string str)
        {
            int payloadStart = str.IndexOf('(') + 1;
            int payloadEnd = str.IndexOf(')') - 1;
            int payloadLength = payloadEnd - payloadStart + 1;
            string[] payload = (str.Substring(payloadStart, payloadLength)).Split(',');

            if (payload[0].Length == 1) { payload[0] = "0" + payload[0]; }

            Byte Channel = Convert.ToByte((ToNibble(payload[0][0]) << 4) + ToNibble(payload[0][1]));

            string Filename = payload[1];

            MainWindow.fpga_control.FPGA_SetWaveform(Channel, Filename);
        }

        private void GetWaveform(string str)
        {
            int payloadStart = str.IndexOf('(') + 1;
            int payloadEnd = str.IndexOf(')') - 1;
            int payloadLength = payloadEnd - payloadStart + 1;
            string[] payload = (str.Substring(payloadStart, payloadLength)).Split(',');

            if (payload[0].Length == 1) { payload[0] = "0" + payload[0]; }

            Byte Channel = Convert.ToByte((ToNibble(payload[0][0]) << 4) + ToNibble(payload[0][1]));

            MainWindow.fpga_control.FPGA_GetWaveform(Channel);
        }

        private void StartMultiStim(string str)
        {
            int payloadStart = str.IndexOf('(') + 1;
            int payloadEnd = str.IndexOf(')') - 1;
            int payloadLength = payloadEnd - payloadStart + 1;
            string[] payload = (str.Substring(payloadStart, payloadLength)).Split(',');

            if (payload[0].Length == 1) { payload[0] = "0" + payload[0]; }

            Byte Channel = Convert.ToByte((ToNibble(payload[0][0]) << 4) + ToNibble(payload[0][1]));

            MainWindow.fpga_control.FPGA_StartMultiStim(Channel);
        }

        private void SingleStim(string str)
        {
            int payloadStart = str.IndexOf('(') + 1;
            int payloadEnd = str.IndexOf(')') - 1;
            int payloadLength = payloadEnd - payloadStart + 1;
            string[] payload = (str.Substring(payloadStart, payloadLength)).Split(',');

            if (payload[0].Length == 1) { payload[0] = "0" + payload[0]; }

            Byte Channel = Convert.ToByte((ToNibble(payload[0][0]) << 4) + ToNibble(payload[0][1]));

            MainWindow.fpga_control.FPGA_SingleStim(Channel);
        }

        private void SleepCmd(string str)
        {
            int payloadStart = str.IndexOf('(') + 1;
            int payloadEnd = str.IndexOf(')') - 1;
            int payloadLength = payloadEnd - payloadStart + 1;
            Int16 sleep = Convert.ToInt16(str.Substring(payloadStart, payloadLength));
            //Wait(sleep);
            Thread.Sleep(sleep);
        }

        private byte ToNibble(char c)
        {
            if ('0' <= c && c <= '9') { return Convert.ToByte(c - '0'); }
            else if ('a' <= c && c <= 'f') { return Convert.ToByte(c - 'a' + 10); }
            else if ('A' <= c && c <= 'F') { return Convert.ToByte(c - 'A' + 10); }
            else
            {
                throw new ArgumentException(String.Format("Character '{0}' cannot be translated to a hexadecimal value because it is not one of 0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,A,B,C,D,E,F", c));
            }
        }

        private string _scriptText;
        public string ScriptText
        {
            get { return _scriptText; }
            set
            {
                _scriptText = value;
                this.NotifyPropertyChanged("ScriptText");
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        private void NotifyPropertyChanged(string name)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, new PropertyChangedEventArgs(name));
        }

    }
}
