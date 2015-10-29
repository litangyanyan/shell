dir=$(ls . | grep ".png")
for i in $dir
do
    newI=$(echo $i|tr -d 0-9)
    echo $newI
    echo $i
    $(mv $i $newI)
done   
