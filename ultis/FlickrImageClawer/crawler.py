#!/usr/bin/python
import platform
import requests
import urllib
import json
import sys
import os
import math

############################################################################
#   [OPTIONS]
#       -k keyword: (mandatory)
#           the keyword to be searched (e.g.) butterfly, effiel_tower
#       -n photo_number: (mandatory)
#           number of photos to be downloaded
#       -y from_year to_year: (optional)
#           fetch photos from 'from_year' to 'to_year' with `photo_number` 
#           photos for each interval
#       -s step: (optional)
#           year interval step, default 1
#       -p:
#           enable parallel downloading, valid by mpiexec only       
#
#   [EXAMPLE]
#       download 100 photos with keyword 'butterfly':       
#           ./crawler.py -k butterfly -n 100
#       download 100 photos for each year from 2010 to 2014 
#           ./crawler.py -k butterfly -n 100 -y 2010 2014
#       download photos from 2010 to 2014 with 2-year step
#           ./crawler.py -k butterfly -n 100 -y 2010 2014 -s 2
#       download photos in parallel (for machines with mpi installed only):           
#           mpiexec -n 4 python crawler.py -k butterfly -n 100 -p
#
#   create by: zhou chao
#   at: 2014.12.17
#   last modified: 2014.12.19
############################################################################


################ global constants ##################
# cse http proxy 
http_proxy = {"http": "???"}

# parallel thread number
thread_number = 4

# request url setting
request_server = "http://flickr.com/services/rest/?"
api_key = "api_key=???&"
response_format = "format=json&"

##########################################################
# function:
#       find the time when @photo is taken
##########################################################
def find_date_taken(photo):
    
    api_method = "method=flickr.photos.getInfo&"
    # compose url
    info_url = request_server + api_method + api_key + response_format +  \
        "photo_id=" + photo["id"]
    
    # get json response
    str_response = requests.get(info_url,  proxies=http_proxy).content
    json_response = json.loads(str_response[14:-1]) #HARDCODE
    return json_response["photo"]["dates"]["taken"]
     
##########################################################################
# function:
#        retrieve photos in the @photo_list and save them in @directory
##########################################################################
def retrieve_photo(photo_list, directory):
    photo_number = len(photo_list)
    count = 1

    print("retrieving photos...")
    for photo in photo_list:
        # compose photo url
        photo_url = "https://farm" + `photo["farm"]` + ".staticflickr.com/" + \
            photo["server"] + "/" + photo["id"] + "_" + photo["secret"] + ".jpg"

        # save to file
        filename = find_date_taken(photo)
        filename = filename.replace(":", "-")
        f = open(directory +`count`+" "+ filename + ".jpg",'wb')
        f.write(requests.get(photo_url, proxies=http_proxy).content)
        f.close()
    
        print(`count` + " of " + `photo_number` + ", from " + photo_url)
        if platform.system() == 'Linux':
            sys.stdout.write("\033[F")
        else:
            sys.stdout.write("\r")
        count = count + 1

    print("\ndone.")
    return

######################################################
#   function:
#       parallel version of @retrieve_photo
######################################################
def retrieve_photo_parallel(photo_list, directory, start):
    photo_number = len(photo_list)
    count = start + 1
    for photo in photo_list:
        # compose photo url
        photo_url = "https://farm" + `photo["farm"]` + ".staticflickr.com/" + \
            photo["server"] + "/" + photo["id"] + "_" + photo["secret"] + ".jpg"

        # save to file
        filename = find_date_taken(photo)
        filename = filename.replace(":", "-")
        f = open(directory +`count`+" "+ filename + ".jpg",'wb')
        f.write(requests.get(photo_url, proxies=http_proxy).content)
        f.close()
        count = count + 1

#########################################################
#   function: 
#      fetch photo list of @photo_number photos by @keyword
#########################################################
def fetch_photo_list(keyword, photo_number):
    api_method = "method=flickr.photos.search&"
    per_page = "per_page=" + photo_number + "&"
    query = "tags=" + keyword 
    in_gallery = "in_gallery=true&"
    
    # compose the request url
    request_url = request_server + api_method + api_key + response_format \
        + per_page + in_gallery + query
    
    # send the request and get the json response
    print("fetching photo list...")
    str_response = requests.get(request_url,  proxies=http_proxy).content
    json_response = json.loads(str_response[14:-1]) #HARDCODE

    # get the photo info list
    photo_list = json_response["photos"]["photo"]
    print("done.")    
    return photo_list

###################################################################
#   function:
#       fetch photo list from @from_year to @to_year with step @step
###################################################################
def fetch_list_by_year(keyword, photo_number, from_year, to_year, step):
    api_method = "method=flickr.photos.search&"
    per_page = "per_page=" + photo_number + "&"
    query = "tags=" + keyword 
    in_gallery = "in_gallery=true&"
    
    photo_list = []
    year = from_year
    while year <= to_year:
        
        from_time = `year` + "-01-01 00:00:00"
        year = year + step - 1
        to_time = `year` + "-12-31 23:59:59"

        min_taken_date = "min_taken_date=" + from_time + "&"
        max_taken_date = "max_taken_date=" + to_time + "&" 
        
        # compose the request url
        request_url = request_server + api_method + api_key + response_format \
            + per_page + min_taken_date + max_taken_date + query
        
        print("fetching photo list from " + from_time + " to " + to_time + "...")
        str_response = requests.get(request_url,  proxies=http_proxy).content
        json_response = json.loads(str_response[14:-1]) #HARDCODE

        # get the photo info list
        photo_list = photo_list + json_response["photos"]["photo"]
        
        year = year + 1
    print("done.")  
    return photo_list  

####################################
#   function:
#       main
####################################
def main():
    
    # check arguments
    if not "-k" in sys.argv or not "-n" in sys.argv:
        print("Usage: " + sys.argv[0] + "-k [keyword] -n [# of photos]")
        sys.exit(0)
    
    # parse keyword
    ind = sys.argv.index("-k")
    keyword = sys.argv[ind + 1].replace('_', '+')
        
    # parse number of photos to be fetched
    ind = sys.argv.index("-n")
    photo_number = sys.argv[ind + 1]

    # parse year index
    if "-y" in sys.argv:
        ind = sys.argv.index("-y")
        from_year = int(sys.argv[ind + 1])
        to_year = int(sys.argv[ind + 2])
        if "-s" in sys.argv:
            ind = sys.argv.index("-s")
            step = int(sys.argv[ind + 1])
        else:
            step = 1

    # set directory 
    directory = keyword.replace('+', '_')

    # mkdir if not exists
    directory = os.path.join(os.getcwd(), directory) + os.sep
    if not os.path.isdir(directory):
        os.makedirs(directory)

    # get photo list and download photos in the list
    if not "-y" in sys.argv:
        photo_list = fetch_photo_list(keyword, photo_number)
    else:
        photo_list = fetch_list_by_year(keyword, photo_number, from_year, to_year, step)
    
    
    if "-p" in sys.argv:
        # download in parallel 
        from mpi4py import MPI
        list_size = len(photo_list)
        rank = MPI.COMM_WORLD.Get_rank()
        process = 0  

        while process < thread_number:
            process = process + 1
            if process == rank + 1:
                start = int((process - 1) * math.floor(list_size / thread_number))
                if process == thread_number:
                    end = list_size
                else:
                    end = int(start + math.floor(list_size / thread_number))
                retrieve_photo_parallel(photo_list[start:end], directory, start)
            else:
                continue
        return
    else:
        retrieve_photo(photo_list, directory)
        

if __name__ == "__main__":
    main()
