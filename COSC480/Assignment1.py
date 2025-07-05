"""
================================================================================
Assignment 1 - Highway Capacity Calculations
================================================================================
"""
from typing import List, Tuple

# Terrain constants
LEVEL_CE_FACTOR = 1.7
ROLLING_CE_FACTOR = 4.0
MOUNTAINOUS_CE_FACTOR = 8.0

# Base PCU values
TWO_LANE_BASE_PCU = 4500
THREE_LANE_BASE_PCU = 6900
FOUR_LANE_BASE_PCU = 9600

# Valid terrain types
VALID_TERRAINS = ['level', 'rolling', 'mountainous']

# Congestion thresholds
FREE_FLOWING_THRESHOLD = 0.25
LIGHT_CONGESTION_THRESHOLD = 0.5
MODERATE_CONGESTION_THRESHOLD = 0.7
HEAVY_CONGESTION_THRESHOLD = 1.0

"""
================================================================================
Q1
================================================================================
"""
def car_equivalent_factor(terrain_type: str) -> float:
    """ Takes a string containing one of the three terrain types and returns the
        number of car equivalents for a truck on the given terrain as a float

    Args:
        terrain_type: One of 'level', 'rolling', or 'mountainous'

    Returns:
        Car equivalent factor as float

    Raises:
        ValueError: If terrain_type is not valid
    """
    terrain_factors = {
        'level': LEVEL_CE_FACTOR,
        'rolling': ROLLING_CE_FACTOR,
        'mountainous': MOUNTAINOUS_CE_FACTOR
    }

    if terrain_type not in terrain_factors:
        raise ValueError(f"Invalid terrain type: {terrain_type}. Must be one of {VALID_TERRAINS}")

    return terrain_factors[terrain_type]
"""
================================================================================
Q2
================================================================================
"""
def truck_adjustment_factor(truck_proportion: float, terrain_type: str) -> float:
    """ Takes the proportion of trucks using the motorway and the terrain type
        as inputs and returns the adjustment factor that is used for calculating
        the highway capacity

    Args:
        truck_proportion: Proportion of trucks (0.0 to 1.0)
        terrain_type: One of 'level', 'rolling', or 'mountainous'

    Returns:
        Truck adjustment factor as float

    Raises:
        ValueError: If truck_proportion is not in valid range or terrain_type is invalid
    """
    if not 0.0 <= truck_proportion <= 1.0:
        raise ValueError("Truck proportion must be between 0.0 and 1.0")

    ta_factor = 1 / (1 + truck_proportion * (car_equivalent_factor(terrain_type) - 1))
    return ta_factor
"""
================================================================================
Q3
================================================================================
"""
def motorway_capacity(num_lanes: int, truck_proportion: float, terrain_type: str) -> float:
    """ Takes the number of lanes each way (int), the proportion of trucks using
        the motorway (float) and the terrain_type (string) as inputs
        Returns the estimated capacity per hour in passenger car equivalent
        units (PCUs) for the highway (as a float)

    Args:
        num_lanes: Number of lanes (2, 3, or 4)
        truck_proportion: Proportion of trucks (0.0 to 1.0)
        terrain_type: One of 'level', 'rolling', or 'mountainous'

    Returns:
        Motorway capacity in PCUs per hour

    Raises:
        ValueError: If num_lanes is not 2, 3, or 4
    """
    lane_base_pcu = {
        2: TWO_LANE_BASE_PCU,
        3: THREE_LANE_BASE_PCU,
        4: FOUR_LANE_BASE_PCU
    }

    if num_lanes not in lane_base_pcu:
        raise ValueError(f"Number of lanes must be 2, 3, or 4, got {num_lanes}")

    base_pcu = lane_base_pcu[num_lanes]
    capacity = base_pcu * truck_adjustment_factor(truck_proportion, terrain_type)
    return capacity
"""
================================================================================
Q4
================================================================================
"""
def volume_to_capacity_ratio(volume: float, capacity: float) -> float:
    """ Takes the traffic volume and the capacity for a given section of
        motorway and returns the volume to capacity ratio

    Args:
        volume: Traffic volume
        capacity: Motorway capacity

    Returns:
        Volume to capacity ratio

    Raises:
        ValueError: If capacity is zero or negative
    """
    if capacity <= 0:
        raise ValueError("Capacity must be positive")

    vtc_ratio = volume / capacity
    return vtc_ratio
