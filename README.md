# 8-Bit Timer Design and Verification Project

This project is the final project of Semcon's course "Elementary Design Verification" by Alvin Tran.
## Project Overview

This project implements and verifies an **8-bit programmable timer** with an APB-like register interface. The main goal is to build not only a working RTL design, but also a structured verification environment that follows industry-style design verification principles.

The project was developed as a complete learning and portfolio project for digital IC design and verification. It covers RTL design, register-level programming, timer functional behavior, APB bus access, constrained-random testing, scoreboard checking, functional coverage, and regression coverage merging.

## Project Objectives

The key objectives of this project are:

- Design an 8-bit timer with programmable load, enable, count direction, and clock selection.
- Implement an APB-style register interface for software-controlled access.
- Verify all major timer functions through a reusable non-UVM SystemVerilog testbench.
- Build a transaction-based verification framework using driver, monitor, scoreboard, coverage, and environment components.
- Create a full regression flow with multiple directed and random testcases.
- Generate functional and code coverage reports using QuestaSim UCDB and `vcover merge`.
- Use the project as a foundation for future migration from non-UVM verification to UVM.

## RTL Design Summary

The timer design is composed of the following RTL blocks:

| RTL Block | Description |
|---|---|
| `top_module.sv` | Top-level module integrating APB controller, counter, and clock selection logic |
| `apb_controller.sv` | Register read/write control and APB response generation |
| `counter.sv` | 8-bit up/down counter with overflow and underflow detection |
| `clock_selection.sv` | Selects one of four external clock inputs based on `clk_sel` |

## Register Map

| Address | Register | Description |
|---|---|---|
| `0x00` | `TDR` | Timer Data Register, stores the counter load value |
| `0x01` | `TCR` | Timer Control Register |
| `0x02` | `TSR` | Timer Status Register |
| `0x03 - 0xFF` | Invalid | Expected to assert `PSLVERR` |

## TCR Bit Fields

| Bit | Field | Description |
|---|---|---|
| `TCR[7]` | `load` | Loads `TDR` value into the counter |
| `TCR[5]` | `up_down` | Selects count direction |
| `TCR[4]` | `enable` | Enables timer counting |
| `TCR[1:0]` | `clk_sel` | Selects one of four clock inputs |

## TSR Bit Fields

| Bit | Field | Description |
|---|---|---|
| `TSR[0]` | `overflow` | Set when counter wraps from `0xFF` to `0x00` |
| `TSR[1]` | `underflow` | Set when counter wraps from `0x00` to `0xFF` |

The status bits are sticky and can be cleared through software write access.

## Verification Architecture

The verification environment is built using a **non-UVM transaction-based SystemVerilog framework**. Although it does not use UVM, the architecture follows the same separation of responsibilities used in industrial verification environments.

```text
Testcase / Base Test
        |
        v
Stimulus
        |
        v
Mailbox
        |
        v
Driver
        |
        v
Interface
        |
        v
DUT
        |
        v
Monitor
        |
        +--> Scoreboard
        |
        +--> Functional Coverage
```

## Testbench Components

| Component | Description |
|---|---|
| `timer_if.sv` | Interface connecting the testbench to the DUT |
| `apb_transaction.sv` | Transaction object representing APB read/write activity |
| `timer_stimulus.sv` | Generates transaction-level stimulus |
| `apb_driver.sv` | Converts transactions into APB pin-level protocol |
| `timer_monitor.sv` | Observes APB bus activity and reconstructs transactions |
| `timer_scoreboard.sv` | Checks DUT behavior using a reference model |
| `timer_coverage.sv` | Collects functional coverage |
| `timer_environment.sv` | Connects all verification components |
| `base_test.sv` | Provides reusable test helper tasks |
| `test_pkg.sv` | Includes all testcase classes |

## Verification Scope

The test plan covers five major verification phases:

| Phase | Verification Focus |
|---|---|
| Phase 1 | Register read/write access, default values, invalid address access |
| Phase 2 | Count-up and count-down functionality across selected clocks |
| Phase 3 | Pause and resume behavior |
| Phase 4 | Reset and load behavior during timer operation |
| Phase 5 | Fake overflow and fake underflow prevention |

## Testcases

The regression includes 21 testcase scenarios:

