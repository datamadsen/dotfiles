#!/usr/bin/env python
import subprocess

def main():
    print("brew update...")
    subprocess.call("brew update", shell=True)

    print("Installing missing formulas")
    install_formulas()

def file_lines_to_array(file_name):
    return [line.rstrip('\n') for line in open(file_name)]

def shell_cmd_lines_to_array(shell_cmd):
    return subprocess.check_output(shell_cmd, shell = True).splitlines()

def install_formulas():
    # Check which, if any formulas to install
    candidates = file_lines_to_array("brew-formulas")
    currents = shell_cmd_lines_to_array("brew list -1");
    to_install = [formula for formula in candidates if formula not in currents]

    if not to_install:
        print("Everything is already installed")
    else:
        print("Installing formula(s): %s" % ', '.join(to_install))
        for formula in to_install:
            subprocess.call("brew install %s" % formula, shell=True)

if __name__== "__main__":
  main()
