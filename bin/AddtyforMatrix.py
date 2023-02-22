import sys,os,math
f1 = open(sys.argv[1],'r')
f2 = open(sys.argv[2],'r')
f3 = open(sys.argv[3],'w')
dics = {}
for line in f1:
	iterms = line.strip().split()
	if len(iterms) == 2:
		dics[iterms[0]] = False
	else:
		dics[iterms[0]] = iterms[-1]
f1.close()


for line in f2:
	iterms = line.strip().split()
	k1 = iterms[0]
	k2 = iterms[3]
	if k1 in dics and k2 in dics:
		continue
	if k1 not in dics and k2 not in dics:
		continue
	if k1 in dics:
		ty = dics[k1]
		mk = k1
	else:
		ty = dics[k2]
		mk = k2
	inte = iterms[-1]
	iterms[-1] = str(math.log(float(inte),10))
	itm = ty if ty else mk 
	iterms.append(itm)
	f3.write('%s\n'%('\t'.join(iterms)))
f2.close()
f3.close()
