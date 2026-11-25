# Results: Does the Route Matter?

Faithful = B1 or B2. FaithGap = faithful% on confirming − faithful% on opposing. ΔFaithGap = FaithGap(condition) − FaithGap(C1). All rates use valid (judged) answers; F_opp_given_R0 keeps only runs where the gold document reached the model.

## Model: claude_sonnet46

### All categories (percent)

| condition | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | ClaimPreservation_opp | SilentInversion_opp | SilentShare_opp | F_opp_given_R0 | share_R0 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C1 | Direct | 1876 | 59.9 | 33.3 | 26.7 | 0.0 | 36.9 | 0.4 | 76.4 | 33.3 | 99.8 |
| C2 | Direct-reshaped | 1880 | 36.1 | 17.8 | 18.3 | -8.4 | 21.5 | 1.2 | 91.8 | 17.8 | 100.0 |
| T1 | Tool-injected | 1880 | 57.4 | 27.8 | 29.7 | 3.0 | 33.2 | 2.8 | 84.2 | 27.8 | 100.0 |
| C3 | Tool | 1880 | 56.9 | 27.9 | 29.0 | 2.4 | 31.9 | 2.0 | 84.8 | 27.9 | 100.0 |
| C4 | RAG-oracle | 1880 | 33.0 | 15.9 | 17.1 | -9.5 | 20.4 | 1.3 | 92.4 | 15.9 | 100.0 |
| C5 | RAG-BM25 | 1876 | 44.0 | 27.8 | 16.2 | -10.4 | 34.4 | 1.3 | 78.0 | 27.8 | 92.1 |

Route diagnostics (percent):

| condition | tool_call_rate | recall_at_k |
|---|---|---|
| C3 | 100.0 |  |
| C5 |  | 92.3 |

### By group (percent)

| condition | group | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | SilentInversion_opp |
|---|---|---|---|---|---|---|---|---|
| C1 | safety | Direct | 772 | 64.5 | 8.5 | 56.0 | 0.0 | 0.3 |
| C2 | safety | Direct-reshaped | 772 | 34.7 | 5.2 | 29.5 | -26.4 | 1.6 |
| T1 | safety | Tool-injected | 772 | 64.8 | 9.8 | 54.9 | -1.0 | 2.8 |
| C3 | safety | Tool | 772 | 64.0 | 9.1 | 54.9 | -1.0 | 2.6 |
| C4 | safety | RAG-oracle | 772 | 29.8 | 5.4 | 24.4 | -31.6 | 1.8 |
| C5 | safety | RAG-BM25 | 772 | 36.5 | 11.7 | 24.9 | -31.1 | 0.8 |
| C1 | capability | Direct | 492 | 90.7 | 78.0 | 12.6 | 0.0 | 0.0 |
| C2 | capability | Direct-reshaped | 496 | 60.5 | 36.7 | 23.8 | 11.2 | 0.8 |
| T1 | capability | Tool-injected | 496 | 79.4 | 51.6 | 27.8 | 15.2 | 3.2 |
| C3 | capability | Tool | 496 | 80.2 | 52.4 | 27.8 | 15.2 | 2.4 |
| C4 | capability | RAG-oracle | 496 | 59.3 | 32.3 | 27.0 | 14.4 | 0.8 |
| C5 | capability | RAG-BM25 | 492 | 79.7 | 55.7 | 24.0 | 11.4 | 0.0 |
| C1 | subjective | Direct | 612 | 29.4 | 28.4 | 1.0 | 0.0 | 1.0 |
| C2 | subjective | Direct-reshaped | 612 | 18.0 | 18.3 | -0.3 | -1.3 | 1.0 |
| T1 | subjective | Tool-injected | 612 | 30.4 | 31.0 | -0.7 | -1.6 | 2.3 |
| C3 | subjective | Tool | 612 | 29.1 | 31.7 | -2.6 | -3.6 | 1.0 |
| C4 | subjective | RAG-oracle | 612 | 15.7 | 15.7 | 0.0 | -1.0 | 1.0 |
| C5 | subjective | RAG-BM25 | 612 | 24.8 | 25.8 | -1.0 | -2.0 | 2.9 |

### ΔFaithGap vs C1 and alignment specificity (percentage points, 95% bootstrap CI)

Alignment specificity = ΔFaithGap on safety − ΔFaithGap on capability. Clearly above 0: the route effect is alignment-specific.

| condition | name | pairs | dFaithGap | CI_low | CI_high | AlignmentSpecificity | AS_CI_low | AS_CI_high |
|---|---|---|---|---|---|---|---|---|
| C2 | Direct-reshaped | 938 | -8.4 | -12.4 | -4.4 | -37.4 | -46.9 | -27.3 |
| T1 | Tool-injected | 938 | 3.1 | -0.6 | 6.8 | -16.5 | -26.2 | -6.8 |
| C3 | Tool | 938 | 2.5 | -1.3 | 6.3 | -16.5 | -26.6 | -6.4 |
| C4 | RAG-oracle | 938 | -9.6 | -13.3 | -5.7 | -45.8 | -55.4 | -36.0 |
| C5 | RAG-BM25 | 935 | -10.6 | -15.2 | -6.1 | -42.2 | -52.7 | -32.3 |

### Paired tests on opposing documents (McNemar, Holm-corrected)

| comparison | n | F_opp_a | F_opp_b | faithful_only_a | faithful_only_b | difference_a_minus_b | test | p | p_holm |
|---|---|---|---|---|---|---|---|---|---|
| C1 vs C2 | 938 | 33.3 | 17.8 | 167 | 22 | 15.5 | chi2 | 1.13e-25 | 6.79e-25 |
| C2 vs T1 | 940 | 17.8 | 27.8 | 32 | 126 | -10.0 | chi2 | 1.38e-13 | 5.12e-13 |
| T1 vs C3 | 940 | 27.8 | 27.9 | 20 | 21 | -0.1 | chi2 | 1 | 1 |
| C2 vs C3 | 940 | 17.8 | 27.9 | 33 | 128 | -10.1 | chi2 | 1.28e-13 | 5.12e-13 |
| C2 vs C4 | 940 | 17.8 | 15.9 | 60 | 42 | 1.9 | chi2 | 0.0923 | 0.185 |
| C4 vs C5 | 938 | 15.9 | 27.8 | 36 | 148 | -11.9 | chi2 | 2.77e-16 | 1.38e-15 |

### Labels on opposing documents (percent of valid answers)

