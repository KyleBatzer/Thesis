using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Threading;
using CyUSB;
using System.IO;
using System.ComponentModel;
using System.Windows.Forms;
using System.Windows.Threading;

namespace Data_Acq_and_Stim_Control_Center
{
    public class CypressDataAcq : INotifyPropertyChanged
    {
        #region data_acq globals
        bool bVista;
        private System.Diagnostics.PerformanceCounter CpuCounter;

        public const uint DIGCF_PRESENT = 0x00000002;
        public const uint DIGCF_INTERFACE_DEVICE = 0x00000010;
        public const int FILE_FLAG_OVERLAPPED = 0x40000000;
        public static IntPtr INVALID_HANDLE = new IntPtr(-1);

        public static Guid DrvGuid = new Guid("{0xae18aa60, 0x7f6a, 0x11d4, {0x97, 0xdd, 0x0, 0x1, 0x2, 0x29, 0xb9, 0x59}}");

        IntPtr hDevice;


        [DllImport("setupapi.dll", SetLastError = true)]
        public static extern IntPtr SetupDiGetClassDevs(
            ref Guid ClassGuid,
            uint Enumerator,
            IntPtr hwndParent,
            uint Flags);

        [DllImport("setupapi.dll", SetLastError = true)]
        public static extern bool SetupDiEnumDeviceInterfaces(
            IntPtr DeviceInfoList,
            uint DeviceInfoData,
            ref Guid InterfaceClassGuid,
            uint MemberIndex,
            SP_DEVICE_INTERFACE_DATA DevInterfaceData);

        [DllImport("setupapi.dll", SetLastError = true)]
        public static extern bool SetupDiGetDeviceInterfaceDetail(
            IntPtr DeviceInfoSet,
            SP_DEVICE_INTERFACE_DATA DevInterfaceData,
            byte[] DetailData,
            int DataSize,
            ref int RequiredSize,
            SP_DEVINFO_DATA DeviceInfoData);

