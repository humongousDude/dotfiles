#!/usr/bin/env python3
# from gemininie (gemini)

#the switchwall script breaks if a filename contains "()" this just removes them and replaces them with
# square brackets. its meant for wallpaper filenames, i wouldn't trust it for anything else lmao 

import os
import sys

def rename_files_replace_parentheses(directory):
    """
    Scans a directory and renames files, replacing parentheses in filenames with square brackets.
    """
    renamed_count = 0
    for root, _, files in os.walk(directory):
        for filename in files:
            if '(' in filename and ')' in filename:
                old_filepath = os.path.join(root, filename)
                new_filename = filename.replace('(', '[').replace(')', ']')
                new_filepath = os.path.join(root, new_filename)

                if old_filepath != new_filepath: # To avoid renaming if no parentheses to replace
                    try:
                        os.rename(old_filepath, new_filepath)
                        print(f"Renamed: '{filename}' to '{new_filename}'")
                        renamed_count += 1
                    except OSError as e:
                        print(f"Error renaming '{filename}' to '{new_filename}': {e}")
    if renamed_count > 0:
        print(f"\nSuccessfully renamed {renamed_count} files in directory '{directory}'.")
    else:
        print(f"No files with parentheses found in directory '{directory}'.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python rename_script.py <directory_path>")
        sys.exit(1)

    target_directory = sys.argv[1]
    if not os.path.isdir(target_directory):
        print(f"Error: '{target_directory}' is not a valid directory.")
        sys.exit(1)

    print(f"Scanning directory: '{target_directory}' for files to rename...")
    rename_files_replace_parentheses(target_directory)
    print("Renaming process complete.")
