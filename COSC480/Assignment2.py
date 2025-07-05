"""
================================================================================
Assignment 2 - Traffic Count Data Analysis
================================================================================
"""
from typing import Dict, List, Tuple, Optional
import numpy as np
import matplotlib.pyplot as plt
import os

# Column indices
class DataColumns:
    YEAR = 0
    MONTH = 1
    DAY = 2
    WEEK_OF_YEAR = 3
    DAY_OF_WEEK = 4
    DAY_OF_YEAR = 5
    SITE_ID = 6
    WEIGHT_CLASS = 7
    COUNT = 8

# Weight class constants
WEIGHT_CLASS_LIGHT = 1
WEIGHT_CLASS_HEAVY = 2
WEIGHT_CLASS_STRING = {WEIGHT_CLASS_LIGHT: 'Light', WEIGHT_CLASS_HEAVY: 'Heavy'}

"""
================================================================================
Q1
================================================================================
"""
def read_sites_info(filename: str) -> Dict[int, Tuple[str, str]]:
    """ Takes as a parameter the name of an existing site info file and returns
        a dictionary that maps site_ids to (site_name, region) tuples

    Args:
        filename: Path to the site info file

    Returns:
        Dictionary mapping site_ids to (site_name, region) tuples

    Raises:
        FileNotFoundError: If the file doesn't exist
        ValueError: If the file format is invalid
    """
    site_dict = {}
    try:
        with open(filename, 'r') as file:
            lines = file.read().splitlines()
            for line in lines[1:]:  # Skip header
                try:
                    site_id, site_name, region = line.split(",")
                    site_dict[int(site_id)] = (site_name, region)
                except ValueError:
                    raise ValueError(f"Invalid line format: {line}")
    except FileNotFoundError:
        raise FileNotFoundError(f"File {filename} not found")

    return site_dict
"""
================================================================================
Q2
================================================================================
"""
def limited_string(s: str, max_len: int) -> str:
    """ Takes string parameter s and maximum field length max_len and returns
        s truncated to the length max_len

    Args:
        s: Input string
        max_len: Maximum allowed length

    Returns:
        String truncated to max_len with "..." if needed
    """
    if len(s) > max_len:
        return s[:(max_len-3)] + "..."
    else:
        return s
"""
================================================================================
Q3
================================================================================
"""
def print_sites_table(sites_info: Dict[int, Tuple[str, str]]) -> None:
    """ Takes a sites_info dictionary and prints out a summary of the sites

    Args:
        sites_info: Dictionary mapping site_ids to (site_name, region) tuples
    """
    print("Site table")
    print("==========")
    print(f'{"ID":>8}:  {"Name":<45}{"Region":<20}')
    for site_id, (name, region) in sorted(sites_info.items()):
        limited_name = limited_string(name, 40)
        print(f'{site_id:8}:  {limited_name:45}{region:20}')
"""
================================================================================
Q4
================================================================================
"""
def regions_from_sites(sites_info: Dict[int, Tuple[str, str]]) -> Dict[str, List[int]]:
    """ Takes a sites_info dictionary and returns a dictionary where the keys
        are region names and the values are lists of site_ids in those regions

    Args:
        sites_info: Dictionary mapping site_ids to (site_name, region) tuples

    Returns:
        Dictionary mapping region names to lists of site_ids
    """
    result = dict()
    for site_id, (name, region) in sites_info.items():
        if region not in result:
            result[region] = [site_id]
        else:
            result[region] = result[region] + [site_id]
    return result
"""
================================================================================
Q5
================================================================================
"""
def load_count_data(filename: str) -> np.ndarray:
    """ Reads a file of traffic count data and returns a numpy 2D array of ints

    Args:
        filename: Path to the count data file

    Returns:
        2D numpy array of traffic count data

    Raises:
        FileNotFoundError: If the file doesn't exist
        ValueError: If the file format is invalid
    """
    try:
        return np.loadtxt(filename, dtype=int, delimiter=",", skiprows=1)
    except FileNotFoundError:
        raise FileNotFoundError(f"Count data file '{filename}' not found")
    except ValueError as e:
        raise ValueError(f"Error reading count data from '{filename}': {e}")
