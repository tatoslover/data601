Statement of Intent
Final Report
COSC480-21S2
Samuel Love
ID: 84107034


# NBA Win Prediction System
*Master of Data Science Project - Canterbury University*

## Project Overview

A data-driven basketball analytics program that predicts NBA team success based on 3-point shooting statistics and temporal trends. The system leverages the modern NBA's evolution toward increased 3-point usage to forecast regular season and playoff performance.

## Background & Motivation

The NBA has undergone a statistical revolution with 3-point shooting becoming increasingly prevalent. This shift has fundamentally changed:
- Game strategies and tactics
- Player positioning and court spacing
- Team composition and roster construction
- Overall scoring patterns and game flow

## Core Concept

### Primary Inputs
- **3-Point Attempts per Game** - Volume of shots taken beyond the arc
- **3-Point Percentage** - Shooting accuracy from 3-point range
- **Year** - Temporal factor capturing league evolution

### Outputs
- **Regular Season Wins** (out of 82 games)
- **Win Percentage**
- **Playoff-Adjusted Predictions** (accounting for increased competition intensity)

## System Features

### User Interface Mockup

```
┌─────────────────────────────────────────────────────────────────┐
│                    NBA Win Prediction System                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  3 Pt %     [✓]    3 Pt Attempts  [✓]      Year    [✓]        │
│    30              1                        1940               │
│    35              2                        1950               │
│    40              3                        ...                │
│    45              4                        2020               │
│    50              5                        2021               │
│                    ...                                         │
│                                                                │
│  Input #1:  30%, 5, 2000   →   Expected Wins: 45/82          │
│  Input #2:  40%, 5, 2010   →   Expected Wins: 52/82          │
│  Input #3:  38%, 8, 2020   →   Expected Wins: 58/82          │
│                                                                │
│  Dynamic Results Chart:                                        │
│                                                                │
│    Wins                                                        │
│      60 ┤                                      •#3             │
│      55 ┤                                                     │
│      50 ┤              •#2                                    │
│      45 ┤  •#1                                               │
│      40 ┤                                                     │
│      35 ┤                                                     │
│         └─────────────────────────────────────────────        │
│          2000    2005    2010    2015    2020                 │
│                            Year                               │
│                                                                │
│  [Regular Season] [Playoff Mode] [Clear Results] [Export]      │
└─────────────────────────────────────────────────────────────────┘
```

### User Interface Elements
- **Drop-down menus** for intuitive parameter selection (3-point %, attempts, year)
- **Interactive input tracking** showing multiple scenario comparisons
- **Real-time graph updates** as users modify parameters
- **Mode switching** between regular season and playoff predictions

### Visualization Components
- **Dynamic scatter plot** tracking successive prediction outputs
- **Interactive data points** labeled by input number (#1, #2, #3...)
- **Historical trend overlay** showing league evolution patterns
- **Comparison modes** for regular season vs playoff predictions

## Data Foundation

### Historical NBA Dataset
- Comprehensive team statistics across multiple seasons
- 3-point shooting metrics by team and year
- Win-loss records for regular season and playoffs
- Temporal data spanning the 3-point era evolution

### Statistical Ranges for Testing
```
3-Point Attempts: 20-50+ per game
3-Point Percentage: 30%-40%+
Years: 1980-2024 (3-point era)
```

## Technical Implementation Plan

### Phase 1: Data Acquisition
- Source reliable NBA statistical databases
- Clean and structure historical team data
- Validate data integrity and completeness

### Phase 2: Model Development
- Analyze correlations between 3-point metrics and wins
- Build predictive algorithms accounting for temporal trends
- Separate models for regular season vs playoff performance

### Phase 3: User Interface
- Design intuitive input controls
- Implement real-time visualization updates
- Create output tracking for parameter comparison

### Phase 4: Enhancement (Optional)
- **Team-specific variables** for deeper insights
- **Additional statistics** (rebounds, turnovers, pace)
- **Advanced metrics** (efficiency ratings, net rating)

## Expected Insights

The system should reveal:
- How 3-point shooting evolution correlates with team success
- Optimal 3-point attempt/percentage combinations
- Year-over-year changes in winning formulas
- Differences between regular season and playoff success factors

## Success Metrics

- **Prediction accuracy** compared to actual historical results
- **User experience** quality and interface intuitiveness
- **Statistical significance** of identified relationships
- **Practical applicability** for basketball analysis

## Future Expansion Possibilities

- **Player-level analysis** for individual performance prediction
- **Game-by-game predictions** for specific matchups
- **Draft analysis** using college 3-point statistics
- **International league comparisons** (EuroLeague, etc.)

---

*This project combines statistical analysis, data visualization, and basketball domain knowledge to create a practical tool for understanding modern NBA success factors.*
