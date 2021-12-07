import sys
import unittest
load('../Niederreiter.sage')
load('../GRSCode.sage')

def GetRandomMessageWithWeight(message_length, message_weight):
    message = matrix(GF(2), 1, message_length)
    rng = range(message_length)
    for i in range(message_weight):
        p = floor(len(rng)*random())
        message[0,rng[p]] = 1 
        rng=[*rng[:p],*rng[p+1:]]
    return message

class NiederreiterTestClass(unittest.TestCase):

    def test_key_generating(self):
        code = GRSCode()
        code_Nied = Niederreiter()
        # self.assertTrue(len(code_Nied.generate_keypair()[0]), 2)

    def test_encrypt(self):
        crypto = Niederreiter()
        message = GetRandomMessageWithWeight(crypto._PublicKey.ncols(),crypto._g.degree())
        encrypted_message = crypto.encrypt(message)
        decrypted_message = crypto.decrypt(encrypted_message)
        print ('random msg:', message.str())
        print ('encrypted msg:', encrypted_message.str())
        print ('decrpted msg:', decrypted_message.str())
        if message == decrypted_message:
	        print ('It works!')    
        else:
	        print ('Something wrong!', crypto._GetRowVectorWeight(decrypted_message))
        self.assertTrue(message == decrypted_message)


suite = unittest.TestLoader().loadTestsFromTestCase(NiederreiterTestClass)
unittest.TextTestRunner(verbosity=2, stream=sys.stderr).run(suite)
