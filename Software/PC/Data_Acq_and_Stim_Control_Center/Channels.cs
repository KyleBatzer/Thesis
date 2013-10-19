using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace Data_Acq_and_Stim_Control_Center
{
    /*****************************************************************************************************
 * Channels class
 * 
 * contains configuration information for channels
/*****************************************************************************************************/
    public class Channels : INotifyPropertyChanged
    {
        private string _channel;
        private string _waveform_file;
        private string _mode;
        private string _sw1;
        private string _sw2;
        private string _sw3;
        private string _sw4;

        public event PropertyChangedEventHandler PropertyChanged;

        public Channels(string channel, string waveform_file, string mode)
        {
            _channel = channel;
            _waveform_file = waveform_file;
            _mode = mode;
            if (mode == "Stimulation")
            {
                _sw1 = "On";
                _sw2 = "On";
                _sw3 = "On";
                _sw4 = "On";
            }
            else
            {
                _sw1 = "Off";
                _sw2 = "Off";
                _sw3 = "Off";
                _sw4 = "Off";
            }
        }

        public string channel
        {
            get { return _channel; }
            set
            {
                _channel = value;
                this.NotifyPropertyChanged("channel");
            }
        }

        public string waveform_file
        {
            get { return _waveform_file; }
            set
            {
                _waveform_file = value;
                this.NotifyPropertyChanged("waveform_file");
            }
        }

        public string mode
        {
            get { return _mode; }
            set
            {
                _mode = value;
                this.NotifyPropertyChanged("mode");
            }
        }

        public string sw1
        {
            get { return _sw1; }
            set
            {
                _sw1 = value;
                this.NotifyPropertyChanged("sw1");
            }
        }

        public string sw2
        {
            get { return _sw2; }
            set
            {
                _sw2 = value;
                this.NotifyPropertyChanged("sw2");
            }
        }

        public string sw3
        {
            get { return _sw3; }
            set
            {
                _sw3 = value;
                this.NotifyPropertyChanged("sw3");
            }
        }

        public string sw4
        {
            get { return _sw4; }
            set
            {
                _sw4 = value;
                this.NotifyPropertyChanged("sw4");
            }
        }

        private void NotifyPropertyChanged(string name)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, new PropertyChangedEventArgs(name));
        }
    }
}
