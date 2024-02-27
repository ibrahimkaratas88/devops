import random

lines = [" O\n","/","|","\\\n","/"," \\"]
words = []
word = ""
reveal =""
drawing = ""
IsDrawn = 0
dcount =0

def read_file_to_list(file):
  myfile = open(file,mode='r')
  return myfile.read().splitlines()
 

def set_word(MyList,reveal):
    index = random.randint(1,len(MyList)-1)
    for i in MyList[index]:
        reveal+="_ "
    return MyList[index]

def set_reveal(word):
    reveal = ""
    l = list(word)
    for i in l:
        reveal += "_"
    return reveal

def draw(dcount,drawing,lines):
    drawing= drawing + lines[dcount] 
    dcount = dcount + 1
    print(drawing)

def guess(letter):
    if letter in word:
        return 1
    else:
        return 0

def get_poses(word,letter):
    count =0
    CountList = []
    for i in word:
        if i == letter:
            CountList.append(count)
        count=count+1
    return CountList

#main

words = read_file_to_list("words.txt") #Reads the file with words and writes it to a python list.

word = set_word(words,reveal) #Sets the word that is going to be guessed.

reveal = set_reveal(word) #Sets the digits of the word that is going to be revealed as the letters are guessed correctly.

drawn = " O\n/|\\\n/ \\" #What the hangman should be looking like when the games is over.

print(reveal) #Print the digits before the game starts.

while(not IsDrawn): #Play the game until the hangman is drawn completely.
    
    letter = raw_input("Predict a letter: ") 

    if guess(letter) == True:
        l = list(reveal) #Convert the reveal into a list to be able to make changes on certain digits.
        lastreveal = "" #Temporary 
        CountList = get_poses(word,letter) #Find the digits of the correctly guessed letter.
        for i in CountList:
            l[i]=letter  #Switch the characters at digits to the letters to be revealed.
        reveal = lastreveal.join(l)
        print(reveal) #print the revealed letters and unrevealed digits.
        if(reveal == word): #Check if the word is found, finish the game if so.
            IsDrawn = 1
            print("You won!")
    elif guess(letter) == False:
         drawing= drawing + lines[dcount] #At part to be drawn.
         dcount = dcount + 1 #Set the digit of the next part to be drawn
         print(drawing) #Print the final version of hangman.
         if (drawing == drawn): #Finish the game if the hangman is completed.
             IsDrawn =1
             print("You lost. The word was: " + word) 
