#!/usr/bin/env python3

# Mapping predicted label to tag

def map_tag(label_predicted, ranking_file):
    ''' Maps label to the cleaned tags for the recipe ranking
    '''

    tags = list()

    with open(ranking_file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            tags += [row[1]]

    tag_vector = np.zeros(len(tags), dtype=np.int8)

    for i in range(len(tags)):
        label_processed = [re.sub('s$', '', item) for item in label_predicted.lower().split('_')]

        if all([item in tags[i] for item in label_processed]):
            tag_vector[i] = 1
    
    list_tags = list()

    for i in np.where(tag_vector == 1)[0]:
        list_tags += [tags[i]]
        
    return list_tags
    
    
if __name__ == '__main__':
    
    import csv
    import numpy as np
    import re
    import sys
    
    print(map_tag(sys.argv[1], sys.argv[2]))
    
    