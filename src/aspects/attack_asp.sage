import aspectlib
import json
import os
from datetime import datetime


@aspectlib.Aspect
def print_algorithm_status(*args, **kwargs):
    try:
        decrypted_message, outer_iter_count, inner_iter_avg = yield aspectlib.Proceed
        print("ISD finished after %d iterations of outer loop and an average of %d iterations of inner loop"
              % (outer_iter_count, inner_iter_avg))
    except:
        raise ValueError('Attack algorithm returns incorrect values')

@aspectlib.Aspect
def save_result_to_file(*args, **kwargs):
    result = yield aspectlib.Proceed
    json_compatible_result = {f: str(result[f]) for f in result}
    # sage is weird so this will be in C:/users/YourUserName
    if not os.path.exists('prange_results'):
        os.makedirs('prange_results')
    with open(f'./prange_results/bin_goppa_m={result["m"]}_t={result["t"]}_{datetime.now()}.json', 'w+') as f:
        json.dump(json_compatible_result, f)
