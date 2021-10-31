load("./PrangeISD.sage")

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


prange = PrangeISD(H = SAMPLE_PC_MATRIX_2, syndrome = SAMPLE_SYNDROME_2, t = SAMPLE_WEIGHT_2)
e = prange.attack()
print("OUTPUT:\n", SAMPLE_PC_MATRIX_2 * e.transpose())
