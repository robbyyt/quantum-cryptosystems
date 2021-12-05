import itertools
import numpy as np

load("./GenericAttack.sage")
load("./utils.sage")
load("./aspects/attack_asp.sage")

MAX_ITERATIONS_INNER = 1000
MAX_ITERATIONS_OUTER = 100000
IDEAL_P = 2

class LeeBrickellISD(GenericAttack):
    def inner_loop(self):
        r, n = self.H.dimensions()
        iteration_count = 0
        while True:
            P = generate_random_permutation_matrix(n)
            H_curr = self.H * P
            H_curr = block_matrix(1, (H_curr, identity_matrix(r)))
            RRE = H_curr.rref()
            U = RRE[:, n:n+r]
            V = RRE[:, r:n]
            W = RRE[:, 0:r]
            iteration_count += 1
            if W != identity_matrix(r):
                return P, V, U, iteration_count

            if iteration_count > MAX_ITERATIONS_INNER:
                raise Exception("Maximum iterations exceeded in inner loop")


    @print_algorithm_status
    def attack(self):
        inner_iter_counts = []
        outer_iter_count = 0
        while True:
            try:
                P, V, U, inner_iteration_count = self.inner_loop()
            except:
                raise Exception(
                    "Exiting ISD algorithm, maximum iterations exceeded in inner loop")
            inner_iter_counts.append(inner_iteration_count)
            r, n = self.H.dimensions()
            k = n - r
            s_curr = U * self.syndrome
            s_curr = s_curr.transpose().list()
            for j in itertools.combinations(range(k), IDEAL_P):
                for i in j:
                    s_curr = np.add(V.column(i), s_curr)

                if get_array_weight(s_curr) == self.t - IDEAL_P:
                    e_curr = [0] * k + s_curr.tolist()
                    for i in j:
                        to_add = [0] * i + [1] + [0] * (r + k - 1 - i)
                        e_curr =np.add(e_curr, to_add)

                    if is_of_desired_weight(e_curr, self.t):
                        result = matrix(e_curr.tolist()) * P.T
                        if self.H * result.transpose() == self.syndrome:
                            return result, outer_iter_count, mean(inner_iter_counts)

                    if outer_iter_count > MAX_ITERATIONS_OUTER:
                        raise Exception("Maximum iterations exceeded in outer loop")

            outer_iter_count += 1
            print("Running outer iteration number %d" % outer_iter_count)


SAMPLE_PC_MATRIX_2 = Matrix(GF(2), matrix([
    [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1],
    [0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1],
    [1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1],
    [0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0],
    [0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1],
    [0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1]
])
)

SAMPLE_SYNDROME_2 = Matrix(GF(2), matrix(8, 1, [0, 1, 1, 0, 0, 1, 0, 0]))
SAMPLE_WEIGHT_2 = 3

lb = LeeBrickellISD(H=SAMPLE_PC_MATRIX_2,
                    syndrome=SAMPLE_SYNDROME_2, t=SAMPLE_WEIGHT_2)

lb.attack()