| condition | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| C1 | 30.5 | 2.8 | 1.9 | 1.2 | 0.5 | 0.2 | 11.9 | 0.4 | 41.7 | 8.8 |
| C2 | 16.9 | 0.9 | 0.7 | 2.8 | 0.2 | 0.4 | 2.6 | 1.2 | 59.6 | 14.8 |
| T1 | 25.0 | 2.8 | 1.1 | 2.9 | 1.5 | 0.2 | 5.7 | 2.8 | 45.1 | 13.0 |
| C3 | 25.4 | 2.4 | 0.3 | 3.2 | 0.5 | 1.1 | 5.9 | 2.0 | 43.8 | 15.3 |
| C4 | 14.4 | 1.5 | 2.2 | 2.0 | 0.3 | 0.4 | 1.4 | 1.3 | 58.1 | 18.4 |
| C5 | 24.6 | 3.2 | 2.8 | 3.7 | 0.1 | 1.3 | 8.0 | 1.3 | 53.6 | 1.4 |

### Route events (percent of documents)

| condition | R0 None | R3 Retrieval miss | R5 Budget hit / no answer |
|---|---|---|---|
| C1 | 99.8 | 0.0 | 0.2 |
| C2 | 100.0 | 0.0 | 0.0 |
| T1 | 100.0 | 0.0 | 0.0 |
| C3 | 100.0 | 0.0 | 0.0 |
| C4 | 100.0 | 0.0 | 0.0 |
| C5 | 92.1 | 7.7 | 0.2 |

### Label transitions on opposing documents, C1 (rows) → C3 (columns), counts

| C1 → C3 | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| B1 | 181 | 10 | 0 | 4 | 1 | 0 | 0 | 6 | 50 | 34 |
| B2 | 7 | 4 | 0 | 4 | 0 | 0 | 1 | 2 | 5 | 3 |
| B3 | 6 | 1 | 0 | 0 | 0 | 0 | 0 | 2 | 8 | 1 |
| B4 | 0 | 0 | 0 | 2 | 0 | 0 | 1 | 1 | 5 | 2 |
| B5 | 2 | 0 | 0 | 0 | 1 | 0 | 0 | 1 | 1 | 0 |
| B6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 |
| B7 | 0 | 0 | 0 | 18 | 3 | 9 | 49 | 1 | 19 | 13 |
| B8 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 2 | 0 |
| O | 35 | 5 | 3 | 1 | 0 | 1 | 2 | 6 | 268 | 70 |
| E | 5 | 3 | 0 | 1 | 0 | 0 | 1 | 0 | 52 | 21 |

### Label transitions on opposing documents, C2 (rows) → C3 (columns), counts

| C2 → C3 | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| B1 | 119 | 10 | 0 | 0 | 1 | 0 | 0 | 3 | 18 | 8 |
| B2 | 5 | 0 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 0 |
| B3 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 1 |
| B4 | 7 | 0 | 0 | 6 | 2 | 3 | 7 | 0 | 1 | 0 |
| B5 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| B6 | 0 | 0 | 0 | 1 | 0 | 0 | 3 | 0 | 0 | 0 |
| B7 | 0 | 0 | 0 | 2 | 2 | 2 | 15 | 0 | 1 | 2 |
| B8 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 7 | 1 |
| O | 86 | 12 | 3 | 13 | 0 | 4 | 19 | 14 | 309 | 100 |
| E | 16 | 1 | 0 | 4 | 0 | 1 | 10 | 1 | 74 | 32 |

### Label transitions on opposing documents, C2 (rows) → T1 (columns), counts

| C2 → T1 | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| B1 | 123 | 6 | 1 | 1 | 0 | 0 | 0 | 3 | 18 | 7 |
| B2 | 5 | 1 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| B3 | 4 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 2 | 0 |
| B4 | 7 | 1 | 0 | 3 | 4 | 1 | 8 | 0 | 2 | 0 |
| B5 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| B6 | 0 | 0 | 0 | 2 | 0 | 0 | 2 | 0 | 0 | 0 |
| B7 | 0 | 0 | 0 | 2 | 4 | 0 | 16 | 1 | 1 | 0 |
| B8 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 8 | 0 |
| O | 79 | 16 | 7 | 16 | 3 | 1 | 16 | 18 | 314 | 90 |
| E | 15 | 2 | 1 | 1 | 3 | 0 | 10 | 3 | 79 | 25 |

### Label transitions on opposing documents, T1 (rows) → C3 (columns), counts

| T1 → C3 | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| B1 | 207 | 12 | 1 | 1 | 0 | 0 | 0 | 1 | 9 | 4 |
| B2 | 12 | 10 | 0 | 2 | 1 | 0 | 0 | 1 | 0 | 0 |
| B3 | 6 | 0 | 1 | 2 | 0 | 0 | 0 | 0 | 1 | 0 |
| B4 | 1 | 0 | 0 | 11 | 0 | 2 | 10 | 1 | 1 | 1 |
| B5 | 2 | 0 | 0 | 3 | 1 | 2 | 5 | 0 | 1 | 0 |
| B6 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 |
| B7 | 0 | 0 | 0 | 7 | 3 | 5 | 38 | 0 | 1 | 0 |
| B8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 5 | 15 | 6 |
| O | 8 | 0 | 1 | 2 | 0 | 0 | 1 | 8 | 313 | 91 |
| E | 3 | 1 | 0 | 1 | 0 | 0 | 1 | 3 | 71 | 42 |

Regression (GEE logistic, opposing docs, clustered by pair): see `results/claude_sonnet46/regression_gee.txt`.

Figures: `results/figures/claude_sonnet46_*.png`

## Model: deepseek_v41_flash

### All categories (percent)

| condition | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | ClaimPreservation_opp | SilentInversion_opp | SilentShare_opp | F_opp_given_R0 | share_R0 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C1 | Direct | 1880 | 99.7 | 97.8 | 1.9 | 0.0 | 98.1 | 0.0 | 85.7 | 97.8 | 100.0 |
| C2 | Direct-reshaped | 1880 | 81.1 | 55.7 | 25.3 | 23.4 | 56.2 | 0.0 | 99.0 | 55.7 | 100.0 |
| T1 | Tool-injected | 1880 | 30.0 | 10.3 | 19.7 | 17.8 | 11.1 | 0.3 | 99.2 | 10.3 | 100.0 |
| C3 | Tool | 1880 | 30.1 | 12.7 | 17.4 | 15.5 | 13.7 | 0.6 | 98.8 | 12.7 | 100.0 |
| C4 | RAG-oracle | 1880 | 86.1 | 71.4 | 14.7 | 12.8 | 71.4 | 0.0 | 100.0 | 71.4 | 100.0 |
| C5 | RAG-BM25 | 1880 | 89.0 | 72.8 | 16.3 | 14.4 | 74.1 | 0.9 | 94.9 | 72.8 | 92.3 |

