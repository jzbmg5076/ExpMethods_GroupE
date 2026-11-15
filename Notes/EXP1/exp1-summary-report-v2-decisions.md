# EXP1 Summary Report — V2 draft decisions (22 Sep 2026)

Draft: EXP1/Report/EXP1_Summary_Report_Draft_Content_V2.docx (+ Fig5_bifilar_signal_processing.png, Fig6_moi_comparison.png, make_report_figures.py)

## Group decisions
- Lab-axis labels: HDPE IntoTable = Iyy, Al frame YData = Ixx, rectangle Bifolar = Izz (named by sensor/test orientation).
- NX models cannot be changed; work with FinalNXModels as-is. Data is final.
- Focus on summary-report required content (8–10 pages).

## Key numbers used (lbm·in²)
- Final values = analytical at measured mass. C1 10.82/51.53/62.19; C2 9.977/54.51/64.23 (principal 9.110/55.37/64.23, 7.87°); C3 151.8/584.8/736.2; C4 tensor principal 24.65/105.9/128.9, CG (5.934, 3.032, 0.509).
- Experimental: C1 Izz bifilar paired 54.0 ± 2.8 (−13.1%), Arduino 53.7, X-Modal 54.3; C2 Iyy 9.13 ± 4.29 (−8.5%); C3 Ixx 545 ± 36 (−6.8%; −1.9% vs NX mass-scaled).
- Frequency predicted vs measured: C2 +0.30%, C3 +0.60%, C1 +7.3%. Sensors agree 0.6%.
- NX C1 modeled at 0.45 in (3.342 lbm vs 3.719) → scale by mass; NX assembly 23.45/100.5/122.5 is ~5% low for the same reason.
- Config 1 is 6061-T651 aluminum (stamp + density 2.716 g/cc), not stainless.

## Open items
- Lab-frame definition sentence; Day 1 date; NX/MATLAB versions; IEPE model/serial.
- NX Config 4 principal-axis vectors (old NX, possibly flipped x) not used.
