
from random import choices, choice
from string import digits

datasets: dict[str, list[str]] = {}

for name in ('passwords', 'wordle', 'words'):
    with open(f'dataset_dictionaries/{name}.txt') as f:
        datasets[name] = f.readlines()

for name, dataset in datasets.items():
    with open(f'passwords/diccionarios/{name}.txt', 'wt') as f:
        f.writelines(choices(dataset, k=100))

with open('passwords/diccionarios/wordle_nums.txt', 'wt') as f:
    for _ in range(100):
        f.write(choice(datasets['wordle'])[:-1]+choice(digits)+choice(digits)+'\n')

with open('passwords/diccionarios/words_nums.txt', 'wt') as f:
    for _ in range(100):
        word = 'a'*6
        while len(word) > 5:
            word = choice(datasets['words'])[:-1]

        f.write(word+choice(digits)+choice(digits)+'\n')
