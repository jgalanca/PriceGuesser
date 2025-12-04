# PriceGuesser 🎯

An iOS social game where players compete to guess restaurant bill prices with precision. Features a sophisticated hybrid scoring system that balances competitive fairness with social incentives, achievement mechanics, and comprehensive gamification.

## Overview

PriceGuesser transforms the social experience of dining out into an engaging game. Players estimate the total cost before the bill arrives, competing on accuracy. The app tracks performance over time, awards achievements, and maintains global rankings—all while adapting its scoring system to encourage both small intimate games and large group gatherings.

**Target Audience:** Social groups, families, friend circles who frequently dine together  
**Platform:** iOS 17.0+ (iPhone & iPad)  
**Tech Stack:** Swift 6.0, SwiftUI, @Observable macro, Strict Concurrency

> **Note on Architecture:** This project's architecture may appear more complex than necessary for a game app. This is intentional—PriceGuesser serves as a testing ground for Swift 6.0's strict concurrency features, including the `@Observable` macro, `Sendable` protocols, and actor isolation. The separation of concerns (repositories, services, managers, view models) demonstrates best practices for concurrent Swift development rather than being strictly required for the app's functionality.

## Key Features

### 🎯 Hybrid Scoring System

The scoring algorithm was designed to solve a critical fairness problem: **How do you make winning meaningful in both 2-player and 10-player games?**

#### The Problem
Traditional fixed-point systems (e.g., 1st = 6pts, 2nd = 3pts, 3rd = 1pt) create imbalance:
- In small games (2-3 players): Low stakes, minimal differentiation
- In large games (8+ players): High competition, but participation feels less rewarding

#### The Solution: Hybrid Scoring
```
Total Points = Base Points (rank-based) + Participation Bonus (group size)
```

**Base Points (Skill Reward):**
- 🥇 1st place: 10 points
- 🥈 2nd place: 7 points  
- 🥉 3rd place: 5 points
- 4th place: 3 points
- 5th place: 2 points
- 6th+ place: 1 point

**Participation Bonus (Social Incentive):**
- 2-3 players: +0 bonus (intimate games)
- 4-5 players: +1 bonus (small groups)
- 6-7 players: +2 bonus (medium groups)
- 8+ players: +3 bonus (large gatherings)

#### Why This Works
1. **Skill remains primary**: Top performers get 5-10x points of last place
2. **Larger games feel rewarding**: Everyone gets bonus points, making 8-player games worth more than 2-player
3. **Balanced progression**: A player who consistently places 3rd in large games can compete with someone who wins small games
4. **Social motivation**: Encourages inviting more friends to play

**Example Scenarios:**
- 2-player game, 1st place: 10 + 0 = **10 points**
- 8-player game, 1st place: 10 + 3 = **13 points** ⭐️
- 8-player game, 5th place: 2 + 3 = **5 points** (still meaningful!)

### 🏆 Achievement System

10 achievement types with bonus points to reward different play styles:

**Skill-Based:**
- 🎯 **Perfect Guess** (<1% accuracy): +5 pts
- � **Close Call** (<5% accuracy): +2 pts
- 🏹 **Sharp Shooter** (10+ perfect guesses): +15 pts

**Consistency:**
- 👑 **Consistent Winner** (3-win streak): +10 pts
- 💪 **Comeback Kid** (won after being last): +5 pts

**Social:**
- 🎉 **Group Host** (8+ player game): +3 pts
- 🦋 **Social Butterfly** (20+ unique opponents): +10 pts

**Milestones:**
- � **First Victory**: +5 pts
- ⭐️ **Veteran** (50 games): +20 pts
- 💯 **Centurion** (100 games): +50 pts

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Javier Galán Cardeñosa

## Acknowledgments

- Built with SwiftUI and modern iOS 17+ features
- Implements Swift 6.0 strict concurrency
- Follows iOS design guidelines and best practices
