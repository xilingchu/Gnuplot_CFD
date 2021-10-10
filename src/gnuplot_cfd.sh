#!/usr/bin/bash
# This is a script for generating gnuplot script.  An easy and effective way to generate data visualization.
#------- Default Parameters settings -------#
# Settings of the default applications
PDFREADER=zathura
LC=pdflatex
# Settings of default line
lw=4; lc=1; dt=1
# Settings of default point
ps=4; pc=1; pt=1
#------- Dictionary of the Variables -------!
declare -A var=(
	['u']='u'
	['v']='v'
	['w']='w'
	['p']='p'
)

#------- Function Lib -------#
gnuplot_help(){
	echo GNUPLOT-CFD
	echo The options of GNUPLOT_OPT
	echo -h\|--help: Help
	echo -o\|--output: The output of gnuplot script.
	echo -f\|--filename: You can use a list to select a file list include your data.
	echo -v\|--variables: The variables of the plot.
	echo -c\|--check: Check the variable in the files.
	echo -e\|--edit: Enter the edit mode.
	echo The combination of the options.
	echo If you want to check the variables in a file: you can use -c
	echo If you want to generate a new file: you can use -o -f -v
	echo If you want to edit a file: you can use -o -e
}

str_plus(){
	printf '$1+'
}

str_brakets(){
	printf '<'$1'>'
}

# str_head(){
# }

str_lable(){
	printf "set $1label '\\Large $%s$'\n" "$(sed -e 's/ /\\\; /g' <<< "$2")"
}

# Default Settings
str_default(){
	printf "set term epslatex standalone color newstyle\n"
	printf "set key samplen 4 spacing 1.2\n"
	printf "set border lw 4\n"
}

str_ranges(){
	printf "set $1range[$2:$3]\n"
}

str_output(){
	printf "set output '${1%.*}.tex'\n"
}

str_fn(){
	printf "fn$1='$2'\n"
}

str_plot_l(){
	# printf "fn$1 u $2:$3 with l lw 4 title '$4-$5', %s\n" "\\"
	printf "fn$1 u $2:$3 every 1::$4::$5 with l lc $6 lw $7 dt $8 t '$9-${10}', %s\n" "\\"
}

str_plot_p(){
	printf "fn$1 u $2:$3 every 1::$4::$5 with p pc $6 ps $7 pt $8 t '$9-${10}', %s\n" "\\"
}

str_plot_lp(){
	printf "fn$1 u $2:$3 every 1::$4::$5 with lp lc $6 lw $7 dt $8 pc $9 ps ${10} pt ${11} t '${12}-${13}', %s\n" "\\"
}

get_var(){
	grep -E '^[[:blank:]]+[a-z]+\b' $1
}

get_lbeg(){
	grep -n -m 1 -E '^[[:blank:]]+[[:digit:]]+\.' $1|awk '{print $1}'|grep -E -o '[0-9]+'
}

get_lend(){
	wc -l $1|awk '{print $1}'
}

get_index(){
	index_out=0
	# eval temp_str="$1"
	# read -a temp_var <<< $temp_str
	read -a temp_var <<< "$1"
	for i in ${!temp_var[@]}
	do
		[ "${temp_var[$i]}" == $2 ] && index_out=$(($i+1)) && return $index_out
	done
	echo "The variable $2 doesn't exist in the File, please use -c\|--check to check the variable" ; exit 1
}

# find_var_max(){
# 
# }

#------- Getopt -------#
args="$(sed -r 's/(-+[A-za-z]+ )([^-]*)( |$)/\1"\2"\3/g' <<< $@)"
declare -a arg_lists="($args)"
set -- "${arg_lists[@]}"
GNUPLOT_OPT=`getopt -o hcef:o:v: -l help,check,edit,filename:,output:,variables: \
	     -n "$0" -- "$@"`
eval set  -- "$GNUPLOT_OPT"
while true
do 
	case "$1" in
		# Filename
		-h|--help) gnuplot_help ; shift ; exit 1 ;;
		-c|--check) flagc1=1; shift ;;
		-e|--edit) flage1=1; shift ;;
		-f|--filename) 
		# read -a temp_word <<< $2
		# [ ${#temp_word[@]} == 1 ]&&filename="$2"||(echo 'Please type just one variable in this option.' ; exit 1)
		read -a file_list <<< $2
		# read -a var_file <<< $(get_var $filename)
		flagf=1
		shift 2 ;;
		# Output filename
		-o|--output)
		read -a temp_word <<< $2
		[ ${#temp_word[@]} == 1 ]&&output="${2%.*}.gnu"||(echo 'Please type just one variable in this option.' ; exit 1) 
		flago=1
		shift 2 ;;
		# Variables
		-v|--variables)
		read -a var_list <<< $2
		xlable=${var_list[0]}
		ylable=${var_list[@]:1:`expr ${#var_list[@]}-1`}
		flagv=1
		shift 2 ;;
		--) shift ; break ;;
		*) echo 'Please choose the proper option!' ; gnuplot_help ; exit 1 ;;
	esac
