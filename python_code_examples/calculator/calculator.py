result =0

def sum(par1,par2):
    return par1+par2      
    
def min(par1,par2):
      return par1 - par2 
    
def mult(par1,par2):
    return par1*par2
 
def div (par1,par2):
    return par1/par2
        
def checkValid(input,MyLst):
    par1=False 
    par2=False 
    opr = False
    operands = ["+","-","*","/"]
    MyLst["ParVal1"] = ""
    MyLst["ParVal2"] = ""
    MyLst["OprVal"] = ""

    for i in input:
        asci = ord(i)
        if  not opr and (48 <= asci <= 57):
            par1 = True
            MyLst["ParVal1"] = MyLst["ParVal1"] + i
        elif not opr and i not in operands:
            par1 = False

        if opr and (48<=asci<=57):
            par2= True
            MyLst["ParVal2"] = MyLst["ParVal2"] + i
        elif opr:
            par2 =False

        if i in operands and not opr:
            MyLst["OprVal"] = i
            opr= True

    return (opr and par1 and par2)
    


op = str(input("Welcome to callulator! Please enter an operation: "))
MyLst = {"ParVal1":"","ParVal2":"","OprVal":""}

while(op != "stop"):
  if checkValid(op,MyLst):
      if MyLst["OprVal"] == "+":
         result = sum(int(MyLst["ParVal1"]),int(MyLst["ParVal2"]))

      if MyLst["OprVal"] == "-":
         result = min(int(MyLst["ParVal1"]),int(MyLst["ParVal2"]))

      if MyLst["OprVal"] == "/":
         result = div(int(MyLst["ParVal1"]),int(MyLst["ParVal2"]))

      if MyLst["OprVal"] == "*":
         result = mult(int(MyLst["ParVal1"]),int(MyLst["ParVal2"]))
  print(result)  

  op = str(input("To terminate, enter 'stop'; to continue, enter another operation: "))
