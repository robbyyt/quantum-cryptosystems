load('../codes/GoppaCode.sage')
load('../utils.sage')
load('../ISD/GeneralizedISD.sage')

def fq_goppa_random_isd():
    TEST_ITERATIONS = 250
    outer_iter_counts = []
    avg_times = []
    m = 4
    t = 7
    base_field = 3
    failed_iters = 0

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
        isd = GeneralizedISD(linear_code, t, p=3)
        try:
            decoded, iter_count, avg_time = isd.decode(syndrome)
        except:
            print("FAILED")
            failed_iters += 1
            continue

        if decoded == syndrome_init:
            print("ISD Worked in %d iterations" % iter_count)
            outer_iter_counts.append(iter_count)
            avg_times.append(avg_time)
        else:
            print("Failed")
            failed_iters += 1

    return {
        "m": m,
        "t": t,
        "succes_rate": failed_iters / TEST_ITERATIONS,
        "time_avg": mean(avg_times),
        "outer_loop_statistics": {
            "mean": mean(outer_iter_counts),
            "median": median(outer_iter_counts),
            "mode": mode(outer_iter_counts),
            "stDev": std(outer_iter_counts),
            "variance": variance(outer_iter_counts)
        }
    }


print(fq_goppa_random_isd())
