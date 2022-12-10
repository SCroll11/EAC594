#OPS435-FinalAssignment-DanielYip
from openpyxl import Workbook
import datetime
import os
import sys
import time
from datetime import datetime
import numpy as np
import matplotlib.pyplot as plt

#Function to get the sum of total CPU usage from specified user using ps command
def getcpu(user):
  #Awk to filter first column based on username, and sum all contents of third column
  cmd = 'ps -aux | awk \'($1=="' + user + '")\' | awk \'{sum+=$3} END {print sum}\''
  fp = os.popen(cmd)
  #Get stdout from popen command
  res = fp.read()
  return res.strip()

#Function to get the sum of total MEMORY usage from specified user using ps command
def getmem(user):
  #Awk to filter first column based on username, and sum all contents of fourth column
  cmd =	'ps -aux | awk \'($1=="' + user + '")\' | awk \'{sum+=$4} END {print sum}\''
  fp = os.popen(cmd)
  #Get stdout from popen command
  res = fp.read()
  return res.strip()

#Function to get the sum of PIDs  from specified user using ps command
def getpid(user):
  #Awk to filter first column based on username, then use wc to get total of lines
  cmd = 'ps -aux | awk \'($1=="' + user + '")\' | wc -l'
  fp = os.popen(cmd)
  #Get stdout from popen command
  res = fp.read()
  return res.strip()

#Store a list of all users in /tmp/ops435users. This list will be called in a for loop to iterate through all users
cmd = 'ps -aux | awk \'{print $1}\' | sort | uniq > /tmp/ops435users'
os.popen(cmd)
time.sleep(1)

#Set first argument to monitoruser variable and date variables
monitoruser = sys.argv[1]
now = datetime.now()
datestr = now.strftime("%d/%m/%Y %H:%M:%S")

#If first argument is 'all', then spreadsheet of all users will be created
if monitoruser == 'all':
  #Create workbork, activate worksheet, and append headers
  wb = Workbook()
  ws = wb.active
  ws.append(["Username", "Total PIDs", "Total CPU Time", "Total Memory Usage"])

  #For loop to iterate through all users from /tmp/ops435users
  users = open('/tmp/ops435users','r')
  for line in users:
    line = line.strip()
    #Run getCPU function for specfied user
    cpu = getcpu(line)
    #Run getMEM function for specified user
    mem = getmem(line)
    #Run getPID function for specified user
    pid = getpid(line)
    #Append all values for user to worksheet
    ws.append([line, pid, cpu, mem])
 
  #Close /tmp/ops435users and save workbook
  users.close()
  wb.save("MemoryUsageAll.xlsx")

#If first argument is not 'all', then assume first argument is name of user
else:
  #Set second argument as the duration variable
  duration = sys.argv[2]

  #If statement to check if username specified is in /tmp/ops435users. If not, exit with error
  if monitoruser in open('/tmp/ops435users').read():
    #Get the last character of duration variable and set the appropriate multiplier to its equivalent in seconds
    lastchar = duration[-1]
    if lastchar == 's' or lastchar == 'S':
      multiplier = 1
    elif lastchar == 'm' or lastchar == 'M':
      multiplier = 60
    elif lastchar == 'h' or lastchar =='H':
      multiplier = 3600
    else:
      exit("Invalid time entered")

    #Get the number in duration variable (exluding last character) and multiply with multiplier. This will give the
    #total time to monitor in seconds
    durationNum = int(duration[:-1])
    durationNum = durationNum * multiplier

    #Create a new list. For each second (from durationNum) run the getmem function on specfied user and append the resulting
    #value to memorylist as float
    memorylist = [] 
    for i in range(durationNum):
      memoryusage = getmem(monitoruser)
      memorylist.append(float(memoryusage))
      time.sleep(1)

    #Set the x axis to duration in seconds, set the y axis to memorylist list
    x = np.arange(1,durationNum + 1)
    y = memorylist

    #plot the reults using matplot
    plt.title(monitoruser + "'s Memory Usage " + datestr)
    plt.xlabel("Time (seconds)")
    plt.ylabel("Memory Usage %")
    plt.plot(x, y, color ="Blue")
    plt.savefig('MemoryGraph.png')
  else:
    exit("Invalid User Entered")