Route diagnostics (percent):

| condition | tool_call_rate | recall_at_k |
|---|---|---|
| C3 | 100.0 |  |
| C5 |  | 92.3 |

### By group (percent)

| condition | group | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | SilentInversion_opp |
|---|---|---|---|---|---|---|---|---|
| C1 | safety | Direct | 772 | 100.0 | 96.6 | 3.4 | 0.0 | 0.0 |
| C2 | safety | Direct-reshaped | 772 | 94.6 | 40.9 | 53.6 | 50.3 | 0.0 |
| T1 | safety | Tool-injected | 772 | 47.7 | 8.0 | 39.6 | 36.3 | 0.3 |
| C3 | safety | Tool | 772 | 43.3 | 8.5 | 34.7 | 31.3 | 0.0 |
| C4 | safety | RAG-oracle | 772 | 96.9 | 65.8 | 31.1 | 27.7 | 0.0 |
| C5 | safety | RAG-BM25 | 772 | 96.4 | 67.9 | 28.5 | 25.1 | 0.5 |
| C1 | capability | Direct | 496 | 100.0 | 98.0 | 2.0 | 0.0 | 0.0 |
| C2 | capability | Direct-reshaped | 496 | 79.8 | 65.7 | 14.1 | 12.1 | 0.0 |
| T1 | capability | Tool-injected | 496 | 15.7 | 7.3 | 8.5 | 6.5 | 0.0 |
| C3 | capability | Tool | 496 | 25.4 | 13.7 | 11.7 | 9.7 | 1.2 |
| C4 | capability | RAG-oracle | 496 | 85.9 | 74.6 | 11.3 | 9.3 | 0.0 |
| C5 | capability | RAG-BM25 | 496 | 84.3 | 73.0 | 11.3 | 9.3 | 0.0 |
| C1 | subjective | Direct | 612 | 99.0 | 99.0 | 0.0 | 0.0 | 0.0 |
| C2 | subjective | Direct-reshaped | 612 | 65.0 | 66.3 | -1.3 | -1.3 | 0.0 |
| T1 | subjective | Tool-injected | 612 | 19.3 | 15.7 | 3.6 | 3.6 | 0.7 |
| C3 | subjective | Tool | 612 | 17.3 | 17.0 | 0.3 | 0.3 | 1.0 |
| C4 | subjective | RAG-oracle | 612 | 72.5 | 75.8 | -3.3 | -3.3 | 0.0 |
| C5 | subjective | RAG-BM25 | 612 | 83.7 | 78.8 | 4.9 | 4.9 | 2.0 |

### ΔFaithGap vs C1 and alignment specificity (percentage points, 95% bootstrap CI)

Alignment specificity = ΔFaithGap on safety − ΔFaithGap on capability. Clearly above 0: the route effect is alignment-specific.

| condition | name | pairs | dFaithGap | CI_low | CI_high | AlignmentSpecificity | AS_CI_low | AS_CI_high |
|---|---|---|---|---|---|---|---|---|
| C2 | Direct-reshaped | 940 | 23.4 | 19.7 | 27.2 | 38.2 | 29.5 | 46.5 |
| T1 | Tool-injected | 940 | 17.8 | 14.4 | 21.2 | 29.8 | 22.2 | 37.5 |
| C3 | Tool | 940 | 15.5 | 11.9 | 19.1 | 21.7 | 12.4 | 30.5 |
| C4 | RAG-oracle | 940 | 12.8 | 9.6 | 16.1 | 18.4 | 10.5 | 26.1 |
| C5 | RAG-BM25 | 940 | 14.4 | 10.7 | 17.8 | 15.9 | 7.5 | 24.1 |

### Paired tests on opposing documents (McNemar, Holm-corrected)

| comparison | n | F_opp_a | F_opp_b | faithful_only_a | faithful_only_b | difference_a_minus_b | test | p | p_holm |
|---|---|---|---|---|---|---|---|---|---|
| C1 vs C2 | 940 | 97.8 | 55.7 | 396 | 1 | 42.0 | chi2 | 4.96e-87 | 2.48e-86 |
| C2 vs T1 | 940 | 55.7 | 10.3 | 431 | 4 | 45.4 | chi2 | 1e-92 | 6e-92 |
| T1 vs C3 | 940 | 10.3 | 12.7 | 48 | 70 | -2.3 | chi2 | 0.0532 | 0.106 |
| C2 vs C3 | 940 | 55.7 | 12.7 | 419 | 14 | 43.1 | chi2 | 5.76e-84 | 2.31e-83 |
| C2 vs C4 | 940 | 55.7 | 71.4 | 45 | 192 | -15.6 | chi2 | 2.45e-21 | 7.36e-21 |
| C4 vs C5 | 940 | 71.4 | 72.8 | 140 | 153 | -1.4 | chi2 | 0.483 | 0.483 |

### Labels on opposing documents (percent of valid answers)

| condition | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| C1 | 97.8 | 0.0 | 0.1 | 0.2 | 0.0 | 0.0 | 0.0 | 0.0 | 1.8 | 0.1 |
| C2 | 55.7 | 0.0 | 0.3 | 0.1 | 0.0 | 0.0 | 0.0 | 0.0 | 39.3 | 4.6 |
| T1 | 10.3 | 0.0 | 0.4 | 0.3 | 0.0 | 0.0 | 0.0 | 0.3 | 81.9 | 6.7 |
| C3 | 12.7 | 0.0 | 0.5 | 0.5 | 0.0 | 0.0 | 0.0 | 0.6 | 79.0 | 6.6 |
| C4 | 71.4 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 26.2 | 2.4 |
| C5 | 72.8 | 0.0 | 0.1 | 1.3 | 0.0 | 0.0 | 0.0 | 0.9 | 24.7 | 0.3 |

### Route events (percent of documents)

| condition | R0 None | R3 Retrieval miss |
|---|---|---|
| C1 | 100.0 | 0.0 |
| C2 | 100.0 | 0.0 |
| T1 | 100.0 | 0.0 |
| C3 | 100.0 | 0.0 |
| C4 | 100.0 | 0.0 |
| C5 | 92.3 | 7.7 |

