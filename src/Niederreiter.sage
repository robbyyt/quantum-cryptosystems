from math import floor
import itertools
load('./CodeBasedCryptosystem.sage')

class GoppaCode:

    def __init__(self, n, m, g):
        t = g.degree()
        F2 = GF(2)
        F_2m = g.base_ring()

        Z = F_2m.gen()
        PR_F_2m = g.parent()

        X = PR_F_2m.gen()

        factor_list = list(factor(2 ^ m - 1))
        final_factor_list = []
        for i in range(len(factor_list)):
            for j in range(factor_list[i][1]):
                final_factor_list.append(factor_list[i][0])

        while 1:
            primitive_root = F_2m.random_element()
            if primitive_root == 0:
                continue

            for i in range(len(final_factor_list)):
                for j in itertools.combinations(final_factor_list, i):
                    exponent = 1
                    for _ in range(len(j)):
                        exponent *= j[_]
                    if primitive_root ^ exponent == 1:
                        output = False
                        break
                    else:
                        output = True
                        continue
                if not output:
                    break
            if output:
                break

        #print("primitive_root", BinRepr(primitive_root))
        codelocators = []
        for i in range(2 ^ m - 1):
            codelocators.append(primitive_root ^ (i + 1))
        codelocators.append(F_2m(0))
        # print('codelocators ', codelocators)
        h = PR_F_2m(1)
        
        gamma = []
        for a_i in codelocators:
            gamma.append((h * ((X - a_i).inverse_mod(g))).mod(g))

        H_check_poly = matrix(F_2m, t, n)
        for i in range(n):
            coeffs = list(gamma[i])

            for j in range(t):
                if j < len(coeffs):
                    H_check_poly[j, i] = coeffs[j]
                else:
                    H_check_poly[j, i] = F_2m(0)

        H_Goppa = matrix(F2, m * H_check_poly.nrows(), H_check_poly.ncols())

        for i in range(H_check_poly.nrows()):
            for j in range(H_check_poly.ncols()):
                be = bin(H_check_poly[i, j].integer_representation())[2:]
                be = be[::-1]
                be = be + '0' * (m - len(be))
                be = list(be)
                H_Goppa[m * i:m * (i + 1), j] = vector(map(int, be))

        G_Goppa = H_Goppa.transpose().kernel().basis_matrix()
        G_Goppa_poly = H_check_poly.transpose().kernel().basis_matrix()

#         print('k=n-mt= ', n - m * g.degree())
#         print('H_goppa_poly rank ', H_check_poly.rank())
#         print(H_check_poly.str())
#         print('H_goppa rank ', H_Goppa.rank())
#         print(H_Goppa.str())

#         print('G_goppa_poly nrows', G_Goppa_poly.nrows())
#         print(G_Goppa_poly.str())
#         print('G_goppa nrows', G_Goppa.nrows())
#         print(G_Goppa.str())

        SyndromeCalculator = matrix(PR_F_2m, 1, len(codelocators))
        for i in range(len(codelocators)):
            SyndromeCalculator[0, i] = (X - codelocators[i]).inverse_mod(g)

        self._n = n
        self._m = m
        self._g = g
        self._t = t
        self._codelocators = codelocators
        self._SyndromeCalculator = SyndromeCalculator
        self._H_Goppa = H_Goppa
        self._H_gRS = H_check_poly
        self._G_Goppa = G_Goppa

        self._R = 0
        self._alpha = 0
        self._beta = 0
        self._sigma = 0

    def _split(self, p):
        Phi = p.parent()
        p0 = Phi([sqrt(c) for c in p.list()[0::2]])
        p1 = Phi([sqrt(c) for c in p.list()[1::2]])
        return p0, p1

    def _g_inverse(self, p):
        (d, u, v) = xgcd(p, self.goppa_polynomial())
        return u.mod(self.goppa_polynomial())

    def _norm(self, a, b):
        X = self.goppa_polynomial().parent().gen()
        return 2 ^ ((a ^ 2 + X * b ^ 2).degree())

    def _lattice_basis_reduce(self, s):
        g = self.goppa_polynomial()
        t = g.degree()
        a = [0]
        b = [0]
        (q, r) = g.quo_rem(s)
        (a[0], b[0]) = simplify((g - q * s, 0 - q))

        if self._norm(a[0], b[0]) > 2 ^ t:
            a.append(0)
            b.append(0)
            (q, r) = s.quo_rem(a[0])
            (a[1], b[1]) = (r, 1 - q * b[0])
            if a[1] == 0:
                return s, 1

        else:
            return a[0], b[0]

        i = 1
        while self._norm(a[i], b[i]) > 2 ^ t:
            a.append(0)
            b.append(0)
            (q, r) = a[i - 1].quo_rem(a[i])
            (a[i + 1], b[i + 1]) = (r, b[i - 1] - q * b[i])
            i += 1
        return (a[i], b[i])

    def _extended_euclidean(self, a, b, degree):
        # v*b = s mod a, a>b
        s = []
        u = []
        v = []
        s.append(a)
        s.append(b)
        u.append(1)
        u.append(0)
        v.append(0)
        v.append(1)
        i = 1

        while s[i].degree() >= degree:
            i += 1
            s.append(0)
            u.append(0)
            v.append(0)
            (q, r) = s[i - 2].quo_rem(s[i - 1])
            s[i] = s[i - 2] + q * s[i - 1]
            u[i] = u[i - 2] + q * u[i - 1]
            v[i] = v[i - 2] + q * v[i - 1]
        sigma = v[i]
        omega = s[i]
        return (sigma, omega)

    def SyndromeDecode(self, syndrome_poly, mode='Patterson'):

        g = self.goppa_polynomial()
        X = g.parent().gen()
        error = matrix(GF(2), 1, self.parity_check_matrix().ncols())

        if mode == 'Patterson':
            (g0, g1) = self._split(g)
            sqrt_X = g0 * self._g_inverse(g1)
            T = syndrome_poly.inverse_mod(g)

            (T0, T1) = self._split(T - X)
            R = (T0 + sqrt_X * T1).mod(g)

            (alpha, beta) = self._lattice_basis_reduce(R)

            sigma = (alpha * alpha) + (beta * beta) * X
            #print(('SyndromeDecode: sigma=', BinRepr(sigma)))
            if (X ^ (2 ^ self._m)).mod(sigma) != X:
                print("sigma: Decodability Test Failed")
                return error  # return a zero vector
            for i in range(len(self._codelocators)):
                if sigma(self._codelocators[i]) == 0:
                    error[0, i] = 1
            return error

    # Accessors
    def generator_matrix(self):
        return self._G_Goppa

    def goppa_polynomial(self):
        return self._g

    def parity_check_matrix(self):
        return self._H_Goppa

    def parity_check_poly_matrix(self):
        return self._H_gRS

    def R(self):
        return self._R

    def error_locator(self):
        return self._sigma, self._alpha, self._beta



