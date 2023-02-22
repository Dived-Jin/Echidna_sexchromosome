import sys,os
def readbed(files):
	redict = {}
	with open(files,'r') as h1:
		for line in h1:
			iterms = line.strip().split()
			k = iterms[0]
			v = iterms[-1]
			ad = "chrY" if v.startswith('Y') else "chrX"
			redict[k] = ad
	h1.close()
	return redict

f1e,f1p,AGS,fa1,Type,outf = sys.argv[1:]
dicEr = readbed(f1e)
dicPr = readbed(f1p)
Af = open(AGS,'r')
AGLis = [i.strip() for i in Af]
dicCheck = {}
dicEch = {}
dicPla = {}
h2 = open(fa1,'r')
for line in h2:
	iterms = line.strip().split()
	famid,sps,Genid,genename,chrn  = iterms
	Genid = Genid[5:]
	chrn = chrn[2:]
	if sps == "Ggal":
		if famid not in dicCheck:
			dicCheck[famid] = []
		dicCheck[famid].append(Genid)
	elif sps == "Oana":
		chrs = dicPr[chrn]
		if chrs not in dicPla:
			dicPla[chrs] = {}
		if famid not in dicPla[chrs]:
			dicPla[chrs][famid] = [[],[]]
		dicPla[chrs][famid][0].append(Genid)
		if Genid in AGLis:
			dicPla[chrs][famid][1].append(Genid)
	else:
		chrs = dicEr[chrn]
		if chrs not in dicEch:
			dicEch[chrs] = {}
		if famid not in dicEch[chrs]:
			dicEch[chrs][famid] = [[],[]]
		dicEch[chrs][famid][0].append(Genid)
		if Genid in AGLis:
			 dicEch[chrs][famid][1].append(Genid)


dicsE = dicEch[Type]
dicsP = dicPla[Type]
familikey = set(list(dicsE.keys()) + list(dicsP.keys()))
famid = 0
outf = open(outf,'w')
outf.write('GenFamilyID\tEchinda_gene\tEchinda_ampliconic_gene\tEchinda_family_class\tPlatypus_gene\tPlatpus_ampliconic_gene\tPlatypus_family_class\tChichen\tFamily_station\n')
tlnum = 0
for i in familikey:
	famid += 1
	Elis = dicsE.get(i,[[],[]])
	Plis = dicsP.get(i,[[],[]])
	writeLs = ['Family_%s'%(famid)]
	Egen=";".join(Elis[0]) if Elis[0] else "None"
	EAG =";".join(Elis[1]) if Elis[1] else "None"
	Pgen = ";".join(Plis[0]) if Plis[0] else "None"
	PAG = ";".join(Plis[1]) if Plis[1] else "None"
	Chickenfamily = "Present" if i in dicCheck else "Not detectable"
	tlnum += len(Elis[0])
	tlnum += len(Plis[0])
	#for i in Elis[0]:
	#	print(famid,i)
	#print("\n".join(Elis[0])#Plis[0]))
	if EAG != "None":
		typE = "Ampliconic gene family"
	else:
		if len(Elis[0]) >1:
			typE = "Multicopy gene family"
		elif len(Elis[0]) == 1:
			typE = "Single copy gene family"
		else:
			typE = "None"
	if PAG != "None":
		typP = "Ampliconic gene family"
	else:
		if len(Plis[0]) >1:
                        typP = "Multicopy gene family"
                elif len(Plis[0]) == 1:
                        typP = "Single copy gene family"
                else:
                        typP = "None"
	writeLs += [Egen,EAG,typE,Pgen,PAG,typP,Chickenfamily]
	if typE == typP:
		if typE == "Ampliconic gene family":
			stat = "Share ampliconic gene family"
		elif typE == "Single copy gene family":
			stat = "Shared single copy gene family"
		else:
			stat = "Shared multicopy gene family"
	else:
		if (typE == "Ampliconic gene family" and typP == "Multicopy gene family") or (typP == "Ampliconic gene family" and typE == "Multicopy gene family"):
			stat = "Difficult confirm, unconsider"
		elif typE == "None":
			if Chickenfamily == "Present":
				stat = "lost in echidna"
			else:
				if typP == "Ampliconic gene family":
					stat = "platypus: Independent acquired ampliconic gene family"
				elif typP == "Multicopy gene family":
					stat = "platypus: Independent acquired multicopy gene family"
				else:
					stat = "platypus: Independent acquired single copy gene family"
		elif typP == "None":
			if Chickenfamily == "Present":
				stat = "lost in platypus"
			else:
				if typE == "Ampliconic gene family":
                                        stat = "echidna: Independent acquired ampliconic gene family"
                                elif typE == "echidna: Multicopy gene family":
                                        stat = "echidna: Independent acquired multicopy gene family"
                                else:
                                        stat = "echidna: Independent acquired single copy gene family"
		elif typP == "Single copy gene family":
			if typE == "Ampliconic gene family":
				stat = "Echidna: X_Linek duplicks gene family (ampliconic)"
			else:
				stat = "Echidna: X_Linek duplicks gene family (multicopy)"
		else:
			if typP == "Ampliconic gene family":
                                stat = "Platypus: X_Linek duplicks gene family (ampliconic)"
                        else:
                                stat = "Platypus: X_Linek duplicks gene family (multicopy)"
	writeLs += [stat]
	outf.write('%s\n'%('\t'.join(writeLs)))
outf.close()
print(tlnum)
