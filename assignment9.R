# LIS4370 - Assignment 9: Base R vs. lattice vs. ggplot2
# Dataset: USInvest (package AER) - US investment data, annual, 1968-1982
#   gnp      = nominal gross national product (billions USD)
#   invest   = nominal gross private investment (billions USD)
#   price    = GNP price deflator (1972 = 100)
#   interest = interest rate (discount rate, %)

# install.packages(c("AER", "lattice", "ggplot2"))   # run once if needed
library(AER)
library(lattice)
library(ggplot2)

# ---- Load and prepare data ------------------------------------------------
data("USInvest", package = "AER")
head(USInvest)

# USInvest is a time series (ts) object, so convert it to a data frame
inv <- as.data.frame(USInvest)
inv$year <- as.numeric(time(USInvest))

# Real (inflation-adjusted) values in 1972 dollars
inv$real_gnp    <- inv$gnp    / (inv$price / 100)
inv$real_invest <- inv$invest / (inv$price / 100)

# Grouping factor for conditioned plots: three 5-year periods
inv$period <- cut(inv$year,
                  breaks = c(1967, 1972, 1977, 1982),
                  labels = c("1968-72", "1973-77", "1978-82"))

str(inv)
summary(inv)

dir.create("plots", showWarnings = FALSE)

# ---- 1. Base R graphics ---------------------------------------------------

# 1a. Scatter plot: investment vs. GNP with a regression line
png("plots/base_scatter.png", width = 1000, height = 700, res = 120)
plot(inv$gnp, inv$invest,
     main = "Base: Investment vs. GNP (nominal, 1968-1982)",
     xlab = "GNP (billions USD)",
     ylab = "Gross private investment (billions USD)",
     pch  = 19, col = "steelblue",
     xlim = c(800, 3300))
abline(lm(invest ~ gnp, data = inv), col = "darkred", lwd = 2, lty = 2)
text(inv$gnp, inv$invest, labels = inv$year,
     pos = ifelse(inv$year == 1973, 2, 4), cex = 0.7, col = "grey30")
dev.off()

# 1b. Histogram: distribution of interest rates
png("plots/base_hist.png", width = 1000, height = 700, res = 120)
hist(inv$interest,
     breaks = seq(4, 14, by = 1),
     main   = "Base: Distribution of Interest Rates, 1968-1982",
     xlab   = "Interest rate (%)",
     ylab   = "Number of years",
     col    = "lightsteelblue", border = "white")
abline(v = mean(inv$interest), col = "darkred", lwd = 2, lty = 2)
dev.off()

# ---- 2. Lattice graphics --------------------------------------------------

# 2a. Conditioned scatter plot (small multiples) with a fitted line per panel
p_lat1 <- xyplot(invest ~ gnp | period,
                 data   = inv,
                 type   = c("p", "r"),
                 pch    = 19,
                 layout = c(3, 1),
                 main   = "Lattice: Investment vs. GNP by period",
                 xlab   = "GNP (billions USD)",
                 ylab   = "Investment (billions USD)")
png("plots/lattice_xyplot.png", width = 1200, height = 600, res = 120)
print(p_lat1)
dev.off()

# 2b. Box-and-whisker plot: interest rate by period
p_lat2 <- bwplot(interest ~ period,
                 data = inv,
                 main = "Lattice: Interest rate by period",
                 xlab = "Period",
                 ylab = "Interest rate (%)")
png("plots/lattice_bwplot.png", width = 1000, height = 700, res = 120)
print(p_lat2)
dev.off()

# ---- 3. ggplot2 -----------------------------------------------------------

# 3a. Layered scatter: real investment vs. real GNP, colored by period,
#     sized by interest rate, with a linear trend per period
p_gg1 <- ggplot(inv, aes(x = real_gnp, y = real_invest, color = period)) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8, linetype = "dashed") +
  geom_point(aes(size = interest), alpha = 0.85) +
  scale_color_manual(values = c("1968-72" = "#1b9e77",
                                "1973-77" = "#7570b3",
                                "1978-82" = "#d95f02")) +
  labs(title    = "ggplot2: Real investment vs. real GNP, by period",
       subtitle = "Values deflated to 1972 dollars; point size = interest rate",
       x        = "Real GNP (billions, 1972 USD)",
       y        = "Real investment (billions, 1972 USD)",
       color    = "Period",
       size     = "Interest rate (%)") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank())
ggsave("plots/ggplot_scatter.png", p_gg1, width = 9, height = 6, dpi = 150, bg = "white")

# 3b. Nominal vs. real investment over time (reshape to long format)
inv_long <- rbind(
  data.frame(year = inv$year, value = inv$invest,      type = "Nominal"),
  data.frame(year = inv$year, value = inv$real_invest, type = "Real (1972 USD)")
)
p_gg2 <- ggplot(inv_long, aes(x = year, y = value, color = type)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = c("Nominal" = "grey50",
                                "Real (1972 USD)" = "#d95f02")) +
  labs(title    = "ggplot2: Nominal vs. real investment, 1968-1982",
       subtitle = "Most of the growth in nominal investment is inflation",
       x = "Year", y = "Investment (billions USD)", color = NULL) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        legend.position = "top",
        panel.grid.minor = element_blank())
ggsave("plots/ggplot_timeseries.png", p_gg2, width = 9, height = 5.5, dpi = 150, bg = "white")

# ---- Quick numbers used in the blog discussion -----------------------------
cor(inv$gnp, inv$invest)
cor(inv$real_gnp, inv$real_invest)
aggregate(cbind(interest, real_invest) ~ period, data = inv, FUN = mean)
