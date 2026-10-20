#!/bin/bash
# Copyright 2011 nvertigo & tomsax
# Distributed under the terms of the GNU General Public License v2

#set -x

#Dateien
MAINDIR="./"
SKINFILE="anthra_1920_OSE.skin"
TEMPLATEPATH="$MAINDIR/templates"
TEMPPATH="$MAINDIR/tmp"
FILELIST=""
PICEXT=".png"

#DEBUG=1

IFS=$'\012'


mktmpxml ()
{
    IFS=$'\012'
    rm -rf $TEMPPATH/$2 >/dev/null 2>&1
    for i in $(cat $1) ; do
        if [ $(echo $i|grep '^#') ] ; then
            continue
        fi
        MENUSTRING=$(echo $i | cut -d':' -f1)
        PICSTRING=$(echo $i | cut -d':' -f2)
	[ $DEBUG ] && echo "mktmpxml: Menustring: $MENUSTRING     Picturestring: $PICSTRING"
	sed -e s/MENUSTRING/$MENUSTRING/ -e s/PICSTRING/$PICSTRING$PICEXT/ \
	    <$TEMPLATEPATH/$2.tmpl >> $TEMPPATH/$2
    done
}


instmpxml ()
{
    INSPT=$(echo $1 | tr '[:lower:]' '[:upper:]')-INSPT
    [ $DEBUG ] && echo "instmpxml: InsertPoint: $INSPT"
    sed "/$INSPT/i MARKER" $MAINDIR/../$SKINFILE | sed -e "/MARKER/r $MAINDIR/tmp/$j" -e '/MARKER/d' \
        > $MAINDIR/../$SKINFILE.neu
    mv $MAINDIR/../$SKINFILE.neu $MAINDIR/../$SKINFILE
}


get_filelist ()
{
    for k in *.conf ; do
        MYFILE=$(basename $k .conf)
	if [ -e $TEMPLATEPATH/$MYFILE.tmpl ] ; then
	    FILELIST+="$MYFILE "
	    [ $DEBUG ] && echo "get_filelist: Filelist: $FILELIST"
	else
	    echo "error: $k depends on $TEMPLATEPATH/$MYFILE.tmpl - but the latter does not exist!"
	fi
    done
}

#main

if [[ -x  $MAINDIR ]] ; then
    rm -r $TEMPPATH >/dev/null 2>&1
    mkdir -p $TEMPPATH >/dev/null 2>&1

    [ -e $MAINDIR/../$SKINFILE ] && cp $MAINDIR/../$SKINFILE $MAINDIR/../$SKINFILE.bak

    get_filelist

    IFS=" "
    for j in $FILELIST ; do
        MY_FILE="$MAINDIR/$j.conf"
        mktmpxml $MY_FILE $j
        instmpxml $j
    done
    IFS=$'\012'

    rm -r $TEMPPATH >/dev/null 2>&1
else
    echo "'\$MAINDIR': $MAINDIR does not exist!"
    exit 1
fi
