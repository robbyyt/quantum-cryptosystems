import aspectlib


@aspectlib.Aspect
def print_algorithm_status(*args, **kwargs):
    try:
        decrypted_message, outer_iter_count, inner_iter_avg = yield aspectlib.Proceed
        print("ISD finished after %d iterations of outer loop and an average of %d iterations of inner loop"
              % (outer_iter_count, inner_iter_avg))
    except:
        raise ValueError('Attack algorithm returns incorrect values')
