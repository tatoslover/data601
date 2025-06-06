""" Program to visually display some NBA data using matplotlib.
    COSC480 2021 S2 Project
    Author: Samuel Love
    Date: 22 October 2021
"""

import numpy as np
import matplotlib.pyplot as plt

TEAM_OPTIONS = ["Mavericks", "Lakers", "Knicks"]
TEAM_ERROR_MESSAGE = "Team must be Mavericks, Lakers, or Knicks"
SEASON_OPTIONS = ["Regular", "Playoff", "Both"]
SEASON_ERROR_MESSAGE = "Options are Regular, Playoff, or Both"
CONTINUE_OPTIONS = ["Y", "N"]
CONTINUE_ERROR_MESSAGE = "Options are Y or N"
STATISTIC_OPTIONS = ["3%","3 Attempts","Points"]
STATISTIC_ERROR_MESSAGE = "Options are 3%, 3 Attempts, or Points"
WELCOME_MESSAGE = "Hello. This program is desgined to help visualise trends in data. The sample dataset is from the NBA which is the premier basketball league in the USA. There is data for three teams: Dallas Mavericks, Los Angeles Lakers, and New York Knicks.  The data also covers three time periods: 2000, 2010, and 2020.  Statistics included are: three point percentage, three point attempts, points, and win percentage.  By graphing various configerations one can observe trends over time and across teams."
    
def prompt_team():
    """ Prompts the user for which teams they want to use.
    """
    print()
    print(f"Team options are {TEAM_OPTIONS}")
    team = input("Which team do you want to use? ")
    while team not in TEAM_OPTIONS:
        print(TEAM_ERROR_MESSAGE)
        team = input("Which team do you want to use? ")
    return team


def prompt_season():
    """ Prompts the user whether they want to use regular season, playoff, or both.
    """
    print(f"Season options are {SEASON_OPTIONS}")
    season = input("Do you want to use the regular season or playoffs or both? ")
    while season not in SEASON_OPTIONS:
        print(SEASON_ERROR_MESSAGE)
        season = input("Do you want to use the regular season or playoffs or both? ")
    return season


def statistic_wanted():
    """ Prompts the user for which statistic they want to graph.
    """
    print(f"Statistic options are {STATISTIC_OPTIONS}")
    statistic = input("Which statistic do you want to plot (x-axis) against wins (y-axis)? ")
    while statistic not in STATISTIC_OPTIONS:
        print(STATISTIC_ERROR_MESSAGE)
        statistic = input("Which statistic do you want to plot (x-axis) against wins (y-axis)? ")
    return statistic


def data_processor_team(team):
    """ Processes the data based on the team input ready for further processing.
    """
    infile = open("Project data Test.txt")
    lines = infile.read().splitlines()
    infile.close()
    mavericks = lines[5:8]
    lakers = lines[8:11]
    knicks = lines[11:14]
    if team == "Mavericks":
        team_data = mavericks
    elif team == "Lakers":
        team_data = lakers
    elif team == "Knicks":
        team_data = knicks
    return team_data


def data_processor_season(season, team_data, statistic):
    """ Processes the data based on the season input ready for plotting.
    """
    team_2020 = team_data[0]
    team_2010 = team_data[1]
    team_2000 = team_data[2]
    data_2020 = team_2020.split()
    data_2010 = team_2010.split()
    data_2000 = team_2000.split()
    if season == "Regular":
        win = [data_2020[4], data_2010[4], data_2000[4]]
        three_percentage = [data_2020[7], data_2010[7], data_2000[7]]
        three_attempts = [data_2020[13], data_2010[13], data_2000[13]]
        points = [data_2020[10], data_2010[10], data_2000[10]]
    elif season == "Playoff":
        win = [data_2020[5], data_2010[5], data_2000[5]]
        three_percentage = [data_2020[8], data_2010[8], data_2000[8]]
        three_attempts = [data_2020[14], data_2010[14], data_2000[14]]
        points = [data_2020[11], data_2010[11], data_2000[11]]
    elif season == "Both":
        win = [data_2020[3], data_2010[3], data_2000[3]]
        three_percentage = [data_2020[6], data_2010[6], data_2000[6]]
        three_attempts = [data_2020[12], data_2010[12], data_2000[12]]
        points = [data_2020[9], data_2010[9], data_2000[9]]
    if statistic == "3%":
        processed_data = [win, three_percentage]
    elif statistic == "3 Attempts":
        processed_data = [win, three_attempts]
    elif statistic == "Points":
        processed_data = [win, points]
    return processed_data


def graph_results(processed_data, team, statistic):
    """ Visualises the results with a graph.
    """
    axes = plt.axes()
    xs = processed_data[1]
    ys = processed_data[0]
    axes.plot(float(xs[0]), float(ys[0]), "bo", label = "2020 season")
    axes.plot(float(xs[1]), float(ys[1]), "ro", label = "2010 season")
    axes.plot(float(xs[2]), float(ys[2]), "go", label = "2000 season")
    axes.legend()
    ticks = range(0, 130, 10)
    axes.set_xticks(ticks)
    axes.set_xticklabels(ticks)
    axes.set_yticks(ticks)   
    axes.set_yticklabels(ticks)
    axes.set_title(f"Scatterplot of win % vs {statistic} for the {team} 2000, 2010, and 2020 seasons")
    axes.set_xlabel(f"{statistic}")
    axes.set_ylabel("Win %")
    axes.grid(True)
    plt.show()
    

def prompt_continue():
    """ Prompts the user whether they want to add more stats to the graph.
    """
    print(f"Continue options are {CONTINUE_OPTIONS}")
    continued = input("Do you want to repeat the process? ")
    if continued not in CONTINUE_OPTIONS:
        print(CONTINUE_ERROR_MESSAGE)
        continued = input("Do you want to repeat the process? ")
    return continued


def main():
    """ Collects and calls all the sub functions.
    """
    print()
    print(WELCOME_MESSAGE)
    team = prompt_team()
    season = prompt_season()
    statistic = statistic_wanted()
    team_data = data_processor_team(team)
    processed_data = data_processor_season(season, team_data, statistic)
    graph = graph_results(processed_data, team, statistic)
    continued = prompt_continue()
    if continued == "Y":
        main()    
    
main()
