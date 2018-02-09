# kaldi-icsi
Kaldi ICSI data recipe:
- cloned AMI one
- add ICSI words by CMUdict Phonetisaurus G2P
- use pre-downloaded data (the headset mix plus NXP annot.) from [web](http://groups.inf.ed.ac.uk/ami/icsi/download/)

# Results:
`icsi/s5$ for d in exp/ihm/tri3/decode_*; do grep Sum $d/*scor*/*ys | utils/best_wer.sh; done
%WER 58.7 | 3749 23117 | 53.7 28.6 17.7 12.4 58.7 79.9 | -1.326 | exp/ihm/tri3/decode_dev_ami_fsh.o3g.kn.pr1-7/ascore_15/dev.ctm.filt.sys
%WER 64.5 | 3749 23121 | 47.7 32.6 19.7 12.2 64.5 82.3 | -1.308 | exp/ihm/tri3/decode_dev_ami_fsh.o3g.kn.pr1-7.si/ascore_15/dev.ctm.filt.sys
%WER 48.9 | 4842 31180 | 61.9 19.5 18.6 10.8 48.9 76.4 | -1.259 | exp/ihm/tri3/decode_eval_ami_fsh.o3g.kn.pr1-7/ascore_15/eval.ctm.filt.sys
%WER 53.5 | 4842 31175 | 57.0 22.9 20.1 10.5 53.5 78.6 | -1.371 | exp/ihm/tri3/decode_eval_ami_fsh.o3g.kn.pr1-7.si/ascore_14/eval.ctm.filt.sys`
