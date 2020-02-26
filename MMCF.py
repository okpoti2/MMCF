# Author: Hanyang MSL Lab, Industrial Engineering
#
# Copyright (c) 2019 Prof. Jeong In-Jae
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#import the modeling package
from docplex.mp.model import Model
import sys

problemName = '64-4-1'
nodeFile = problemName+'.nod'
arcFile = problemName+'.arc'
mutFile = problemName+'.mut'
supFile = problemName+'.sup'
instanceInfo = [] # [commodity, nodes, arcs, cap_arcs]
numNodes = 0
numCommodity = 0
numArcs = 0
numCapacitatedArcs = 0
bigM = 99999999

#Read the node file
nodeFileData = open(nodeFile, "r")

for eachLine in nodeFileData:
    instanceInfo.append(int(eachLine))
numCommodity = instanceInfo[0]
numNodes = instanceInfo[1]
numArcs = instanceInfo[2]
nodeFileData.close()

#Read mutual capacity pointer file
mutualCapacityPointer = {}
mcpFileData = open(mutFile, "r")

for eachLine in mcpFileData:
    data = eachLine.split("	")
    mutualCapacityPointer[int(data[0])] = int(data[1])

mcpFileData.close()

#Read arc file
uniqueArcs = {}
arcCapacity = {}
mutualCapacity = {}
cost = {}
temp_arc = [0]*numCommodity
temp_cost = [0]*numCommodity
arcFileData = open(arcFile, "r")

for eachLine in arcFileData:
    data = eachLine.split("	")
    uniqueArcs[int(data[0])] = [int(data[1]),int(data[2])]
    mutualCapacity[int(data[0])] = int(data[6])
    if temp_arc[int(data[3])-1]==0:
        temp_arc[int(data[3])-1] = [0]*numArcs
        temp_arc[int(data[3])-1][int(data[0])-1]=int(data[5])
    else:
        temp_arc[int(data[3])-1][int(data[0])-1]=int(data[5])
    if temp_cost[int(data[3])-1]==0:
        temp_cost[int(data[3])-1] = [bigM]*numArcs
        temp_cost[int(data[3])-1][int(data[0])-1] = float(data[4])
    else:
        temp_cost[int(data[3])-1][int(data[0])-1] = float(data[4])
    

for i in range(numCommodity):
    arcCapacity[i+1] = temp_arc[i]    
    cost[i+1] = temp_cost[i] 
    
arcFileData.close()


#Read sup file
supplyDemand = {}
temp_supDem = [0]*numCommodity
supFileData = open(supFile, "r")


for eachLine in supFileData:
    data = eachLine.split("	")
    if temp_supDem[int(data[1])-1]==0:
        temp_supDem[int(data[1])-1] = [0]*numNodes
        temp_supDem[int(data[1])-1][int(data[0])-1]=int(data[2])
    else:
        temp_supDem[int(data[1])-1][int(data[0])-1]=int(data[2])

for i in range(numCommodity):
    supplyDemand[i+1] = temp_supDem[i]  
    
supFileData.close()


#---------------------------Solve the math model------------------------------
mmcf = Model(name='Min cost multi-commodity network flow problem') # model object and name
#
C = [(a,k) for a in uniqueArcs.keys() for k in range(numCommodity)] #decision variable indexer         
X = mmcf.continuous_var_dict(C,lb=0,name="X") 

objFunc = mmcf.sum(cost[k+1][a-1]*X[a,k] for (a,k) in C) #objective function
mmcf.minimize(objFunc)

#constraint 1
for i in range(numNodes):
    for k in range(numCommodity):
        sumIn = 0
        sumOut = 0
        for key,value in uniqueArcs.items():
            if value[0]==(i+1):
                sumIn +=X[key,k]
            elif value[1]==(i+1):
                sumOut +=X[key,k]
        const1=sumIn-sumOut==supplyDemand[k+1][i]
        mmcf.add_constraint(const1)
 

#constraint 2
for (a,k) in C:
    maxVal = sys.float_info.max
    if arcCapacity[k+1][a-1]==-1:
        const2=X[a,k]<=maxVal
        mmcf.add_constraint(const2)
    else:
        const2=X[a,k]<=arcCapacity[k+1][a-1]
        mmcf.add_constraint(const2)
        
#constraint 3
for a in uniqueArcs.keys():
    lhs = mmcf.sum(X[a,k] for k in range(numCommodity))
    if mutualCapacity[a]!=0:
        const3=lhs<=mutualCapacityPointer[mutualCapacity[a]]
        mmcf.add_constraint(const3)


mmcf.solve()
print("MMCF objective function value is ",mmcf.objective_value)

