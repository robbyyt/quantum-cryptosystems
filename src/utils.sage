from random import shuffle

def generate_random_permutation_matrix(n):
    return Permutations(n).random_element().to_matrix()

def generate_binary_vector_of_weight_t(len, t):
    arr = [1] * t + [0] * (len - t)
    shuffle(arr)
    return arr

def is_of_desired_weight(arr, weight):
    if get_array_weight(arr) != weight:
        return False

    return True

def get_array_weight(arr):
    w_curr = 0
    for x in arr:
        if x != 0:
            w_curr += 1

    return w_curr

def generate_random_binary_nonsingular_matrix(size):
    S = random_matrix(GF(2), size)

    while not S.is_singular() and S.determinant() == 0:
        S = random_matrix(GF(2), size)

    return matrix(ZZ, S)

def generate_random_nonsingular_matrix(size, field_size=2):
    S = random_matrix(GF(2), size)

    while not S.is_singular() and S.determinant() == 0:
        S = random_matrix(GF(field_size), size)

    return S
