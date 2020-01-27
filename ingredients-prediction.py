#!/usr/bin/env python3

# Making single image predictions
# Loading model
import sys
from keras.models import load_model
from keras.optimizers import Adadelta
import cv2
import numpy as np
import os

# load model
model = load_model('/home/miber/creative-cooking/ingredients_training_output_files/ingredients_detection_model/model.h5')

# Load and resize image
image_size = (100, 100)
input_shape = (1, 100, 100, 3) 

image = sys.argv[1]
#image = '/home/miber/data/ingredients-images/ingredients-train/Apple/0_100.jpg'
#image = '/home/miber/data/ingredients-images/ingredients-train/Eggs/26.AjitsukeTamago28RamenEggs298000716-min.jpg'
#image = '/home/miber/data/ingredients-images/ingredients-train/Banana/222_100.jpg'
image = cv2.imread(image)
image = cv2.resize(image,image_size)
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