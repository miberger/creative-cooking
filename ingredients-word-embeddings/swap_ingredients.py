#!/usr/bin/env python3
# getting ingredients replacements

# Please note that you need to change the file locations 'model1_vectors.kv' and 
# '/home/miber/creative-cooking/ingredients-image-detection/data/ingredient_list.csv'

def get_substitutes(word, 
                    embedding_file='model1_vectors.kv', # w2v embedding file for ingredients embeddings
                    cutoff=0.5,
                    n=10,
                    tag_file = '/home/miber/creative-cooking/ingredients-image-detection/data/ingredient_list.csv', # ingredients tag file
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
    '''

    from gensim.models import KeyedVectors
    from nltk.stem import WordNetLemmatizer, PorterStemmer

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

def preprocessor_recipe_ingredients(ingredients):
    '''
    Preprocesses either a string representing a list of ingredients or a Python list of ingredients,
    each ingredient being a string. All recipes should be separated by comma.
    
    Args:
    - String of list of ingredients, e.g. "['Winter Squash', 'mexican seasoning', 'mixed spice', 'honey', 'butter', 'olive oil', 'salt']"
    - or Python list of ingredients e.g. ['Winter Squash', 'mexican seasoning', 'mixed spice', 'honey', 'butter', 'olive oil', 'salt']
    
    Returns: 
    - Tuple of list of processed ingredient token and list of original ingredient words
    
    Dependencies:
    - regular expressions (re) library
    - nltk wordnet lemmatizer and porter stemmer
    '''
    processed_steps = list()
    
    if isinstance(ingredients, str):
        int_step = ''.join([text.replace('"','').replace("'","").replace('[','').replace(']','') for text in ingredients])
        text = re.sub(' +', ' ', int_step.lstrip()).split(',')
        text = [w.lstrip() for w in text]
    else:
        text = ingredients
    
    processed_text = [t.split(' ')[1] if len(t.split(' '))>1 else t for t in text] # keep second word
    processed_text = [word.lower() for word in processed_text] # all words are lower case
    porter = PorterStemmer()
    wnl = WordNetLemmatizer()
    tokens = [wnl.lemmatize(w) if wnl.lemmatize(w).endswith('e') else porter.stem(w) for w in processed_text]
    
    return tokens, text

def get_substitutes_for_recipe(ingredients, own_ingredients):
    '''
    This function swaps ingredients in a recipe which are not in the own ingredients list with ingredients in the own list.
    In case several substitution possibilities exist, a random choice is made.
    
    Args:
    - List of recipe ingredients as Python list of strings or string representing a list
    - List of own ingredients as Python list of strings or string representing a list 
    
    Returns: 
    - List of ingredients with substiutution suggestions
    
    Dependencies:
    - Numpy library
    '''
    
    processed_ingredients, ingredients = preprocessor_recipe_ingredients(ingredients)
    processed_own, own_ingred = preprocessor_recipe_ingredients(own_ingredients)
    
    return_list = list()
    substitute_list = list()
    
    for processed_ing, own_ing in zip(processed_ingredients, ingredients):
        if processed_ing not in processed_own:
            substitutes = get_substitutes(processed_ing)
            substitutes = [subst[0] for subst in substitutes if subst[0] in processed_own and subst[0] not in processed_ingredients]

            if substitutes:
                if len(substitutes) > 1:
                    idx = np.random.randint(len(substitutes))
                    substitute_list += [(processed_ing, substitutes[idx])]
                else:
                    substitute_list += [(processed_ing, substitutes[0])]
    
    if substitute_list:
        subst_poss = [s[0] for s in substitute_list]
        
        for proc_ingr, ingr in zip(processed_ingredients, ingredients):
            if proc_ingr in subst_poss:
                idx = subst_poss.index(proc_ingr)
                subst = substitute_list[idx][1]
                return_list += ['try {} instead of {}'.format(subst.capitalize(), ingr)]
                
            else:
                return_list += [ingr]
    
    else:
        return_list = ingredients
        
    return return_list


if __name__ == '__main__':

    from gensim.models import KeyedVectors
    from nltk.stem import WordNetLemmatizer, PorterStemmer
    import csv
    import numpy as np
    import re
    import sys
    
    ingredients = sys.argv[1]
    own_ingredients = sys.argv[2]
    
    print(get_substitutes_for_recipe(ingredients, own_ingredients))