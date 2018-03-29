
UNITY = true;
PYTHON = true;
EEG_connected = true;
EYE_connected = true;
SIMULATE_DATA = false;
PCA_ICA = false;
UPDATE_INTEREST_SPHERES = true;
UPDATE_CAR_PATH = true;    
MARKER_STREAM = false; % Output event markers for BCI Lab

SAVE_RAW_DATA = false;
SAVE_EPOCHED_DATA = false;
PLOTS = false;

EPOCHED_VERSION = 8; % Different versions of the data. Look at readme in data folder for details.
SUBJECT_ID = '19';
BATCH = '21'; % First block in batch
nBLOCKS = 20; % Number of blocks to do in batch

EEG_WARNING_THRESHOLD = 500; % threshold for EEG data overwhich matlab will warn you that you are getting extreme values

smi_pixels_y = 1010; % Range of SMI eye-tracker in the y-direction (in pixels)
oculus_fov = 106.188; % Field of view of oculus in degrees (Unity lists it)
oculus_pixels_x = 1915; % Pixels in oculus in the horizontal direction, found empirically
allowedDiscrepency = 6*oculus_pixels_x/oculus_fov; % Number of degrees to expand the bounding box of billboards for fixation

n_chan = 64;
freq_eye = 60;
freq_unity = 75;
freq_eeg = 2048;
n_block_start_cues = 0;

% Thresholds for pupil radius to be considered valid data
blink_upper_thresh = 3.2;
blink_lower_thresh = 1.3;

% Dimensions of the chunks we are pushing to python
dimChunkForPython = [66, 385];

initialPath = true;
