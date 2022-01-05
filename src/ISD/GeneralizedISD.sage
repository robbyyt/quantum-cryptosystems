import itertools
load('../codes/GoppaCode.sage')

MAX_ITERATIONS = 10000

class GeneralizedISD:
    def __init__(self, code, desired_weight, p=2) -> None:
        self.code = code
        self.p = p
        self.desired_weight = desired_weight

    def decode(self, syndrome):
        iteration_count = 1
        n, k = self.code.length(), self.code.dimension()
        G = self.code.generator_matrix()
        F = self.code.base_ring()
        F_s = F.list()[1:]
        while True:
            I = sample(range(n), k)
            Gi = G.matrix_from_columns(I)
            try:
                Gi_inv = Gi.inverse()
            except ZeroDivisionError:
                # this happens if I was not an information set
                continue

            Gt = Gi_inv * G
            y = syndrome - vector([syndrome[i] for i in I]) * Gt
            if self.p == 0:
                e = syndrome - y
                if e.hamming_weight() == self.desired_weight:
                    return e, iteration_count
            else:
                 g = Gt.rows()
                 for pi in range(self.p+1):
                    for A in itertools.combinations(range(k), pi):
                        for m in itertools.product(F_s, repeat=pi):
                            e = y - sum(m[i]*g[A[i]] for i in range(pi))
                            if e.hamming_weight() == self.desired_weight:
                                return syndrome - e, iteration_count
            iteration_count += 1

            if iteration_count > MAX_ITERATIONS:
                raise Exception("Maximum iterations exceeded")
