#!/usr/bin/env python3
# Usage: python3 line_code.py <file_path> <old_line> <new_line>
#   Added line (+):   old_line=0,      new_line=<line in new file>
#   Deleted line (-): old_line=<line>, new_line=0
#   Context line:     old_line=<line>, new_line=<line>
import hashlib
import sys


def line_code(file_path, old_line, new_line):
    h = hashlib.sha1(file_path.encode()).hexdigest()
    return f"{h}_{old_line}_{new_line}"


if __name__ == "__main__":
    print(line_code(sys.argv[1], sys.argv[2], sys.argv[3]))
