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
| `tests/test_KAN64_74_profile_validation.sh` | KAN-64, KAN-74 | Profile edit success, blank/non-numeric/out-of-range field rejection (stubs until profile paragraph implemented) |
| `tests/test_KAN84_experience_limits.sh` | KAN-84 | Zero, one, and three experience entries; timeout guard (stubs until experience paragraph implemented) |
| `tests/test_KAN95_profile_persistence.sh` | KAN-95 | Account persists across restarts; profile field stubs (activate when EDIT-PROFILE implemented) |
| `run_profile_batch_tests.sh` | KAN-99, KAN-100 | Edge-case batch inputs; logs to `results/` |
| `test_dual_output.sh` | KAN-43 | Console stdout matches `InCollege-Output.txt` |
