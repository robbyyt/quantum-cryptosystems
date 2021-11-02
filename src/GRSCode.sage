load('./LinearCode.sage')

class GRSCode(LinearCode):
    def __init__(self, code=None, n=10, k=5, q=11):
        if code == None:
            self.code = self.generate_code(n, k, q)
            self.decoder = codes.decoders.GRSKeyEquationSyndromeDecoder(self.code)
            self.ambient_space = self.code.ambient_space()
        else:
            self.code = code
            self.decoder = codes.decoders.GRSKeyEquationSyndromeDecoder(self.code)
            self.ambient_space = self.code.ambient_space()

    def get_parity_check_matrix(self):
        return self.code.parity_check_matrix()

    def generate_code(self, n, k, q):
        F = GF(q)
        return codes.GeneralizedReedSolomonCode(F.list()[1:n+1], k)

