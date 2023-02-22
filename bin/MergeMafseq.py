# _*_ encoding: utf-8 _*_
'''
@File : RMredundancyseq.py
@TIME : 2023/02/06 22:CURRENT_MONUTE:09
@AUTHOR : Jin Jiazheng
@VERSION : 1.0
@Contact : jinjiazhengxiao@163.com
@LISCENCE : None
'''

# here put the import lib
import sys,os
f1 = open(sys.argv[1],'r')
keepRuns = []
for line in f1:
    iterms = line.strip().split('-')
    keepRuns.append(iterms[0])
f1.close()
f2 = open(sys.argv[2],'r')
querdict = {}
tardict = {}
tarn = 0
quern = 0
for line in f2 :
    if line.startswith('#'):
        continue
    iterms = line.strip().split()
    if "target" in line:
        tarn += 1
        tardict[str(tarn)] = iterms[-1]
    if "query" in line:
        quern += 1
        querdict[str(quern)] = iterms[-1]
f2.close()


target = ""
query = ""
for key in keepRuns:
    target += tardict[key]
    query += querdict[key]

f3 = open(sys.argv[3],'w')
f3.write('%d %d\n' %(2,len(target)))
f3.write('%-20s %s\n' % ("target",target))
f3.write('%-20s %s\n' % ("query",query))
f3.close()