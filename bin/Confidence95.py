import sys,os
import numpy as np
f1 = open(sys.argv[1],'r')
rootL = []
for line in f1:
	iterms = line.strip().split()
	rootL.append(float(iterms[-1]))
rootL = list(sorted(rootL))
num = len(rootL)
medians = np.median(rootL)
indxk=int(len(rootL)*0.025)
ci = [rootL[indxk-1],rootL[-indxk]]
print('%s\t%s\t%s'%(medians,ci[0],ci[1]))
