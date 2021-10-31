def generate_random_permutation_matrix(n):
    return Permutations(n).random_element().to_matrix()


def is_of_desired_weight(arr, weight):
    w_curr = 0
    for x in arr:
        if x != 0:
            w_curr += 1

    if w_curr != weight:
        return False

    return True
