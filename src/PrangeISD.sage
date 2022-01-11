load("./GenericAttack.sage")
load("./utils.sage")
load("./aspects/attack_asp.sage")

import time

MAX_ITERATIONS_INNER = 1000
MAX_ITERATIONS_OUTER = 1000

class PrangeISD(GenericAttack):
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
        outer_iter_times = []
        outer_iter_count = 0
        while True:
            start_time = time.time()
            try:
                P, V, U, inner_iteration_count = self.inner_loop()
            except:
                raise Exception("Exiting ISD algorithm, maximum iterations exceeded in inner loop")
            inner_iter_counts.append(inner_iteration_count)
            r, n = self.H.dimensions()
            s_curr = U * self.syndrome
            s_curr = s_curr.transpose().list()
            e_curr = s_curr + [0] * (n - len(s_curr))

            outer_iter_count += 1
            outer_iter_times.append(round(time.time() - start_time, 2))
            print("Running outer iteration number %d" % outer_iter_count)

            if is_of_desired_weight(e_curr, self.t):
                result = matrix(e_curr) * P.T
                if self.H * result.transpose() == self.syndrome:
                    return result, outer_iter_count, mean(inner_iter_counts), mean(outer_iter_times)

            if outer_iter_count > MAX_ITERATIONS_OUTER:
                raise Exception("Maximum iterations exceeded in outer loop")


