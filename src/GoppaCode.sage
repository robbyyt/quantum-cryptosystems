load('./LinearCode.sage')


class GoppaCode(LinearCode):
    def __init__(self, code=None, m=9, t=28):
        if code == None:
            self.m = m
            self.F = GF(2^m)
            self.t = t
            self.code = self.generate_code()
            print("Generated Code: ", self.code)
        else:
            self.code = code

    def get_parity_check_matrix(self):
        print(self.code)
        return self.code.parity_check_matrix()

    def generate_code(self):
        g = self.generate_goppa_polynomial_v1()
        self.poly = g
        L = [a for a in self.F.list() if g(a) != 0]
        return codes.GoppaCode(g, L)

    def generate_goppa_polynomial_v1(self):
        PolyRing = PolynomialRing(self.F, 'x')
        return PolyRing.irreducible_element(self.t)


