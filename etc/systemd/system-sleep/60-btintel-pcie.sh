#!/bin/sh
# Work around btintel_pcie blocking suspend/hibernate (see WATCHLIST.md).
#
# The Intel CNVi Bluetooth controller (8086:e476) sometimes misses the D3/D2
# handshake; the driver then returns -EBUSY from its PM callbacks, which aborts
# system sleep and leaves the laptop awake in a retry loop with the lid closed.
# Powering Bluetooth off does not help, as the driver still runs its PM
# callbacks. Unloading the module removes it from the sleep path entirely and
# gives the controller a fresh firmware load on wake.
#
# Remove once the upstream "btintel_pcie: fix D-state transitions and PM flows"
# series lands in the running kernel.

module=btintel_pcie
marker=/run/btintel-pcie-sleep-unloaded

case "$1" in
pre)
	if [ -d "/sys/module/$module" ]; then
		if modprobe -r "$module"; then
			touch "$marker"
		else
			echo "failed to unload $module; sleep may be blocked" >&2
		fi
	fi
	;;
post)
	if [ -e "$marker" ]; then
		rm -f "$marker"
		modprobe "$module" || echo "failed to reload $module" >&2
	fi
	;;
esac

exit 0
