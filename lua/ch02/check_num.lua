-- Exercise 2.2: Which of the following are valid
-- numerals? What are their value

print(".0e12:", .0e12)
--print(".e12:", .e12)  没有实数
--print("0.0e:", 0.0e)  没有指数
print("0x12:", 0x12)
--print("0xABFG:", 0xABFG) G不是16进制
print("OxA:", 0xA)
print("FFFF:", FFFF)
print("0xFFFFFFFF", 0xFFFFFFF)
--print("ox:", 0x)      没有具体的数
print("ox1P10:", 0x1P10)  
print("0.1e1:", 0.1e1)
print("0x0.1p1:", 0x0.1p1)