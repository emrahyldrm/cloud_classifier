
import time
import numpy as np
import sys, os, time
import pprint
import urllib2
sys.path.append("/home/host/caffe/python")
import caffe


path = "/tmp/classifier_fifo"
print path in os.listdir(".")

if path in os.listdir("."):
  os.remove(path)

try:
  os.mkfifo(path)
except OSError:
  os.remove(path)
  os.mkfifo(path)


caffe.set_mode_cpu()
#caffe.set_device(1)

model_def = './deploy.prototxt'
model_weights = './bvlc_alexnet.caffemodel'

net = caffe.Net(model_def, model_weights, caffe.TEST)


mu = np.load('./ilsvrc_2012_mean.npy')
mu = mu.mean(1).mean(1)  # average over pixels to obtain the mean (BGR) pixel values
print 'mean-subtracted values:', zip('BGR', mu)


transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})

transformer.set_transpose('data', (2,0,1))  # move image channels to outermost dimension
transformer.set_mean('data', mu)            # subtract the dataset-mean value in each channel
transformer.set_raw_scale('data', 255)      # rescale from [0, 1] to [0, 255]
transformer.set_channel_swap('data', (2,1,0))  # swap channels from RGB to BGR

net.blobs['data'].reshape(1,        # batch size
                          3,         # 3-channel (BGR) images
                          227, 227)  # image size is 227x227




while True:
  print "\n\n\n"
  print "########################################"
  print "Waiting for Classification Request"

  fifo = open(path, "r")
  file_name = fifo.read()
  fifo.close()

  print "REQUEST IMAGE", file_name

  #image = caffe.io.load_image(sys.argv[2])
  image = caffe.io.load_image(file_name)


  transformed_image = transformer.preprocess('data', image)
  start_time = time.time()
  net.blobs['data'].data[...] = transformed_image
  output = net.forward()
  elapsed = time.time() - start_time
  output_prob = output['prob'][0]


  labels_file = './synset_words.txt'    
  labels = np.loadtxt(labels_file, str, delimiter='\t')
  top_inds = output_prob.argsort()[::-1][:5] 

  p_class = output_prob.argmax()
  p_label = labels[output_prob.argmax()]
  p_label = p_label[p_label.find(" ")+1:]

  print "\n\n\n"  
  print 'predicted class is:', p_class
  print 'output label:', p_label
  print 'probabilities and labels:'
  pprint.pprint(zip(output_prob[top_inds], labels[top_inds]))

  
  fifo = open(path, "w")
  wr = p_label + "-" + str(elapsed)
  fifo.write(wr)
  fifo.close()
