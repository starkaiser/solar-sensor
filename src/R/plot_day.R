library(ggplot2)

df <- read.csv("./data/jan/1_1_18.CSV", stringsAsFactors = FALSE)
df$time <- as.POSIXct(df$time, format = "%H:%M:%S")

ggplot(df, aes(x = time, y = power)) +
   # geom_line() +
    labs(
        title = "Power over Time",
        x = "Time",
        y = "Power"
    ) +
    theme_minimal() +
    geom_smooth(se = FALSE)