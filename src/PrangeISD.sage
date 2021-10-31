load("./GenericAttack.sage")
load("./utils.sage")

MAX_ITERATIONS_INNER = 10000
MAX_ITERATIONS_OUTER = 10000

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
            if W == identity_matrix(r):
                return P, V, U, iteration_count

            if iteration_count > MAX_ITERATIONS_INNER:
                raise Exception("Maximum iterations exceeded in inner loop")

    def attack(self, verbose=True):
        inner_iter_counts = []
        outer_iter_count = 0
        while True:
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

            if is_of_desired_weight(e_curr, self.t):
                print("e: ", e_curr)
                print(P.transpose())
                if verbose:
                    print("ISD finished after %d iterations of outer loop and an average of %d iterations of inner loop"
                        % (outer_iter_count, mean(inner_iter_counts)))

                return matrix(e_curr) * P.T

            if outer_iter_count > MAX_ITERATIONS_OUTER:
                raise Exception("Maximum iterations exceeded in outer loop")


