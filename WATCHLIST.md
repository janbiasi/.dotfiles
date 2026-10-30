# Watchlist

## Issues

### Lid close: Bluetooth blocks suspend and hibernation

Last checked: 2026-10-30. Status: working after reboot; recurrence and hibernation remain unverified.

#### Incident

- 2026-10-29 17:37 CET: closing the lid started suspend-then-hibernate.
- At 19:38, the Intel Bluetooth device failed to reset/reprobe during the hibernation transition. `btintel_pcie` returned `-16` (`Device or resource busy`), blocking hibernation.
- Subsequent suspend attempts failed roughly every 30 seconds until 2026-10-30 01:03. The laptop stayed awake with the lid closed; the screen was reportedly still on. Logs do not establish a complete system freeze.

#### Verification so far

- Unloading `btintel_pcie` allowed a short suspend/resume test to complete successfully. The module was reloaded afterward.
- After reboot, a short suspend-then-hibernate request completed successfully at 16:32 on October 30. It resumed after five seconds, before reaching hibernation.
- Kernel `7.2.11-arch1-1` and Intel firmware package `20260916-1` were unchanged at the latest check. There is no evidence that an update fixed this; rebooting appears to have cleared the stuck state.
- No persistent workaround was installed.

#### Watch for

- Laptop remains warm or screen stays on with the lid closed.
- Sleep works initially but fails when transitioning to hibernation about two hours later.
- Repeated `btintel_pcie_suspend` or `btintel_pcie_hibernate` failures with error `-16`.
- Bluetooth reprobe failures, firmware command timeouts, or `Failed to put system to sleep`.

Check the current boot, or replace `-b` with `-b -1` after rebooting:

```bash
journalctl -b -k --no-pager | rg -i 'btintel|Bluetooth.*(failed|timeout)|PM:.*(failed|error)'
journalctl -b -u systemd-suspend-then-hibernate.service -u systemd-suspend.service --no-pager
```

If it recurs, save the logs before making changes. A temporary diagnostic workaround that worked once is to unload Bluetooth before sleep and reload it after waking:

```bash
sudo modprobe -r btintel_pcie
sudo systemctl suspend
# After waking:
sudo modprobe btintel_pcie
```

Next meaningful verification: leave the lid closed long enough to exercise the hibernation transition, then check the logs. A brief suspend test cannot establish that this issue is fixed.

### Other warnings observed during sleep testing

These persisted during a successful short sleep cycle; neither was the explicit blocker in the incident:

- DisplayLink sleep hook: `/usr/lib/systemd/system-sleep/displaylink.sh` reports missing `/tmp/PmMessagesPort_out`.
- RAM sensor driver: `spd5118 20-0050` reports resume error `-6`.

Bluetooth also reports `Malformed DDC record (plen=11, remaining=1)` during firmware initialization. Its connection to the sleep failure is unproven.
