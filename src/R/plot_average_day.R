# BSD 3-Clause License
# 
# Copyright (c) 2026, Sorin Cătălin Păștiță
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     
#     1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#          SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

library(tidyverse)
library(lubridate)
library(scales)

folder_path <- "/home/starkaiser/Coding/solar-sensor/data/processed/jan"

files <- list.files(
    path = folder_path,
    pattern = "\\.csv$",
    full.names = TRUE,
    ignore.case = TRUE
)

if (length(files) == 0) {
    stop("No CSV files found.")
}


data_list <- lapply(files, function(file) {
    
    cat("Reading:", basename(file), "\n")
    
    tryCatch({
        
        df <- read_csv(file, show_col_types = FALSE)
        
        # Ensure exactly 2 columns
        df <- df[, 1:2]
        
        colnames(df) <- c("time", "power")
        
        # Convert HH:MM:SS to seconds since midnight
        df$time_sec <- period_to_seconds(hms(df$time))
        
        # Round to nearest 3 seconds
        df$time_sec <- round(df$time_sec / 3) * 3
        
        # Average duplicate timestamps inside same file
        df <- df %>%
            group_by(time_sec) %>%
            summarise(
                power = mean(power, na.rm = TRUE),
                .groups = "drop"
            )
        
        return(df)
        
    }, error = function(e) {
        
        cat("Skipping bad file:", basename(file), "\n")
        return(NULL)
    })
})

# Remove failed files
data_list <- data_list[!sapply(data_list, is.null)]

all_data <- bind_rows(data_list)

average_day <- all_data %>%
    group_by(time_sec) %>%
    summarise(
        mean_power = mean(power, na.rm = TRUE),
        .groups = "drop"
    ) %>%
    arrange(time_sec)


average_day$time <- as.POSIXct(
    average_day$time_sec,
    origin = "1970-01-01",
    tz = "UTC"
)

write_csv(
    average_day %>% select(time, mean_power),
    file.path(folder_path, "average_day.csv")
)


p <- ggplot(average_day, aes(x = time, y = mean_power)) +
    
    geom_smooth(
        color = "#0072B2",
        linewidth = 1.5,
        se = FALSE,
        span = 0.05
    ) +
    
    theme_minimal(base_size = 15) +
    
    labs(
        title = "Average Daily Power Consumption",
        subtitle = paste("Mean profile from", length(files), "CSV files"),
        x = "Time of Day",
        y = "Power (W/m²)"
    ) +
    
    scale_x_datetime(
        date_labels = "%H:%M",
        date_breaks = "1 hour",
        timezone = "UTC"
    ) +
    
    scale_y_continuous(
        limits = c(0, 1000),
        breaks = seq(0, 1000, by = 100),
        labels = comma
    ) +
    
    theme(
        plot.title = element_text(
            size = 20,
            face = "bold"
        ),
        
        plot.subtitle = element_text(
            size = 13,
            color = "gray40"
        ),
        
        axis.text.x = element_text(
            angle = 45,
            hjust = 1
        ),
        
        panel.grid.minor = element_blank(),
        
        panel.grid.major = element_line(
            color = "gray90"
        )
    )

print(p)