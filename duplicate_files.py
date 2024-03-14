#!/usr/bin/env python3
import os
import hashlib
from collections import defaultdict

def chunk_reader(fobj, chunk_size=1024):
    """Generator that reads a file in chunks of bytes"""
    while True:
        chunk = fobj.read(chunk_size)
        if not chunk:
            return
        yield chunk

def get_hash(filename, first_chunk_only=False, hash=hashlib.sha1):
    hashobj = hash()
    file_object = open(filename, 'rb')
    if first_chunk_only:
        hashobj.update(file_object.read(1024))
    else:
        for chunk in chunk_reader(file_object):
            hashobj.update(chunk)
    hashed = hashobj.digest()
    file_object.close()
    return hashed

def check_for_duplicates(paths, hash=hashlib.sha1):
    hashes_by_size = defaultdict(list)  # dict of size_in_bytes: [full_path_to_file1, full_path_to_file2, ]
    hashes_on_1k = defaultdict(list)  # dict of (hash1k, size_in_bytes): [full_path_to_file1, full_path_to_file2, ]
    hashes_full = {}  # dict of full_file_hash: full_path_to_file_string

    for path in paths:
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                full_path = os.path.join(dirpath, filename)
                file_size = os.path.getsize(full_path)
                hash1k = get_hash(full_path, first_chunk_only=True)
                hashes_by_size[file_size].append(full_path)
                hashes_on_1k[(hash1k, file_size)].append(full_path)

    for size_in_bytes, files in hashes_by_size.items():
        if len(files) > 1:
            for full_path in files:
                hash_full = get_hash(full_path)
                if hash_full in hashes_full:
                    print(f"Duplicate found: {full_path} (same as {hashes_full[hash_full]})")
                else:
                    hashes_full[hash_full] = full_path

if __name__ == "__main__":
    # Example usage: Replace with the directory path you want to check for duplicate files
    directories_to_check = ["/path/to/your/folder"]
    check_for_duplicates(directories_to_check)
