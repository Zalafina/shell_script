#!/bin/bash

rm -f list_pack* file_list packsize;
filesizesum=0;
packsize=2090000;
packnum=1;
find media -name "*" | sort -f > file_list;
while read line;
do
    filepath=`echo $line`;
    if [ -d $filepath ];then
        filesize=4;
    else
        filesize=`du $filepath|awk '{print $1}'`;
    fi
    filesizecheck=$[filesizesum+filesize];
    if (($filesizecheck <= $packsize));then
        filesizesum=$filesizecheck;
    else
        echo pack$packnum : $filesizesum | tee -a packsize;
        packnum=$[packnum+1];
        filesizesum=$filesize;
    fi
    echo $filepath | tee -a "list_pack"$packnum;
done < file_list;
echo pack$packnum : $filesizesum | tee -a packsize;
packcount=1;
while (($packcount <= $packnum))
do
    echo packing mapdata$packcount.tar;
    cat list_pack$packcount | xargs tar cvpf mapdata$packcount.tar --no-recursion --group=media_rw --owner=media_rw --mode=775;
    packcount=$[packcount+1];
done;
rm -f list_pack* file_list;
