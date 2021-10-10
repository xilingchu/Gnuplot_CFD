# Gnuplot_CFD
An easy way to generate gnuplot scripts. In this scripts, you can choose variables and filenames to define the gnuplot scripts.

## Installation
The first thing you should install is the gnuplot. And you should also install LaTeX(Now the script only support term in latex, I will update other terminal in the future.)
That is a just a bash script, so you can use alias in you ~/.bashrc or use ln to create a symbolic link. If you choose the first one, you can use
```bash
alias [path to script]/gnuplot_cfd.sh
```
If you choose the second one, you can use
```bash
ln -s [path to script]/gnuplot_cfd.sh /bin/[command_name]
```

## Configuration
The first two lines in the script is the application of the PDF reader and Latex command.
And the third and fourth line is the default settings of the line types.

## Usage
The easiest way to get the usage is try to use -h option of the script.
```
GNUPLOT-CFD
The options of GNUPLOT_OPT
-h|--help: Help
-o|--output: The output of gnuplot script.
-f|--filename: You can use a list to select a file list include your data.
-v|--variables: The variables of the plot.
-c|--check: Check the variable in the files.
-e|--edit: Enter the edit mode.
The combination of the options.
If you want to check the variables in a file: you can use -c
If you want to generate a new file: you can use -o -f -v
If you want to edit a file: you can use -o -e
```