def GetGoppaPolynomial(polynomial_ring, polynomial_degree):
            while 1:
                irr_poly = polynomial_ring.random_element(polynomial_degree)
                irr_poly_list = irr_poly.list()
                irr_poly_list[-1] = 1
                irr_poly = polynomial_ring(irr_poly_list)
                if irr_poly.degree() != polynomial_degree:
                    continue
                elif irr_poly.is_irreducible():
                    break
                else:
                    continue

            return irr_poly

class Niederreiter(CodeBasedCryptosystem):
        def __init__(self):
            m = 4
            n = 2 ** m
            t = 2
            delta = 2
            F_2m = GF(n, 'Z', modulus='random')
            PR_F_2m = PolynomialRing(F_2m, 'X')
            Z = F_2m.gen()
            X = PR_F_2m.gen()
            irr_poly = GetGoppaPolynomial(PR_F_2m, t)

            goppa_code = GoppaCode(n, m, irr_poly)

            k = goppa_code.generator_matrix().nrows()

            # Set up the random scrambler matrix
            S = matrix(GF(2), n - k, [random() < 0.5 for _ in range((n - k) ^ 2)])
            while rank(S) < n - k:
                S[floor((n - k) * random()), floor((n - k) * random())] += 1

            # Set up the permutation matrix
            rng = range(n)
            P = matrix(GF(2), n)
            for i in range(n):
                p = floor(len(rng) * random())
                P[i, rng[p]] = 1
                rng = [*rng[:p], *rng[p + 1:]]

            self._m_GoppaCode = goppa_code
            self._g = irr_poly
            self._t = self._g.degree()
            self._S = S
            self._P = P
            self._PublicKey = S * (self._m_GoppaCode.parity_check_matrix()) * P
            self._delta = delta

            # This is a help function which will be useful for encryption.

    

        def _GetRowVectorWeight(self, n):
            weight = 0
            for i in range(n.ncols()):
                if n[0, i] == 1:
                    weight = weight + 1
            return weight

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

        def encrypt(self, message):
            #Assert that the message is of the right length
            assert (message.ncols() == self._PublicKey.ncols()), "Message is not of the correct length."             
            code_word = self._PublicKey*(message.transpose())
            return code_word.transpose()

        def decrypt(self, received_word):
            #Assert that the received_word is of the right length
            received_word = received_word.transpose()
            assert (received_word.nrows() == self._PublicKey.nrows()), "Received word is not of the correct row length."
            assert (received_word.ncols() == 1), "Received word is not of the correct column length."
            #Strip off the random scrambler matrix and decode the received word.
            message = ~(self._S)*received_word
            
            #Convert message into syndrome polynomial.
            t = self._t
            m = message.nrows()/t
            g = self._m_GoppaCode.goppa_polynomial()
            F2 = GF(2)
            F_2m = g.base_ring() 
            Z = F_2m.gen()
            PR_F_2m = g.parent()
            X = PR_F_2m.gen()
            syndrome_poly = 0
                
            for i in range(t):
                tmp = []
                for j in range(m):
                    tmp.append(message[i*m+j,0])
                syndrome_poly += F_2m(tmp[::1])*X^i
               
            #Retrieve using syndrome decoding algorithm. 		
            message = self._m_GoppaCode.SyndromeDecode(syndrome_poly)
            
            #Solve the system to determine the original message.
            message = message*self._P
            return message

        def generate_keypair(self):
            H = code.get_parity_check_matrix()
            n, k = H.ncols(), H.nrows()
            S = self.generate_random_nonsingular_matrix(n - k)
            P = self.generate_random_permutation_matrix(n)
            t = floor((n - k) / 2)

            return ((S * H * P, t), (H, S, P))