"""
================================================================================
Example usage patterns (commented out)
================================================================================
"""
# Example 1: Filter for specific site and weight class
# for i in range(len(data)):
#     if data[i, DataColumns.SITE_ID] == required_site_id and data[i, DataColumns.COUNT] == 2:
#         process_row(data[i])

# Example 2: Using constants for better readability
# for i in range(len(data)):
#     if data[i, DataColumns.SITE_ID] == required_site_id and data[i, DataColumns.WEIGHT_CLASS] == WEIGHT_CLASS_HEAVY:
#         process_row(data[i])
"""
================================================================================
Q6
================================================================================
"""
def print_summary(counts_data: np.ndarray) -> None:
    """ Prints a summary of the information present in the parameter counts_data
        which is a 2D numpy array as returned by the load_count_data function

    Args:
        counts_data: 2D numpy array of traffic count data
    """
    print("Data summary")
    print("============")
    print(f"Number of rows: {counts_data.shape[0]}")
    print(f"Min daily traffic count: {np.min(counts_data[:,DataColumns.COUNT])}")
    print(f"Max daily traffic count: {np.max(counts_data[:,DataColumns.COUNT])}")
    print(f"Mean daily traffic count: {np.mean(counts_data[:,DataColumns.COUNT]):.2f}")
    sites = ", ".join([str(num) for num in np.sort(np.unique(counts_data[:,DataColumns.SITE_ID]))])
    print(f"Site IDs: {sites}")
    years = ", ".join([str(num) for num in np.sort(np.unique(counts_data[:,DataColumns.YEAR]))])
    print(f"Years: {years}")
"""
================================================================================
Q7
================================================================================
"""
def filter_by(column_number: int, data: np.ndarray, match_value: int) -> np.ndarray:
    """ Takes an int column_number, a numpy 2D array data, and a value match_value
        and returns a new numpy array containing all the rows from data that have
        the given match_value at the given column number (0 origin)

    Args:
        column_number: Column index to filter on
        data: 2D numpy array to filter
        match_value: Value to match in the specified column

    Returns:
        Filtered numpy array
    """
    return data[match_value == data[:, column_number], :]
"""
================================================================================
Example filter usage (commented out)
================================================================================
"""
# year_data = filter_by(DataColumns.YEAR, data, 2019)
# heavy_traffic_for_year = filter_by(DataColumns.WEIGHT_CLASS, year_data, WEIGHT_CLASS_HEAVY)
# site_data = filter_by(DataColumns.SITE_ID, data, site_id)
# year_data = filter_by(DataColumns.YEAR, site_data, year)
# weight_data = filter_by(DataColumns.WEIGHT_CLASS, year_data, WEIGHT_CLASS_LIGHT)
"""
================================================================================
Q8
================================================================================
"""
def traffic_for_date(site_id: int, year: int, month: int, day: int, data: np.ndarray) -> Optional[Tuple[int, int]]:
    """ Returns a tuple of the light traffic count and heavy traffic count for
        the given site on the given date

    Args:
        site_id: Site ID to filter for
        year: Year to filter for
        month: Month to filter for
        day: Day to filter for
        data: Traffic count data array

    Returns:
        Tuple of (light_count, heavy_count) or None if no data found
    """
    site_data = filter_by(DataColumns.SITE_ID, data, site_id)
    year_data = filter_by(DataColumns.YEAR, site_data, year)
    month_data = filter_by(DataColumns.MONTH, year_data, month)
    day_data = filter_by(DataColumns.DAY, month_data, day)
    lightweight_data = filter_by(DataColumns.WEIGHT_CLASS, day_data, WEIGHT_CLASS_LIGHT)
    heavyweight_data = filter_by(DataColumns.WEIGHT_CLASS, day_data, WEIGHT_CLASS_HEAVY)
    if lightweight_data.shape == (0, 9) or heavyweight_data.shape == (0, 9):
        return None
    else:
        return (lightweight_data[0, -1], heavyweight_data[0, -1])
