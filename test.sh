inputfile='test.cu'
outputFolder='testout'
outputfile='testout/process.o'


echo Files used: inputfile=$inputfile, outputfile=$outputfile

if [ ! -d $outputFolder ]; then mkdir $outputFolder; fi
if [ -f $outputfile ]; then rm $outputfile; fi;

if nvcc -O3 -arch=sm_70 -std=c++11 $inputfile -o $outputfile; then
    echo -e "Successfully compiled $outputfile\n\n"
else
    echo -e "Failed to compile $outputfile\n\n"
fi

./$outputfile
