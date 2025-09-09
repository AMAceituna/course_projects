# Needleman-Wunsch Alignment Algorithm

import numpy as np

# Get sequences
seq1 = input("Please give sequence 1 as either a string or list:")
seq2 = input("Please give sequence 2 as either a string or list:")

# test
# seq1 = "ATC"
# seq2 = "ATGGA"

# cast as list
seq1 = list(seq1)
seq2 = list(seq2)


def nwalgo(seq1, seq2):
    #### set up score matrix
    score_matrix = np.zeros((len(seq1) + 1, len(seq2) + 1))
    # BTW This makes seq1 the y rather than x axis of matrix, so they look backwards for the rest of the script.

    # Assign scores
    for row_idx, row in enumerate(score_matrix):
        for element_idx, element in enumerate(row):

            if row_idx == 0 and element_idx == 0: # First element is 0
                score_matrix[row_idx][element_idx] = 0

            else:
                # Gap penalties for top and left
                top = score_matrix[row_idx - 1][element_idx] -2
                left = score_matrix[row_idx][element_idx -1] -2

                # Assign score
                if row_idx == 0: # first row
                    score_matrix[row_idx][element_idx] = left
                elif element_idx == 0: # first column
                    score_matrix[row_idx][element_idx] = top
                
                else: # Check diagonal for match/mismatch                    
                    if seq2[element_idx -1] == seq1[row_idx -1]:
                        diagonal = score_matrix[row_idx -1][element_idx -1] +1
                    else:
                        diagonal = score_matrix[row_idx -1][element_idx -1] -1

                    score_matrix[row_idx][element_idx] = max(top, left, diagonal)

    print(f"Score matrix for {seq1}(vertical) and {seq2}(horizontal):\n \n", score_matrix)

    #### Create Alignments
    
    x = len(seq2)
    y = len(seq1) # god this is clunky, but I'm tired and can't remember a better way to iterate backwards.

    print(x,y)

    # Forgive the ugly. I'm trying really hard not to look up how this has been done before.
    direction_seq = []

    while x != 0 and y != 0:
        # choose direction
        up = score_matrix[y-1][x] -2
        # print(up)
        left = score_matrix[y][x-1] -2
        # print(left)
        if seq1[y-1] == seq2[x-1]: # -1 because they're already offset
            diagonal = score_matrix[y-1][x-1] +1
        else:
            diagonal = score_matrix[y-1][x-1] -1
        # print(diagonal)

        # move
        if max(up, left, diagonal) is up:
            direction_seq.append('u') # using append should already reverse the order as needed
            y -= 1
        elif max(up, left, diagonal) is left:
            direction_seq.append('l')
            x -= 1
        else:
            direction_seq.append('d')
            y -= 1
            x -= 1

    print(f"The traceback movement sequence is {direction_seq} (already inverted).")

    #### Translate alignment
    optimal_alignment = [[],[]]

    # counters because can't just loop through the sequences cause gaps
    seq1_count = 0
    seq2_count = 0

    for idx, i in enumerate(direction_seq):
        # Add gaps
        if i == 'u':
            optimal_alignment[0].append(seq1[seq1_count])
            seq1_count += 1
            optimal_alignment[1].append('-')
        elif i == 'l':
            optimal_alignment[0].append('-')
            optimal_alignment[1].append(seq2[seq2_count])
            seq2_count += 1
        elif i == 'd':
            optimal_alignment[0].append(seq1[seq1_count])
            optimal_alignment[1].append(seq2[seq2_count])
            seq1_count += 1
            seq2_count += 1
        

    print(f"Optimal_alignment(s): {optimal_alignment}")

    # Still need to make it able to give more than one optimal alignment, but it's the basic thing and works right nwo.
    # I have to go to sleep.



    















nwalgo(seq1, seq2)
    

    







