#!/bin/bash

#adapted from fisher dict preparation script, Author: Pawel Swietojanski

dir=data/local/dict
mkdir -p $dir

echo "Creating ICSIAMI dictionary; use AMI dict plus generate missing pronuncations"

if ! command -v phonetisaurus-apply >/dev/null 2>&1 ; then
  echo "$0: Error: the Phonetisaurus G2P is not available or compiled" >&2
  echo "$0: Error: To install it, follow https://github.com/AdolfVonKleist/Phonetisaurus" >&2
  exit 1
fi

cp ../../ami/s5b/data/local/dict/silence_phones.txt $dir
cp ../../ami/s5b/data/local/dict/optional_silence.txt $dir
cp ../../ami/s5b/data/local/dict/nonsilence_phones.txt $dir
cp ../../ami/s5b/data/local/dict/extra_questions.txt $dir
cp ../../ami/s5b/data/local/dict/lexicon.txt $dir/lexicon.ami.txt

# [ ! -f $dir/lexicon.txt ] && exit 1;

# This is just for diagnostics:
cat data/local/annotations/train.txt  | \
  awk '{for (n=6;n<=NF;n++){ count[$n]++; } } END { for(n in count) { print count[n], n; }}' | \
  sort -nr > $dir/word_counts

awk '{print $1}' $dir/lexicon.ami.txt | \
  perl -e '($word_counts)=@ARGV;
   open(W, "<$word_counts")||die "opening word-counts $word_counts";
   while(<STDIN>) { chop; $seen{$_}=1; }
   while(<W>) {
     ($c,$w) = split;
     if (!defined $seen{$w}) { print; }
   } ' $dir/word_counts > $dir/oov_counts.txt

cat $dir/oov_counts.txt | awk '{print tolower($2)}' > $dir/oov.txt
# This runs only with python 2.7 - ToDO for python 3
phonetisaurus-apply --model local/CMUdict.fst \
		    --word_list $dir/oov.txt > $dir/oov-phonetisaurus.txt

cat $dir/oov-phonetisaurus.txt | awk '{print toupper($0)}' > $dir/oov-phonetisaurus-UC.txt
cat $dir/lexicon.ami.txt $dir/oov-phonetisaurus-UC.txt | sort -u > $dir/lexicon.txt

awk '{print $1}' $dir/lexicon.txt | \
  perl -e '($word_counts)=@ARGV;
   open(W, "<$word_counts")||die "opening word-counts $word_counts";
   while(<STDIN>) { chop; $seen{$_}=1; }
   while(<W>) {
     ($c,$w) = split;
     if (!defined $seen{$w}) { print; }
   } ' $dir/word_counts > $dir/oov_counts.txt

# echo "*OOVs are:"
head -n 20 $dir/oov_counts.txt

utils/validate_dict_dir.pl $dir
