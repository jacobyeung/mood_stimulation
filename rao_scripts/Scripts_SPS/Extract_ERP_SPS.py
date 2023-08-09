import numpy as np
from scipy.signal import find_peaks, butter, sosfiltfilt, zpk2sos


def extract_erp_sps(raw_data, fs, anatomy, peak_detection_channel, patient_id):
    # Determine stim times
    apeak = raw_data[peak_detection_channel, :]
    peak_values, peak_indices = find_peaks(np.abs(apeak))

    # Set threshold for each patient
    threshold_values = {
        "EC137": 34000,
        "EC139": 34000,
        "EC150": 2000,
        "EC153": 20000,
        "EC155": 34000,
    }
    threshold_value = threshold_values.get(patient_id, 0)

    select_indices = peak_indices[peak_values > threshold_value]
    min_diff = fs - int(0.04 * fs)  # Stimulation is at 1Hz
    max_diff = fs + int(0.04 * fs)

    pulse_time = []
    for i in range(len(select_indices) - 1):
        if min_diff < (select_indices[i + 1] - select_indices[i]) < max_diff:
            pulse_time.append(select_indices[i])

    if np.diff(pulse_time[-2:]) < min_diff:
        pulse_time.pop()

    if np.diff(pulse_time[-2:]) > fs * 2:
        pulse_time.pop()

    num_pulses = 20
    pulse = []

    end_samples = np.where(np.diff(pulse_time) > max_diff)[0]
    pulse_matches = pulse_time[: end_samples[0] + 1] - pulse_time[0]

    if end_samples[0] < num_pulses:
        for i in range(len(pulse_matches)):
            if i == 0:
                pulse.append(pulse_matches[i : end_samples[i]])
            elif i == len(pulse_matches) - 1:
                pulse.append(pulse_matches[end_samples[i - 1] + 1 :])
            else:
                pulse.append(pulse_matches[end_samples[i - 1] + 1 : end_samples[i]])

    for i in range(len(pulse)):
        pulse[i] = np.concatenate(
            (pulse[i], [pulse[i][-1] + fs])
        )  # The pulses are at 1 Hz

    # Manually select bad channels
    remove_chans = []
    select_chans = np.setdiff1d(np.arange(raw_data.shape[0]), remove_chans)
    select_chans_labels = anatomy[select_chans, 0]
    select_chans_regions = anatomy[select_chans, 3]
    raw_data = raw_data[select_chans, :]

    # Organize data into cells
    select_data = []
    pulse_match = []
    for i in range(len(pulse)):
        select_data.append(raw_data[:, pulse[i][0] - fs : pulse[i][-1] + fs])
        pulse_match.append(pulse[i] - (pulse[i][0] - fs))

    # Blanking parameters
    blank_before = int(fs * 0.005)
    blank_after = int(0.01 * fs)
    stim_starts = []
    stim_ends = []
    for i in range(len(pulse_match)):
        stim_starts.append(pulse_match[i] - blank_before)
        stim_ends.append(pulse_match[i] + blank_after)

    # Stimulus blanking
    blanked_data = select_data.copy()
    for k in range(len(pulse_match)):
        for i_stim in range(len(stim_starts[k])):
            replacement_values = (
                select_data[k][:, stim_starts[k][i_stim]]
                + select_data[k][:, stim_ends[k][i_stim]]
            ) / 2
            blanked_data[k][
                :, stim_starts[k][i_stim] : stim_ends[k][i_stim] + 1
            ] = np.tile(
                replacement_values,
                (1, stim_ends[k][i_stim] - stim_starts[k][i_stim] + 1),
            )

    # High-pass filter coefficients and gains
    z_H, p_H, T_H = butter(4, 2 * 1 / fs, "high")  # high pass above 1 Hz
    sos_H, G_H = zpk2sos(z_H, p_H, T_H)

    # Low-pass filter coefficients and gains
    z_L, p_L, T_L = butter(8, 2 * 100 / fs, "low")  # low pass below 100 Hz
    sos_L, G_L = zpk2sos(z_L, p_L, T_L)

    # Filtering
    bp_filt_data = blanked_data.copy()
    for k in range(len(pulse_match)):
        bp_filt_data[k] = sosfiltfilt(sos_H, G_H, bp_filt_data[k].T).T
        bp_filt_data[k] = sosfiltfilt(sos_L, G_L, bp_filt_data[k].T).T

        notch_freq = 60
        while notch_freq <= 200:
            z, p, T = butter(2, [notch_freq - 5, notch_freq + 5] / (fs / 2), "stop")
            sos, G = zpk2sos(z, p, T)
            bp_filt_data[k] = sosfiltfilt(sos, G, bp_filt_data[k].T).T
            notch_freq += 60

    # Align trials
    stim_trials = []
    mid_data = np.empty((len(pulse_match), len(raw_data), int(fs)))
    for k in range(len(pulse_match)):
        for i_stim in range(len(pulse_match[k])):
            mid_data[i_stim, :, :] = bp_filt_data[k][
                :,
                pulse_match[k][i_stim]
                - int(fs * 0.5) : pulse_match[k][i_stim]
                + int(fs * 0.5),
            ]
        stim_trials.append(mid_data.copy())

    # Calculate baseline and z-scored ERPs
    norm_evoked_all_chans = []
    norm_evoked_z = []
    erp = []
    z_erp = []
    se_erp = []
    se_z_erp = []

    baseline_time = np.arange(int(fs * 0.2), int(fs * 0.4))

    for k in range(len(pulse_match)):
        mean_baseline = np.nanmean(stim_trials[k][:, :, baseline_time], axis=2)
        std_baseline = np.nanstd(stim_trials[k][:, :, baseline_time], axis=2)

        norm_evoked_all_chans.append((stim_trials[k] - mean_baseline[:, :, np.newaxis]))
        norm_evoked_z.append(norm_evoked_all_chans[k] / std_baseline[:, :, np.newaxis])

        erp.append(np.nanmean(norm_evoked_all_chans[k], axis=0))
        z_erp.append(np.nanmean(norm_evoked_z[k], axis=0))

        se_erp.append(np.nanstd(norm_evoked_all_chans[k], axis=0) / np.sqrt(num_pulses))
        se_z_erp.append(np.nanstd(norm_evoked_z[k], axis=0) / np.sqrt(num_pulses))

    # Return relevant results
    return (
        erp,
        z_erp,
        norm_evoked_all_chans,
        norm_evoked_z,
        se_erp,
        se_z_erp,
        blank_after,
        blank_before,
        fs,
        select_chans_labels,
        select_chans_regions,
        remove_chans,
    )
