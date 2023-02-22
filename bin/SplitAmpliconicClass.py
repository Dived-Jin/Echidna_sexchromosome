import sys,os,re
def readRegion(files):
	redic = {}
	h1 = open(files,'r')
	for line in h1:
		iterms = line.strip().split()
		k,s,e,genid = iterms[:]
		redic[genid] = [k,s,e]
	h1.close()
	return redic

Echi,platyi,classfil = sys.argv[1:]
echidic = readRegion(Echi)
platyidic = readRegion(platyi)
echidic.update(platyidic)
Sharfile = open("shared.txt",'w')
Xlinkfile = open('Xlink.txt','w')
indepandentfile = open('indepandent.txt','w')
h2 = open(classfil,'r')
for line in h2:
	iterms = line.strip().split('\t')
	keys = iterms[-1]
	Eamk = iterms[2]
	Pamk = iterms[5]
	if 'ampliconic' not in keys:
		continue
	if "Share" in keys:
		wri = Sharfile 
	elif "Independent" in keys:
		wri = indepandentfile
	elif "X_Linek":
		wri = Xlinkfile
	else:
		wri = False
	if wri:
		ls = re.split(r';',Eamk) + re.split(r';',Pamk)	
		for subk in ls:
			wrils = echidic.get(subk,False)
			if wrils:
				k,s,e = wrils
				wri.write('%s\t%s\t%s\t1'%(k,s,e))
h2.close()
Sharfile.close()
Xlinkfile.close()
indepandentfile.close()
