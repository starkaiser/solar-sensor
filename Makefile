# ==========================================================
# Solar Sensor in Fortran
# Options: all (programs + tests), programs only, test, clean
# ==========================================================

FC      = gfortran
FFLAGS  = -O2 -Wall -Wextra -std=f2008 -J$(BUILD_DIR) -I$(BUILD_DIR)

SRC_DIR   = src/Fortran
PROG_DIR  = src/Fortran
BUILD_DIR = build

# -------------------------------
# Files
# -------------------------------
SRC_FILES = \
	$(SRC_DIR)/m_parameters.f90 \
	$(SRC_DIR)/m_logger.f90 \
	$(SRC_DIR)/m_data_convert.f90 \
	$(SRC_DIR)/m_io.f90

PROG_FILES = \
	$(PROG_DIR)/solar_sensor.f90

# -------------------------------
# Derived build targets
# -------------------------------
SRC_OBJS  = $(patsubst $(SRC_DIR)/%.f90,$(BUILD_DIR)/%.o,$(SRC_FILES))
PROG_BINS = $(patsubst $(PROG_DIR)/%.f90,$(BUILD_DIR)/%,$(PROG_FILES))

# ==========================================================
# Default target: build everything
# ==========================================================
all: programs

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# -------------------------------
# Compile source modules
# -------------------------------
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.f90 | $(BUILD_DIR)
	$(FC) $(FFLAGS) -c $< -o $@

# -------------------------------
# Build programs only
# -------------------------------
programs: $(BUILD_DIR) $(PROG_BINS)

$(BUILD_DIR)/%: $(PROG_DIR)/%.f90 $(SRC_OBJS)
	$(FC) $(FFLAGS) $(SRC_OBJS) $< -o $@


# ==========================================================
# Utility targets
# ==========================================================
.PHONY: clean rebuild

clean:
	rm -rf $(BUILD_DIR)
	@echo "Build directory cleaned."

rebuild: clean all


#caf -O2 m_parameters.f90 m_logger.f90 m_data_convert.f90 m_io.f90 m_parallel.f90 solar_sensor_parallel.f90 -o solar_sensor_parallel
#cafrun -n 4 ./solar_sensor_parallel 

