total_bits = 6380352
modulation_bits = 4
coding_rate = 1 / 2

effective_bits_per_symbol = modulation_bits * coding_rate

total_symbols = total_bits / effective_bits_per_symbol

print(total_symbols)
