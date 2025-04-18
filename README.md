1. Program Structure & Setup
Include & Entry Point

include "emu8086.inc" brings in helper macros for I/O (e.g. SCAN_NUM, PRINT_STRING, etc.).

JMP START skips over the data declarations straight to the code entry point.

Segments

DATA SEGMENT holds all variables and message strings:

N (word) for the number of students.

Arrays of length 1000 for MARKS, ID, and GRADE.

Counters for pass/fail and each grade category (GRADE_S_COUNT, …, GRADE_F_COUNT).

Storage for computed summary stats: highest/lowest marks and corresponding IDs, MEDIAN.

Text messages for prompts, headers, and results.

CODE SEGMENT contains the actual program logic, with DS set to DATA.

2. Input & Validation
Number of Students

Prompts “Enter the number of students…” via PRINT_STRING.

Reads a number into CX with SCAN_NUM, stores in N.

Validates 1 ≤ N ≤ 1000. If out of range, shows an error and restarts.

Student IDs

Prompts for each student’s ID.

A simple loop (LOOP1) reads N values with SCAN_NUM, stores each byte in the ID array.

Student Marks

Prompts for each mark in the range 0–100.

Loop (LOOP2) reads a mark, validates it (underflow/overflow), and—on error—re‑prompts for that same student.

Valid entries are stored in the MARKS array.

3. Sorting (Bubble Sort)
Implements a descending‑order bubble sort over MARKS[].

Whenever two adjacent marks are out of order, it swaps both the mark and its corresponding student ID in lock‑step so the records remain aligned.

4. Grade Assignment & Pass/Fail Tally
Iterates through each sorted mark:

Uses a cascade of CMP/JAE instructions to assign grades:

≥90 → S

≥80 → A

≥70 → B

≥60 → C

≥55 → D

≥50 → E

<50 → F

Increments the corresponding grade counter (GRADE_X_COUNT).

If grade ≠ F, increments PASS_COUNT; else increments FAIL_COUNT.

5. Summary Statistics
Highest & Lowest Marks

After grading, walks once through the sorted array to set HIGH_MARK/HIGH_ID and LOW_MARK/LOW_ID.

Average

Sums all marks in a 16‑bit accumulator (BX), divides by N (DIV CX), and prints the integer average.

Median

Since the array is sorted descending:

Odd N: picks the middle element at index ⌊N/2⌋.

Even N: averages the two middle marks → prints as unsigned.

6. Output & User Interface
Screen Clear

Before printing results, calls a custom CLEAR_SCREEN that wipes text mode video RAM and resets the cursor.

Sorted Records

Prints a header (HR, MSG4) then iterates through all students:

Displays ID, MARKS, GRADE, and “PASS”/“FAIL” status in columns.

Counts & Statistics

Prints total pass/fail counts, each grade’s count, followed by average, median, highest & lowest marks (with their student IDs).

Exit

Waits for a key (INT 16h) then terminates via DOS function 4Ch.