        [DllImport("setupapi.dll", SetLastError = true)]
        public static extern bool SetupDiDestroyDevInfoList(
            IntPtr DeviceInfoSet);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr CreateFile(
            byte[] filename,
            [MarshalAs(UnmanagedType.U4)]FileAccess fAccess,
            [MarshalAs(UnmanagedType.U4)]FileShare fShare,
            int secturityAttributes,
            [MarshalAs(UnmanagedType.U4)]FileMode fMode,
            int flags,
            IntPtr template);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool CloseHandle(
            IntPtr hObject);

        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true, CharSet = CharSet.Auto)]
        static extern bool DeviceIoControl(
            IntPtr hDevice,
            uint IoControlCode,
            byte[] InBuffer,
            int InBufSize,
            byte[] lpOutBuffer,
            int OutBufSize,
            ref int BytesReturned,
            OVERLAP OverLapped);



        FileStream file;
        static int DATA_BUF_SIZE = 8388608;
        static int MAX_FILE_SIZE = 102400000;
        byte[] data_buffer_1 = new byte[DATA_BUF_SIZE];
        byte[] data_buffer_2 = new byte[DATA_BUF_SIZE];
        int data_buf1_pos = 0;
        int data_buf2_pos = 0;
        int active_buffer = 1;
        Thread tFileWrite;
        string file_name = "C:\\DumpData\\data_out";
        int current_file = 0;

        public BindingList<string> EndpointList = new BindingList<string>();

        // CyUSBDevice MyDevice2;


        public USBDeviceList usbDevices;
        public CyUSBDevice MyDevice;
        public CyUSBEndPoint EndPoint;

        DateTime t1, t2;
        TimeSpan elapsed;
        double XferBytes;
        long xferRate;

        int BufSz;
        //int QueueSz;
        //int PPX;
        int IsoPktBlockSize;
        int Successes;
        int Failures;

        Thread tListen;
        bool bRunning;

        // These are  needed for Thread to update the UI
        delegate void UpdateUICallback();
        UpdateUICallback updateUI;

        // These are needed to close the app from the Thread exception(exception handling)
        delegate void ExceptionCallback();
        ExceptionCallback handleException;
        #endregion

        private string _TransferStatusText;
        public string TransferStatusText
        {
            get { return _TransferStatusText; }
            set
            {
                _TransferStatusText = value;
                this.NotifyPropertyChanged("TransferStatusText");
            }
        }

        private int _TransferTimeout;
        public int TransferTimeout
        {
            get { return _TransferTimeout; }
            set
            {
                _TransferTimeout = value;
                this.NotifyPropertyChanged("TransferTimeout");
            }
        }

        private int _ppx;
        public int PPX
        {
            get { return _ppx; }
            set
            {
                _ppx = value;
                this.NotifyPropertyChanged("PPX");
            }
        }

        private int _QueueSz;
        public int QueueSz
        {
            get { return _QueueSz; }
            set
            {
                _QueueSz = value;
                this.NotifyPropertyChanged("QueueSz");
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        private void NotifyPropertyChanged(string name)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, new PropertyChangedEventArgs(name));
        }

        public CypressDataAcq()
        {
            PPX = 64;
            QueueSz = 64;

            // Setup the callback routine for updating the UI
            updateUI = new UpdateUICallback(StatusUpdate);

            // Setup the callback routine for NullReference exception handling
            handleException = new ExceptionCallback(ThreadException);

            // Create the list of USB devices attached to the CyUSB.sys driver.
            usbDevices = new USBDeviceList(CyConst.DEVICES_CYUSB);

            //Assign event handlers for device attachment and device removal.
            usbDevices.DeviceAttached += new EventHandler(usbDevices_DeviceAttached);
            usbDevices.DeviceRemoved += new EventHandler(usbDevices_DeviceRemoved);

            //Set and search the device with VID-PID 04b4-1003 and if found, selects the end point
            SetDevice();

            TransferStatusText = "Acquisition Not Active";
        }

        public unsafe void Flush_Cypress_Chip()
        {
            int len = 4096;
            byte[] buf1 = new byte[len];
            byte[] buf2 = new byte[len];
            byte[] buf3 = new byte[len];
            byte[] buf4 = new byte[len];
            EndPoint.BeginDataXfer(ref buf1, ref buf2, ref len, ref buf3);
            Thread.Sleep(100);
            EndPoint.Abort();

            //// WaitForXfer
            //fixed (byte* tmpOvlap = buf4)
            //{
            //    OVERLAPPED* ovLapStatus = (OVERLAPPED*)tmpOvlap;
            //    if (!EndPoint.WaitForXfer(ovLapStatus->hEvent, 200))
            //    {
            //        EndPoint.Abort();
            //        PInvoke.WaitForSingleObject(ovLapStatus->hEvent, 50);
            //    }
            //}
            //EndPoint.XferData(ref buf, ref len);
        }

        public void Start_Cypress_Acq()
        {
            //Flush_Cypress_Chip();

            file = new FileStream(file_name + current_file + ".txt", FileMode.Create);

            data_buf1_pos = 0;
            data_buf2_pos = 0;
            active_buffer = 1;

            //EndPointsComboBox.IsEditable = false;
            // acq_button.Text = "Stop";
            // acq_button.BackColor = Color.Pink;

            BufSz = EndPoint.MaxPktSize * PPX;
            //QueueSz = Convert.ToUInt16(QueueBox.Text);
            //PPX = Convert.ToUInt16(PpxBox.Text);

            EndPoint.XferSize = BufSz;

            if (EndPoint is CyIsocEndPoint)
                IsoPktBlockSize = (EndPoint as CyIsocEndPoint).GetPktBlockSize(BufSz);
            else
                IsoPktBlockSize = 0;

            bRunning = true;

            tListen = new Thread(new ThreadStart(XferThread));
            tListen.IsBackground = true;
            tListen.Priority = ThreadPriority.Highest;
            tListen.Start();

            tFileWrite = new Thread(new ThreadStart(FileThread));
            tFileWrite.IsBackground = true;
            tFileWrite.Priority = ThreadPriority.Normal;
            tFileWrite.Start();
        }

        public void Stop_Cypress_Acq()
        {

            if (tListen.IsAlive)
            {
                //EndPointsComboBox.IsEditable = true;
                // StartBtn.Text = "Start";
                bRunning = false;

                t2 = DateTime.Now;
                elapsed = t2 - t1;
                xferRate = (long)(XferBytes / elapsed.TotalMilliseconds);
                xferRate = xferRate / (int)100 * (int)100;

                tListen.Abort();
                tListen.Join();
                tListen = null;

                tFileWrite.Abort();
                tFileWrite.Join();
                tFileWrite = null;

                //StartBtn.BackColor = Color.Aquamarine;
            }

            if (data_buf1_pos != 0)
            {
                file.Write(data_buffer_1, 0, data_buf1_pos);
                //file.Write(data_buffer_1, 0, data_buffer_1.Length);
                data_buf1_pos = 0;
                if (file.Position >= MAX_FILE_SIZE)
                {
                    file.Close();
                    current_file++;
                    file = new FileStream(file_name + current_file + ".txt", FileMode.Create);
                }
            }
            if (data_buf2_pos != 0)
            {

                file.Write(data_buffer_2, 0, data_buf2_pos);
                //file.Write(data_buffer_2, 0, data_buffer_2.Length);
                data_buf2_pos = 0;
                if (file.Position >= MAX_FILE_SIZE)
                {
                    file.Close();
                    current_file++;
                    file = new FileStream(file_name + current_file + ".txt", FileMode.Create);
                }
            }

            file.Close();
        }

        /*Summary
           This is the event handler for device removal. This method resets the device count and searches for the device with 
           VID-PID 04b4-1003
        */
        void usbDevices_DeviceRemoved(object sender, EventArgs e)
        {
            MyDevice = null;
            EndPoint = null;
            SetDevice();
        }



        /*Summary
           This is the event handler for device attachment. This method  searches for the device with 
           VID-PID 04b4-1003
        */
        void usbDevices_DeviceAttached(object sender, EventArgs e)
        {
            SetDevice();
        }


        private void GetDeviceHandle(uint dev)
        {
            int predictedLength = 0;
            int actualLength = 0;
            int last_error = 0;

            IntPtr hwDeviceInfo = SetupDiGetClassDevs(ref DrvGuid, 0, IntPtr.Zero, DIGCF_PRESENT | DIGCF_INTERFACE_DEVICE);

            if (hwDeviceInfo.ToInt32() == -1) return;

            SP_DEVICE_INTERFACE_DATA devIntefaceData = new SP_DEVICE_INTERFACE_DATA();
            devIntefaceData.cbSize = Marshal.SizeOf(devIntefaceData);
            if (!SetupDiEnumDeviceInterfaces(hwDeviceInfo, 0, ref DrvGuid, dev, devIntefaceData)) //return;
                last_error = Marshal.GetLastWin32Error();

            SetupDiGetDeviceInterfaceDetail(hwDeviceInfo, devIntefaceData, null, 0, ref predictedLength, null);

            byte[] detailData = new byte[predictedLength];
            detailData[0] = 5; //Set the cbSize filed of what would be a SP_DEVICE_INTERFACE_DETAIL_DATA struct
            if (!SetupDiGetDeviceInterfaceDetail(hwDeviceInfo, devIntefaceData, detailData, predictedLength, ref actualLength, null)) return;

            //Move the chars of the DevicePath field to the front of the array
            for (int i = 0; i < (actualLength - 4); i++) detailData[i] = detailData[i + 4];
            hDevice = CreateFile(detailData, FileAccess.ReadWrite, FileShare.ReadWrite, 0, FileMode.Open, FILE_FLAG_OVERLAPPED, IntPtr.Zero);

            SetupDiDestroyDevInfoList(hwDeviceInfo);
        }


        public void SetEndpoint(int index)
        {
            //string temp = EndPointsComboBox.SelectedValue.ToString();
            //string EndPointCBValue="";
            //System.Windows.Controls.ComboBoxItem curItem=((System.Windows.Controls.ComboBoxItem)EndPointsComboBox.SelectedItem);
            //EndPointCBValue = curItem.Content.ToString();

            // Get the Alt setting
            string sAlt = EndpointList[index].Substring(4, 1);
            //string sAlt = EndPointsComboBox.Text.Substring(4, 1);
            byte a = Convert.ToByte(sAlt);
            MyDevice.AltIntfc = a;

            // Get the endpoint
            //int aX = EndPointsComboBox.Text.LastIndexOf("0x");
            //string sAddr = EndPointsComboBox.Text.Substring(aX, 4);
            int aX = EndpointList[index].LastIndexOf("0x");
            string sAddr = EndpointList[index].Substring(aX, 4);
            byte addr = (byte)Util.HexToInt(sAddr);

            EndPoint = MyDevice.EndPointOf(addr);

            // Ensure valid PPX for this endpoint
            //PpxBox_SelectionChanged(sender, null);
        }

        /*Summary
           Search the device with VID-PID 04b4-1003 and if found, select the end point
        */
        private void SetDevice()
        {
            USBDevice dev = usbDevices[0x04B4, 0x8613];

            if (dev != null)
            {
                MyDevice = (CyUSBDevice)dev;

                GetEndpointsOfNode(MyDevice.Tree);

                SetEndpoint(0);
                
                ////if (EndPointsComboBox.Items.Count > 0)
                //{
                //    EndPointsComboBox.SelectedIndex = 0;
                //    //PpxBox.SelectedIndex = 0;
                //    //QueueBox.SelectedIndex = 0;
                //    // StartBtn.Enabled = true;
                //}
                CySafeFileHandle handle = MyDevice.DeviceHandle;
                hDevice = handle.DangerousGetHandle();
                bool ret_status;
                int bytesxfered = 0;
                UInt32 GET_TRANSFER_SIZE_CTL = 0x00220034;
                UInt32 SET_TRANSFER_SIZE_CTL = 0x00220038;
                SET_TRANSFER_SIZE_INFO SetTransferInfo = new SET_TRANSFER_SIZE_INFO();
                if (EndPoint.Attributes == 3)
                {
                    SetTransferInfo.EndPointAddress = MyDevice.InterruptInEndPt.Address;
                }
                else if (EndPoint.Attributes == 2)
                {
                    SetTransferInfo.EndPointAddress = MyDevice.BulkInEndPt.Address;
                }
                //
                //string TransInfo = SetTransferInfo.ToString;
                byte[] Trans_Info = new byte[9];
                Trans_Info[0] = SetTransferInfo.EndPointAddress;
                ret_status = DeviceIoControl(hDevice, GET_TRANSFER_SIZE_CTL, Trans_Info, Trans_Info.Length, Trans_Info, Trans_Info.Length, ref bytesxfered, null);

                //change to 65536 KB buffer
                Trans_Info[2] = 0x00;
                Trans_Info[3] = 0x80;
                ret_status = DeviceIoControl(hDevice, SET_TRANSFER_SIZE_CTL, Trans_Info, Trans_Info.Length, Trans_Info, Trans_Info.Length, ref bytesxfered, null);
                //check to make sure change was made
                Trans_Info[2] = 0x00;
                Trans_Info[3] = 0x00;
                ret_status = DeviceIoControl(hDevice, GET_TRANSFER_SIZE_CTL, Trans_Info, Trans_Info.Length, Trans_Info, Trans_Info.Length, ref bytesxfered, null);
            }
            else
            {
                // StartBtn.Enabled = false;
               // EndPointsComboBox.Items.Clear();
              //  EndPointsComboBox.Text = "";

                EndpointList.Clear();
            }



        }

        private void GetEndpointsOfNode(TreeNode devTree)
        {
            foreach (TreeNode node in devTree.Nodes)
            {
                if (node.Nodes.Count > 0)
                    GetEndpointsOfNode(node);
                else
                {
                    CyUSBEndPoint ept = node.Tag as CyUSBEndPoint;
                    if (ept == null)
                    {
                        //return;
                    }
                    else if (!node.Text.Contains("Control"))
                    {
                        CyUSBInterface ifc = node.Parent.Tag as CyUSBInterface;
                        string s = string.Format("ALT-{0}, {1} Byte, {2}", ifc.bAlternateSetting, ept.MaxPktSize, node.Text);
                        //EndPointsComboBox.Items.Add(s);

                        EndpointList.Add(s);
                    }
                }
            }

        }

        /*Summary
         This is the System event handler.  
         Enforces valid values for PPX(Packet per transfer)
        */
        //private void PpxBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        //{
        //    //string temp = PpxBox.SelectedValue.ToString();

        //    string PpxCBValue = "";
        //    System.Windows.Controls.ComboBoxItem curItem = ((System.Windows.Controls.ComboBoxItem)PpxBox.SelectedItem);
        //    PpxCBValue = curItem.Content.ToString();

        //    if (EndPoint == null) return;

        //    //int ppx = Convert.ToUInt16(PpxBox.Text);
        //    int ppx = Convert.ToUInt16(PpxCBValue);
        //    int len = EndPoint.MaxPktSize * ppx;


        //    int maxLen = 0x10000; // 64K
        //    if (len > maxLen)
        //    {
        //        ppx = maxLen / EndPoint.MaxPktSize / 8 * 8;
        //        PpxBox.SelectedIndex = PpxBox.SelectedIndex - 1;
        //        //PpxBox.Text = ppx.ToString();
        //        System.Windows.MessageBox.Show("Maximum of 64KB per transfer.  Packets reduced.", "Invalid Packets per Xfer.");
        //    }

        //    if (MyDevice.bHighSpeed && (EndPoint.Attributes == 1) && (ppx < 8))
        //    {
        //        PpxBox.SelectedIndex = 4;
        //        System.Windows.MessageBox.Show("Minimum of 8 Packets per Xfer required for HS Isoc.", "Invalid Packets per Xfer.");
        //    }

        //}



        /*Summary
         This is a system event handler, when the selected index changes(end point selection).
        */
        //private void EndPointsComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        //{
        //    //string temp = EndPointsComboBox.SelectedValue.ToString();
        //    //string EndPointCBValue="";
        //    //System.Windows.Controls.ComboBoxItem curItem=((System.Windows.Controls.ComboBoxItem)EndPointsComboBox.SelectedItem);
        //    //EndPointCBValue = curItem.Content.ToString();

        //    // Get the Alt setting
        //    string sAlt = (EndPointsComboBox.SelectedValue.ToString()).Substring(4, 1);
        //    //string sAlt = EndPointsComboBox.Text.Substring(4, 1);
        //    byte a = Convert.ToByte(sAlt);
        //    MyDevice.AltIntfc = a;

        //    // Get the endpoint
        //    //int aX = EndPointsComboBox.Text.LastIndexOf("0x");
        //    //string sAddr = EndPointsComboBox.Text.Substring(aX, 4);
        //    int aX = (EndPointsComboBox.SelectedValue.ToString()).LastIndexOf("0x");
        //    string sAddr = (EndPointsComboBox.SelectedValue.ToString()).Substring(aX, 4);
        //    byte addr = (byte)Util.HexToInt(sAddr);

        //    EndPoint = MyDevice.EndPointOf(addr);

        //    // Ensure valid PPX for this endpoint
        //    PpxBox_SelectionChanged(sender, null);
        //}

        /*Summary
          File Write Thread entry point. Starts the thread on Start Button click 
        */
        public unsafe void FileThread()
        {
            for (; bRunning; )
            {
                if (data_buf1_pos == DATA_BUF_SIZE)
                {
                    file.Write(data_buffer_1, 0, data_buffer_1.Length);
                    data_buf1_pos = 0;
                    if (file.Position >= MAX_FILE_SIZE)
                    {
                        file.Close();
                        current_file++;
                        file = new FileStream(file_name + current_file + ".txt", FileMode.Create);
                    }
                }
                if (data_buf2_pos == DATA_BUF_SIZE)
                {

                    file.Write(data_buffer_2, 0, data_buffer_2.Length);
                    data_buf2_pos = 0;
                    if (file.Position >= MAX_FILE_SIZE)
                    {
                        file.Close();
                        current_file++;
                        file = new FileStream(file_name + current_file + ".txt", FileMode.Create);
                    }
                }
                Thread.Sleep(1);
            }
        }


        /*Summary
          Data Xfer Thread entry point. Starts the thread on Start Button click 
        */
        public unsafe void XferThread()
        {
            // Setup the queue buffers
            byte[][] cmdBufs = new byte[QueueSz][];
            byte[][] xferBufs = new byte[QueueSz][];
            byte[][] ovLaps = new byte[QueueSz][];
            ISO_PKT_INFO[][] pktsInfo = new ISO_PKT_INFO[QueueSz][];

            int xStart = 0;

            try
            {
                LockNLoad(ref xStart, cmdBufs, xferBufs, ovLaps, pktsInfo);
            }
            catch (NullReferenceException e)
            {
                // This exception gets thrown if the device is unplugged 
                // while we're streaming data
                e.GetBaseException();
                //this.Invoke(handleException);
                
                Dispatcher.CurrentDispatcher.Invoke(handleException);
                //this.Dispatcher.Invoke(handleException);

            }
        }




        /*Summary
          This is a recursive routine for pinning all the buffers used in the transfer in memory.
        It will get recursively called QueueSz times.  On the QueueSz_th call, it will call
        XferData, which will loop, transferring data, until the stop button is clicked.
        Then, the recursion will unwind.
        */
        public unsafe void LockNLoad(ref int j, byte[][] cBufs, byte[][] xBufs, byte[][] oLaps, ISO_PKT_INFO[][] pktsInfo)
        {
            // Allocate one set of buffers for the queue
            cBufs[j] = new byte[CyConst.SINGLE_XFER_LEN + IsoPktBlockSize];
            xBufs[j] = new byte[BufSz];
            oLaps[j] = new byte[20];
            pktsInfo[j] = new ISO_PKT_INFO[PPX];

            fixed (byte* tL0 = oLaps[j], tc0 = cBufs[j], tb0 = xBufs[j])  // Pin the buffers in memory
            {
                OVERLAPPED* ovLapStatus = (OVERLAPPED*)tL0;
                ovLapStatus->hEvent = (IntPtr)PInvoke.CreateEvent(0, 0, 0, 0);

                // Pre-load the queue with a request
                int len = BufSz;
                EndPoint.BeginDataXfer(ref cBufs[j], ref xBufs[j], ref len, ref oLaps[j]);

                j++;

                if (j < QueueSz)
                    LockNLoad(ref j, cBufs, xBufs, oLaps, pktsInfo);  // Recursive call to pin next buffers in memory
                else
                    XferData(cBufs, xBufs, oLaps, pktsInfo);          // All loaded. Let's go!

            }

        }



        /*Summary
          Called at the end of recursive method, LockNLoad().
          XferData() implements the infinite transfer loop
        */
        public unsafe void XferData(byte[][] cBufs, byte[][] xBufs, byte[][] oLaps, ISO_PKT_INFO[][] pktsInfo)
        {
            IAsyncResult ar;

            int k = 0;
            int len = 0;

            Successes = 0;
            Failures = 0;

            XferBytes = 0;
            t1 = DateTime.Now;

            for (; bRunning; )
            {
                // WaitForXfer
                fixed (byte* tmpOvlap = oLaps[k])
                {
                    OVERLAPPED* ovLapStatus = (OVERLAPPED*)tmpOvlap;
                    if (!EndPoint.WaitForXfer(ovLapStatus->hEvent, 5000))
                    {
                        EndPoint.Abort();
                        PInvoke.WaitForSingleObject(ovLapStatus->hEvent, 5000);
                    }
                }

                if (EndPoint.Attributes == 1)
                {
                    CyIsocEndPoint isoc = EndPoint as CyIsocEndPoint;
                    // FinishDataXfer
                    if (isoc.FinishDataXfer(ref cBufs[k], ref xBufs[k], ref len, ref oLaps[k], ref pktsInfo[k]))
                    {
                        //XferBytes += len;
                        //Successes++;

                        ISO_PKT_INFO[] pkts = pktsInfo[k];

                        for (int j = 0; j < PPX; j++)
                        {
                            if (pkts[j].Status == 0)
                            {
                                XferBytes += pkts[j].Length;

                                Successes++;
                            }
                            else
                                Failures++;

                            pkts[j].Length = 0;
                        }

                    }
                    else
                        Failures++;
                }
                else
                {
                    // FinishDataXfer
                    if (EndPoint.FinishDataXfer(ref cBufs[k], ref xBufs[k], ref len, ref oLaps[k]))
                    {
                        XferBytes += len;
                        Successes++;

                        if (active_buffer == 1)
                        {
                            if (data_buf1_pos < DATA_BUF_SIZE && ((data_buf1_pos + len) <= DATA_BUF_SIZE))
                            {
                                Array.Copy(xBufs[k], 0, data_buffer_1, data_buf1_pos, len);
                                data_buf1_pos += len;

                                if (data_buf1_pos >= DATA_BUF_SIZE)
                                {
                                    active_buffer = 2;
                                }
                            }
                            else
                            {
                                active_buffer = 2;
                            }
                        }
                        else
                        {
                            if (data_buf2_pos < DATA_BUF_SIZE && ((data_buf2_pos + len) <= DATA_BUF_SIZE))
                            {
                                Array.Copy(xBufs[k], 0, data_buffer_2, data_buf2_pos, len);
                                data_buf2_pos += len;

                                if (data_buf2_pos >= DATA_BUF_SIZE)
                                {
                                    active_buffer = 1;
                                }
                            }
                            else
                            {
                                active_buffer = 1;
                            }
                        }

                        //file.Write(xBufs[k], 0, xBufs[k].Length);
                    }
                    else
                        Failures++;

                }



                // ar = file.BeginWrite(xBufs[k], 0, xBufs[k].Length, null, null);

                k++;
                if (k == QueueSz)  // Only update displayed stats once each time through the queue
                {
                    k = 0;

                    t2 = DateTime.Now;
                    elapsed = t2 - t1;

                    xferRate = (long)(XferBytes / elapsed.TotalMilliseconds);
                    xferRate = xferRate / (int)100 * (int)100;

                    // Call StatusUpdate() in the main thread
                    //this.Dispatcher.Invoke(updateUI);
                    Dispatcher.CurrentDispatcher.Invoke(updateUI);

                    //************************** Adding write to file *********************************//


                    // for (int j = 0; j < QueueSz; j++)
                    // {
                    // file.Write(xBufs[j], 0, xBufs[j].Length);
                    // }
                    //file.Close();

                    // For small QueueSz or PPX, the loop is too tight for UI thread to ever get service.   
                    // Without this, app hangs in those scenarios.

                    //Thread.Sleep(1);


                }

                /* if (!ar.IsCompleted)
                 {
                     file.EndWrite(ar);
                 }
                 else
                 {
                     file.EndWrite(ar);
                 }*/

                // Re-submit this buffer into the queue
                len = BufSz;
                EndPoint.BeginDataXfer(ref cBufs[k], ref xBufs[k], ref len, ref oLaps[k]);




            } // End infinite loop

        }


        /*Summary
          The callback routine delegated to updateUI.
        */
        public void StatusUpdate()
        {
            //if (xferRate > ProgressBar.Maximum)
             //   ProgressBar.Maximum = (int)(xferRate * 1.25);

            //ProgressBar.Value = (int)xferRate;
            //ThroughputLabel.Content = ProgressBar.Value.ToString();

            //SuccessBox.Text = Successes.ToString();
            //FailuresBox.Text = Failures.ToString();

            TransferStatusText = "Acquisition Active: " + Successes.ToString() + " of " + (Successes + Failures).ToString() + " Successful!";
        }


        /*Summary
          The callback routine delegated to handleException.
        */
        public void ThreadException()
        {
            //acq_button.Content = "Start Acquisition";
            bRunning = false;

            t2 = DateTime.Now;
            elapsed = t2 - t1;
            xferRate = (long)(XferBytes / elapsed.TotalMilliseconds);
            xferRate = xferRate / (int)100 * (int)100;

            tListen = null;

            // StartBtn.BackColor = Color.Aquamarine;

        }

    }

    #region data_acq



    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public class SP_DEVINFO_DATA
    {
        public int cbSize;
        public Guid ClassGuid;
        public uint DevInst;
        public uint Reserved;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public class SP_DEVICE_INTERFACE_DATA
    {
        public int cbSize;
        public Guid InterfaceClassGuid;
        public uint Flags;
        public uint Reserved;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public class OVERLAP
    {
        public uint Internal;
        public uint InternalHigh;
        public uint Offset;
        public uint OffsetHigh;
        public IntPtr hEvent;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public class SET_TRANSFER_SIZE_INFO
    {
        public byte EndPointAddress;
        public uint TransferSize;
    }
    #endregion
}
