# $ awk -f sort.awk data
# BEGIN { FS=","; }
{
    myArray[$1]=$2;
}
END {
    for (name in myArray)
        printf ("%d\t%s\n", myArray[name], name) | "sort -k2 -h"
}
