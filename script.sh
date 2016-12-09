for dir in `ls`
do
( knife cookbook upload $dir --force ) 

done