- Register tests: `tdr_test`, `tcr_test`, `tsr_test`
- Address tests: `null_address_test`, `mixed_address_test`
- Count-up tests: `countup_pclk2_test`, `countup_pclk4_test`, `countup_pclk8_test`, `countup_pclk16_test`
- Count-down tests: `countdw_pclk2_test`, `countdw_pclk4_test`, `countdw_pclk8_test`, `countdw_pclk16_test`
- Pause tests: `countup_pause_countup_test`, `countdw_pause_countdw_test`
- Reset/load tests: `countup_reset_countdw_pclk2_test`, `countdw_reset_countup_pclk2_test`, `countup_reset_load_countdw_pclk2_test`, `countdw_reset_load_countdw_pclk2_test`
- Fake event tests: `fake_overflow_test`, `fake_underflow_test`

## Coverage and Regression

The regression flow uses QuestaSim and UCDB coverage databases.

The flow is:

```text
Run each testcase with coverage enabled
        |
        v
Save one UCDB file per testcase
        |
        v
Merge all UCDB files using vcover merge
        |
        v
Generate HTML/text coverage report
```

Example commands:

```sh
make cov_regress
vcover merge -inputs cov/ucdb_files.txt cov/all_tests.ucdb
vcover report -html cov/all_tests.ucdb -output covhtmlreport
```

## Achieved Results

The project achieved the following verification results:

- Built a complete RTL design for an 8-bit programmable timer.
- Developed a reusable non-UVM transaction-based verification framework.
- Implemented 21 testcase scenarios covering register, functional, reset, pause, and fake event behavior.
- Built a scoreboard reference model to check APB response, register behavior, counter behavior, overflow, and underflow.
- Built functional coverage for APB access, valid/invalid addresses, TCR control fields, and cross coverage.
- Created a regression flow using UCDB and `vcover merge`.
- Achieved high overall coverage in QuestaSim regression reporting.

Example coverage result from the project:

| Coverage Type | Coverage |
|---|---|
| Total Coverage | ~92% |
| Covergroups | ~93% |
| Statements | ~94% |
| Branches | ~81% |
| FEC Expressions | 100% |
| Toggles | ~93% |
| FSMs | ~90% |

## Key Debug Lessons

Several practical verification lessons were learned during this project:

- A passing testcase can still appear as `ERROR` in the UCDB report if the testbench calls `$error` for an expected behavior.
- Invalid address access should be treated as expected behavior when `PSLVERR=1`.
- Driver and monitor sampling must match the actual RTL response timing, not only the ideal APB timing diagram.
- Sticky status bits must be cleared before starting a new independent scenario.
- Reset must update both the DUT and the scoreboard reference model.
- Timing-sensitive checks should avoid relying only on long delay-based waits.
- Functional coverage tells whether scenarios were exercised; the scoreboard tells whether behavior was correct.

## Tools Used

| Tool | Purpose |
|---|---|
| SystemVerilog | RTL design and verification |
| QuestaSim | Compilation, simulation, waveform debug |
| Makefile | Build and regression automation |
| UCDB | Coverage database generation |
| `vcover` | Coverage merge and report generation |

## Project Structure

```text
Final_lab-Timer_8bit/
├── rtl/
│   ├── top_module.sv
│   ├── apb_controller.sv
│   ├── counter.sv
│   └── clock_selection.sv
├── tb/
│   ├── timer_if.sv
│   ├── timer_pkg.sv
│   ├── apb_transaction.sv
│   ├── apb_driver.sv
│   ├── timer_monitor.sv
│   ├── timer_scoreboard.sv
│   ├── timer_coverage.sv
│   ├── timer_environment.sv
│   └── testcases/
├── compile.f
├── Makefile
└── README.md
```

## Future Improvements

Potential next steps:

- Migrate the current non-UVM framework to a UVM-based environment.
- Add SystemVerilog Assertions for APB protocol and timer event checking.
- Improve branch and FSM transition coverage.
- Add a UVM Register Abstraction Layer model.
- Add waveform snapshots and coverage screenshots to the documentation.

## What This Project Demonstrates

This project demonstrates practical knowledge of:

- RTL design for a configurable timer IP.
- APB-style register interface design.
- SystemVerilog class-based verification.
- Transaction-level stimulus generation.
- Driver/monitor separation.
- Scoreboard-based checking.
- Functional coverage modeling.
- Regression and coverage closure flow.
- Debugging false failures caused by testbench timing or reporting issues.

The project serves as a solid foundation for moving toward UVM-based design verification and larger reusable verification environments.