### Label transitions on opposing documents, C1 (rows) → C3 (columns), counts

| C1 → C3 | B1 | B3 | B4 | B8 | O | E |
|---|---|---|---|---|---|---|
| B1 | 118 | 5 | 5 | 6 | 724 | 61 |
| B3 | 0 | 0 | 0 | 0 | 1 | 0 |
| B4 | 0 | 0 | 0 | 0 | 2 | 0 |
| O | 1 | 0 | 0 | 0 | 15 | 1 |
| E | 0 | 0 | 0 | 0 | 1 | 0 |

### Label transitions on opposing documents, C2 (rows) → C3 (columns), counts

| C2 → C3 | B1 | B3 | B4 | B8 | O | E |
|---|---|---|---|---|---|---|
| B1 | 105 | 5 | 5 | 3 | 376 | 30 |
| B3 | 0 | 0 | 0 | 0 | 3 | 0 |
| B4 | 1 | 0 | 0 | 0 | 0 | 0 |
| O | 12 | 0 | 0 | 3 | 327 | 27 |
| E | 1 | 0 | 0 | 0 | 37 | 5 |

### Label transitions on opposing documents, C2 (rows) → T1 (columns), counts

| C2 → T1 | B1 | B3 | B4 | B8 | O | E |
|---|---|---|---|---|---|---|
| B1 | 93 | 3 | 1 | 3 | 398 | 26 |
| B3 | 0 | 0 | 0 | 0 | 2 | 1 |
| B4 | 0 | 0 | 0 | 0 | 1 | 0 |
| O | 4 | 1 | 2 | 0 | 331 | 31 |
| E | 0 | 0 | 0 | 0 | 38 | 5 |

### Label transitions on opposing documents, T1 (rows) → C3 (columns), counts

| T1 → C3 | B1 | B3 | B4 | B8 | O | E |
|---|---|---|---|---|---|---|
| B1 | 49 | 0 | 0 | 1 | 46 | 1 |
| B3 | 2 | 0 | 0 | 0 | 2 | 0 |
| B4 | 1 | 0 | 0 | 0 | 2 | 0 |
| B8 | 1 | 0 | 0 | 1 | 1 | 0 |
| O | 61 | 5 | 4 | 4 | 639 | 57 |
| E | 5 | 0 | 1 | 0 | 53 | 4 |

Regression (GEE logistic, opposing docs, clustered by pair): see `results/deepseek_v41_flash/regression_gee.txt`.

Figures: `results/figures/deepseek_v41_flash_*.png`

## Model: gemini35_flash

### All categories (percent)

| condition | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | ClaimPreservation_opp | SilentInversion_opp | SilentShare_opp | F_opp_given_R0 | share_R0 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C1 | Direct | 1880 | 71.1 | 42.7 | 28.4 | 0.0 | 44.5 | 0.1 | 96.8 | 42.7 | 100.0 |
| C2 | Direct-reshaped | 1880 | 44.0 | 21.9 | 22.1 | -6.3 | 23.0 | 0.3 | 98.6 | 21.9 | 100.0 |
| T1 | Tool-injected | 1858 | 70.2 | 34.0 | 36.3 | 7.9 | 35.6 | 0.5 | 97.5 | 34.0 | 98.8 |
| C3 | Tool | 1811 | 68.0 | 33.7 | 34.3 | 5.9 | 36.0 | 0.8 | 96.7 | 33.7 | 96.3 |
| C4 | RAG-oracle | 1880 | 60.9 | 26.0 | 34.9 | 6.5 | 27.1 | 0.0 | 98.4 | 26.0 | 100.0 |
| C5 | RAG-BM25 | 1880 | 63.0 | 39.4 | 23.6 | -4.8 | 42.6 | 0.7 | 94.7 | 39.4 | 92.3 |

Route diagnostics (percent):

| condition | tool_call_rate | recall_at_k |
|---|---|---|
| C3 | 100.0 |  |
| C5 |  | 92.3 |

### By group (percent)

| condition | group | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | SilentInversion_opp |
|---|---|---|---|---|---|---|---|---|
| C1 | safety | Direct | 772 | 83.2 | 17.1 | 66.1 | 0.0 | 0.0 |
| C2 | safety | Direct-reshaped | 772 | 59.1 | 13.7 | 45.3 | -20.7 | 0.3 |
| T1 | safety | Tool-injected | 766 | 89.5 | 18.4 | 71.1 | 5.0 | 0.5 |
| C3 | safety | Tool | 730 | 89.2 | 20.5 | 68.7 | 2.6 | 0.3 |
| C4 | safety | RAG-oracle | 772 | 75.4 | 15.3 | 60.1 | -6.0 | 0.0 |
| C5 | safety | RAG-BM25 | 772 | 66.8 | 23.1 | 43.8 | -22.3 | 0.3 |
| C1 | capability | Direct | 496 | 89.5 | 79.4 | 10.1 | 0.0 | 0.4 |
| C2 | capability | Direct-reshaped | 496 | 39.5 | 21.8 | 17.7 | 7.7 | 0.8 |
| T1 | capability | Tool-injected | 492 | 79.8 | 50.0 | 29.8 | 19.8 | 0.8 |
| C3 | capability | Tool | 491 | 69.4 | 44.7 | 24.7 | 14.6 | 1.6 |
| C4 | capability | RAG-oracle | 496 | 68.1 | 29.0 | 39.1 | 29.0 | 0.0 |
| C5 | capability | RAG-BM25 | 496 | 82.7 | 58.5 | 24.2 | 14.1 | 0.0 |
| C1 | subjective | Direct | 612 | 40.8 | 45.1 | -4.2 | 0.0 | 0.0 |
| C2 | subjective | Direct-reshaped | 612 | 28.8 | 32.4 | -3.6 | 0.7 | 0.0 |
| T1 | subjective | Tool-injected | 600 | 38.1 | 40.9 | -2.9 | 1.4 | 0.3 |
| C3 | subjective | Tool | 590 | 40.3 | 40.7 | -0.5 | 3.8 | 0.7 |
| C4 | subjective | RAG-oracle | 612 | 36.6 | 36.9 | -0.3 | 3.9 | 0.0 |
| C5 | subjective | RAG-BM25 | 612 | 42.2 | 44.4 | -2.3 | 2.0 | 2.0 |

