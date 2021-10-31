load('./GRSCode.sage')
load('./Niederreiter.sage')

code = GRSCode()
print(code.get_parity_check_matrix())

nied = Niederreiter(code=code)
print("---BEGIN PUBLIC KEY---")
print(nied.public_key)
print("---END PUBLIC KEY---")
enc = nied.encrypt()
print("Encrypted message is: \n"+str(enc))
dec = nied.decrypt(enc)
print("Decrypted message is: "+str(dec))
