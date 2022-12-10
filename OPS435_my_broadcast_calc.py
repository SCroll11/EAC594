#OPS435 - Daniel Yip - Assignment 2

#Import sys (to capture arguments) and re (for regular expression matching) modules
import sys
import re

#Function to check if binary subnet mask (string) has contiguious 1's followed by contiguious 0's
#This will ensure the subnet entered is valid
def validsubnet(subnet):
  if re.fullmatch("1*0*", subnet) and len(subnet) == 32:
    pass
  else:
    exit("Invalid subnet mask")

#Function to convert decimal value (string) to hex (string). If decimal is less than 16, then include a leading 0
#eg. decimaltohex('15') = 0F
def decimaltohex(decimal):
  if decimal < 16:
    return "0" + hex(decimal)[2:]
  else:
    return hex(decimal)[2:]

#Function to convert decimal (integer) to binary (string) with leading 0's up to 8 bits
#eg. decimaltobinary(240) = '11110000'
def decimaltobinary(decimal):
  #Remove the leading '0b' from bin() function and left fill with zeros until 8 bits is reached
  binary = bin(decimal)[2:].zfill(8)
  return binary

#Function to convert binary (string) of 8 bits that represent the subnet mask into decimal (integer)
#eg. binarytodecimal('11110000') = 240
def binarytodecimal(binary):
  decimal = 0
  #Reverse the octect for decimal calculation
  binary = binary[::-1]
  for i in range(8):
    if binary[i] == '1':
      decimal = decimal + (2 ** i)
  return decimal

#Function to convert a hexidecimal (string) to binary (string) with leading 0's up to 4 bits
#eg. hextobinary('F') = 1111
def hextobinary(hex):
  hex = bin(int(hex, 16))
  #Remove the leading '0b' from bin() function and left fill with zeros until 4 bits is reached
  hex = hex[2:].zfill(4)
  return hex

#Function to calulate the broadcast address given the IP octects (list of integers) and binary subnet mask (string)
def calcbroadcast(ipoctects, mask):
  broadcastaddr = []
  #For loop to iterate through each octect
  for i in range(4):
    #Get the next 8 bits in subnet mask
    next8bits = mask[0:8]
    #If next8bits is all 1's, then the ip octect is the broadcastaddr octect. Remove the 8 bits that was analyzed from mask
    if next8bits == "11111111":
      broadcastaddr.append(ipoctects[i])
      mask = mask[8:]
    #If next8bits is all 0's, then the broadcastaddr octect is 255. Remove the 8 bits that was analyzed from mask
    elif next8bits == "00000000":
      broadcastaddr.append(int(255))
      mask = mask[8:]
    #Count the number of 1's in the next8bits. This will indicate how many bits are for network and should not be modified
    else:
      numberof1s = next8bits.count('1')
      #Convert the ip octect to binary
      ipbinary = decimaltobinary(ipoctects[i])
      #Set the bits from range numberof1s to 8 to value of 1. This will set all the host bits to 1.
      for z in range(numberof1s, 8):
        ipbinary = ipbinary[:z] + '1' + ipbinary[z+1:]
      #Convert the resulting ip octect from binary to decimal and append to broadcastaddr list
      broadcastaddr.append(binarytodecimal(ipbinary))
      mask = mask[8:]
  return broadcastaddr

#Function that will accept a list of ip octects (list of integers), and will print in X.X.X.X notation. 
#Will also check if last argument is hex to determine if hex conversion will be applied
def printip(ipoctects):
  ip = ""
  #If last argument is 'hex', then apply decimal to hex conversion on each octect. Append '0x' at the front
  if sys.argv[-1] == "hex":
    for q in range(4):
      ip = ip + decimaltohex(int(ipoctects[q]))
    ip = "0x" + ip
    print (ip)
  #Else, append each octect from list to a string with '.' added inbetween. Remove the last period character.
  else:
    for q in range(4):
      ip = ip + ipoctects[q] + "."
    ip = ip[:-1]
    print (ip)

#RegEx for valid IP address
ippattern = r"([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
cidrpattern = r"[0-9]|[1-2][0-9]|3[0-2]"
hexpattern = r"0x([0-9]|[a-f]|[A-F]){8}"

#If first argument matched ippattern regex
if re.fullmatch(ippattern, sys.argv[1]):
  #Split each ip octect into list of integers
  ip = sys.argv[1]
  ipoctects = ip.split('.')
  ipoctects = list(map(int, ipoctects))

  #If second argument matched ippattern regex
  if re.fullmatch(ippattern, sys.argv[2]):
    #Split each subnet octect into list of integers
    subnet = sys.argv[2]
    subnetoctects = subnet.split('.')
    subnetoctects = list(map(int, subnetoctects))
    subnetstring = ""
    #For each subnet octect, convert from decimal to binary. Append to string.
    for i in range(4):
       subnetstring = subnetstring + decimaltobinary(subnetoctects[i])
    #Run subnetstring against validsubnet function to verify subnet is valid
    validsubnet(subnetstring)
    #Run calcbroadcast with ip octects and subnetstring arguement. Store resulting broadcast address in list of integers
    broadcast = calcbroadcast(ipoctects, subnetstring)
    broadcast = list(map(str, broadcast))
    #Run printip function which will check for hex argument and print in xxx.xxx.xxx.xxx notation
    printip(broadcast)
  #If second argument matched cidrpattern regex
  elif re.fullmatch(cidrpattern, sys.argv[2]):
    #Set the subnetstring to specified number of 1's (this will indicate network portion of mask), fill the rest of 0's
    subnet = sys.argv[2]
    numberof1s = int(subnet)
    numberof0s = 32 - numberof1s
    subnetstring = "1" * numberof1s + "0" * numberof0s
    #Run subnetstring against validsubnet function to verify subnet is valid
    validsubnet(subnetstring)
    #Run calcbroadcast with ip octects and subnetstring arguement. Store resulting broadcast address in list of integers
    broadcast = calcbroadcast(ipoctects, subnetstring)
    broadcast = list(map(str, broadcast))
    #Run printip function which will check for hex argument and print in xxx.xxx.xxx.xxx notation
    printip(broadcast)
  #If second argument matched hexpattern regex
  elif re.fullmatch(hexpattern, sys.argv[2]):
    #Remove the '0x'
    subnet = sys.argv[2]
    subnet = subnet.replace("0x", "")
    subnetstring = ""
    #Convert each hex value to binary
    for t, y in enumerate(subnet):
      subnetstring = subnetstring + hextobinary(y)
    #Run subnetstring against validsubnet function to verify subnet is valid
    validsubnet(subnetstring)
    #Run calcbroadcast with ip octects and subnetstring arguement. Store resulting broadcast address in list of integers
    broadcast = calcbroadcast(ipoctects, subnetstring)
    broadcast = list(map(str, broadcast))
    #Run printip function which will check for hex argument and print in xxx.xxx.xxx.xxx notation
    printip(broadcast)
  else:
     exit("Invalid subnet mask")

else:
  exit("Invalid IP")

