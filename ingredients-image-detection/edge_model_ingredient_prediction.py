#!/usr/bin/env python3

# Making single image predictions using tf.lite model
# use: python3 image_path

def make_prediction(image_path, 
                    model_path="./model-export/icn/tflite-ingredients_detection_mobile-2020-02-09T16:42:35.238Z/model.tflite",
                    label_path="./model-export/icn/tflite-ingredients_detection_mobile-2020-02-09T16:42:35.238Z/dict.txt"):
    ''' This function makes a single image prediction.
        Note to change the model path and the path to the label
        dictionary!
    '''
    # Load TFLite model and allocate tensors.
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()

    # Get input and output tensors.
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    # read and reshape image file
    image_size = (224, 224)
    input_shape = (1, 224, 224, 3)
    image = cv2.imread(image_path)
    image = cv2.resize(image, image_size)
    image = np.reshape(image, input_shape)
    
    # Make prediction
    input_data = image
    interpreter.set_tensor(input_details[0]['index'], input_data)

    interpreter.invoke()

    # The function `get_tensor()` returns a copy of the tensor data.
    # Use `tensor()` in order to get a pointer to the tensor.
    output_data = interpreter.get_tensor(output_details[0]['index'])
    
    with open(label_path, "r") as f:
        labels = [x.rstrip('\n') for x in f.readlines()]
        
    total = np.sum(output_data[0])
    
    for i in sorted(np.argpartition(output_data[0], -5)[-5:], key=lambda x: -x):
        print("{:<20s} | Score: {}%".format(labels[i], str(round(output_data[0][i]/total * 100, 2))))

if __name__ == '__main__':
    import os
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
    
    import sys
    stderr = sys.stderr
    sys.stderr = open(os.devnull, 'w')
    
    import tensorflow as tf
    sys.stderr = stderr
    
    import cv2
    import numpy as np
    
    
    make_prediction(sys.argv[1])