"""
================================================================================
Q5
================================================================================
"""
def volume_to_capacity_ratios(volumes: List[float], capacity: float) -> List[float]:
    """ Takes a list of hourly traffic volumes and the capacity for a given
        section of highway and returns the volume to capacity ratio for each
        volume in the list

    Args:
        volumes: List of traffic volumes
        capacity: Motorway capacity

    Returns:
        List of volume to capacity ratios
    """
    vtc_ratios = []
    for volume in volumes:
        vtc_ratios.append(volume_to_capacity_ratio(volume, capacity))
    return vtc_ratios
"""
================================================================================
Q6
================================================================================
"""
def volume_to_capacity_ratios_2(volumes: List[float], capacity: float) -> List[float]:
    """ Takes a list of hourly traffic volumes and the capacity for a given
        section of highway and returns the volume to capacity ratio for each
        volume in the list (using list comprehension)

    Args:
        volumes: List of traffic volumes
        capacity: Motorway capacity

    Returns:
        List of volume to capacity ratios
    """
    return [volume_to_capacity_ratio(volume, capacity) for volume in volumes]
"""
================================================================================
Q7
================================================================================
"""
def congestion_rating(ratio: float) -> str:
    """ Takes a volume to capacity ratio and returns a string containing a
        rating for the given ratio

    Args:
        ratio: Volume to capacity ratio

    Returns:
        Congestion rating as string
    """
    if ratio < FREE_FLOWING_THRESHOLD:
        cong_rating = 'free flowing'
    elif FREE_FLOWING_THRESHOLD <= ratio < LIGHT_CONGESTION_THRESHOLD:
        cong_rating = 'lightly congested'
    elif LIGHT_CONGESTION_THRESHOLD <= ratio < MODERATE_CONGESTION_THRESHOLD:
        cong_rating = 'moderately congested'
    elif MODERATE_CONGESTION_THRESHOLD <= ratio < HEAVY_CONGESTION_THRESHOLD:
        cong_rating = 'heavily congested'
    else:
        cong_rating = 'bottlenecked'
    return cong_rating
"""
================================================================================
Q8
================================================================================
"""
def num_hours_at_given_rating(volumes: List[float], capacity: float, rating: str) -> int:
    """ Takes a list of hourly traffic volumes, the capacity of the highway, and
        a target congestion rating as inputs
        Returns the number of readings where the volume to capacity ratio gives
        the given rating

    Args:
        volumes: List of traffic volumes
        capacity: Motorway capacity
        rating: Target congestion rating

    Returns:
        Number of hours with the given rating
    """
    count = 0
    for volume in volumes:
        if congestion_rating(volume_to_capacity_ratio(volume, capacity)) == rating:
            count += 1
    return count
"""
================================================================================
Q9
================================================================================
"""
def car_equivalent_volume(n_cars: float, n_trucks: float, terrain_type: str) -> float:
    """ Takes the number of cars and trucks and a terrain type and returns the
        total car equivalent volume of vehicles (total PCUs)

    Args:
        n_cars: Number of cars
        n_trucks: Number of trucks
        terrain_type: One of 'level', 'rolling', or 'mountainous'

    Returns:
        Total passenger car equivalent units (PCUs)
    """
    if n_cars < 0 or n_trucks < 0:
        raise ValueError("Number of vehicles cannot be negative")

    total_pcus = n_cars + n_trucks * car_equivalent_factor(terrain_type)
    return total_pcus
"""
================================================================================
Q10
================================================================================
"""
def print_growth(n_cars: float, n_trucks: float, car_growth: float, truck_growth: float,
                terrain: str, capacity: float) -> None:
    """ Prints out a table showing the average traffic flows each year up until
        the given motorway becomes bottlenecked

    Args:
        n_cars: Initial number of cars
        n_trucks: Initial number of trucks
        car_growth: Annual car growth rate (as decimal, e.g., 0.05 for 5%)
        truck_growth: Annual truck growth rate (as decimal)
        terrain: Terrain type
        capacity: Motorway capacity
    """
    if car_growth < 0 or truck_growth < 0:
        raise ValueError("Growth rates cannot be negative")

    year = 0
    cars = n_cars
    trucks = n_trucks

    print("Year        Cars      Trucks        PCUs       Ratio")

    while True:
        pcu = car_equivalent_volume(cars, trucks, terrain)
        ratio = volume_to_capacity_ratio(pcu, capacity)

        if ratio >= 1.0:
            break

        print(f'{year:4}{cars:12.2f}{trucks:12.2f}{pcu:12.2f}{ratio:12.2f}')

        year += 1
        cars *= (1 + car_growth)
        trucks *= (1 + truck_growth)
