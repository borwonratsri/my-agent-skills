---
name: product-impact-assessment
description: Pharmaceutical Product Impact Assessment (PIA) expert for evaluating deviations, changes, quality risk management, and regulatory compliance under GMP/GAMP standards.
---

# Pharmaceutical Product Impact Assessment (PIA) Skill

Expert evaluation framework for assessing the impact of deviations, planned changes (Change Control), out-of-specification (OOS) results, and process variations on pharmaceutical drug products, active pharmaceutical ingredients (APIs), and medical devices under GMP, GAMP 5, ICH Q9 (Quality Risk Management), and ICH Q10 guidelines.

## Trigger Scenarios
- Slash command: `/product-impact-assessment`
- User requests: "Evaluate impact of this deviation", "ทำ Product Impact Assessment (PIA)", "ประเมินผลกระทบ GMP/Change Control", "Pharma risk assessment"

## Core Assessment Framework (ICH Q9 / GMP)

1. **Impact on Critical Quality Attributes (CQAs)**:
   - Sterility, Endotoxin, Particulate Matter (Sterile products).
   - Assay / Potency, Content Uniformity, Purity / Impurities profile.
   - Dissolution, Disintegration, Bioavailability, Stability profile.
   - Packaging integrity, Labeling accuracy, Tamper evidence.

2. **Impact on Critical Process Parameters (CPPs)**:
   - Temperature, Pressure, Agitation, pH, Lyophilization parameters, Sterilization cycle parameters (F0/D-value).

3. **Risk Matrix & Severity Scoring**:
   - **Severity (S)**: Patient safety and clinical efficacy impact (Critical / Major / Minor).
   - **Probability of Occurrence (P)**: High / Medium / Rare.
   - **Detectability (D)**: Reliable in-process testing vs undetectable until release/market.
   - Overall Risk Priority Number (RPN) calculation.

4. **Regulatory & Batch Disposition Strategy**:
   - Affected batches (Current batch, Previous distributed batches, Batches currently in-process).
   - Regulatory notification requirements (FDA FAR, EMA defect report, Variation filing).
   - Corrective and Preventive Actions (CAPA) definition.

## Instructions for the Agent
1. Gather deviation or change details: Process step, material lot, equipment ID, observed value vs validated range.
2. Structure the PIA Report:
   - **Event Summary & Description**
   - **Technical Root Cause Analysis (Fishbone / 5 Whys)**
   - **CQA & CPP Impact Matrix**
   - **Batch Scope Assessment**
   - **Final Risk Conclusion & Batch Disposition Recommendation**
   - **CAPA Action Plan**
3. Maintain rigorous, defensible pharmaceutical quality terminology.
