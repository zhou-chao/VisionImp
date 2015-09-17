#!/usr/bin/python

########################
# created by: zhou chao
# at: 2014.12.18
########################
import sys
import glob
import shutil
import os

def get_name_from_path(path):
    k = path.rfind(os.sep)
    return path[k+1:]

def get_dir_from_path(path):
    k = path.rfind(os.sep)
    return path[:k]


def main():
    # file all jpg files in the directory
    directory = sys.argv[1]
    file_list = glob.glob( directory + "/*.jpg")
    
    # clean result directory if exists
    result_dir = directory + "/rename/" 
    if os.path.exists(result_dir):
        shutil.rmtree(result_dir)    
    os.mkdir(result_dir)
    
    # copy files to the result directory
    for file_name in file_list:
        shutil.copy2(file_name, get_dir_from_path(file_name) + os.sep + "rename" \
            + os.sep + get_name_from_path(file_name).replace(':', '-'))

if __name__ == "__main__":
    main()