"""
================================================================================
Q9
================================================================================
"""
def extract_plot_line_data(data_array: np.ndarray, site_id: int, year: int, weight_class: int) -> np.ndarray:
    """ Extracts the traffic counts for a given site, year, and weight class ready for graphing

    Args:
        data_array: 2D numpy array of traffic count data
        site_id: Site ID to filter for
        year: Year to filter for
        weight_class: Weight class (1 for light, 2 for heavy)

    Returns:
        Filtered numpy array for the specified parameters
    """
    site_data = filter_by(DataColumns.SITE_ID, data_array, site_id)
    year_data = filter_by(DataColumns.YEAR, site_data, year)
    if weight_class == WEIGHT_CLASS_LIGHT:
        return filter_by(DataColumns.WEIGHT_CLASS, year_data, WEIGHT_CLASS_LIGHT)
    elif weight_class == WEIGHT_CLASS_HEAVY:
        return filter_by(DataColumns.WEIGHT_CLASS, year_data, WEIGHT_CLASS_HEAVY)
    else:
        raise ValueError(f"Invalid weight class: {weight_class}. Must be {WEIGHT_CLASS_LIGHT} or {WEIGHT_CLASS_HEAVY}")

def plot_daily_traffic(data_array: np.ndarray, sites_info_dict: Dict[int, Tuple[str, str]], site_id: int, year: int) -> None:
    """ Plots on the same set of axes both the light traffic counts and the heavy
        traffic counts for a given site and year

    Args:
        data_array: 2D numpy array of traffic count data
        sites_info_dict: Dictionary mapping site_ids to (site_name, region) tuples
        site_id: Site ID to plot
        year: Year to plot
    """
    axes = plt.axes()
    lightweight = extract_plot_line_data(data_array, site_id, year, WEIGHT_CLASS_LIGHT)
    heavyweight = extract_plot_line_data(data_array, site_id, year, WEIGHT_CLASS_HEAVY)
    xs = [lightweight[:, DataColumns.DAY_OF_YEAR], heavyweight[:, DataColumns.DAY_OF_YEAR]]
    ys = [lightweight[:, DataColumns.COUNT], heavyweight[:, DataColumns.COUNT]]
    axes.plot(xs[0], ys[0], label="Light")
    axes.plot(xs[1], ys[1], label="Heavy")
    axes.legend()
    site_name = sites_info_dict[site_id][0]
    axes.set_title(f'Daily traffic, {year}\nSite {site_id}: {site_name}')
    axes.set_xlabel("Day number")
    axes.set_ylabel("Daily traffic")
    axes.grid(True)
    plt.show()
"""
================================================================================
Q10
================================================================================
"""
def weekly_totals(data: np.ndarray, site_id: int, year: int, weight_class: int) -> np.ndarray:
    """ Takes as parameters a numpy array of traffic count data as returned by
        load_count_data, a site ID, a year and weight class (1 or 2 for light
        and heavy respectively) and returns a numpy array of 52 numbers

    Args:
        data: 2D numpy array of traffic count data
        site_id: Site ID to filter for
        year: Year to filter for
        weight_class: Weight class (1 for light, 2 for heavy)

    Returns:
        Numpy array of 52 weekly totals
    """
    filtered_data = extract_plot_line_data(data, site_id, year, weight_class)

    if filtered_data.size == 0:
        return np.zeros(52)

    # Group by week and sum counts
    weeks = filtered_data[:, DataColumns.WEEK_OF_YEAR]
    counts = filtered_data[:, DataColumns.COUNT]

    weekly_sums = np.zeros(52)
    for week_num in range(1, 53):
        week_mask = weeks == week_num
        weekly_sums[week_num - 1] = counts[week_mask].sum()

    return weekly_sums
