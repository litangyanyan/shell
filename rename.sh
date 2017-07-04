dir=$(ls . | grep ".png")
cnt=1
for i in $dir
do
    newI=$(echo $i|tr -d 0-9)
    newI=${cnt}$(echo $i|tr -d 0-9)
    cnt=`expr $cnt + 1`
    echo $newI
    echo $i
    $(mv $i $newI)
done   