done

# Judge if we should generate a new file
[ $flagf ] && [ $flagv ] && [ $flago ] && flagn=1
# Check the variable
[ $flagf ] && [ $flagc1 ] && flagc=1
# Edit mode
[ $flago ] && [ $flage1 ] && flage=1
# Judge if we should continue the code
[ $flagn ] | [ $flagc ] | { $flage } || (echo Please choose the proper option; exit 1)

#------- Check the variables -------#
if [ $flagc ]; then
	for ifile in "${file_list[@]}"
	do
		printf "Variables in $ifile are"
		printf "$(get_var $ifile|sed -r 's/[[:blank:]]+/ /g')\n"
	done
	exit 0
fi

#------- Get new gnuplot file -------#
if [ $flagn ]; then
	# Variables
	switch_plot=1
	# The header of the gnuplot file
	echo 'New gnuplot file generating now!'
	ls|grep $output && rm $output
	str_default >> $output
	str_output $output >> $output 
	str_lable 'x' $xlable >> $output
	str_lable 'y' "$ylable" >> $output
	# Define the filename
	for i_ifile in "${!file_list[@]}"
	do 
		ifile=${file_list[i_ifile]}
		str_fn $(($i_ifile+1)) $ifile >> $output
	done
	# Define the plot name
	for i_ifile in "${!file_list[@]}"
	do 
		ifile=${file_list[i_ifile]}
		line_s=$(get_lbeg $ifile)
		line_e=$(get_lend $ifile)
		read -a var_file <<< $(get_var $ifile)
		index_list=""
		for ivar in "${var_list[@]}"
		do 
			[ $switch_plot == 1 ] && printf 'plot ' >> $output && switch_plot=0
			temp_word="${var_file[@]}"
			get_index "$temp_word" ${ivar}
			index_list+="$? "
		done
		read -a index_list <<< $index_list
		for i in "${index_list[@]:1:`expr ${#index_list[@]}-1`}"
		do
			temp_str=${ifile##*/}
			temp_str=${temp_str%.*}
			str_plot_l $((i_ifile+1)) ${index_list[0]} $i $((line_s-1)) $((line_e-1)) $lc $lw $dt $temp_str ${var_file[$(($i-1))]} >> $output
			((lc++))
		done
	done
	# Delete the ',\' in the last line
	# Get the line number
	linenum=$(wc -l $output|awk '{print $1}')
	eval sed -e "'${linenum}s/, \\\/ /'" -i $output
fi

#------- Edit Mode -------#
if [ $flage ]; then
	cont=1
	openz=1
	echo Enter edit mode!
	while [ $cont == 1 ]
	do
		(gnuplot $output > /dev/null && $LC ${output%.*}.tex > /dev/null) || (echo The file cannot generate && exit 1)
		[ $openz == 1 ] && $PDFREADER ${output%.*}.pdf &
		openz=0
		cat -n $output
		echo "Three types of mode: edit(e), change(c), insert(i), delete(d), quit(q)"
		read -p '>> ' edit
		case $edit in
			e|edit)
				read -p 'Please choose the line number(The same as sed):' linen 
				echo 'The text you want to edit:' 
				read -a ctext
				eval sed -i -r \"$linen s/\(${ctext[0]}\) [^ ]+/\\1 ${ctext[1]}/\" \$output
			;;
			c|change)
				read -p 'Please choose the line number:' linen 
				echo 'The text you want to change:' 
				read ctext
				eval sed -i \"$linen c $ctext\" \$output 
			;;
			i|insert)
				read -p 'Please choose the line number:' linen 
				echo 'The text you want to add:'
				read ctext
				eval sed -i \"$linen i $ctext\" \$output 
			;;
			d|delete)
				read -p 'Please choose the line number:' linen 
				eval sed -i \"$linen d\" \$output 
			;;
			q|quit) 
			cont=0 
			;;
			*) 
				echo Please choose the proper option!
			;;
		esac
	done
fi
echo 'The gnuplot file generate sucessfully!'
