# ============================================================
# RTL Verification Makefile
#
# Targets:
#   lint  - Lint RTL and testbench using Verilator
#   build - Lint, compile and simulate using Icarus Verilog
#   sim   - Open the generated waveform using a viewer
#   run   - Build, simulate and open the waveform
#   clean - Remove directories immediately under this directory
#
# Usage:
#   make lint TB_TOP=tb_top.sv
#   make build TB_TOP=tb_top.sv
#   make sim
#   make run TB_TOP=tb_top.sv
#   make clean
# ============================================================

.DEFAULT_GOAL := help
SHELL := /bin/bash

# ------------------------------------------------------------
# User-configurable variables
# ------------------------------------------------------------

RTL_DIR          ?= ../rtl
TB_DIR           ?= ../tb

# Required: testbench filename relative to TB_DIR.
# Example: make run TB_TOP=tb_top.sv
TB_TOP           ?=

# Tool options
LINT_OPTIONS     ?=
VERILOG_OPTIONS  ?=
VVP_OPTIONS      ?=

# Waveform viewer
VIEWER           ?= surfer

# Output configuration
TIMESTAMP        := $(shell date +%Y%m%d_%H%M%S)
OUT_ROOT         ?= build
OUT_DIR          ?= $(OUT_ROOT)_$(TIMESTAMP)

# Generated files
WAVE_FORMAT      ?= fst
SIM_EXEC         := $(OUT_DIR)/sim.vvp
WAVEFORM         ?= $(OUT_DIR)/wave.$(WAVE_FORMAT)
LINT_LOG         := $(OUT_DIR)/lint.log

# RTL sources
RTL_FILES        := $(sort $(wildcard $(RTL_DIR)/*.v) \
                            $(wildcard $(RTL_DIR)/*.sv))

# Testbench source
TB_FILE          := $(TB_DIR)/$(TB_TOP)

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------

.PHONY: help check_tb lint build sim run clean

check_tb:
	@if [ -z "$(strip $(TB_TOP))" ]; then \
		echo "ERROR: TB_TOP is required."; \
		echo "Usage: make <target> TB_TOP=tb_top.sv"; \
		exit 1; \
	fi
	@if [ ! -f "$(TB_FILE)" ]; then \
		echo "ERROR: Testbench not found: $(TB_FILE)"; \
		exit 1; \
	fi
	@if [ -z "$(strip $(RTL_FILES))" ]; then \
		echo "ERROR: No RTL sources found in $(RTL_DIR)"; \
		exit 1; \
	fi

# ------------------------------------------------------------
# Lint
# ------------------------------------------------------------

lint: check_tb
	@mkdir -p "$(OUT_DIR)"
	@echo "============================================================"
	@echo "Linting RTL and testbench"
	@echo "Output directory: $(OUT_DIR)"
	@echo "============================================================"
	@set -o pipefail; \
	verilator --lint-only --Wall \
		$(LINT_OPTIONS) \
		--top-module $(basename $(notdir $(TB_TOP))) \
		$(RTL_FILES) $(TB_FILE) \
		2>&1 | tee "$(LINT_LOG)"

# ------------------------------------------------------------
# Build and simulate
# ------------------------------------------------------------

build: lint
	@echo "============================================================"
	@echo "Compiling with Icarus Verilog"
	@echo "Output directory: $(OUT_DIR)"
	@echo "Waveform output:  $(WAVEFORM)"
	@echo "============================================================"
	iverilog -g2023 \
		$(VERILOG_OPTIONS) \
		-s $(basename $(notdir $(TB_TOP))) \
		-o "$(SIM_EXEC)" \
		$(RTL_FILES) $(TB_FILE)

	@echo "============================================================"
	@echo "Running simulation"
	@echo "Waveform output: $(WAVEFORM)"
	@echo "============================================================"
	vvp $(VVP_OPTIONS) "$(SIM_EXEC)" -$(WAVE_FORMAT) +WAVEFORM="$(abspath $(WAVEFORM))"

# ------------------------------------------------------------
# Waveform viewer
# ------------------------------------------------------------

sim:
	@if [ ! -f "$(WAVEFORM)" ]; then \
		echo "ERROR: Waveform file not found: $(WAVEFORM)"; \
		exit 1; \
	fi
	$(VIEWER) "$(WAVEFORM)"

# ------------------------------------------------------------
# Run complete workflow
# ------------------------------------------------------------

run: build
	$(MAKE) sim \
		OUT_DIR="$(OUT_DIR)" \
		WAVEFORM="$(WAVEFORM)" \
		VIEWER="$(VIEWER)"

# ------------------------------------------------------------
# Clean
# ------------------------------------------------------------

clean:
	@echo "WARNING: Removing directories immediately inside the Makefile directory."
	@find . -mindepth 1 -maxdepth 1 -type d \
		-exec rm -rf -- {} +
	@echo "Clean complete."

# ------------------------------------------------------------
# Help
# ------------------------------------------------------------

help:
	@echo "RTL Verification Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  lint   Lint RTL and testbench using Verilator"
	@echo "  build  Lint, compile and simulate using Icarus Verilog"
	@echo "  sim    Open a waveform using the selected viewer"
	@echo "  run    Build, simulate and open the waveform"
	@echo "  clean  Delete directories immediately under this directory"
	@echo ""
	@echo "Required variable:"
	@echo "  TB_TOP=<testbench_filename>"
	@echo ""
	@echo "Optional variables:"
	@echo "  RTL_DIR=../rtl"
	@echo "  TB_DIR=../tb"
	@echo "  LINT_OPTIONS='...'"
	@echo "  VERILOG_OPTIONS='...'"
	@echo "  VVP_OPTIONS='...'"
	@echo "  VIEWER=surfer"
	@echo "  OUT_ROOT=build"
	@echo "  OUT_DIR=<output_directory>"
	@echo "  WAVEFORM=<waveform_file>"
	@echo ""
	@echo "Examples:"
	@echo "  make lint TB_TOP=tb_top.sv"
	@echo "  make build TB_TOP=tb_top.sv"
	@echo "  make run TB_TOP=tb_top.sv"
	@echo "  make run TB_TOP=tb_top.sv LINT_OPTIONS='-Wno-fatal'"
	@echo "  make run TB_TOP=tb_top.sv VIEWER=gtkwave"
	@echo "  make clean"