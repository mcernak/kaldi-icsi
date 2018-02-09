#!/bin/bash

# Copyright 2015, Brno University of Technology (Author: Karel Vesely)
# Copyright 2014, University of Edinburgh (Author: Pawel Swietojanski), 2014, Apache 2.0

if [ $# -ne 1 ]; then
  echo "Usage: $0 <icsi-dir>"
  echo " <icsi-dir> is download space."
  exit 1;
fi

set -eux

dir=$1
mkdir -p $dir

# echo "Downloading annotations..."
# ToDo: from http://groups.inf.ed.ac.uk/ami/icsi/download/
ICSIannotations=/home/milos/data/ICSI_meeting_speech/ICSI_core_NXT.zip

if [ ! -d $dir/annotations ]; then
  mkdir -p $dir/annotations
  unzip -o -d $dir/annotations $ICSIannotations &> /dev/null
fi

[ ! -f "$dir/annotations/ICSI/ICSI-metadata.xml" ] && echo "$0: File ICSI-Metadata.xml not found under $dir/annotations." && exit 1;

# extract text from ICSI XML annotations,
local/icsi_xml2text.sh $dir

wdir=data/local/annotations
[ ! -f $wdir/transcripts1 ] && echo "$0: File $wdir/transcripts1 not found." && exit 1;

echo "Preprocessing ICSI transcripts..."
# fix some annotation
cat $wdir/transcripts1 | sed -e "s/ '/'/g" -e "s/\"//g" > $wdir/transcripts1a

# # replace NaN for some missing segment times boundaries ??
# cat $wdir/transcripts1a | grep NaN > $wdir/transcripts1NaN
# cat $wdir/transcripts1a | grep -v NaN > $wdir/transcripts1OK
# # sed -E 's/[\.,\?\!\:].\s+(NaN.)+/\t-/g' $wdir/transcripts1 > $wdir/transcripts1b
# sed -E 's/ [\.,\?\!\:]//g' $wdir/transcripts1NaN > $wdir/transcripts1NaNOK
# cat $wdir/transcripts1NaNOK $wdir/transcripts1OK > $wdir/transcripts1b
# sed -E 's/(NaN.)+/-/g' $wdir/transcripts1b > $wdir/transcripts1c
# local/icsi_split_segments.pl $wdir/transcripts1c $wdir/transcripts2 &> $wdir/log/split_segments.log

# or call just this
local/icsi_split_segments.pl $wdir/transcripts1a $wdir/transcripts2 &> $wdir/log/split_segments.log

# make final train/dev/eval splits; following Pawel's PhD thesis split
for dset in train eval dev; do
  grep -f local/split_$dset $wdir/transcripts2 > $wdir/$dset.txt
done


