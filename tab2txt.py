#!/usr/bin/python
#
# Converts a stardict tab file to an HTML file
# If you have stardict ifo/idx/dict.dz files, you first
# need to decompile them with stardict-editor (found in stardict-tools)
#
# Usage: tab2html.py < dictionary.txt > dictionary.html
#
# Copyright (c) 2012 Carlos E. Torchia (redistribute under GPL2)
#

import sys
import re

for line in sys.stdin.readlines():
  line = line.replace('\\n', '\n')
  line = line.replace('\\\\', '\\')
  print line
