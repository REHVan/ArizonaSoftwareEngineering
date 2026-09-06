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
