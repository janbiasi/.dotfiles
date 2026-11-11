# Watchlist

## Issues

### Lid close: Bluetooth blocks suspend and hibernation

Last checked: 2026-11-11. Status: recurring known upstream bug; workaround installed via `etc/systemd/system-sleep/60-btintel-pcie.sh` (unloads `btintel_pcie` before sleep and reloads it after waking). Remove the hook once the upstream fix is in the running kernel.

#### Recurrences

- Boot ending 2026-11-04: 1 failed hibernation, then 1,092 failed suspends.
- 2026-11-09 20:35 lid close: hibernation at 22:36 failed with `btintel_pcie_hibernate` `-16`; 1,059 failed suspends until the lid opened at 07:30. The laptop was hot in the morning.
- 2026-11-11 17:52 lid close: hibernation at 19:54 failed the same way, with Bluetooth powered off. The controller reset, timed out on D3/D2, and then logged `Intel Soft Reset failed (-62)` and `Controller in error state`. It looped until the lid opened at 20:17.
- Kernel 7.2.11 (October) and 7.2.14 (November) are both affected, so the 2026-11-02 kernel/firmware update did not cause it. Turning Bluetooth off does not help because the driver's PM callbacks still run.

#### Upstream

- Reports: [EBUSY from PM callbacks aborts hibernate/suspend](https://ratatoskr.run/linux-bluetooth/2026/08/17480301) and [root-cause thread](https://ratatoskr.run/linux-bluetooth/2026/09/17532967/t). Possibly kernel bugzilla 221481.
- Fix: Kondratyev's "fix stale cache in set_dxstate fallback check" plus Ravindra's "fix PM flow for S0ix, S3 and S4", latest as the "fix D-state transitions and PM flows" series ([CI run](https://github.com/bluez/bluetooth-next/pull/834)). It was not applied to bluetooth-next as of 2026-11-11. Check lore.kernel.org/linux-bluetooth for an "Applied" reply.
- Upstream reports cover Lunar Lake (BE201 `8086:a876`); this laptop has the Panther Lake CNVi `8086:e476`.

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
