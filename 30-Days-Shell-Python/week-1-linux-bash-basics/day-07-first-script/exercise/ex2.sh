#!/bin/bash


if [ $# -eq 0 ]; then
	    echo "Usage: $0 <name>"
	        exit 1
fi

echo "Hello, $1! Welcome to Day 7."
echo "This script is: $0"
echo "You provided $# argument(s)."
