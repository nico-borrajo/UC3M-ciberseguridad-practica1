from random import choices
from string import ascii_lowercase, ascii_uppercase, digits, punctuation

data_sets = (
    ('minusculas', ascii_lowercase),
    ('mayusculas', ascii_uppercase),
    ('digitos', digits),
    ('alfanumericos', ascii_lowercase + ascii_uppercase + digits + punctuation)
)

for name, charset in data_sets:
    for length in range(3, 8):
        passwords = [''.join(choices(charset, k=length)) for _ in range(100)]

        with open(f'passwords/{name}/len{length}.txt', 'w') as f:
            f.write('\n'.join(passwords))