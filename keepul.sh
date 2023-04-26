#! /bin/bash

function FileJust
{
	FILES=$(ls /usr/local/etc/v2ray/)
#	echo "$FILES"
#<<'COMMENT'
	RST=0
	for FILE in $FILES
	do
   		if [[ $FILE =~ "ipv4" ]];then
		RST=1 # current is ipv6 nf
		break
		elif [[ $FILE =~ "ipv6" ]];then
		RST=2 # current is ipv4 nf
       		break
      		fi
	done
	echo $RST
#COMMENT
#echo $FILES
}

function FindCheckFile
{
        FILES=$(ls /root/)
#       echo "$FILES"
#<<'COMMENT'
        RST=0
        for FILE in $FILES
        do
                if [[ $FILE =~ "checkfile" ]];then
                RST=1 
                break
                fi
        done
        echo $RST
#COMMENT
#echo $FILES
}

function ModifyFile
{
#	echo "canshu : $1"
	if [ $1 == 0 ];then
		echo "ModiyFile error"
	elif [ $1 == 1 ];then
		echo "ipv4 file to config file"
		mv /usr/local/etc/v2ray/config.json /usr/local/etc/v2ray/config-all-ipv6.json
		mv /usr/local/etc/v2ray/config-ipv4.json /usr/local/etc/v2ray/config.json
		
	else 
		echo "ipv6 file to config file"
		mv /usr/local/etc/v2ray/config.json /usr/local/etc/v2ray/config-ipv4.json
               	mv /usr/local/etc/v2ray/config-all-ipv6.json /usr/local/etc/v2ray/config.json
	fi
}

#<<'COMMENT'
a="不支持解锁非自制剧"
b="支持解锁非自制剧"

RESULT=$(/root/nf)
FileRes=$(FileJust)
echo "$FileRes"
c=$(echo "$RESULT"|awk 'NR==7{print}'|sed "s,\x1B\[[0-9;]*[a-zA-Z],,g")
d=$(echo "$RESULT"|tail -1|awk 'NR==1{print}'|sed "s,\x1B\[[0-9;]*[a-zA-Z],,g")
echo "ipv4:$c" "ipv6:$d"

#echo “str_${c}” “str_${d}”
#echo ${#c} ${#a}
#echo "$c" > /root/c.txt
#echo "$a" > /root/a.txt
#echo "$c"|sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" > /root/yes.txt
#echo "a= $a" "b= $b"

#<<'COMMENT'
if [ "$c"x = "$a"x ];then
	echo "Jump ipv4 locked!"
	if [ "$d"x = "$b"x ];then
		echo "Jump ipv6 unlocked"
		if [ $FileRes == 2 ];then
			echo "process1"
			ModifyFile $FileRes
			PID=$(ps -e|grep java|grep -v grep|awk '{print $1}')
			systemctl restart v2ray|kill -9 ${PID}|nohup java -jar -Xms50m -Xmx200m -XX:MaxDirectMemorySize=50M -XX:MaxMetaspaceSize=80m /opt/jar/v2ray-proxy.jar --spring.config.location=/opt/jar/proxy.yaml > /dev/null 2>&1 &
			if [ $(FindCheckFile) == 1 ];then
                        	rm /root/checkfile
                	fi
		elif [ $FileRes == 1 ];then
			echo "nothing due to ipv6"
			if [ $(FindCheckFile) == 1 ];then
                        	rm /root/checkfile
                	fi
		else
			echo "file error"
		fi
	else
		echo "Jump ipv6 locked"
		if [ $(FindCheckFile) == 0 ];then
			touch /root/checkfile
		fi

	fi
#<<'COMMENT'
elif [ "$c"x = "$b"x ];then
        echo "Jump ipv4 unlocked"
	if [ "$d"x = "$a"x ];then
		echo "Jump ipv6 locked"
		if [ $FileRes == 1 ];then
			echo "process2"
                       test=$(ModifyFile $FileRes)
			echo "modityres:$test"
                        PID=$(ps -e|grep java|grep -v grep|awk '{print $1}')
			echo "PID=$PID"
                        systemctl restart v2ray|kill -9 ${PID}|nohup java -jar -Xms50m -Xmx200m -XX:MaxDirectMemorySize=50M -XX:MaxMetaspaceSize=80m /opt/jar/v2ray-proxy.jar --spring.config.location=/opt/jar/proxy.yaml > /dev/null 2>&1 &
                	if [ $(FindCheckFile) == 1 ];then
                                rm /root/checkfile
                        fi
		elif [ $FileRes == 2 ];then
                        echo "nothing due to ipv4"
			if [ $(FindCheckFile) == 1 ];then
                                rm /root/checkfile
                        fi
                else
                        echo "file error"
                fi
        else
                echo "Jump ipv6 unlocked"
                echo "nothing due to all unlocked"
		if [ $(FindCheckFile) == 1 ];then
                        rm /root/checkfile
                fi
        fi
#COMMENT
else
        echo "ipv4 test error"
fi
#COMMENT