# ArizonaSoftwareEngineering

## Part 1: Login

### How to Compile & Run

Place all files in the same folder, open the directory in VS Code via WSL, then run `Code .` to open with the dev container.

**Compile:**
```bash
cobc -x -o InCollege InCollege.cob
```

**Run:**
```bash
./InCollege
```

### Input File
Edit `InCollege-Input.txt` — one response per line, in the order the program prompts for them.

Example (Create Account flow):
```
Create New Account
John Doe
John6769420@!@@@@!$
```

Example (Log In flow):
```
Log In
John Doe
John6769420@!@@@@!$
```

### Output File
Console output is simultaneously written to `InCollege-Output.txt` (KAN-41/42 dual output).

---

## KAN-43: Dual Output Verification

Asserts that `InCollege-Output.txt` matches console output exactly.
Requires the binary to be compiled first.

```bash
bash test_dual_output.sh
```

---

## Test Suites

All tests live in `tests/`. Run everything at once with:

```bash
bash run_all_tests.sh
```

Or run individual suites:

| Script | Tickets | What it covers |
|---|---|---|
| `tests/test_KAN18_account_creation.sh` | KAN-18 | Valid creation, empty inputs, 50-char PIC X boundary |
| `tests/test_KAN28_login.sh` | KAN-28 | Successful login, invalid menu choice, empty credentials |
| `tests/test_KAN31_37_menus.sh` | KAN-31, KAN-37 | Unexpected input timeout guard; Go Back stubs (activate when paragraphs are added) |
| `tests/test_KAN24_persistence.sh` | KAN-24 | Output file survives between executions, run 1 vs run 2 content differs |
| `test_dual_output.sh` | KAN-43 | Console stdout matches `InCollege-Output.txt` |
