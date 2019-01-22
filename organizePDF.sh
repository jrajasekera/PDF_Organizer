#!/bin/bash

echo 'Organizing PDFs'

dirPDF="../BoogieBoard"
MATD=2700
AvgAllowedTimeDiff=1200

rm -rf fileDir

mkdir fileDir
cd fileDir
mkdir originalImages
mkdir organizedImgs
cd ..

dirOgImages="./fileDir/originalImages" 
cp -r -p $dirPDF/*.PDF $dirOgImages  


cd $dirOgImages

folderN=1
for fileName in ./*.PDF; do
		
	#check that file exists
	if [ -f $fileName ]; then
    		mkdir ../organizedImgs/tmp$folderN
		mv $fileName ../organizedImgs/tmp$folderN	
	
		fileOneDate=$(date -r ../organizedImgs/tmp$folderN/$fileName +'%Y%m%d%H%M%S')
		#echo "Looking for siblings" $fileName $fileOneDate

		for fileName2 in ./*.PDF; do
			
			#check that file2 exists
			if [ -f $fileName2 ]; then
			
				#echo "Checking" $fileName2
			
				fileTwoDate=$(date -r $fileName2 +'%Y%m%d%H%M%S')		
		

				
				for fileName3 in ../organizedImgs/tmp$folderN/*.PDF; do 
					#echo "fileName3" $fileName3
					fileThreeDate=$(date -r $fileName3 +'%Y%m%d%H%M%S')
					TimeDiff=$(dateutils.ddiff -i '%Y%m%d%H%M%S' $fileThreeDate $fileTwoDate)
					
					TD="$TimeDiff"
					TD=${TD//[s-]/}
					#echo "TD" $TD
					if [ $TD -le $AvgAllowedTimeDiff ]
					then
    						#echo "Found sibling" $fileName2 $fileTwoDate
						mv $fileName2 ../organizedImgs/tmp$folderN
						break
					fi
				done
				
			fi
		done	
		#((folderN++))
		folderN+=1
	fi

done

cd ..
cd ..

pwd
rm -rf $dirOgImages

cd ./fileDir/organizedImgs
read -p "Verify that files are correctly classified. Press enter to continue."

for groupDir in */ ; do
    echo __________________ $groupDir VERIFICATION ______________________________
    for file in $groupDir/*.PDF; do
	xdg-open $file
	
	read -r -n1 -p "Part of Doc? [y/l/n] " response  
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
	    echo ""
	    fuser -s -k -TERM $file
	elif [[ "$response" =~ ^([lL])+$ ]]
	then
	    echo " "
	    fuser -s -k -TERM $file
	    lastDir=${groupDir::-2}
	    mv $file $lastDir
	else
	    fuser -s -k -TERM $file
	    echo ""
	    nextDir=${groupDir::-1}
	    nextDir+=1

	    if [ ! -d "$nextDir" ]; then
		mkdir $nextDir
	    fi
	    
	    #echo Moving $file to $nextDir
	    mv $file $nextDir
	fi    
    done    
done

count=1
for groupDir in */ ; do
	if [ -z "$(ls -A $groupDir)" ]; then
		rm -rf $groupDir
	else
	        fileDate=""
	        fileList=""
		for file in $groupDir/*.PDF; do
		    fileList+=" $file"
		    fileDate=$(date -r $file +'%Y%m%d%H%M%S')	    
		done
		Date=${fileDate:0:4}-${fileDate:4:2}-${fileDate:6:2}
	       
		../../joinPDF.sh $fileList
		
		cp finished.pdf "$Date $count.pdf"
		cp "$Date $count.pdf" ..
		((count++))
	fi
done

cd ..
rm -rf organizedImgs

echo ____Class Assignments____
echo Math 3345 = TOP
echo CSE 2421 = LEFT
echo ECE 2020 = BOTTOM
echo CSE 2331 = RIGHT
