#!/bin/bash

if [ $# != 1 ]
then
	echo Usage: $0 [dataSetName]
	echo Example: $0 CESM-ATM-Tylor-Data
	exit
fi 

dataSetName=$1

GNUPLOT_PATH=`which gnuplot`
if [ ! -x $GNUPLOT_PATH ]; then
	echo "Error: Please install GNUPLOT first and make sure the command 'gnuplot' works."
	exit
fi
LATEXMK_PATH=`which latexmk`
if [ ! -x $LATEXMK_PATH ]; then
	echo "Error: Please install latexmk first and make sure the command 'latexmk' works."
	exit
fi

envConfigPath="../../env_config.sh"
if [ -f $envConfigPath ]
then
	source $envConfigPath
fi

./modifyZCConfig ./zc.config checkingStatus COMPARE_COMPRESSOR
echo ./generateGNUPlot zc.config
./generateGNUPlot zc.config

mkdir compareCompressors
mv *.eps compareCompressors/

mkdir compareCompressors/data
mv *_*.txt compareCompressors/data

mkdir compareCompressors/gnuplot_scripts
mv *.p compareCompressors/gnuplot_scripts

#convert png files to eps files
echo "converting png files (if any) to eps files"
cd dataProperties
pngFileList=`ls *.png`
for file in $pngFileList
do
        sam2p $file ${file}.eps
done
cd -

echo ./generateReport zc.config $dataSetName
./generateReport zc.config $dataSetName

cd report
if [ -f z-checker-report.pdf ]; then
	make clean
fi
make
cd ..

if [ ! -f report/z-checker-report.pdf ]; then
	zip -r report.zip report
	echo "Notice: Your local latexmk cannot generate the report successfully, probably because of missing dependencies such as texlive. "
	echo "To solve this issue, you probably need to install texlive using root previlege."
	echo "Alternatively, you can also upload the source code (`pwd`/report.zip) of the report we generated to some online latex2pdf website such as Overleaf (https://www.overleaf.com)."
	exit
else
	echo "The report is generated successfully."
	echo "Here it is: `pwd`/report/z-checker-report.pdf"
fi
