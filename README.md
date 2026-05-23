# solar-sensor
Monthly average solar power intensity plots for Craiova, Romania, 2017-2018.

My father wanted to install solar panels on his house, but he wanted first to get an idea of how the energy production would look like and how it will change depending on month and hour of the day. He asked me to make some plots of average solar power intensity, so I used an Arduino board and a sensor that measures the solar power in W/m^2 to log the data in a CSV format.

To experiment with parallel programming, I used Fortran to filter the raw data and extract only the values for power and time. I used coarrays to run 4 images in parallel and got a 3x increase in speed, comapred to the serial implementation of the program.
R is used to average the filtered values for each month, make a plot of the average values for each month and one for the whole year.

This is an older project of mine. I did it some time ago in MATLAB, but now I wanted to use R and experiment with parallel programming in Fortran, so this is the result.

## Results
The plots are located in the /results folder.

### Comparison for each month and also the whole year
![](/results/all_months_comparison.png)

### Average daily power for the whole year
![](/results/year_average.png)

### Average daily power for each month
![](/results/jan_average.png)
![](/results/feb_average.png)
![](/results/mar_average.png)
![](/results/apr_average.png)
![](/results/may_average.png)
![](/results/jun_average.png)
![](/results/jul_average.png)
![](/results/aug_average.png)
![](/results/sep_average.png)
![](/results/oct_average.png)
![](/results/nov_average.png)
![](/results/dec_average.png)

## Build Instructions

You will need:
* GNU Fortran
* Open Coarrays
* R
* Make

### Fortran

To build and run the parallel program to filter the raw data, simply run:

```
$ make
$ make run_parallel
```

### R

To make the plots, simply run the scripts in the /src/R folder. This is easy to do in RStudio.

## License

BSD-3-Clause license