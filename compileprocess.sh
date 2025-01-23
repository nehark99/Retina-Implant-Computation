inputfile='main.cu'
outputFolder='out'
outputfile='out/process.o'
libfile='out/libprocess.so'


echo Files used: inputfile=$inputfile, outputfile=$outputfile, libfile=$libfile

if [ ! -d $outputFolder ]; then mkdir $outputFolder; fi
if [ -f $libfile ]; then rm $libfile; fi;
if [ -f $outputfile ]; then rm $outputfile; fi;

echo -e ""
if nvcc -Xcompiler=-fPIC,-O2,-Wall,-ansi -c $inputfile -o $outputfile; then
    echo -e "Successfully compiled $outputfile"

    if nvcc -shared -o $libfile $outputfile; then
        echo -e "Successfully compiled $libfile\n\n"
        exit 0
    
    else
        echo -e "\nFailed to compile $libfile\n\n"
        exit 1
    
    fi

else
    echo -e "\nFailed to compile $outputfile\n\n"
    exit 1

fi
