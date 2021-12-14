load('../codes/GoppaCode.sage')
load('../utils.sage')
load('../ISD/GeneralizedISD.sage')

def fq_goppa_random_isd():
    TEST_ITERATIONS = 1
    outer_iter_counts = []
    inner_iter_avgs = []
    m = 4
    t = 6
    base_field = 3

    for i in range(TEST_ITERATIONS):
        F = GF(base_field)
        g = GoppaCode(m=m, t=t, base_field=base_field)
        G_priv = g.code.generator_matrix()
        k, n = G_priv.dimensions()
        print("K:", k)
        print("N:", n)
        S = generate_random_binary_nonsingular_matrix(k)
        P = generate_random_permutation_matrix(n)
        G_pub = S * G_priv * P
        linear_code = codes.LinearCode(G_pub)
        msg = linear_code.random_element()
        syndrome = G_pub * matrix(msg).transpose()
        syndrome = vector(syndrome)
        isd = GeneralizedISD(linear_code, t, p=0)
        decoded, iter_count = isd.decode(syndrome)

fq_goppa_random_isd()
