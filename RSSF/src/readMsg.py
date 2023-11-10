# import csv
# import os
# import sys
# import time
# import datetime
# import re
# import pandas as pd

def treatMsg(line):
    # take line
     
    return line

#Function to read a .txt file to read the messages
def readMsg(filename):
    #print("Reading file: " + filename)
    file = open(filename, "r")
    lines = file.readlines()
    file.close()
    return lines

#Function to write a .csv file to write the messages
def writeMsg(filename, lines):
    #print("Writing file: " + filename)
    file = open(filename, "w")
    file.writelines(lines)
    file.close()

text = readMsg("msg.txt")
for line in text:
    print(treatMsg(line))
