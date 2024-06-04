# _*_ encoding: utf-8 _*_
'''
@File : Depthformat.py
@TIME : 2022/03/24 15:CURRENT_MONUTE:33
@AUTHOR : Jin Jiazheng
@VERSION : 1.0
@Contact : jinjiazhengxiao@163.com
@LISCENCE : None
'''

# here put the import lib
from re import M
import sys,os
f1 = open(sys.argv[1],'r')
LogicDepth = float(sys.argv[2])
for line in f1:
    iterms = line.strip().split()
    ModeNumber = 0 if iterms[3] == "." else float(iterms[3])
    MeanNumber = 0 if iterms[4] == "." else float(iterms[4])
    FormNumber = round(ModeNumber/LogicDepth,2)
    print('\t'.join(iterms+[str(FormNumber)]))
f1.close()