# source settings file maker
import numpy as np

# parameters

xmin=[0.4,0]
xmax=[0.5,0]
ymin=[0.4,0]
ymax=[0.5,0]

totaltimesteps=300
timestepincrement=1

# getting field time series

fieldsource_1=[]
fieldsource_2=[]
if len(fieldsource_1) == 0 and len(fieldsource_2) == 0:
	for i in np.arange(0,totaltimesteps,timestepincrement):
            if i <=100:
    		fieldsource_1.append(1.5)
    		fieldsource_2.append(0)
            else:
                fieldsource_1.append(0)
                fieldsource_2.append(0)


# writing the file

f=open("sourcefield.txt","w+")

for i in range(0,len(xmin)):
    f.write(str(xmin[i])+" "+str(xmax[i])+" "+str(ymin[i])+" "+str(ymax[i])+"\n")

for i in range(0,len(fieldsource_1)):
    f.write(str(round(timestepincrement*i,4)) +" "+str(round(sourcemagnitude[0]*fieldsource_1[i],4))+" "+str(round(sourcemagnitude[1]*fieldsource_2[i],4))+" 0\n")

f.close()
