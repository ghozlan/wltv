# Multi-Layer Transmission in Wideband Linear Time-Varying Channels

# Abstract
A wideband linear time-varying multi-scale multi-lag channel is considered.
This channel model is appropriate for underwater acoustic communication.
This project follows up on the multi-layer (multi-rate) transmission scheme proposed by 
[Xu et al.](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=6365356)
where the data symbols of different layers are modulated using different pulse shapes at different rates and transmitted at different carriers.
The proposed scheme can ensure that there is no crosstalk between different layers at the the receiver if certain conditions are satisfied.
In this project, the multi-layer scheme is further investigated with some crosstalk permitted between layers,
which would allow using more layers compared to the no-crosstalk case. 
To evaluate the trade-off between quality degradation due to crosstalk between layers and the gain in data rate due to transmission of more layers,
information rates are computed numerically.


# MATLAB

### See the code and its output in a friendly format (html)!
  * Click [multilayer_script](https://htmlpreview.github.io/?https://github.com/ghozlan/rain/blob/master/matlab/html/multilayer_script.html) to see **signal spectra** (input to and output from the channel) and **information rates** achieved by various receivers for
   * Channel E, Scheme 1   
   * Note: **scroll down after you click above** to see the figures!
  * Click [sim_wltv_script](https://htmlpreview.github.io/?https://github.com/ghozlan/rain/blob/master/matlab/html/sim_wltv_script.html) to see **spectra** and **rates** for
   * Channel A, Scheme 1   
   * Channel A, Scheme 2   
   * Channel E, Scheme 1  
   * Note: less code is revealed here than in multilayer_script. Also, do not forget to scroll down after you click to see the figures!
  * Click [load_batch_script](https://htmlpreview.github.io/?https://github.com/ghozlan/rain/blob/master/matlab/html/load_batch_script.html) to see **comparisons** between the information rates of Scheme 1 and Scheme 2.

### Source code
* The source code can be found [here](/matlab/src/).
*  To reproduce the results, run the following scripts (in the following order):
 1. multilayer_script
 2. sim_wltv_script
 3. load_batch_script
*  The code was run on MATLAB 7.14.0.739 (R2012a).

### Output files
* The .mat files, the log files, and the figures can be found [here](/matlab/output).
