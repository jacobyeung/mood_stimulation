import numpy as np


def find_peak_values_time(num_pulses, ERP, norm_evoked_z, test_samples, p, pulse_after):
    num_channels = ERP[0].shape[0]

    peak_values_before = np.empty((num_pulses, num_channels))
    peak_values_after = np.empty((num_pulses, num_channels))
    peak_times_before = np.empty((num_pulses, num_channels), dtype=int)
    peak_times_after = np.empty((num_pulses, num_channels), dtype=int)

    trou_val_bef = np.empty((num_pulses, num_channels))
    trou_val_aft = np.empty((num_pulses, num_channels))
    trou_time_bef = np.empty((num_pulses, num_channels), dtype=int)
    trou_time_aft = np.empty((num_pulses, num_channels), dtype=int)
    percent_change = np.empty((num_pulses, num_channels))

    for i_channel in range(num_channels):
        for i_pulse in range(num_pulses):
            apeak_bef = np.abs(
                norm_evoked_z[Pulse_Before][i_pulse, i_channel, test_samples]
            )
            peak_values_before[i_pulse, i_channel] = np.max(apeak_bef)
            peak_times_before[i_pulse, i_channel] = np.argmax(apeak_bef)
            trou_val_bef[i_pulse, i_channel] = np.min(apeak_bef)
            trou_time_bef[i_pulse, i_channel] = np.argmin(apeak_bef)

            apeak_aft = np.abs(
                norm_evoked_z[pulse_after][i_pulse, i_channel, test_samples]
            )
            peak_values_after[i_pulse, i_channel] = np.max(apeak_aft)
            peak_times_after[i_pulse, i_channel] = np.argmax(apeak_aft)
            trou_val_aft[i_pulse, i_channel] = np.min(apeak_aft)
            trou_time_aft[i_pulse, i_channel] = np.argmin(apeak_aft)

            percent_change[i_pulse, i_channel] = (
                (
                    peak_values_after[i_pulse, i_channel]
                    - peak_values_before[i_pulse, i_channel]
                )
                / peak_values_before[i_pulse, i_channel]
            ) * 100

    return (
        peak_values_before,
        peak_values_after,
        peak_times_before,
        peak_times_after,
        percent_change,
    )
