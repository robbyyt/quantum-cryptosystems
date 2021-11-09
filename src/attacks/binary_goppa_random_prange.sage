load('../GoppaCode.sage')
load('../utils.sage')
load('../PrangeISD.sage')
load('../aspects/attack_asp.sage')

@save_result_to_file
def binary_goppa_random_prange():
    TEST_ITERATIONS = 2
    outer_iter_counts = []
    inner_iter_avgs = []
    m = 6
    t = 9

    for i in range(TEST_ITERATIONS):
        g = GoppaCode(m=m, t=t)
        H_priv = g.get_parity_check_matrix()
        r, n = H_priv.dimensions()

        S = generate_random_binary_nonsingular_matrix(r)
        P = generate_random_permutation_matrix(n)
        H_pub = S * H_priv * P
        message = generate_binary_vector_of_weight_t(n, g.t)

        enc_message = H_pub * matrix(message).transpose()

        prange = PrangeISD(H = H_pub, syndrome = enc_message, t = g.t)
        try:
            decrypted_message, outer_iter_count, inner_iter_avg = prange.attack()
        except:
            # TODO: Save hard-to-compute polynomials
            continue

        success = matrix(GF(2), message) == decrypted_message
        if(success):
            print("Decryption successful")
            outer_iter_counts.append(outer_iter_count)
            inner_iter_avgs.append(inner_iter_avg)
        else:
            print("Decryption failed")

    return {
        "m": m,
        "t": t,
        "outer_loop_statistics": {
            "mean": mean(outer_iter_counts),
            "median": median(outer_iter_counts),
            "mode": mode(outer_iter_counts),
            "stDev": std(outer_iter_counts),
            "variance": variance(outer_iter_counts)
        },
        "inner_loop_statistics": {
            "mean": mean(inner_iter_avgs),
            "median": median(inner_iter_avgs),
            "mode": mode(inner_iter_avgs),
            "stDev": std(inner_iter_avgs),
            "variance": variance(inner_iter_avgs)
        }
    }

binary_goppa_random_prange()
