#!/usr/bin/python



import sys

import fileinput

if __name__ == '__main__':
    if( len(sys.argv) != 4):
        print 'USAGE:\n\t{0} <FILE_NAME> <FROM_STRING> <TO_STRING>'.format(__file__)
        exit(0)

    file_path = sys.argv[1]
    from_string = sys.argv[2]
    to_string = sys.argv[3]
    
    for line in fileinput.input(file_path, inplace=True):
        print line.replace(from_string, to_string, 1)
        break
