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

folder_path <- "/home/starkaiser/Coding/solar-sensor/output"
results_folder <- "/home/starkaiser/Coding/solar-sensor/results"

files <- list.files(
    path = folder_path,
    pattern = "_average\\.csv$",
    full.names = TRUE,
    ignore.case = TRUE
)

# Remove yearly average from monthly list
files <- files[!grepl("year_average\\.csv$", files)]

if (length(files) == 0) {
    stop("No monthly average CSV files found.")
}

data_list <- lapply(files, function(file) {
    
    month_name <- tools::file_path_sans_ext(
        basename(file)
    )
    
    month_name <- gsub("_average", "", month_name)
    
    df <- read_csv(file, show_col_types = FALSE)
    
    colnames(df) <- c("time", "mean_power")
    
    # Convert time
    df$time <- as.POSIXct(df$time, tz = "UTC")
    
    # Month label
    df$month <- toupper(month_name)
    
    return(df)
})

year_file <- file.path(folder_path, "year_average.csv")

if (file.exists(year_file)) {
    
    year_df <- read_csv(
        year_file,
        show_col_types = FALSE
    )
    
    colnames(year_df) <- c("time", "mean_power")
    
    year_df$time <- as.POSIXct(
        year_df$time,
        tz = "UTC"
    )
    
    year_df$month <- "YEAR"
    
    data_list <- append(
        data_list,
        list(year_df)
    )
}

all_months <- bind_rows(data_list)

months <- unique(all_months$month)

default_colors <- scales::hue_pal()(length(months))

names(default_colors) <- months

default_colors["YEAR"] <- "black"

p <- ggplot(
    all_months,
    aes(
        x = time,
        y = mean_power,
        color = month
    )
) +
    
    geom_smooth(
        se = FALSE,
        linewidth = 1.3,
        span = 0.05
    ) +
    
    theme_minimal(base_size = 15) +
    
    labs(
        title = "Average Daily Power Profiles by Month",
        subtitle = "Comparison of monthly average days",
        x = "Time of Day",
        y = "Power (W/m²)",
        color = "Profile"
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
    
    scale_color_manual(
        values = default_colors
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
        
        legend.position = "right"
    )

print(p)

output_file <- file.path(
    results_folder,
    "all_months_comparison.png"
)

ggsave(
    filename = output_file,
    plot = p,
    width = 14,
    height = 7,
    dpi = 300
)

cat("\nSaved plot:\n")
cat(output_file, "\n")