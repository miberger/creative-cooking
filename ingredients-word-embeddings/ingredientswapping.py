#!/usr/bin/env python3
# getting ingredients replacements

from gensim.models import KeyedVectors
from nltk.stem import WordNetLemmatizer, PorterStemmer
import csv
    
def get_substitutes(word, 
                    embedding_file='model1_vectors.kv', 
                    cutoff=0.5,
                    n=100,
                    tag_file = '/home/miber/creative-cooking/ingredients-image-detection/data/ingredient_list.csv',
                    print_substitutes=False):
    '''
    This function returns a list of substitutes out of a list of tags for an ingredient.
    The function uses own trained word2vec embeddings and cosine similarity to find
    the closest substitutes. It filters "unuseful substitutes" based on a list of word
    called 'not-useful'. It lemmatizes and stems the word based on Porter. 
    It prints the substitutes (optional) and returns a list of tuples of
    possible replacements and their cosine similarity.
    
    Args:
    - word ingredient for which substitutes are looked for
    - embedding file provided as .kv file
    - cutoff for cosine similarity to be considered
    - maximum number of replacements provided
    - file for tags for ingredients
    - whether to print out substitutes in order
    
    Returns: 
    - List of tuples (substitute, cosine similarity)
    - Optional: Print out ingredients
    
    Dependencies:
    - gensim library for loading word embeddings and getting most similar words
    - nltk wordnet lemmatizer and porter stemmer
    - csv to import csv tag file
    '''

    tags = list()
    
    # loading substitution tags
    with open(tag_file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            tags += [row[1]]

    # Loading embedding vector and word preprocessing functions
    word_vectors = KeyedVectors.load(embedding_file, mmap='r')
    porter = PorterStemmer()
    wnl = WordNetLemmatizer()
    
    # Defining which tags will not be useful and setting up list to save substitutes
    not_useful = ['fruit', 'dairy', 'vegetable', 'salad', 'fish', 'meat', 'spice', 'fillet']
    substitutes = list()

    try: # catching key error in word dictionary
        if print_substitutes:
            print('Suggestion for substitute of {}'.format(word))
        
        # Preprocess word
        word = word.replace('_', ' ').lower()
        token = word.split(' ')[0] # take the first part, if the word consists of several terms
            
        token = wnl.lemmatize(token) if wnl.lemmatize(token).endswith('e') else porter.stem(token)

        for substitute in word_vectors.most_similar(token, topn=n):

            distance = substitute[1]

            if distance < cutoff:
                break

            substitute_ingredient = substitute[0]
            
            # Do not consider an ingredient, if
            # - the substitute is not in the tag list
            # - the substitute is in the not useful list
            # - if the substitute is in the to be replaced word (e.g. melon in watermelon)
            if substitute_ingredient not in tags or substitute_ingredient in not_useful or substitute_ingredient in word:
                continue

            substitutes += [substitute]

            if print_substitutes:
                print('\t{}, similarity score {}'.format(substitute_ingredient.capitalize(), round(substitute[1],2)))

    except KeyError:
        if print_substitutes:
            print('Unfortunately, we cannot find a replacement for {}.'.format(word))

    return substitutes
