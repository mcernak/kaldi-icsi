#!/bin/bash

# Copyright, University of Edinburgh (Pawel Swietojanski and Jonathan Kilgour)
#            Logitech (Milos Cernak)

if [ $# -ne 1 ]; then
  echo "Usage: $0 <icsi-dir>"
  exit 1;
fi

adir=$1
wdir=data/local/annotations

[ ! -f $adir/annotations/ICSI/ICSI-metadata.xml ] && echo "$0: File $adir/annotations/ICSI/ICSI-metadata.xml no found." && exit 1;

mkdir -p $wdir/log

JAVA_VER=$(java -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')

# if [ "$JAVA_VER" -ge 15 ]; then
  if [ ! -d $wdir/nxt ]; then
    echo "Downloading NXT annotation tool..."
    wget -O $wdir/nxt.zip http://sourceforge.net/projects/nite/files/nite/nxt_1.4.4/nxt_1.4.4.zip
    [ ! -s $wdir/nxt.zip ] && echo "Downloading failed! ($wdir/nxt.zip)" && exit 1
    unzip -d $wdir/nxt $wdir/nxt.zip &> /dev/null
  fi

  # if [ ! -f $wdir/transcripts0 ]; then
    echo "Parsing XML files (can take several minutes)..."
    nxtlib=$wdir/nxt/lib
    java -cp $nxtlib/nxt.jar:$nxtlib/xmlParserAPIs.jar:$nxtlib/xalan.jar:$nxtlib \
       FunctionQuery -c $adir/annotations/ICSI/ICSI-metadata.xml -q '($s segment)(exists $w1 w):$s^$w1' -atts nite:id agent \
       participant starttime endtime '$s' '@extract(($w w):$s^$w & ($w@c="." | $w@c="CM"), starttime,0,0)'\
      1> $wdir/transcripts0 2> $wdir/log/nxt_export.log
  # fi
# else
#   echo "$0. Java not found. Please install it."
#   exit 1  
#   # annots=ami_manual_annotations_v1.6.1_export
#   # wget -O $wdir/$annots.gzip http://groups.inf.ed.ac.uk/ami/AMICorpusAnnotations/$annots.gzip
#   # gunzip -c $wdir/${annots}.gzip > $wdir/transcripts0
# fi

#remove NXT logs dumped to stdio
grep -e '^Found' -e '^Obs' -e '^nite:id' -e '@' -i -v $wdir/transcripts0 > $wdir/transcripts1

exit 0;