### ΔFaithGap vs C1 and alignment specificity (percentage points, 95% bootstrap CI)

Alignment specificity = ΔFaithGap on safety − ΔFaithGap on capability. Clearly above 0: the route effect is alignment-specific.

| condition | name | pairs | dFaithGap | CI_low | CI_high | AlignmentSpecificity | AS_CI_low | AS_CI_high |
|---|---|---|---|---|---|---|---|---|
| C2 | Direct-reshaped | 940 | -6.3 | -10.1 | -2.4 | -28.4 | -38.4 | -19.1 |
| T1 | Tool-injected | 920 | 7.7 | 4.3 | 11.2 | -14.3 | -22.9 | -5.7 |
| C3 | Tool | 872 | 6.9 | 3.2 | 10.6 | -10.5 | -19.2 | -1.7 |
| C4 | RAG-oracle | 940 | 6.5 | 2.9 | 10.2 | -35.0 | -44.4 | -25.5 |
| C5 | RAG-BM25 | 940 | -4.8 | -9.1 | -0.4 | -36.4 | -46.7 | -27.2 |

### Paired tests on opposing documents (McNemar, Holm-corrected)

| comparison | n | F_opp_a | F_opp_b | faithful_only_a | faithful_only_b | difference_a_minus_b | test | p | p_holm |
|---|---|---|---|---|---|---|---|---|---|
| C1 vs C2 | 940 | 42.7 | 21.9 | 215 | 20 | 20.7 | chi2 | 1.05e-36 | 6.29e-36 |
| C2 vs T1 | 927 | 21.5 | 34.0 | 23 | 139 | -12.5 | chi2 | 1.64e-19 | 8.18e-19 |
| T1 vs C3 | 891 | 34.7 | 33.2 | 68 | 55 | 1.5 | chi2 | 0.279 | 0.279 |
| C2 vs C3 | 904 | 22.1 | 33.7 | 28 | 133 | -11.6 | chi2 | 2.48e-16 | 7.43e-16 |
| C2 vs C4 | 940 | 21.9 | 26.0 | 35 | 73 | -4.0 | chi2 | 0.00037 | 0.000741 |
| C4 vs C5 | 940 | 26.0 | 39.4 | 40 | 166 | -13.4 | chi2 | 3.06e-18 | 1.22e-17 |

### Labels on opposing documents (percent of valid answers)

| condition | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| C1 | 42.6 | 0.1 | 1.4 | 0.4 | 0.0 | 0.0 | 0.0 | 0.1 | 47.7 | 7.8 |
| C2 | 21.8 | 0.1 | 0.7 | 0.3 | 0.0 | 0.0 | 0.0 | 0.3 | 66.1 | 10.6 |
| T1 | 34.0 | 0.0 | 1.2 | 0.4 | 0.0 | 0.0 | 0.0 | 0.5 | 58.0 | 5.8 |
| C3 | 33.7 | 0.0 | 1.4 | 0.8 | 0.0 | 0.0 | 0.0 | 0.8 | 58.4 | 4.9 |
| C4 | 26.0 | 0.0 | 1.0 | 0.2 | 0.0 | 0.0 | 0.0 | 0.0 | 64.7 | 8.2 |
| C5 | 39.3 | 0.1 | 1.0 | 2.2 | 0.0 | 0.0 | 0.0 | 0.7 | 55.9 | 0.9 |

### Route events (percent of documents)

| condition | R0 None | R3 Retrieval miss | R5 Budget hit / no answer |
|---|---|---|---|
| C1 | 100.0 | 0.0 | 0.0 |
| C2 | 100.0 | 0.0 | 0.0 |
| T1 | 98.8 | 0.0 | 1.2 |
| C3 | 96.3 | 0.0 | 3.7 |
| C4 | 100.0 | 0.0 | 0.0 |
| C5 | 92.3 | 7.7 | 0.0 |

### Label transitions on opposing documents, C1 (rows) → C3 (columns), counts

| C1 → C3 | B1 | B3 | B4 | B8 | O | E |
|---|---|---|---|---|---|---|
| B1 | 246 | 10 | 3 | 6 | 124 | 5 |
| B2 | 1 | 0 | 0 | 0 | 0 | 0 |
| B3 | 5 | 1 | 2 | 0 | 5 | 0 |
| B4 | 3 | 0 | 1 | 0 | 0 | 0 |
| B8 | 0 | 0 | 0 | 0 | 1 | 0 |
| O | 45 | 2 | 1 | 1 | 342 | 34 |
| E | 5 | 0 | 0 | 0 | 56 | 5 |

### Label transitions on opposing documents, C2 (rows) → C3 (columns), counts

| C2 → C3 | B1 | B3 | B4 | B8 | O | E |
|---|---|---|---|---|---|---|
| B1 | 171 | 8 | 1 | 2 | 17 | 0 |
| B2 | 1 | 0 | 0 | 0 | 0 | 0 |
| B3 | 4 | 2 | 0 | 0 | 1 | 0 |
| B4 | 2 | 0 | 1 | 0 | 0 | 0 |
| B8 | 2 | 0 | 0 | 0 | 1 | 0 |
| O | 121 | 3 | 5 | 3 | 430 | 36 |
| E | 4 | 0 | 0 | 2 | 79 | 8 |

### Label transitions on opposing documents, C2 (rows) → T1 (columns), counts

| C2 → T1 | B1 | B3 | B4 | B8 | O | E |
|---|---|---|---|---|---|---|
| B1 | 176 | 2 | 1 | 2 | 14 | 3 |
| B2 | 0 | 1 | 0 | 0 | 0 | 0 |
| B3 | 3 | 0 | 0 | 0 | 4 | 0 |
| B4 | 2 | 1 | 0 | 0 | 0 | 0 |
| B8 | 2 | 0 | 0 | 0 | 1 | 0 |
| O | 128 | 7 | 3 | 2 | 437 | 39 |
| E | 4 | 0 | 0 | 1 | 82 | 12 |

### Label transitions on opposing documents, T1 (rows) → C3 (columns), counts

| T1 → C3 | B1 | B3 | B4 | B8 | O | E |
|---|---|---|---|---|---|---|
| B1 | 241 | 8 | 2 | 2 | 54 | 2 |
| B3 | 4 | 0 | 1 | 1 | 4 | 1 |
| B4 | 1 | 0 | 0 | 0 | 3 | 0 |
| B8 | 2 | 0 | 0 | 1 | 2 | 0 |
| O | 47 | 4 | 4 | 3 | 419 | 36 |
| E | 1 | 1 | 0 | 0 | 42 | 5 |

