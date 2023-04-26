#! /bin/bash

function CheckFile
{
 FILES=$(ls /root/)
 #       echo "$FILES"
 #<<'COMMENT'
 RST=0
 for FILE in $FILES
 do
	 if [[ $FILE =~ "checkfile" ]];then
	 RST=1 # exit
	 break
         fi
 done
 echo $RST
 #COMMENT
}

function SetNode
{
	RES=$(curl -o /dev/null -s -w "%{http_code}\n" -v -X PUT "http://127.0.0.1:9090/proxies/$1" -H "Authorization: Bearer 12345678" -d "{\"name\": \"$2\"}")
	echo $RES
}

if [ $(CheckFile) == 1 ];then
        echo "checkfile exsit"
	rm /root/checkfile
	echo "canceled it"
fi

scp -o StrictHostKeyChecking=no root@"chsg.matthuo.space":/root/checkfile /root/
if [ "$?" -ne "0" ];
then
    echo "FAIL1"
    scp -o StrictHostKeyChecking=no root@"chsg.matthuo.space":/root/checkfile /root/
    if [ "$?" -ne "0" ];then
	    echo "FAIL2"
	    scp -o StrictHostKeyChecking=no root@"chsg.matthuo.space":/root/checkfile /root/
	    if [ "$?" -ne "0" ];then
		    echo "FAIL3"
	    else
		    echo "SUCCESS3"
            fi
    else
	    echo "SUCCESS2"
    fi
else
    echo "SUCCESS1"
fi
if [ $(CheckFile) == 1 ];then
	echo "server has checkfile"
	# check node and switch tw
	RES=$(SetNode "Proxies" "Auto - TWFallBack")
	if [ $RES = "204" ];then
		echo "switch Proxies tw success"
	elif [ $RES = "400" ];then
		echo "switch Proxies tw fail due to Bad Request"
	elif [ $RES = "404" ];then
		echo "switch Proxies tw fail due to Not Found"
	fi

	RES2=$(SetNode "Netflix" "Auto - TWFallBack")
	if [ $RES2 = "204" ];then
		echo "switch Netflix tw success"
	elif [ $RES2 = "400" ];then
		echo "switch Netflix tw fail due to Bad Request"
	elif [ $RES2 = "404" ];then
		echo "switch Netflix tw fail due to Not Found"
	fi
	echo "switch tw success"
else
	echo "server has not checkfile"
	# check node and recovery sg
 	RES=$(SetNode "Proxies" "Auto - SGFallBack")
	#echo "print1 : $RES"
	if [ $RES = "204" ];then
		echo "switch Proxies sg success"
	elif [ $RES = "400" ];then
		echo "switch Proxies sg fail due to Bad Request"
	elif [ $RES = "404" ];then
		echo "switch Proxies sg fail due to Not Found"
	fi
	RES2=$(SetNode "Netflix" "Auto - SGFallBack")
	if [ $RES2 = "204" ];then
		echo "switch Netflix sg success"
	elif [ $RES2 = "400" ];then
		echo "switch Netflix sg fail due to Bad Request"
	elif [ $RES2 = "404" ];then
		echo "switch Netflix sg fail due to Not Found"
	fi
	
	echo "recovery sg success"
fi
echo `date "+%Y-%m-%d %H:%M:%S"`
