#!/bin/sh
#use -tile x1 for a single row
montage -trim *60p.png all60p.png
montage -trim ?.png all.png
