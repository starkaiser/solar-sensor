library(dplyr)

month_dir <- "./data-raw/1_jan_2018_full"
files <- list.files(month_dir, pattern = "\\.CSV$", full.names = TRUE)
missing_report_name <- "missing_report_jan.csv"

output_dir <- file.path("./data", "jan")
dir.create(output_dir, showWarnings = FALSE)

missing_report <- data.frame(file = character(), missing_points = numeric())

for (file in files) {
    
    df <- read.csv(file, header = FALSE, stringsAsFactors = FALSE)
    
    clean_df <- df %>%
        select(time = V4, power = V2) %>%
        mutate(
            power = suppressWarnings(as.numeric(power))
        ) %>%
        filter(!is.na(time), !is.na(power))
    
    # Convert time
    clean_df$time <- as.POSIXct(clean_df$time, format = "%H:%M:%S")
    
    # # Convert time to POSIXct format
    # data$time <- as.POSIXct(data$time, format="%H:%M")
    # 
    # # Filter rows between 5:00 and 22:00
    # data_filtered <- subset(data, format(time, "%H:%M") >= "05:00" & format(time, "%H:%M") <= "22:00")
    
    # 🔹 Expected full timeline (every 3 seconds)
    full_time <- data.frame(
        time = seq(
            as.POSIXct("05:00:02", format = "%H:%M:%S"),
            as.POSIXct("22:00:00", format = "%H:%M:%S"),
            by = "3 sec"
        )
    )
    
    # 🔹 Merge
    merged <- full_time %>%
        left_join(clean_df, by = "time")
    
    # 🔹 Detect missing
    missing_count <- sum(is.na(merged$power))
    
    missing_report <- rbind(missing_report, data.frame(
        file = basename(file),
        missing_points = missing_count
    ))
    
    # 🔹 Fill missing values (linear interpolation)
    # merged$power <- approx(
    #     x = as.numeric(clean_df$time),
    #     y = clean_df$power,
    #     xout = as.numeric(merged$time),
    #     rule = 2
    # )$y
    
    # Convert time back
    merged$time <- format(merged$time, "%H:%M:%S")
    
    # Save cleaned file
    write.csv(merged,
              file.path(output_dir, basename(file)),
              row.names = FALSE)
}

# 🔹 Save missing data report
write.csv(missing_report,
          file.path("./output", missing_report_name),
          row.names = FALSE)