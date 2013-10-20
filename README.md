Thesis
======

Data Acquisition and Stimulation System
---------------------------------------
Built on previous work and on research literature, software and firmware were designed, and integrated with instrumentation electronics developed by fellow graduate student Mr. Donovan Squires to realize a measurement and stimulation system for electrophysiology experiments at the Neurobiology Engineering Laboratory at Western Michigan University. A standard electrophysiology experiment was performed with the developed system, and the results compared favorably with results from previous designs.

![DASS Overview](https://github.com/KyleBatzer/Thesis/blob/master/Documentation/Images/DASS_Overview.png?raw=true)

Required Software and Drivers
-----------------------------
Required for building Cypress EZ-USB firmware
* Cygwin
* SDCC version 2.9 (newer version no longer supports asx8051)
* asx8051 (linker for 8051 processors)

Required for programming Cypress EZ-USB firmware
* [LibUSB](http://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/1.2.5.0/)
* [CySuiteUSB](http://www.cypress.com/?rID=34870)
* [FX2loader](http://www.makestuff.eu/wordpress/software/fx2tools/)

Required for Nexys2 Spartan-3E development
* Xilinx ISE (Webpack)
* Adept Suite 
