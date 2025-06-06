Final Report
COSC480-21S2
Samuel Love
ID: 84107034

# Intro
My program is designed for visualising some data from the NBA which is the
USA's premier basketball league. The game is ever changing so it is interesting
to visualise various data to investigate trends over time. Three pointers are
discussed a lot as becoming increasingly effective and utilised by teams. The
dataset was sourced from
https://www.nba.com/stats/teams/traditional/?sort=FG3M&dir=-1.

# Design
The program design consists of two imports (numpy and matplotlib) for plotting
the data, nine global variables, four prompt functions, two data processing
functions, one graphing function, and one main function that wraps everything
up. The dataset consists of win %, 3pt attempts, 3pt %, and points as statistics
of interest. The data is accessed using techniques from learning module 9.
There are three teams (Dallas Mavericks, Los Angeles Lakers, and New York
Knicks) from three different years (2000, 2010, 2020). There is also a split into
regular season, playoffs, and both since the playoffs are usually more
competitive than the regular season.

# Challenges
Collecting the data was the first challenge. I considered coding some scraping
tool but decided to get the program running first using a small subset manually
collected which is what I ended up continuing with. Importing the data for
coding was the next challenge. I tried as a csv, and as a dictionary but ended up
choosing the technique in learning module 9. This technique gives the easiest
data input to code for in my opinion. Additionally for the code to work I later
edited the dataset team names since two of them were three entries long whilst
the other was two. This meant I could use code that can read from all three
teams using the same positions from the list. I initially wanted the graph to be
maintained and added to over successive runs of the program, but this proved to
be too difficult to code. I could have kept running the prompts but decided
against that because it would be less intuitive for the use and make the data less
interchangeable in preprocessing.

# Improvements
The main improvement that could be made is using a bigger more
comprehensive dataset that would show more accurate trends over time and
across statistics. Other improvements could be using data that splits the teams
based on conference. The East and West are often discussed and usually one
conference has much more dominant teams over periods of time. Having a
graph that maintains previous inputs would be a huge improvement but requires
much more comprehensive code and labelling on the graph. A basic
improvement that could be made is adding a quit option in all the prompts but
since the user is intentionally using the program I decided. against this.
Thanks for reading.
