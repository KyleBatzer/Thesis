using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.IO;

namespace Data_Acq_and_Stim_Control_Center
{
    public class FPGA_Commands
    {
        public RS232_Communication RS232_Com;


        public FPGA_Commands()
        {
            RS232_Com = new RS232_Communication();
        }

        public void FPGA_SetConfig(Byte Channel, Byte Config)
        {
            byte length_h = 0x00;
            byte length_l = 0x07;
            byte checksum = 0x00;

            // Build Message
            byte[] msg = new byte[] { 0x5A, 0x01, length_h, length_l, Channel, Config, checksum };

            // Calculate Checksum
            for (int j = 0; j < msg.Length - 1; j++)
            {
                checksum += msg[j];
            }
            msg[msg.Length - 1] = checksum;

            // Send Message
            RS232_Com.SendData(msg);
        }

        public void FPGA_GetConfig(Byte Channel)
        {
            Byte length_h = 0x00;
            Byte length_l = 0x06;
            Byte checksum = 0x00;

            // Build Message
            byte[] msg = new byte[] { 0x5A, 0x02, length_h, length_l, Channel, checksum };

            // Calculate Checksum
            for (int j = 0; j < msg.Length - 1; j++)
            {
                checksum += msg[j];
            }
            msg[msg.Length - 1] = checksum;

            // Send Message
            RS232_Com.SendData(msg);

        }

        public void FPGA_SetWaveform(Byte Channel, string Filename)
        {
            List<Byte> wave_data = new List<Byte>();

            try
            {
                using (StreamReader sr = new StreamReader(Filename))
                {
                    String line;
                    String[] split_str = new String[2];

                    while ((line = sr.ReadLine()) != null)
                    {
                        //this.Dispatcher.Invoke(DispatcherPriority.Normal, (Action)(() =>
                        //{
                        //    textBox1.AppendText(line + "\r\n");
                        //}));

                        split_str = line.Split(',');
                        string temp1 = split_str[0].Substring(0, 2);
                        string temp2 = split_str[0].Substring(2, 2);
                        string temp3 = split_str[1].Substring(0, 2);
                        string temp4 = split_str[1].Substring(2, 2);
                        wave_data.Add(Convert.ToByte((ToNibble(temp1[0]) << 4) + ToNibble(temp1[1])));
                        wave_data.Add(Convert.ToByte((ToNibble(temp2[0]) << 4) + ToNibble(temp2[1])));
                        wave_data.Add(Convert.ToByte((ToNibble(temp3[0]) << 4) + ToNibble(temp3[1])));
                        wave_data.Add(Convert.ToByte((ToNibble(temp4[0]) << 4) + ToNibble(temp4[1])));

                        //port.WriteLine();
                    }
                }
                byte[] newarray = wave_data.ToArray();

                byte[] msg_buf = new byte[7 + wave_data.Count];
                msg_buf[0] = 0x5A;                                              // Start Byte
                msg_buf[1] = 0x05;                                              // MSG_ID
                msg_buf[2] = 0x00;                                              // Length_High
                msg_buf[3] = Convert.ToByte(7 + wave_data.Count);               // Length_Low
                msg_buf[4] = Channel;                                           // Channel
                msg_buf[5] = Convert.ToByte(wave_data.Count / 4);               // Samples
                newarray.CopyTo(msg_buf, 6);
                msg_buf[msg_buf[3] - 1] = 0xFF;

                // Send Message
                RS232_Com.SendData(msg_buf);
            }
            catch { }
        }

        public void FPGA_GetWaveform(Byte Channel)
        {
            byte length_h = 0x00;
            byte length_l = 0x06;
            //byte channel = Convert.ToByte(setWaveChan_CB.SelectedIndex + 1);
            byte checksum = 0x00;

            // Build Message
            byte[] msg_buf = new byte[] { 0x5A, 0x06, length_h, length_l, Channel, checksum };

            // Calculate Checksum
            for (int j = 0; j < msg_buf.Length - 1; j++)
            {
                checksum += msg_buf[j];
            }
            msg_buf[msg_buf.Length - 1] = checksum;

            // Send Message
            RS232_Com.SendData(msg_buf);
        }

        public void FPGA_StartAcquisition()
        {
            // Adding call to start cypress acquisition
            //MainWindow.CypressDA.Start_Cypress_Acq();
            //Start_Cypress_Acq();

            // Temporary Start Acq
            byte[] temp_start_msg = new byte[] { 0x5A, 0x01, 0x00, 0x07, 0x01, 0x9F, 0xFF };

            // Send command
            RS232_Com.SendData(temp_start_msg);

        }

        public void FPGA_EndAcquisition()
        {
            // Adding call to stop cypress acquisition
            //MainWindow.CypressDA.Stop_Cypress_Acq();
            //Stop_Cypress_Acq();

            // Temporary Start Acq
            byte[] temp_end_msg = new byte[] { 0x5A, 0x01, 0x00, 0x07, 0x01, 0x1F, 0xFF };

            // Send command
            RS232_Com.SendData(temp_end_msg);
        }

        public void FPGA_StartMultiStim(Byte Channel)
        {
            byte length_h = 0x00;
            byte length_l = 0x07;
            byte continuous = Channel;
            byte checksum = 0x00;

            // Build Message
            byte[] msg = new byte[] { 0x5A, 0x07, length_h, length_l, Channel, continuous, checksum };

            // Calculate Checksum
            for (int j = 0; j < msg.Length - 1; j++)
            {
                checksum += msg[j];
            }
            msg[msg.Length - 1] = checksum;

            // Send Message
            RS232_Com.SendData(msg);
        }

        public void FPGA_EndMuliStim()
        {
            byte length_h = 0x00;
            byte length_l = 0x07;
            byte channel = 0x00;
            byte continuous = 0x00;
            byte checksum = 0x00;

            // Build Message
            byte[] msg = new byte[] { 0x5A, 0x07, length_h, length_l, channel, continuous, checksum };

            // Calculate Checksum
            for (int j = 0; j < msg.Length - 1; j++)
            {
                checksum += msg[j];
            }
            msg[msg.Length - 1] = checksum;

            // Send Message
            RS232_Com.SendData(msg);
        }

        public void FPGA_SingleStim(Byte Channel)
        {
            byte length_h = 0x00;
            byte length_l = 0x07;
            byte continuous = 0x00;
            byte checksum = 0x00;

            // Build Message
            byte[] msg = new byte[] { 0x5A, 0x07, length_h, length_l, Channel, continuous, checksum };

            // Calculate Checksum
            for (int j = 0; j < msg.Length - 1; j++)
            {
                checksum += msg[j];
            }
            msg[msg.Length - 1] = checksum;

            // Send Message
            RS232_Com.SendData(msg);
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
    }
}
