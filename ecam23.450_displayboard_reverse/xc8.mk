# Microchip XC8 toolchain setup shared by reimplem/ and pb_reimplem/.
#
# Before including this file, set DFP_NAME and DFP_VERSION (the device
# family pack of the chip).
#
# XC8 v3+ no longer ships the device files: they come from device family
# packs (DFPs). By default the newest XC8 under /opt/microchip/xc8 and the
# packs under ~/.mchp_packs (where MPLAB X puts them) are used; override with
#   make XC8=/path/to/xc8-cc DFP=/path/to/<pack>/xc8
# `make dfp` downloads and unpacks the pack from packs.download.microchip.com.

XC8   ?= $(or $(lastword $(sort $(wildcard /opt/microchip/xc8/v*/bin/xc8-cc))),xc8-cc)
PACKS ?= $(HOME)/.mchp_packs/Microchip
DFP   ?= $(lastword $(sort $(wildcard $(PACKS)/$(DFP_NAME)/*/xc8)))

.DEFAULT_GOAL := all
.PHONY: dfp

dfp:
	@mkdir -p $(PACKS)/$(DFP_NAME)/$(DFP_VERSION)
	curl -fL -o /tmp/$(DFP_NAME).$(DFP_VERSION).atpack \
	  https://packs.download.microchip.com/Microchip.$(DFP_NAME).$(DFP_VERSION).atpack
	cd $(PACKS)/$(DFP_NAME)/$(DFP_VERSION) && unzip -qo /tmp/$(DFP_NAME).$(DFP_VERSION).atpack
	rm -f /tmp/$(DFP_NAME).$(DFP_VERSION).atpack

# fail early with a useful message when the pack is missing
define need_dfp
	@test -n "$(DFP)" -a -d "$(DFP)" || { echo "No $(DFP_NAME) device pack found under $(PACKS)."; \
	  echo "Run 'make dfp' to download it, or pass DFP=/path/to/$(DFP_NAME)/<version>/xc8."; exit 1; }
endef
