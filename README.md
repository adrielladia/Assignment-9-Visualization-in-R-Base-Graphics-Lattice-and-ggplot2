[README (4).md](https://github.com/user-attachments/files/33669951/README.4.md)
# Assignment-9-Visualization-in-R-Base-Graphics-Lattice-and-ggplot2
Base R vs. lattice vs. ggplot2 visualizations of U.S. investment data (USInvest, 1968–1982) for LIS4370.
# LIS4370 – Assignment 9: Base R vs. Lattice vs. ggplot2

This assignment compares R's three main graphics systems on the same data.

## Dataset
`USInvest` from the **AER** package ([Rdatasets](https://vincentarelbundock.github.io/Rdatasets/datasets.html)). It contains annual U.S. data from 1968 to 1982:

| Variable | Description |
|---|---|
| `gnp` | Nominal gross national product (billions USD) |
| `invest` | Nominal gross private investment (billions USD) |
| `price` | GNP price deflator (1972 = 100) |
| `interest` | Interest rate (%) |

The script also adds three derived variables:
- `year`
- `real_gnp` and `real_invest` (in 1972 dollars)
- a `period` factor with three groups: 1968–72, 1973–77, and 1978–82

## Plots
| System | File | Plot |
|---|---|---|
| Base R | `plots/base_scatter.png` | Investment vs. GNP with regression line |
| Base R | `plots/base_hist.png` | Distribution of interest rates |
| Lattice | `plots/lattice_xyplot.png` | Investment vs. GNP, conditioned by period |
| Lattice | `plots/lattice_bwplot.png` | Interest rate by period |
| ggplot2 | `plots/ggplot_scatter.png` | Real investment vs. real GNP (color = period, size = interest) |
| ggplot2 | `plots/ggplot_timeseries.png` | Nominal vs. real investment over time |

## How to run
```r
install.packages(c("AER", "lattice", "ggplot2"))
source("assignment9.R")
```
Running the script creates the `plots/` folder and saves all six PNGs into it.

## Key finding
Nominal investment more than tripled from 1968 to 1982, but most of that growth was inflation. Real investment peaked in 1979 and then fell as interest rates rose to 11–13%.

## Blog post
[paste your blog post link here]
