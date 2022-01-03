load('../codes/GoppaCode.sage')
load('../utils.sage')
load('../ISD/GeneralizedISD.sage')

def fq_goppa_random_isd():
    TEST_ITERATIONS = 1
    outer_iter_counts = []
    inner_iter_avgs = []
    m = 6
    t = 9
    base_field = 2

    for i in range(TEST_ITERATIONS):
        F = GF(base_field)
        g = GoppaCode(m=m, t=t, base_field=base_field)
        G_priv = g.code.generator_matrix()
        k, n = G_priv.dimensions()
        S = generate_random_binary_nonsingular_matrix(k)
        P = generate_random_permutation_matrix(n)
        G_pub = S * G_priv * P
        print(G_pub.dimensions())
        linear_code = codes.LinearCode(G_pub)
        msg = vector(F, random_vector_in_field_of_weight_t(F, k, t))
        Chan = channels.StaticErrorRateChannel(linear_code.ambient_space(), t)
        syndrome_init = msg * G_pub
        syndrome = Chan(syndrome_init)
        isd = GeneralizedISD(linear_code, t, p=2)
        decoded, iter_count = isd.decode(syndrome)
        print("DECODED:", decoded)
        print("INIT: ", syndrome_init)
        print("SYNDROME: ", syndrome)
        if decoded == syndrome_init:
            print("DID IT")


fq_goppa_random_isd()
