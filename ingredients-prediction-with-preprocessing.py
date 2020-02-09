#!/usr/bin/env python3

# Making single image predictions
# use: python3 (y or n for using preprocessing) file_path

def preprocess_background(input_img):
    #== Libraries =======================================================================
    import numpy as np
    import cv2
    
    #== Parameters =======================================================================
    BLUR = 21
    CANNY_THRESH_1 = 10
    CANNY_THRESH_2 = 200
    MASK_DILATE_ITER = 10
    MASK_ERODE_ITER = 10
    MASK_COLOR = (0.0,0.0,1.0) # In BGR format
    
    image_size = (100, 100)  # width and height of the used images
    input_shape = (100, 100, 3)


    #== Processing =======================================================================

    #-- Convert image -----------------------------------------------------------------------
    img = (input_img*255).astype(np.uint8)
    gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

    #-- Edge detection -------------------------------------------------------------------
    edges = cv2.Canny(gray, CANNY_THRESH_1, CANNY_THRESH_2)
    edges = cv2.dilate(edges, None)
    edges = cv2.erode(edges, None)

    #-- Find contours in edges, sort by area ---------------------------------------------
    contour_info = []
    contours, _ = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)

    for c in contours:
        contour_info.append((
            c,
            cv2.isContourConvex(c),
            cv2.contourArea(c),
        ))
        
    contour_info = sorted(contour_info, key=lambda c: c[2], reverse=True)
    max_contour = contour_info[0]

    #-- Create empty mask, draw filled polygon on it corresponding to largest contour ----
    # Mask is black, polygon is white
    mask = np.zeros(edges.shape)
    cv2.fillConvexPoly(mask, max_contour[0], (255))

    #-- Smooth mask, then blur it --------------------------------------------------------
    mask = cv2.dilate(mask, None, iterations=MASK_DILATE_ITER)
    mask = cv2.erode(mask, None, iterations=MASK_ERODE_ITER)
    mask = cv2.GaussianBlur(mask, (BLUR, BLUR), 0)
    mask_stack = np.dstack([mask]*3)    # Create 3-channel alpha mask

    #-- Blend masked img into MASK_COLOR background --------------------------------------
    mask_stack  = mask_stack.astype('float32') / 255.0          # Use float matrices, 
    img         = img.astype('float32') / 255.0                 #  for easy blending

    masked = (mask_stack * img) + ((1-mask_stack) * MASK_COLOR) # Blend
    masked = (masked * 255).astype('uint8')                     # Convert back to 8-bit
    
    image = cv2.resize(masked, image_size)
    image = np.reshape(image, input_shape)
    
    return image

def predict_image(label_file='/home/miber/creative-cooking/labels.txt', model_path='/home/miber/creative-cooking/ingredients_training_output_files/ingredients_detection_model/model.h5'):
    #== load model =======================================================================
    model = load_model(model_path)

    #== load image =======================================================================
    image_size = (100, 100)
    input_shape = (1, 100, 100, 3) 

    image = str(sys.argv[2])
    image = cv2.imread(image)

    if str(sys.argv[1]) == 'y':
        image = preprocess_background(image)

    image = cv2.resize(image, image_size)
    image = np.reshape(image, input_shape)

    #== make prediction =======================================================================
    learning_rate = 0.1
    optimizer = Adadelta(lr=learning_rate)
    model.compile(optimizer=optimizer, loss="sparse_categorical_crossentropy", metrics=["accuracy"])

    prediction = model.predict(image)

    #== format prediction and yield top 5 results with prob ===================================
    label_file = label_file

    with open(label_file, "r") as f:
        labels = [x.rstrip('\n') for x in f.readlines()]

    for ingredient, prob in sorted(list(zip(labels, prediction[0])), key = lambda x: -x[1])[:5]:
        print('{}: {:.2f}%'.format(ingredient.replace('_'," "), round(prob, 4) * 100))
    
    
if __name__ == '__main__':
    
    #== Libraries =======================================================================
    import os
    # No messages 
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
    
    import sys
    
    stderr = sys.stderr
    sys.stderr = open(os.devnull, 'w')
    
    import keras
    sys.stderr = stderr
    
    from keras.models import load_model
    from keras.optimizers import Adadelta
    import cv2
    import numpy as np
    
    #== Predict image =======================================================================
    predict_image()