# CIS II - Programming Assignment (Matlab)
Luiza Brunelli and Pranhav Sundararajan

# Project Organization
The CISPA_MATLAB folder contains four directories: programs, PA2 Student Data, output, and tests. For the main pa2_run_script.m script, the PA2 Student Data directory must contain all of the input text files and must be at the same level as programs. Inside the programs directory and inside helper_functions is where all the code files are located and used by the main script pa2_run_script.m and the main function assignment_2.m. Again, for proper use, one has to simply download the zip file for this repository or clone it, enter into CISPA_MATLAB/programs and run the pa2_run_script.m script. This will create an output directory inside CISPA_MATLAB in which the resulting output file will be placed. Upon downloading this repository, the output folder will already contain outout files for each dataset. These files are produced from our code inside this repository. These files will be overwritten when the pa2_run_script.m script is run again.

## Files
pa2_run_script.m - Main script that when run calls assignment_2.m. This script allows the user to set the parameters for assignment_2.m, choosing whether the input is a debugging or unknown file and what file letter to use.

assignment_2.m - Main function to run the programming assignment.

find_transformation.m - Calculates the rigid transformation (rotation and translation) between two sets of 3D points.

invert_transform.m - Inverts a rigid body transformation.

pivot_calibration.m - Performs pivot calibration to find the location of a pivot point.

read_block.m - Helper function to read a block of 3D-coordinate data from a file.

read_calbody.m - Reads the calibration body file (calbody.txt).

read_calreadings.m - Reads the calibration readings file (calreadings.txt).

read_optpivot_data.m - Reads optical pivot data from a file.

read_pivot_data.m - Reads EM pivot data from a file.

compute_transformations.m - Computes the transformations F_D, F_A, and C_expected.

problem4a.m - Solves problem 4a.

problem4b.m - Solves problem 4b.

problem4d.m - Solves problem 4d.

problem5.m - Solves problem 5.

problem6.m - Solves problem 6.