"""
================================================================================
Q11
================================================================================
"""
def plot_weekly_total_bars(data: np.ndarray, sites_info: Dict[int, Tuple[str, str]], site_id: int, year: int) -> None:
    """ Takes as parameters the counts data array, the sites info dictionary a
        site ID and a year and plots a bar chart of the totals for each week of the year

    Args:
        data: 2D numpy array of traffic count data
        sites_info: Dictionary mapping site_ids to (site_name, region) tuples
        site_id: Site ID to plot
        year: Year to plot
    """
    axes = plt.axes()
    lightweight = weekly_totals(data, site_id, year, WEIGHT_CLASS_LIGHT)
    heavyweight = weekly_totals(data, site_id, year, WEIGHT_CLASS_HEAVY)
    xs = np.arange(1, 53, 1)
    ys = [lightweight, heavyweight]
    axes.bar(xs, ys[0], label='Light', width=0.5, color='slateblue')
    axes.bar(xs, ys[1], label='Heavy', color='orange')
    axes.legend()
    site_name = sites_info[site_id][0]
    axes.set_title(f'Total weekly traffic, {year}\nSite {site_id}: {site_name}')
    axes.set_xlabel("Week numbers")
    axes.set_ylabel("Total vehicles per week")
    plt.show()
"""
================================================================================
Q12
================================================================================
"""
def get_valid_site_id(sites_info: Dict[int, Tuple[str, str]]) -> int:
    """ Takes a sites_info dictionary and asks the user to input a site_id
        number using a prompt

    Args:
        sites_info: Dictionary mapping site_ids to (site_name, region) tuples

    Returns:
        Valid site ID entered by user
    """
    while True:
        site_id_input = input("Enter a site id number (? for help): ")

        if site_id_input == "?":
            print_sites_table(sites_info)
            continue

        try:
            site_id = int(site_id_input)
            if site_id in sites_info:
                return site_id
            else:
                print("Unknown site number")
        except ValueError:
            print("You must enter a valid integer")
"""
================================================================================
Q13
================================================================================
"""
def site_prompt() -> str:
    """ Prompts user for site info filename and validates it exists

    Returns:
        Valid site info filename
    """
    while True:
        site_file = input("Enter filename of site info data: ")
        if os.path.isfile(site_file):
            return site_file
        else:
            print("File not found")

def count_prompt() -> str:
    """ Prompts user for count data filename and validates it exists

    Returns:
        Valid count data filename
    """
    while True:
        count_file = input("Enter filename of count data: ")
        if os.path.isfile(count_file):
            return count_file
        else:
            print("File not found")

def get_valid_year() -> int:
    """ Prompts user for a valid year

    Returns:
        Valid year as integer
    """
    while True:
        try:
            year = int(input("Year to plot? "))
            if 1900 <= year <= 2100:  # Reasonable year range
                return year
            else:
                print("Please enter a reasonable year (1900-2100)")
        except ValueError:
            print("Please enter a valid year")

def get_valid_plot_type() -> int:
    """ Prompts user for a valid plot type

    Returns:
        Valid plot type (1 for daily, 2 for weekly)
    """
    while True:
        try:
            plot_type = int(input("Type of plot (1 = daily, 2 = weekly)? "))
            if plot_type in [1, 2]:
                return plot_type
            else:
                print("Please enter 1 for daily or 2 for weekly plots")
        except ValueError:
            print("Please enter a valid number (1 or 2)")

def main() -> None:
    """ A program for visually displaying some traffic count data
        For COSC131
        Author: Sam Love
        Date: 31 October 2021

        Collects and calls all the required functions for the program
    """
    try:
        site_file = site_prompt()
        count_file = count_prompt()
        sites = read_sites_info(site_file)
        counts = load_count_data(count_file)
        print("")
        print_summary(counts)
        print("")
        site_id = get_valid_site_id(sites)
        year = get_valid_year()
        graph_type = get_valid_plot_type()
        if graph_type == 1:
            plot_daily_traffic(counts, sites, site_id, year)
        else:
            plot_weekly_total_bars(counts, sites, site_id, year)
    except (FileNotFoundError, ValueError, KeyboardInterrupt) as e:
        print(f"Program terminated: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()