Regression (GEE logistic, opposing docs, clustered by pair): see `results/gemini35_flash/regression_gee.txt`.

Figures: `results/figures/gemini35_flash_*.png`

## Model: gemma4_26b

### All categories (percent)

| condition | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | ClaimPreservation_opp | SilentInversion_opp | SilentShare_opp | F_opp_given_R0 | share_R0 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C1 | Direct | 1880 | 94.6 | 89.5 | 5.1 | 0.0 | 89.8 | 0.0 | 97.0 | 89.5 | 100.0 |
| C2 | Direct-reshaped | 1880 | 85.3 | 70.2 | 15.1 | 10.0 | 70.5 | 0.0 | 98.9 | 70.2 | 100.0 |
| T1 | Tool-injected | 1880 | 95.6 | 94.4 | 1.3 | -3.8 | 94.4 | 0.0 | 100.0 | 94.4 | 100.0 |
| C3 | Tool | 1880 | 95.0 | 93.7 | 1.3 | -3.8 | 93.8 | 0.0 | 98.3 | 93.7 | 100.0 |
| C4 | RAG-oracle | 1880 | 93.0 | 77.9 | 15.1 | 10.0 | 78.2 | 0.1 | 98.6 | 77.9 | 100.0 |
| C5 | RAG-BM25 | 1880 | 95.7 | 83.9 | 11.8 | 6.7 | 84.3 | 0.0 | 98.0 | 83.9 | 92.3 |

Route diagnostics (percent):

| condition | tool_call_rate | recall_at_k |
|---|---|---|
| C3 | 100.0 |  |
| C5 |  | 92.3 |

### By group (percent)

| condition | group | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | SilentInversion_opp |
|---|---|---|---|---|---|---|---|---|
| C1 | safety | Direct | 772 | 96.4 | 85.5 | 10.9 | 0.0 | 0.0 |
| C2 | safety | Direct-reshaped | 772 | 89.6 | 58.5 | 31.1 | 20.2 | 0.0 |
| T1 | safety | Tool-injected | 772 | 94.0 | 89.9 | 4.1 | -6.7 | 0.0 |
| C3 | safety | Tool | 772 | 93.8 | 88.6 | 5.2 | -5.7 | 0.0 |
| C4 | safety | RAG-oracle | 772 | 97.7 | 64.8 | 32.9 | 22.0 | 0.3 |
| C5 | safety | RAG-BM25 | 772 | 99.0 | 69.9 | 29.0 | 18.1 | 0.0 |
| C1 | capability | Direct | 496 | 98.0 | 95.6 | 2.4 | 0.0 | 0.0 |
| C2 | capability | Direct-reshaped | 496 | 80.2 | 74.2 | 6.0 | 3.6 | 0.0 |
| T1 | capability | Tool-injected | 496 | 98.0 | 97.6 | 0.4 | -2.0 | 0.0 |
| C3 | capability | Tool | 496 | 96.4 | 98.0 | -1.6 | -4.0 | 0.0 |
| C4 | capability | RAG-oracle | 496 | 94.4 | 87.9 | 6.5 | 4.0 | 0.0 |
| C5 | capability | RAG-BM25 | 496 | 98.8 | 96.4 | 2.4 | 0.0 | 0.0 |
| C1 | subjective | Direct | 612 | 89.5 | 89.5 | 0.0 | 0.0 | 0.0 |
| C2 | subjective | Direct-reshaped | 612 | 84.0 | 81.7 | 2.3 | 2.3 | 0.0 |
| T1 | subjective | Tool-injected | 612 | 95.8 | 97.4 | -1.6 | -1.6 | 0.0 |
| C3 | subjective | Tool | 612 | 95.4 | 96.7 | -1.3 | -1.3 | 0.0 |
| C4 | subjective | RAG-oracle | 612 | 85.9 | 86.3 | -0.3 | -0.3 | 0.0 |
| C5 | subjective | RAG-BM25 | 612 | 89.2 | 91.5 | -2.3 | -2.3 | 0.0 |

### ΔFaithGap vs C1 and alignment specificity (percentage points, 95% bootstrap CI)

Alignment specificity = ΔFaithGap on safety − ΔFaithGap on capability. Clearly above 0: the route effect is alignment-specific.

| condition | name | pairs | dFaithGap | CI_low | CI_high | AlignmentSpecificity | AS_CI_low | AS_CI_high |
|---|---|---|---|---|---|---|---|---|
| C2 | Direct-reshaped | 940 | 10.0 | 6.8 | 13.3 | 16.6 | 8.4 | 23.8 |
| T1 | Tool-injected | 940 | -3.8 | -6.6 | -1.0 | -4.7 | -11.5 | 1.6 |
| C3 | Tool | 940 | -3.8 | -6.6 | -1.0 | -1.7 | -8.4 | 4.3 |
| C4 | RAG-oracle | 940 | 10.0 | 6.9 | 13.0 | 18.0 | 11.0 | 24.9 |
| C5 | RAG-BM25 | 940 | 6.7 | 3.6 | 9.9 | 18.1 | 11.7 | 24.5 |

### Paired tests on opposing documents (McNemar, Holm-corrected)

| comparison | n | F_opp_a | F_opp_b | faithful_only_a | faithful_only_b | difference_a_minus_b | test | p | p_holm |
|---|---|---|---|---|---|---|---|---|---|
| C1 vs C2 | 940 | 89.5 | 70.2 | 212 | 31 | 19.3 | chi2 | 7.64e-31 | 3.06e-30 |
| C2 vs T1 | 940 | 70.2 | 94.4 | 10 | 237 | -24.1 | chi2 | 6.91e-47 | 4.14e-46 |
| T1 vs C3 | 940 | 94.4 | 93.7 | 18 | 12 | 0.6 | chi2 | 0.361 | 0.361 |
| C2 vs C3 | 940 | 70.2 | 93.7 | 7 | 228 | -23.5 | chi2 | 1.05e-46 | 5.23e-46 |
| C2 vs C4 | 940 | 70.2 | 77.9 | 29 | 101 | -7.7 | chi2 | 4.75e-10 | 1.43e-09 |
| C4 vs C5 | 940 | 77.9 | 83.9 | 44 | 101 | -6.1 | chi2 | 3.31e-06 | 6.62e-06 |

### Labels on opposing documents (percent of valid answers)

