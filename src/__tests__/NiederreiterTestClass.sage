import sys
import unittest
load('../Niederreiter.sage')
load('../GRSCode.sage')

class NiederreiterTestClass(unittest.TestCase):

    def test_key_generating(self):
        code = GRSCode()
        code_Nied = Niederreiter(code=code)
        self.assertTrue(len(code_Nied.generate_keypair()[0]), 2)

    def test_encrypt(self):
        code = GRSCode()
        code_Nied = Niederreiter(code=code)
        self.assertTrue(len(code_Nied.encrypt()[0]), 5)


suite = unittest.TestLoader().loadTestsFromTestCase(NiederreiterTestClass)
unittest.TextTestRunner(verbosity=2, stream=sys.stderr).run(suite)
