#!/usr/bin/env python3

# Making single image predictions
# Loading model
import sys
from keras.models import load_model
from keras.optimizers import Adadelta
import cv2
import numpy as np
import os

def preprocess_background(input_img):
    '''
    This function preprocesses an image based on cv2.
    It tries to remove the background of an image.
    The intention is to make then prediction easier for the model.
    
    Input:
    - Image object
    
    Output:
    - Preprocessed image
    
    Source: https://stackoverflow.com/questions/29313667/how-do-i-remove-the-background-from-this-kind-of-image
    '''
    
    # Removes background
    
    # Parameters
    BLUR = 21
    CANNY_THRESH_1 = 10
    CANNY_THRESH_2 = 200
    MASK_DILATE_ITER = 10
    MASK_ERODE_ITER = 10
    MASK_COLOR = (0.0,0.0,1.0) # In BGR format
    
    image_size = (100, 100)  # width and height of the used images
    input_shape = (100, 100, 3)


    # Processing 

    # Convert image
    img = (input_img*255).astype(np.uint8)
    gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

    # Edge detection
    edges = cv2.Canny(gray, CANNY_THRESH_1, CANNY_THRESH_2)
    edges = cv2.dilate(edges, None)
    edges = cv2.erode(edges, None)

    # Find contours in edges, sort by area
    contour_info = []
    #_, contours, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
    # Previously, for a previous version of cv2, this line was: 
    contours, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
    # Thanks to notes from commenters, I've updated the code but left this note
    for c in contours:
        contour_info.append((
            c,
            cv2.isContourConvex(c),
            cv2.contourArea(c),
        ))
    contour_info = sorted(contour_info, key=lambda c: c[2], reverse=True)
    max_contour = contour_info[0]

    # Create empty mask, draw filled polygon on it corresponding to largest contour
    # Mask is black, polygon is white
    mask = np.zeros(edges.shape)
    cv2.fillConvexPoly(mask, max_contour[0], (255))

    # Smooth mask, then blur it 
    mask = cv2.dilate(mask, None, iterations=MASK_DILATE_ITER)
    mask = cv2.erode(mask, None, iterations=MASK_ERODE_ITER)
    mask = cv2.GaussianBlur(mask, (BLUR, BLUR), 0)
    mask_stack = np.dstack([mask]*3)    # Create 3-channel alpha mask

    # Blend masked img into MASK_COLOR background
    mask_stack  = mask_stack.astype('float32') / 255.0          # Use float matrices, 
    img         = img.astype('float32') / 255.0                 #  for easy blending

    masked = (mask_stack * img) + ((1-mask_stack) * MASK_COLOR) # Blend
    masked = (masked * 255).astype('uint8')                     # Convert back to 8-bit
    
    image = cv2.resize(masked, image_size)
    image = np.reshape(image, input_shape)
    
    return image

# load model
model = load_model('/home/miber/creative-cooking/ingredients_training_output_files/ingredients_detection_model/model.h5')

# Load and resize image
input_shape = (1, 100, 100, 3) 

image = sys.argv[1]

image = cv2.imread(image)
image = preprocess_background(image)
image = np.reshape(image, input_shape)

# Run model
learning_rate = 0.1
optimizer = Adadelta(lr=learning_rate)
model.compile(optimizer=optimizer, loss="sparse_categorical_crossentropy", metrics=["accuracy"])

prediction = model.predict(image)

# Format prediction
label_file = '/home/miber/creative-cooking/labels.txt'

with open(label_file, "r") as f:
    labels = [x.rstrip('\n') for x in f.readlines()]

print('Prediction Ingredient:')

for ingredient, prob in sorted(list(zip(labels, prediction[0])), key = lambda x: -x[1])[:5]:
    print('{}: {:.2f}%'.format(ingredient, round(prob, 4) * 100))