| condition | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| C1 | 89.5 | 0.0 | 0.1 | 0.2 | 0.0 | 0.0 | 0.0 | 0.0 | 9.9 | 0.3 |
| C2 | 70.2 | 0.0 | 0.2 | 0.1 | 0.0 | 0.0 | 0.0 | 0.0 | 27.7 | 1.8 |
| T1 | 94.4 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 4.3 | 1.4 |
| C3 | 93.7 | 0.0 | 0.1 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 4.7 | 1.5 |
| C4 | 77.9 | 0.0 | 0.2 | 0.1 | 0.0 | 0.0 | 0.0 | 0.1 | 19.9 | 1.8 |
| C5 | 83.9 | 0.0 | 0.1 | 0.2 | 0.0 | 0.0 | 0.0 | 0.0 | 15.6 | 0.1 |

### Route events (percent of documents)

| condition | R0 None | R3 Retrieval miss |
|---|---|---|
| C1 | 100.0 | 0.0 |
| C2 | 100.0 | 0.0 |
| T1 | 100.0 | 0.0 |
| C3 | 100.0 | 0.0 |
| C4 | 100.0 | 0.0 |
| C5 | 92.3 | 7.7 |

### Label transitions on opposing documents, C1 (rows) → C3 (columns), counts

| C1 → C3 | B1 | B3 | O | E |
|---|---|---|---|---|
| B1 | 800 | 0 | 33 | 8 |
| B3 | 1 | 0 | 0 | 0 |
| B4 | 2 | 0 | 0 | 0 |
| O | 76 | 1 | 11 | 5 |
| E | 2 | 0 | 0 | 1 |

### Label transitions on opposing documents, C2 (rows) → C3 (columns), counts

| C2 → C3 | B1 | B3 | O | E |
|---|---|---|---|---|
| B1 | 653 | 0 | 7 | 0 |
| B3 | 2 | 0 | 0 | 0 |
| B4 | 1 | 0 | 0 | 0 |
| O | 212 | 1 | 34 | 13 |
| E | 13 | 0 | 3 | 1 |

### Label transitions on opposing documents, C2 (rows) → T1 (columns), counts

| C2 → T1 | B1 | O | E |
|---|---|---|---|
| B1 | 650 | 9 | 1 |
| B3 | 2 | 0 | 0 |
| B4 | 1 | 0 | 0 |
| O | 220 | 28 | 12 |
| E | 14 | 3 | 0 |

### Label transitions on opposing documents, T1 (rows) → C3 (columns), counts

| T1 → C3 | B1 | B3 | O | E |
|---|---|---|---|---|
| B1 | 869 | 1 | 14 | 3 |
| O | 11 | 0 | 24 | 5 |
| E | 1 | 0 | 6 | 6 |

Regression (GEE logistic, opposing docs, clustered by pair): see `results/gemma4_26b/regression_gee.txt`.

Figures: `results/figures/gemma4_26b_*.png`

## Model: mistral_small31

### All categories (percent)

| condition | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | ClaimPreservation_opp | SilentInversion_opp | SilentShare_opp | F_opp_given_R0 | share_R0 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C1 | Direct | 1880 | 87.9 | 68.8 | 19.0 | 0.0 | 69.6 | 0.6 | 97.6 | 68.8 | 100.0 |
| C2 | Direct-reshaped | 1880 | 82.9 | 65.5 | 17.3 | -1.7 | 65.9 | 1.9 | 99.1 | 65.5 | 100.0 |
| T1 | Tool-injected | 1880 | 72.1 | 58.9 | 13.2 | -5.9 | 59.0 | 4.6 | 99.7 | 58.9 | 100.0 |
| C3 | Tool | 1880 | 72.3 | 59.0 | 13.3 | -5.7 | 59.1 | 4.9 | 99.7 | 59.0 | 100.0 |
| C4 | RAG-oracle | 1880 | 66.0 | 36.3 | 29.7 | 10.6 | 36.5 | 2.3 | 99.7 | 36.3 | 100.0 |
| C5 | RAG-BM25 | 1880 | 51.7 | 27.4 | 24.3 | 5.2 | 28.3 | 1.4 | 98.8 | 27.4 | 92.3 |

Route diagnostics (percent):

| condition | tool_call_rate | recall_at_k |
|---|---|---|
| C3 | 100.0 |  |
| C5 |  | 92.3 |

### By group (percent)

| condition | group | name | n_valid | F_conf | F_opp | FaithGap | dFaithGap_vs_C1 | SilentInversion_opp |
|---|---|---|---|---|---|---|---|---|
| C1 | safety | Direct | 772 | 92.5 | 55.2 | 37.3 | 0.0 | 0.8 |
| C2 | safety | Direct-reshaped | 772 | 95.9 | 55.4 | 40.4 | 3.1 | 3.9 |
| T1 | safety | Tool-injected | 772 | 90.4 | 57.5 | 32.9 | -4.4 | 10.1 |
| C3 | safety | Tool | 772 | 90.9 | 59.1 | 31.9 | -5.4 | 11.1 |
| C4 | safety | RAG-oracle | 772 | 91.2 | 26.4 | 64.8 | 27.5 | 4.9 |
| C5 | safety | RAG-BM25 | 772 | 71.0 | 15.3 | 55.7 | 18.4 | 1.6 |
| C1 | capability | Direct | 496 | 88.3 | 76.2 | 12.1 | 0.0 | 0.8 |
| C2 | capability | Direct-reshaped | 496 | 69.8 | 62.9 | 6.9 | -5.2 | 0.8 |
| T1 | capability | Tool-injected | 496 | 30.2 | 26.2 | 4.0 | -8.1 | 1.2 |
| C3 | capability | Tool | 496 | 30.2 | 23.4 | 6.9 | -5.2 | 0.8 |
| C4 | capability | RAG-oracle | 496 | 36.7 | 23.4 | 13.3 | 1.2 | 0.8 |
| C5 | capability | RAG-BM25 | 496 | 39.1 | 30.6 | 8.5 | -3.6 | 0.0 |
| C1 | subjective | Direct | 612 | 81.7 | 80.1 | 1.6 | 0.0 | 0.3 |
| C2 | subjective | Direct-reshaped | 612 | 77.1 | 80.4 | -3.3 | -4.9 | 0.3 |
| T1 | subjective | Tool-injected | 612 | 83.0 | 87.3 | -4.2 | -5.9 | 0.3 |
| C3 | subjective | Tool | 612 | 83.0 | 87.9 | -4.9 | -6.5 | 0.3 |
| C4 | subjective | RAG-oracle | 612 | 57.8 | 59.2 | -1.3 | -2.9 | 0.3 |
| C5 | subjective | RAG-BM25 | 612 | 37.6 | 40.2 | -2.6 | -4.2 | 2.3 |

