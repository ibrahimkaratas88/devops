inFile = open('encrypted.txt', 'r')

# read the ciphertext into a string
strFile = inFile.read()

# create the dictionary
letters = {}
for symbol in strFile:              # for each symbol in the file
  if symbol.isalnum():            # if it is either digit or from alphabet
    if symbol in letters:       # if the symbol is already in the dictionary
      letters[symbol] += 1    # update its value
    else:                       # otherwise
      letters[symbol] = 1     # add it to the dictionary

# find the maximum occuring letter's count
maxLetterCount = max(letters.values())

# find the maximum occuring letter
for symbol, count in letters.items():
  if count == maxLetterCount:
    maxLetter = symbol
    break

# find the shift amount
shift = ord(maxLetter)-ord("E")

# decrypt the ciphertext and store it in another string
plain = ""
for symbol in strFile:                   # for each symbol in the text
  if symbol.isalpha():                # if it is a letter
    charOrd = ord(symbol) - shift     # find the original letter
    if charOrd < ord("A"):            # correct if it is smaller than A  
      charOrd += 26
    elif charOrd > ord("Z"):          # correct if it is greater than Z 
      charOrd -= 26
    plain += chr(charOrd)   # append the original letter to the plaintext  
  else:                               # otherwise
    plain += symbol

# open the output file, write the plaintext
outFile = open('plaintext2.txt','w')
outFile.write(plain)
print("Encryption suceeded. Plaintext is in plaintext.txt")

# close the files
inFile.close()
outFile.close()
