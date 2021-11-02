import sys
import unittest

load("../PrangeISD.sage")

SAMPLE_PC_MATRIX_2 = Matrix(ZZ, matrix([
    [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1],
    [0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1],
    [1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1],
    [0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0],
    [0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1],
    [0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1]
])
)

SAMPLE_SYNDROME_2 = Matrix(ZZ, matrix(8, 1, [0, 1, 1, 0, 0, 1, 0, 0]))
SAMPLE_WEIGHT_2 = 3

class PrangeTestClass(unittest.TestCase):

    def test_inner_loop_returns_right_data_format(self):
        prange = PrangeISD(H=SAMPLE_PC_MATRIX_2,
                           syndrome=SAMPLE_SYNDROME_2, t=SAMPLE_WEIGHT_2)
        P, V, U, inner_iteration_count = prange.inner_loop()
        r, n = SAMPLE_PC_MATRIX_2.dimensions()
        self.assertEqual((n, n), P.dimensions())
        self.assertEqual((r, n - r), V.dimensions())
        self.assertEqual((r, r), U.dimensions())
        self.assertGreater(inner_iteration_count, 0)

    def test_attack_result(self):
        prange = PrangeISD(H=SAMPLE_PC_MATRIX_2,
                           syndrome=SAMPLE_SYNDROME_2, t=SAMPLE_WEIGHT_2)

        e = prange.attack()
        decoding = SAMPLE_PC_MATRIX_2 * e.transpose()

        self.assertEqual(decoding, SAMPLE_SYNDROME_2)



suite = unittest.TestLoader().loadTestsFromTestCase(PrangeTestClass)
unittest.TextTestRunner(verbosity=2, stream=sys.stderr).run(suite)