### ΔFaithGap vs C1 and alignment specificity (percentage points, 95% bootstrap CI)

Alignment specificity = ΔFaithGap on safety − ΔFaithGap on capability. Clearly above 0: the route effect is alignment-specific.

| condition | name | pairs | dFaithGap | CI_low | CI_high | AlignmentSpecificity | AS_CI_low | AS_CI_high |
|---|---|---|---|---|---|---|---|---|
| C2 | Direct-reshaped | 940 | -1.7 | -5.5 | 1.8 | 8.4 | -1.0 | 17.5 |
| T1 | Tool-injected | 940 | -5.9 | -10.0 | -1.8 | 3.7 | -6.0 | 13.1 |
| C3 | Tool | 940 | -5.7 | -9.8 | -1.7 | -0.2 | -10.3 | 9.9 |
| C4 | RAG-oracle | 940 | 10.6 | 6.5 | 14.8 | 26.3 | 15.9 | 36.0 |
| C5 | RAG-BM25 | 940 | 5.2 | 0.8 | 9.6 | 22.0 | 11.7 | 32.6 |

### Paired tests on opposing documents (McNemar, Holm-corrected)

| comparison | n | F_opp_a | F_opp_b | faithful_only_a | faithful_only_b | difference_a_minus_b | test | p | p_holm |
|---|---|---|---|---|---|---|---|---|---|
| C1 vs C2 | 940 | 68.8 | 65.5 | 151 | 120 | 3.3 | chi2 | 0.0684 | 0.137 |
| C2 vs T1 | 940 | 65.5 | 58.9 | 185 | 123 | 6.6 | chi2 | 0.000509 | 0.00204 |
| T1 vs C3 | 940 | 58.9 | 59.0 | 68 | 69 | -0.1 | chi2 | 1 | 1 |
| C2 vs C3 | 940 | 65.5 | 59.0 | 182 | 121 | 6.5 | chi2 | 0.000567 | 0.00204 |
| C2 vs C4 | 940 | 65.5 | 36.3 | 291 | 16 | 29.3 | chi2 | 4.01e-55 | 2.41e-54 |
| C4 vs C5 | 940 | 36.3 | 27.4 | 169 | 86 | 8.8 | chi2 | 2.82e-07 | 1.41e-06 |

### Labels on opposing documents (percent of valid answers)

| condition | B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | O | E |
|---|---|---|---|---|---|---|---|---|---|---|
| C1 | 68.8 | 0.0 | 0.3 | 0.4 | 0.0 | 0.0 | 0.0 | 0.6 | 27.2 | 2.6 |
| C2 | 65.5 | 0.0 | 0.2 | 0.1 | 0.0 | 0.0 | 0.0 | 1.9 | 29.7 | 2.6 |
| T1 | 58.9 | 0.0 | 0.1 | 0.0 | 0.0 | 0.0 | 0.0 | 4.6 | 31.7 | 4.7 |
| C3 | 59.0 | 0.0 | 0.1 | 0.0 | 0.0 | 0.0 | 0.0 | 4.9 | 31.6 | 4.4 |
| C4 | 36.3 | 0.0 | 0.2 | 0.0 | 0.0 | 0.0 | 0.0 | 2.3 | 54.9 | 6.3 |
| C5 | 27.4 | 0.0 | 0.1 | 0.7 | 0.0 | 0.0 | 0.0 | 1.4 | 69.8 | 0.5 |

### Route events (percent of documents)

| condition | R0 None | R3 Retrieval miss |
|---|---|---|
| C1 | 100.0 | 0.0 |
| C2 | 100.0 | 0.0 |
| T1 | 100.0 | 0.0 |
| C3 | 100.0 | 0.0 |
| C4 | 100.0 | 0.0 |
| C5 | 92.3 | 7.7 |

### Label transitions on opposing documents, C1 (rows) → C3 (columns), counts

| C1 → C3 | B1 | B3 | B8 | O | E |
|---|---|---|---|---|---|
| B1 | 412 | 0 | 11 | 197 | 27 |
| B3 | 3 | 0 | 0 | 0 | 0 |
| B4 | 1 | 0 | 0 | 3 | 0 |
| B8 | 4 | 0 | 1 | 1 | 0 |
| O | 123 | 1 | 33 | 85 | 14 |
| E | 12 | 0 | 1 | 11 | 0 |

### Label transitions on opposing documents, C2 (rows) → C3 (columns), counts

| C2 → C3 | B1 | B3 | B8 | O | E |
|---|---|---|---|---|---|
| B1 | 434 | 0 | 13 | 150 | 19 |
| B3 | 1 | 0 | 0 | 1 | 0 |
| B4 | 0 | 0 | 0 | 1 | 0 |
| B8 | 9 | 0 | 4 | 5 | 0 |
| O | 103 | 1 | 27 | 127 | 21 |
| E | 8 | 0 | 2 | 13 | 1 |

### Label transitions on opposing documents, C2 (rows) → T1 (columns), counts

| C2 → T1 | B1 | B3 | B8 | O | E |
|---|---|---|---|---|---|
| B1 | 431 | 1 | 14 | 151 | 19 |
| B3 | 1 | 0 | 0 | 1 | 0 |
| B4 | 0 | 0 | 0 | 1 | 0 |
| B8 | 7 | 0 | 6 | 5 | 0 |
| O | 111 | 0 | 21 | 123 | 24 |
| E | 4 | 0 | 2 | 17 | 1 |

### Label transitions on opposing documents, T1 (rows) → C3 (columns), counts

| T1 → C3 | B1 | B3 | B8 | O | E |
|---|---|---|---|---|---|
| B1 | 486 | 0 | 14 | 51 | 3 |
| B3 | 1 | 0 | 0 | 0 | 0 |
| B8 | 9 | 0 | 24 | 10 | 0 |
| O | 57 | 1 | 8 | 208 | 24 |
| E | 2 | 0 | 0 | 28 | 14 |

Regression (GEE logistic, opposing docs, clustered by pair): see `results/mistral_small31/regression_gee.txt`.

Figures: `results/figures/mistral_small31_*.png`
