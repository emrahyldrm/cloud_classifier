import os
import sys

image_path = "cat.jpg"
if len(sys.argv) > 1:
	image_path = sys.argv[1]

path = "/home/host/SE/imagenet_demo/classifier_fifo"
fifo = open(path, "w")
fifo.write(image_path)
fifo.close()

fifo = open(path, "r")
result = fifo.read()
fifo.close()

print result
