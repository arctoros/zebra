import random

def calculate_output_voltage(resistors, bits):
    parallel_resistance = sum(1 / resistors[i] for i in range(4) if bits[i])
    if parallel_resistance == 0:
        return 0  # If no switch is on, output is 0V
    Req = 1 / parallel_resistance
    Vout = 5 * (75 / (75 + Req))
    return Vout

avail_resistors = [
        402, 412, 422, 432, 442, 453, 464, 475, 487, 499, 511, 523, 536, 549, 562, 576, 590, 604, 619, 634, 649, 665, 681, 698, 715, 732, 750, 768, 787, 806, 825, 845, 866, 887, 909, 931, 953, 976,
        1240, 1270, 1300, 1330, 1370, 1400, 1430, 1470, 1500, 1540, 1580, 1620, 1650, 1690, 1740, 1780, 1820, 1870, 1910, 1960, 2000, 2050, 2100, 2160, 2210, 2260, 2320, 2370, 2430, 2490, 2550, 2610, 
        2670, 2740, 2800, 2870, 2940, 3010, 3090, 3160, 3240, 3320, 3400, 3480, 3570, 3650, 3740, 3830, 3920, 4020, 4120, 4220, 4320, 4420, 4530, 4640, 4750, 4870, 4990, 5110, 5230, 5360, 5490, 5620, 
        5760, 5900, 6040, 6190, 6340, 6490, 6650, 6810, 6980, 7150, 7320, 7500, 7680, 7870, 8060, 8250, 8450, 8660, 8870, 9090, 9310, 9530, 9760
        ]

best_combination = [925, 2099, 3900, 7099] 
resistors = best_combination
best_error = float('inf')
heat = 200

while True:
    while heat > 20:
        for i in range(4):
            rand = random.random()
            if rand > 0.8:
                resistors[i] += heat

            elif rand < 0.2:
                resistors[i] -= heat

        # Calculate voltage levels for all 4-bit combinations (0000 to 1111)
        expected_voltages = [0, 0.04375, 0.0875, 0.13125, 0.175, 0.21875, 0.2625, 0.30625, 0.35, 0.39375, 0.4375, 0.48125, 0.525, 0.56875, 0.6125, 0.65625, 0.7]
        actual_voltages = [calculate_output_voltage(resistors, list(map(int, f"{i:04b}"))) for i in range(16)]
        
        # Compute total error as sum of squared differences
        error = 0
        for i in range(16):
            error += abs((actual_voltages[i] - expected_voltages[i]))
        
        heat *= 0.99999
        #print(heat)

        # Check if this is the best combination so far
        if error < best_error:
            best_error = error
            best_combination = resistors
            print("New Best:", best_combination, "Error:", best_error)

    resistors = best_combination
    best_error = float('inf')
    heat = 500
    print("Cycle Done.")
