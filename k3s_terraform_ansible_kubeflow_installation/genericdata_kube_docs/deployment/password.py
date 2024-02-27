import bcrypt

password = b"jca@23571113V"

hashed = bcrypt.hashpw(password, bcrypt.gensalt())

print(hashed)
