<h1 align="center"> LP Project - Tents and Trees Solver </h1>

<p align="center">
  <img src="image_192aa2.png" alt="Tents and Trees" width="250"/>
</p>

This repository contains the project for the "Lógica para Programação" (Programming Logic) course @IST Instituto Superior Técnico (2023/2024). The project consists of a solver for the "Tents and Trees" puzzle, written entirely in Prolog.

The goal is to place a tent adjacent to each tree on the board, following a set of rules:
* The number of tents in each row and column must match the specified counts.
* A tent can only be placed horizontally or vertically adjacent to a tree.
* Each tree must be associated with at least one tent, and in the end, a one-to-one mapping must be possible.
* Tents cannot be adjacent to each other, including diagonally.

## Project Overview

The solver is built by implementing a series of predicates that apply logical rules to deduce the placement of tents and grass.

* **Data Structures:** The puzzle is represented by a main board (a list of lists), a list of tent counts for rows, and a list of tent counts for columns.
* **Query Predicates:** A set of helper predicates was developed to query the board's state, such as finding adjacent cells, cells in the extended neighborhood, counting objects per line, and checking if a cell is empty.
* **Insertion Predicates:** Predicates to update the board by inserting an object (tent 't' or grass 'r') at a specific coordinate.
* **Logical Strategies:** A series of deterministic predicates that apply the puzzle's rules to place objects without guessing:
    * Fills rows/columns with grass once their tent count is met.
    * Places grass on all cells that are not adjacent to any tree.
    * Places tents in all remaining empty spots in a line if the number of empty spots equals the number of tents still required.
    * Places grass in the diagonal and adjacent cells of all tents to enforce the no-adjacency rule.
    * Places a tent for a tree if only one possible empty position exists in its vicinity.
* **Backtracking Solver:** A main `resolve/1` predicate is used to solve the puzzle. It repeatedly applies the logical strategies until no more deductions can be made. If the puzzle is still unsolved, it uses Prolog's backtracking (trial and error) to place a tent in an empty spot and re-applies the strategies.
* **Validation:** A final `valida/2` predicate checks if the solved board is valid by ensuring a one-to-one mapping can be established between every tree and an adjacent tent.
