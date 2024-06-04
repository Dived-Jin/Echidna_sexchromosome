# _*_ encoding: utf-8 _*_
'''
@File : dat2gff.py
@TIME : 2023/01/04 17:CURRENT_MONUTE:51
@AUTHOR : Jin Jiazheng
@VERSION : 1.0
@Contact : jinjiazhengxiao@163.com
@LISCENCE : None
'''

# here put the import lib
import sys,os,re
datf = open(sys.argv[1],'r')
outgff = open(sys.argv[2],'w')
outgff.write('##gff-version 3\n')
alls = datf.read()
iterms = alls.split('@')
oder = 0
for subiterms in iterms:
    klis = subiterms.split("\n")
    scaffoldid = klis[0]
    for substr in klis[1:]:
        Ilis = substr.strip().split()
        if len(Ilis) < 15:
            continue
        oder += 1
        IDname = "TR%s"%(oder)
        outgff.write('%s\n'%('\t'.join([scaffoldid,"TRF\tTandemRepeat",Ilis[0],Ilis[1],Ilis[7],"+\t.","ID=%s;PeriodSize=%s;CopyNumber=%s;PercentMatches=%s;PercentIndels=%s;Consensus=%s;"%(IDname,Ilis[2],Ilis[3],Ilis[5],Ilis[6],Ilis[13])])))
datf.close()
outgff.close()