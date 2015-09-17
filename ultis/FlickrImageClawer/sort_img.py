#!/usr/bin/python

################################################################
#   [EXAMPLE]
#       sort images in folder './butterfly' by date:
#           sort_img.py ./buttery date
#       sort images in folder './butterfly' by time in day:
#           sort_img.py ./buttery time
#
#   created by: zhou chao
#   at: 2014.12.18
###############################################################
import sys
import glob
import shutil
import os

####################################
#   functions:
#      comparison keys
####################################
def time_taken(item):
    splited = item.split(' ')
    return splited[2]

def date_taken(item):
    splited = item.split(' ')
    return splited[1]

#############################################
#   function:
#       main
#############################################
def main():
    if len(sys.argv) < 3:
        print("usage: " + sys.argv[0] + " [directory] [sort by: date|time]")
        return
    # file all jpg files in the directory
    directory = sys.argv[1]
    file_list = glob.glob( directory + "/*.jpg")
    
    # clean result directory if exists
    result_dir = directory + "/" + sys.argv[2] 
    if os.path.exists(result_dir):
        shutil.rmtree(result_dir)    
    os.mkdir(result_dir)
    
    # sort files
    if sys.argv[2] == "date":
        file_sorted = sorted(file_list, key=date_taken)
    elif sys.argv[2] == "time":
        file_sorted = sorted(file_list, key=time_taken)
    else:
        print("usage: " + sys.argv[0] + " [directory] [sort by: date|time]")
        return
    # copy files to the result directory
    count = 1;
    for file_name in file_sorted:
        splited = file_name.split(' ', 1);        
        shutil.copy2(file_name, result_dir + "/" + `count` + \
            " " +splited[1])
        count = count + 1

if __name__ == "__main__":
    main()
