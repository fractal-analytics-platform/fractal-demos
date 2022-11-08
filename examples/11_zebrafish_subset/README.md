**IMPORTANT**: The `BASE_FOLDER_EXAMPLE` at the top of the script needs to be adapted to point to the examples folder of the user you submit the example from.

The zebrafish example data is only available on the Pelkmans lab server.

This example currently only runs on a subset of the zebrafish example data. There are 2 limitations:
1. The full data contains some wells where images overlap, which is not currently supported
2. We're having an issue with filename prefixes, thus the filenames needed to be renamed. Should be solved soon. See here: https://github.com/fractal-analytics-platform/fractal-tasks-core/issues/189


This example ran successfully with:   
* `fractal-server==0.3.5, fractal-client==0.2.9, fracal-tasks-core==0.2.6`
