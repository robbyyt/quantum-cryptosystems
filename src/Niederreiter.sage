from math import floor
load('./CodeBasedCryptosystem.sage')

class Niederreiter(CodeBasedCryptosystem):
    def generate_random_nonsingular_matrix(self, size):
        S = random_matrix(ZZ, size)

        while not S.is_singular() and S.determinant() == 0:
            S = random_matrix(ZZ, size)

        return S

    def generate_random_permutation_matrix(self, n):
        return Permutations(n).random_element().to_matrix()

    def encode_(self, n, t):
        enc = [0]*n
        count = t
        while count > 0:
            r = randrange(n)
            if enc[r] == 0:
                enc[r] += 1
                count -= 1
        return matrix(enc)

    def encrypt(self, message=None):
        H_pub, t = self.public_key
        n = H_pub.ncols()

        if message == None:
            message = self.encode_(n, t)

        print("Message is: " + str(message))

        return matrix(QQ, H_pub) * matrix(QQ, message.transpose())

    def decrypt(self, cryptotext):
        H, S, P = self.private_key
        HPMt = (~S) * cryptotext
        PMt = self.decoder.decode_to_code(HPMt)
        return (matrix(QQ, (~P)) * matrix(QQ, PMt)).transpose()

    def generate_keypair(self):
        H = code.get_parity_check_matrix()
        n, k = H.ncols(), H.nrows()
        S = self.generate_random_nonsingular_matrix(n - k)
        P = self.generate_random_permutation_matrix(n)
        t = floor((n - k) / 2)

        return ((S * H * P, t), (H, S, P))
