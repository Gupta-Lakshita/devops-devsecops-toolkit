def multiply_values(list):
    multiplied_values = []

    for item in list:
        multiplied_values.append(item * 2)

    return multiplied_values

print(multiply_values([1, 2, 3]))

# output: [2, 4, 6]