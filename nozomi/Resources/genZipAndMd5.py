#coding:utf8
import zipfile
import hashlib
import os
def tranverse(cur):
    ret = []
    files = os.listdir(cur)
    for i in files:
        name = os.path.join(cur, i)
        if os.path.isdir(name):
            ret.append(name)#compress file directory
            n = tranverse(name)
            ret += n
        elif name[-4:] == '.lua':
            ret.append(name)
    return ret
allLuaFile = tranverse('.')
print allLuaFile

zipFile = zipfile.ZipFile('test1.zip', 'w')
for i in allLuaFile:
    zipFile.write(i)
zipFile.commet = "test zip"
zipFile.close()


m = hashlib.md5()
f = open('test1.zip').read()
m.update(f)
nf = open('version', 'w')
nf.write(m.hexdigest())
nf.close()

os.system('mv test1.zip ../')
os.system('mv version ../')

