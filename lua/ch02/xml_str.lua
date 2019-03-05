-- Exercise 2.4: How can you embed the following piece
-- of XML as a string in Lua? Show at least two
-- different ways.

xml_str = [=[
<![CDATA[
    Hello world
]]>]=]

xml_str2 = "<![CDATA[\n    Hello world\n]]>"

print("xml_str == xml_str2:", xml_str == xml_str2)
print(xml_str)