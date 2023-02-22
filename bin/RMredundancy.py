# _*_ encoding: utf-8 _*_
'''
@File : RMredundancy.py
@TIME : 2023/02/06 10:CURRENT_MONUTE:21
@AUTHOR : Jin Jiazheng
@VERSION : 1.0
@Contact : jinjiazhengxiao@163.com
@LISCENCE : None
'''

# here put the import lib
import sys,os
def Readaln(files):
    redict = {}
    f1 = open(files,'r')
    for line in f1:
        iterms = line.strip().split()
        k,start,end,maps = iterms[:4]
        mapsS = iterms[4]
        mapsE = iterms[5]
        if k not in redict:
            redict[k] = []
        redict[k].append([int(start),int(end),maps,int(mapsS),int(mapsE)])
    f1.close()
    #print(redict["SUPER_X1"])
    return redict

def inters(ls):
    raw1,raw2,m1,m2 = ls 
    sortel = list(sorted(ls))
    #print(sortel,ls)
    inds1 = sortel.index(raw1)
    inds2 = sortel.index(raw2)
    inde1 = sortel.index(m1)
    inde2 = sortel.index(m2)
    #print(inds2 - inds1,inde2 - inde1)
    if  raw1 == m1 or raw2 == m2:
        return True
    if raw1 !=raw2 and m1 != m2:
        if ((abs(inds2 - inds1) != 1) or (abs(inde2 - inde1) != 1)):

            return True 
    else:
        if (raw1 == raw2 and abs(inde2 - inde1) >1) or (m1 == m2 and abs(inds2 - inds1) >1):
            return True
    return False

def GetMaps(ls1,Lista):
    for Ls in Lista:
        s1,s2,maps,mapsS,mapsE = Ls
        e1,e2,kmy,eY1,eY2 = ls1
        local1 = [e1,e2,s1,s2]
        local2 = [eY1,eY2,mapsS,mapsE]
        key1 = inters(local1)
        if key1:
            if kmy == maps:
                key2 = inters(local2)
                if key2:
                    return True 
    return False 

def ReadMaf(files,fileout):
    redict = {}
    f2 = open(files,'r')
    outs = open(fileout,'w')
    for line in f2:
        iterms = line.strip().split()
        k,star,ends = [iterms[i] for i in [6,8,9]]
        kY,starY,endsY = [iterms[i] for i in [1,3,4]]
        if k not in alnDict:
            continue
        keepS = GetMaps([int(star),int(ends),kY,int(starY),int(endsY)],alnDict[k])
        if keepS:
            outs.write('%s'%(line))
    f2.close()
    outs.close()
def main():
    global alnDict
    f1aln,filemaf,outmaf = sys.argv[1:] 
    alnDict = Readaln(f1aln)
    ReadMaf(filemaf,outmaf)
if __name__ ==  "__main__":
    main()