"""
================================================================================
Q11
================================================================================
"""
def car_equivalent_volumes(volume_tuples: List[Tuple[float, float]], terrain_type: str) -> List[float]:
    """ Takes a list of (car_volume, truck_volume) tuples and a terrain type and
        returns a the list of car equivalent volumes corresponding to each tuple

    Args:
        volume_tuples: List of (car_volume, truck_volume) tuples
        terrain_type: One of 'level', 'rolling', or 'mountainous'

    Returns:
        List of car equivalent volumes
    """
    cev_list = []
    for car_volume, truck_volume in volume_tuples:
        cev_list.append(car_equivalent_volume(car_volume, truck_volume, terrain_type))
    return cev_list
"""
================================================================================
Q12
================================================================================
"""
def get_valid_terrain_type() -> str:
    """ Asks the user to enter a terrain type and keeps asking until
        level, rolling, or mountainous is entered

    Returns:
        Valid terrain type string
    """
    prompt = "Enter terrain type: "
    response = input(prompt)
    while response not in VALID_TERRAINS:
        print("Must be level, rolling or mountainous.")
        response = input(prompt)
    return response
"""
================================================================================
Q13
================================================================================
"""
def get_int_in_range(prompt: str, minimum: int, maximum: int) -> int:
    """ Asks the user to enter an integer (using the given prompt) and keeps
        asking until a valid value (between minimum and maximum) is entered

    Args:
        prompt: Input prompt string
        minimum: Minimum allowed value
        maximum: Maximum allowed value

    Returns:
        Valid integer within range
    """
    while True:
        try:
            response = int(input(prompt))
            if minimum <= response <= maximum:
                return response
            else:
                print(f"Number must be between {minimum} and {maximum}.")
        except ValueError:
            print("Please enter a valid integer.")
"""
================================================================================
Q14
================================================================================
"""
def get_non_negative_float(prompt: str) -> float:
    """ Asks the user to enter a number (using the given prompt) and keeps
        asking until a non-negative value is entered

    Args:
        prompt: Input prompt string

    Returns:
        Non-negative float value
    """
    while True:
        try:
            response = float(input(prompt))
            if response >= 0:
                return response
            else:
                print('Number must be at least zero.')
        except ValueError:
            print("Please enter a valid number.")
"""
================================================================================
Q15
================================================================================
"""
def get_float_in_range(prompt: str, minimum: float, maximum: float) -> float:
    """Asks the user to enter a number (using the given prompt) and keeps asking
       until a valid value (between minimum and maximum, inclusive) is entered

    Args:
        prompt: Input prompt string
        minimum: Minimum allowed value
        maximum: Maximum allowed value

    Returns:
        Valid float within range
    """
    while True:
        try:
            response = float(input(prompt))
            if minimum <= response <= maximum:
                return response
            else:
                print(f'Number must be between {minimum} and {maximum}.')
        except ValueError:
            print("Please enter a valid number.")
"""
================================================================================
Q16
================================================================================
"""
def print_congestion_ratings(motorway_info: dict) -> None:
    """ Takes a dictionary, mapping from motorway names to motorway info tuples
        Prints out a summary of the congestion rating for each motorway

    Args:
        motorway_info: Dictionary mapping motorway names to (num_lanes, truck_proportion, terrain, volume) tuples
    """
    print("Motorway             Ratio  Congestion")
    for name, info in sorted(motorway_info.items()):
        num_lanes, truck_proportion, terrain, volume = info
        capac = motorway_capacity(num_lanes, truck_proportion, terrain)
        ratio = volume_to_capacity_ratio(volume, capac)
        rating = congestion_rating(ratio)
        print(f'{name:20}{ratio:6.2f}  {rating:<12}')
"""
================================================================================
Q17
================================================================================
"""
def main() -> None:
    """ This program asks the user for the number of lanes, the terrain type, the
        proportion of trucks, and the current volume of vehicles on a motorway
        It then calculates and prints the motorway capacity, the volume to capacity
        ratio, and the congestion rating under these circumstances
    """
    try:
        num_lanes = int(get_float_in_range('Enter number of lanes: ', 2, 4))
        terrain = get_valid_terrain_type()
        n_trucks = get_float_in_range('Enter truck proportion: ', 0, 1)
        capacity = motorway_capacity(num_lanes, n_trucks, terrain)
        print(f'Motorway capacity is {capacity:.2f} PCUs/hour.')
        volume = get_non_negative_float('Enter vehicle volume: ')
        v2c_ratio = volume_to_capacity_ratio(volume, capacity)
        print(f'Volume to capacity ratio is {v2c_ratio:.2f}.')
        congestion = congestion_rating(v2c_ratio)
        print(f'The traffic is {congestion}.')
    except (ValueError, KeyboardInterrupt) as e:
        print(f"Program terminated: {e}")

if __name__ == "__main__":
    main()
