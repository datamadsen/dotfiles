#!/bin/bash
# Generate padding to balance the status-right section

# Get the hostname and session name (matching what's in status-right)
hostname=$(hostname -s)
session_name="$1"

# Calculate the length of what appears in status-right: "  #h: #S"
# The format is: "  hostname: session_name"
right_content="  ${hostname}: ${session_name}"
right_length=${#right_content}

# Generate that many spaces for the left side
printf "%${right_length}s" ""
