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

root_folder <- "/home/starkaiser/Coding/solar-sensor/data/processed"

output_folder <- "/home/starkaiser/Coding/solar-sensor/output"
results_folder <- "/home/starkaiser/Coding/solar-sensor/results"


month_folders <- list.dirs(
    path = root_folder,
    recursive = FALSE,
    full.names = TRUE
)

process_month <- function(folder_path, month_name) {
    
    cat("\nProcessing:", month_name, "\n")
    
    files <- list.files(
        path = folder_path,
        pattern = "\\.csv$",
        full.names = TRUE,
        ignore.case = TRUE
    )
    
    if (length(files) == 0) {
        cat("No CSV files found.\n")
        return(NULL)
    }
    
    # ---------------------------------------------
    # Read all files
    # ---------------------------------------------
    
    data_list <- lapply(files, function(file) {
        
        tryCatch({
            
            df <- read_csv(file, show_col_types = FALSE)
            
            df <- df[, 1:2]
            colnames(df) <- c("time", "power")
            
            # Convert HH:MM:SS -> seconds
            df$time_sec <- period_to_seconds(hms(df$time))
            
            # Round to nearest 3 sec
            df$time_sec <- round(df$time_sec / 3) * 3
            
            # Average duplicates inside file
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
    
    # Remove NULLs
    data_list <- data_list[!sapply(data_list, is.null)]
    
    if (length(data_list) == 0) {
        cat("No valid data.\n")
        return(NULL)
    }
    
    # ---------------------------------------------
    # Combine all days
    # ---------------------------------------------
    
    all_data <- bind_rows(data_list)
    
    # ---------------------------------------------
    # Monthly average profile
    # ---------------------------------------------
    
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
    
    # ---------------------------------------------
    # Save averaged CSV
    # ---------------------------------------------
    
    write_csv(
        average_day %>% select(time, mean_power),
        file.path(output_folder, paste0(month_name, "_average.csv"))
    )
    
    # ---------------------------------------------
    # Plot
    # ---------------------------------------------
    
    p <- ggplot(average_day, aes(x = time, y = mean_power)) +
        
        geom_smooth(
            color = "#0072B2",
            linewidth = 1.5,
            se = FALSE,
            span = 0.05
        ) +
        
        theme_minimal(base_size = 15) +
        
        labs(
            title = paste("Average Daily Power -", toupper(month_name)),
            subtitle = paste(length(files), "days averaged"),
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
            
            axis.text.x = element_text(
                angle = 45,
                hjust = 1
            ),
            
            panel.grid.minor = element_blank()
        )
    
    # Save plot
    ggsave(
        filename = file.path(
            results_folder,
            paste0(month_name, "_average.png")
        ),
        plot = p,
        width = 12,
        height = 6,
        dpi = 300
    )
    
    cat("Saved:", month_name, "\n")
    
    return(all_data)
}

# PROCESS ALL MONTHS

year_data <- list()

for (folder in month_folders) {
    
    month_name <- basename(folder)
    
    result <- process_month(folder, month_name)
    
    if (!is.null(result)) {
        year_data[[month_name]] <- result
    }
}

# WHOLE YEAR AVERAGE

cat("\nGenerating yearly average...\n")

all_year_data <- bind_rows(year_data)

year_average <- all_year_data %>%
    group_by(time_sec) %>%
    summarise(
        mean_power = mean(power, na.rm = TRUE),
        .groups = "drop"
    ) %>%
    arrange(time_sec)

year_average$time <- as.POSIXct(
    year_average$time_sec,
    origin = "1970-01-01",
    tz = "UTC"
)

# Save yearly CSV
write_csv(
    year_average %>% select(time, mean_power),
    file.path(output_folder, "year_average.csv")
)

# YEARLY PLOT

p_year <- ggplot(year_average, aes(x = time, y = mean_power)) +
    
    geom_smooth(
        color = "#D55E00",
        linewidth = 1.5,
        se = FALSE,
        span = 0.05
    ) +
    
    theme_minimal(base_size = 15) +
    
    labs(
        title = "Average Daily Power Profile - Whole Year",
        subtitle = "Average across all months",
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
        
        axis.text.x = element_text(
            angle = 45,
            hjust = 1
        ),
        
        panel.grid.minor = element_blank()
    )

ggsave(
    filename = file.path(results_folder, "year_average.png"),
    plot = p_year,
    width = 12,
    height = 6,
    dpi = 300
)

print(p_year)

cat("\nDone.\n")
cat("All results saved in:\n")
cat(output_folder, "\n")