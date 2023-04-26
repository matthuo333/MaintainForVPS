#! /bin/bash
function GetCpu  
{
#       CpuValue=`ps -p $1 -o pcpu |grep -v CPU | awk '{print $1}' | awk -F. '{print $1}'`  
        CpuValue=$(top -b -n1 | grep $1 | head -1 | awk '{print $9}'| awk -F. '{print $1}')
        echo $CpuValue
}

PID=$(ps -e|grep java|grep -v grep|awk '{print $1}')
if [ -z $PID ]; then
        echo "PID java not exist"
        nohup java -jar -Xms50m -Xmx200m -XX:MaxDirectMemorySize=50M -XX:MaxMetaspaceSize=80m /opt/jar/v2ray-proxy.jar --spring.config.location=/opt/jar/proxy.yaml > /dev/null 2>&1 &
        echo "Finish to start java"
else
        echo "java id: $PID"
        for((i=1;i<=10;i++));
        do
                echo $i  

                cpu=`GetCpu ${PID}`
                echo "java cpu: $cpu"
                if [ $cpu -gt 50 ];
                then
                {
                        echo “The usage of cpu is larger than 50%”
                        kill -9 ${PID}
                        echo "java is killed"
                        nohup java -jar -Xms50m -Xmx200m -XX:MaxDirectMemorySize=50M -XX:MaxMetaspaceSize=80m /opt/jar/v2ray-proxy.jar --spring.config.location=/opt/jar/proxy.yaml > /dev/null 2>&1 &
                        echo "Finish to restart java"
                        break
                }
                else
                {
                        echo “The usage of cpu is normal” 
                }
                fi
                sleep 3s   
        done    
fi
